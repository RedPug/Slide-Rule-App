//
//  RulerView.swift
//  Slide Rule
//
//  Created by Rowan on 8/21/24.
//

import SwiftUI
import CoreMotion

struct RulerView: View {
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var orientationInfo: OrientationInfo
    @Binding var posDat: PosData
    @State var isFlipping: Bool = false
    @State var isPhysicsActive = false
    @State var isSteppingPhysics = false
    
    let flipTime: CGFloat = 1
    
    let motionManager = CMMotionManager()
    
    var body: some View {
        ZStack{
            Frame(posDat: $posDat)
                .zIndex(2)
                .rotation3DEffect(Angle(degrees:posDat.flipAngle), axis: (x:1,y:0,z:0), anchorZ:0)
                .frame(height:240, alignment: .center)
                .contentShape(.interaction, Rectangle())
                .simultaneousGesture(
                    //flip the ruler
                    DragGesture(minimumDistance: 10)
                        .onChanged{value in
                            if(isFlipping){return}
                            let height = value.translation.height
                            var h = 0.0
                            
                            if(height > 20.0){
                                h = height - 20.0
                            }else if(height < -20.0){
                                h = height + 20.0
                            }
                            posDat.flipAngle = min(45.0,max(-h*0.4,-45.0))
                        }
                        .onEnded{value in
                            
                            if abs(posDat.flipAngle) >= 44.0 {
                                flip(dir: value.translation.height < 0)
                            }else{
                                withAnimation(.spring(dampingFraction: 0.5)){
                                    posDat.flipAngle = 0
                                }
                            }
                        }
                )
                .onChange(of: posDat.shouldFlip){ oldState, newState in
                    if oldState == false && newState{
                        flip(dir: true);
                    }
                }
            
        }.onAppear{
            if settings.hasPhysics{
                startPhysics()
            }
        }.onDisappear(){
            stopPhysics()
        }
    }
    
    func flip(dir: Bool) -> Void {
        if(isFlipping){return}
        
        let f = dir ? 1.0 : -1.0
        let t0 = abs(posDat.flipAngle)/90 //portion of first turn time already completed by manual turn
        let t1 = flipTime*0.5*(1-t0) //flip time for first bit
        let t2 = flipTime*0.5 //flip time for second bit
        isFlipping = true
        
        withAnimation(.easeIn(duration: t1)){
            posDat.flipAngle = 90.0*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+t1){
            posDat.isFlippedTemp.toggle()
            posDat.isFlipped = posDat.isFlippedTemp
            posDat.flipAngle += 180*f
        }
        withAnimation(.easeOut(duration: t2).delay(t1)){
            posDat.flipAngle += 90*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+t1+t2){
            posDat.flipAngle = 0
            posDat.shouldFlip = false
            isFlipping = false
        }
    }
    
    func startPhysics() -> Void {
        if !isPhysicsActive {
            motionManager.startAccelerometerUpdates()
            //print("Started accelerometer updates")
            isPhysicsActive = true
            
            if !isSteppingPhysics {
                stepPhysics()
            }
        }
    }
    
    func stopPhysics() -> Void {
        if isPhysicsActive {
            motionManager.stopAccelerometerUpdates()
            //print("Stopped accelerometer updates")
            isPhysicsActive = false
        }
    }
    
    func stepPhysics() -> Void {
        isSteppingPhysics = true
        let dt: CGFloat = 0.01
        
        if(!isPhysicsActive || !settings.hasPhysics){
            posDat.velocity = 0
            isSteppingPhysics = false
            //print("Stopped physics from step function", isPhysicsActive, settings.hasPhysics)
            return
        }
        
        if let data = motionManager.accelerometerData {
            //manage if screen is landscale left or right
            let direction: CGFloat = orientationInfo.orientation == .landscapeLeft ? 1 : -1
            
            let g = settings.gravity //gravitational acceleration, in g's
            let coeff = settings.friction //no units, coefficient of friction
            
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
            
            var velocity = posDat.velocity + -sideForce * dt
            
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
            
            posDat.velocity = velocity
            posDat.slidePos = posDat.slidePos + velocity*dt
            posDat.slidePos0 = posDat.slidePos
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+dt, execute: stepPhysics)
    }
}

