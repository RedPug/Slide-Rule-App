//
//  CursorView.swift
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

struct CursorView: View {
    @Binding var posDat: PosData
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius:3)
                .fill(Color.theme.cursorBase)
                //.stroke(.gray, lineWidth:1)
                .frame(width:100, height:18)
                .offset(y:-110)
            RoundedRectangle(cornerRadius:3)
                .fill(Color.theme.cursorBase)
                //.stroke(.gray, lineWidth:1)
                .frame(width:100, height:18)
                .offset(y:110)
            
            screwHead(rotation:16)
                .offset(x:42,y:111)
            screwHead(rotation:72)
                .offset(x:-42,y:111)
            screwHead(rotation:48)
                .offset(x:42,y:-111)
            screwHead(rotation:116)
                .offset(x:-42,y:-111)
            
            Rectangle()
                .fill(.red.opacity(0.7))
                .frame(width:0.5, height:210)
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.1))
                .stroke(.gray, lineWidth: 0.5)
                .frame(width:82, height:210)
     
            
            
        }
//            .resizable()
            .frame(width:100,height:240)
            .preciseOffset(x:posDat.cursorPos+posDat.framePos)
            .defersSystemGestures(on: .all)
            .gesture(
                DragGesture()
                    .onChanged({value in
                        if posDat.isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        posDat.isDragging = true
                        posDat.cursorPos = posDat.cursorPos0+value.translation.width*posDat.movementSpeed
                    })
                    .onEnded({value in
                        if posDat.isLocked {return}
                        posDat.isDragging = false
                        posDat.cursorPos0 = posDat.cursorPos
                        posDat.timesPlaced += 1
                    })
            )
            .onChange(of: posDat.cursorPos) {
                clampPosition()
            }
    }
    
    func clampPosition(){
        //from 1600-100-64+10 to 64-10
        posDat.cursorPos = Double(min(1496.0,max(104.0,posDat.cursorPos)))
        posDat.cursorPos0 = Double(min(1496.0,max(104.0,posDat.cursorPos0)))
    }
    
    func screwHead(rotation:CGFloat) -> some View {
        Circle()
            .fill(Color(red:0.6, green:0.6, blue:0.6))
            .stroke(Color(red:0.4, green:0.4, blue:0.4), lineWidth:0.5)
            .frame(width:7, height:7)
            .overlay{
                Rectangle()
                    .fill(Color(red:0.4, green:0.4, blue:0.4))
                    .frame(width:0.5,height:7)
            }
            .rotationEffect(.degrees(rotation))
    }
}
