//
//  RulerView.swift
//  Slide Rule
//
//  Copyright (c) 2024 Rowan Richards
//
//  This file is part of Ultimate Slide Rule
//
//  Ultimate Slide Rule is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by the
//  Free Software Foundation, either version 3 of the License, or 
//  (at your option) any later version.
//
//  Ultimate Slide Rule is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
//  See the GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License along with this program.
//  If not, see <https://www.gnu.org/licenses/>.
//
//  Created by Rowan on 8/21/24.
//

import SwiftUI
import CoreMotion

extension RulerView where Overlay == EmptyView {
    init(posData: Binding<PosData>){
        self.init(posData: posData, overlay: {EmptyView()})
    }
}

struct RulerView <Overlay: View>: View {
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var orientationInfo: OrientationInfo
    @Binding var posData: PosData
    @State var isFlipping: Bool = false
    @State var isReadyToFlip = false
    
    @State var isPhysicsActive = false
    @State var isSteppingPhysics = false
    
    let flipTime: CGFloat = 1
    
    let motionManager = CMMotionManager()
    
    let overlay: Overlay
    
    init(posData: Binding<PosData>, @ViewBuilder overlay: () -> Overlay){
        self._posData = posData
        self.overlay = overlay()
    }
    
    
    
    var body: some View {
        RulerZoomWrapper(posData: $posData){
			ZStack{
				SlideView(posDat: $posData)
				FrameView(posDat: $posData)
				CursorView(posDat: $posData)
			}
                .sensoryFeedback(.impact, trigger: isReadyToFlip)
                .overlay(overlay)
                .rotation3DEffect(Angle(degrees:posData.flipAngle), axis: (x:1,y:0,z:0), anchorZ:0)
                .frame(height:240, alignment: .center)
                .contentShape(.interaction, Rectangle())
                .simultaneousGesture(
                    rulerFlipGesture
                )
                .onChange(of: posData.shouldFlip){ oldState, newState in
                    if oldState == false && newState{
                        flip(dir: true);
                    }
                }
            
        }
        .scaleEffect(1.4, anchor:.center) //make bigger
        .frame(width:100,height:100) //avoid making whole screen wonky
        .frame(maxWidth:.infinity,maxHeight:.infinity) //takes up visible screen area
        .onAppear{
            if settings.hasPhysics{
                startPhysics()
            }
        }.onDisappear(){
            stopPhysics()
        }
    }
    
    
}



extension RulerView {
    private var rulerFlipGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged{value in
				if posData.lockState.contains(.frame) {return}
                if(isFlipping || !posData.canDragToFlip){return}
                let height = value.translation.height
                var h = 0.0
                
                if(height > 20.0){
                    h = height - 20.0
                }else if(height < -20.0){
                    h = height + 20.0
                }
                let angle = -h*0.4
                
                if angle > -45 && angle < 45 {
                    posData.flipAngle = angle
                    isReadyToFlip = false
                }else if angle > 0{
                    posData.flipAngle = 45
                    isReadyToFlip = true
                }else{
                    posData.flipAngle = -45
                    isReadyToFlip = true
                }
            }
            .onEnded{value in
                isReadyToFlip = false
                if abs(posData.flipAngle) >= 44.0 {
                    flip(dir: value.translation.height < 0)
                }else{
                    withAnimation(.spring(dampingFraction: 0.5)){
                        posData.flipAngle = 0
                    }
                }
            }
    }
    
    private func flip(dir: Bool) -> Void {
        if(isFlipping){return}
        
        let f = dir ? 1.0 : -1.0
        let t0 = abs(posData.flipAngle)/90 //portion of first turn time already completed by manual turn
        let t1 = flipTime*0.5*(1-t0) //flip time for first bit
        let t2 = flipTime*0.5 //flip time for second bit
        isFlipping = true
        
        withAnimation(.easeIn(duration: t1)){
            posData.flipAngle = 90.0*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+t1){
            posData.isFlippedTemp.toggle()
            posData.isFlipped = posData.isFlippedTemp
            posData.flipAngle += 180*f
        }
        withAnimation(.easeOut(duration: t2).delay(t1)){
            posData.flipAngle += 90*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+t1+t2){
            posData.flipAngle = 0
            posData.shouldFlip = false
            isFlipping = false
        }
    }
}


extension RulerView {
    private func startPhysics() -> Void {
        if !isPhysicsActive {
            motionManager.startAccelerometerUpdates()
            isPhysicsActive = true
            
            if !isSteppingPhysics {
                stepPhysics()
            }
        }
    }
    
    private func stopPhysics() -> Void {
        if isPhysicsActive {
            motionManager.stopAccelerometerUpdates()
            isPhysicsActive = false
        }
    }
    
    private func stepPhysics() -> Void {
        isSteppingPhysics = true
        let dt: CGFloat = 0.01
        
        if(!isPhysicsActive || !settings.hasPhysics){
            posData.velocity = 0
            isSteppingPhysics = false
            return
        }
        
        if posData.isDragging {
            posData.velocity = 0
        }else if let data = motionManager.accelerometerData {
            //manage if screen is landscale left or right
            let direction: CGFloat = orientationInfo.orientation == .landscapeLeft ? 1 : -1
            
            let g = settings.gravity //gravitational acceleration, in g's
            let coeff = posData.velocity == 0 ? settings.friction : settings.friction*0.8 //no units, coefficient of friction
            
            var x = data.acceleration.x*direction //top bottom, landscape
            let y = data.acceleration.y*direction //left right, landscape
            var z = data.acceleration.z //in out
            //measured in g's
            //assume total acceleration = 1 normally
            //y_g = what the gravity component of y should be
            var y_g = sqrt(max(0.0, 1.0 - (x*x + z*z)))
            
            if(y < 0){
                y_g = -y_g
            }
            
            //y_f = external force component of y
            let y_f = y - y_g
            
            var sideForce = y_f + y_g * g
            
            //print(y_f, y_g, g)
            
            //1 g = 386 inches/second^2, and about 20 pixels/inch -> 386*20 pixels/second^2
            let factor = 386.0 * 20.0
            
            //x, y, z now in pixels/sec^2
            x *= factor
            sideForce *= factor
            z *= factor
            
            var velocity = posData.velocity + -sideForce * dt
            
            //normal force, all forces except in direction of travel.
            let normal: CGFloat = sqrt(x*x+z*z) + 10
            
            //using acceleration * time = change in velocity
            //only provie friction to stop, not reverse
            let friction = min(coeff * normal * dt, abs(velocity))
            if(velocity > 0){
                velocity = velocity - friction
            }else{
                velocity = velocity + friction
            }
            
            posData.velocity = velocity
            posData.slidePos = posData.slidePos + velocity*dt
            posData.slidePos0 = posData.slidePos
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+dt, execute: stepPhysics)
    }
}
