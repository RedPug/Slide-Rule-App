//
//  TutorialGestureView.swift
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
//  Created by Rowan on 5/4/24.
//

import SwiftUI

enum GestureHint{
    case none, flip, left, right
}

struct GestureHandView: View {
    var hint: GestureHint
    
    var body: some View {
        let img: String
        switch hint {
        case .flip:
            img = "arrowshape.up"
        case .left:
            img = "arrowshape.left"
        case .right:
            img = "arrowshape.right"
        default:
            img = "questionmark"
        }
        
        return Image(systemName:img)
            .resizable()
            .scaledToFill()
            .frame(width:50, height:50)
            .foregroundStyle(.black)
            .zIndex(1.0)
    }
}

struct TutorialGestureView: View {
    @Binding var gestureHint: GestureHint
    @State var isGestureMoving: Bool = false
    @State var isGestureVisible: Bool = true
    @State var isGestureAnimating: Bool = false
    
    var body: some View {
        Group{
            if(gestureHint == .flip){
                GestureHandView(hint:gestureHint)
                    .offset(y:isGestureMoving ? -75 : 75)
            }else{
                GestureHandView(hint:gestureHint)
                    .offset(x:(gestureHint == .left ? -1 : 1)*(isGestureMoving ? 75 : -75), y:100)
            }
        }
        .opacity(isGestureVisible ? 1 : 0)
        .onAppear(){
            cycleGestureMoving()
        }
    }
    
    func cycleGestureMoving(){
        if(gestureHint != .none){
            if(!isGestureAnimating){
                isGestureAnimating = true
                isGestureMoving = false
                isGestureVisible = true
                withAnimation(.easeInOut(duration:0.5)){
                    isGestureMoving = true
                    //isGestureVisible = false
                }
                withAnimation(.easeInOut(duration:0.5).delay(0.5)){
                    isGestureVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
                    isGestureAnimating = false
                    cycleGestureMoving()
                }
            }
        }else{
            isGestureAnimating = false
        }
    }
}
