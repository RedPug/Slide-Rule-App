//
//  Frame.swift
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

struct Frame: View {
    
    @State var isDragging = false
    
    @State var isSummoning: Bool = false
    @State var summonLocation: CGPoint = .zero
    
    @Binding var posDat: PosData
    
    let radius = 15.0
    
    var body: some View {
        ZStack(){
            SlideView(posDat: $posDat)
                

            ZStack{
                RoundedRectangle(cornerRadius:radius)
                    .size(width: 1600, height: 57)
                    .offset(x:0,y:145)
                    .fill(Color.theme.rulerBase)
                    .stroke(.gray, lineWidth: 0.5)
                    .zIndex(1.0)
                
                RoundedRectangle(cornerRadius:radius)
                    .size(width: 1600, height: 57)
                    .fill(Color.theme.rulerBase)
                    .stroke(.gray, lineWidth: 0.5)
                    .zIndex(1.0)
                
                
                Path{path in
                    let r0 = 44.0
                    let cx = -30.0
                    let r = sqrt(r0*r0+cx*cx)
                    let alpha = Double.pi/2.0 + atan(cx/r0)
                    
                    let dh = 57.0
                    
                    let width = 60.0
                    let height = 202.0
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: 0,y: height-dh))
                    path.addArc(
                        center: CGPoint(x:cx, y:height/2),
                        radius: r,
                        startAngle: Angle(radians: alpha),
                        endAngle: Angle(radians: -alpha),
                        clockwise: true
                    )
                    path.closeSubpath()
                    
                    path.move(to: CGPoint(x: 1600-0, y: 0))
                    path.addLine(to: CGPoint(x: 1600-width, y: 0))
                    path.addLine(to: CGPoint(x: 1600-width, y: height))
                    path.addLine(to: CGPoint(x: 1600-0, y: height))
                    path.addLine(to: CGPoint(x: 1600-0,y: height-dh))
                    path.addArc(
                        center: CGPoint(x:1600-cx, y:height/2),
                        radius: r,
                        startAngle: Angle(radians: Double.pi-alpha),
                        endAngle: Angle(radians: Double.pi+alpha),
                        clockwise: false
                    )
                    path.closeSubpath()
                    
                }.fill(
                    //LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue, Color.gray]), startPoint: .top, endPoint: .bottom)
                    Color(#colorLiteral(red: 0.71716851, green: 0.71716851, blue: 0.71716851, alpha: 1))
                )
                .stroke(.gray, lineWidth: 0.5)
                .zIndex(2.0)
                
                //former height = 88
                Group{
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesFront, minIndex: 0, maxIndex:2)
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesFront, minIndex: 8, maxIndex:10)
                }
                    .zIndex(posDat.isFlippedTemp ? 0.5 : 1.5)
                Group{
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesBack, minIndex: 0, maxIndex:2)
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesBack, minIndex: 8, maxIndex:10)
                }
                    .zIndex(posDat.isFlippedTemp ? 1.5 : 0.5)
            }
            .frame(width:1600, height:202)
            .preciseOffset(x: posDat.framePos+800,y:0)
            .defersSystemGestures(on: .all)
            .gesture(
                DragGesture(minimumDistance: 5.0)
                    .onChanged({value in
                        if posDat.isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        isDragging = true
                        posDat.framePos = posDat.framePos0+value.translation.width
                    })
                    .onEnded({value in
                        if posDat.isLocked {return}
                        isDragging = false
                        posDat.framePos0 = posDat.framePos
                    })
            )
//            .longPressDetector(duration: 0.3){value in
//                print("onHeld \(value)")
//                isSummoning = true
//                summonLocation = value
//            }onReleased:{value in
//                //print("onReleased")
//                withAnimation(.snappy(duration: 0.3)){
//                    posDat.cursorPos = value.x - posDat.framePos - 800
//                    posDat.cursorPos0 = posDat.cursorPos
//                }
//                isSummoning = false
//                        }
//            .onTouch(limitToBounds: true){location in
//                print("Updated to \(location)")
//            }
//            .gesture(
//                ClickGesture(coordinateSpace: .local)
//                    .onEnded(){location in
//                        print(location)
//                    }
//            )
//
//            if(isSummoning){
//                PulsingCircleView(beginWidth:30, endWidth:50, color: .theme.text)
//                    .offset(x: 800-summonLocation.x, y: summonLocation.y-101)
//
//            }

//            .contentShape(.interaction,
//                Rectangle()
//                .size(width: 1600, height: 57)
//                .offset(x:0,y:145)
//                .union(
//                    Rectangle()
//                        .size(width: 1600, height: 57)
//                )
//            )
            
            
            CursorView(posDat: $posDat)
        }
        .onChange(of: posDat.framePos) {
            clampPosition()
        }
    }
    
    func clampPosition() -> Void{
        //posDat.framePos = min(200, max(-1600-200+UIScreen.main.bounds.width,posDat.framePos))
        //posDat.framePos0 = min(200, max(-1600-200+UIScreen.main.bounds.width,posDat.framePos0))
        posDat.framePos = min(0, max(-1600,posDat.framePos))
        posDat.framePos0 = min(0, max(-1600,posDat.framePos0))
    }
}
