//
//  PulsingCircleView.swift
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
//  Created by Rowan on 11/24/24.
//

import SwiftUI

struct PulsingCircleView: View{
    var beginWidth: CGFloat
    var endWidth: CGFloat
    var color: Color
    var thickness: CGFloat = 5
    
    @State var enabled: Bool = true
    
    @State var state: Bool = false
    
    @State var opacity: CGFloat = 1
    
    var body: some View {
        Circle()
            .stroke(color.opacity(opacity), lineWidth:thickness)
            .frame(width:state ? endWidth : beginWidth, height:state ? endWidth : beginWidth)
            .onAppear(){
                cycle()
            }
            
    }
    
    func cycle(){
        if !enabled {return}
        
        withAnimation(.easeInOut(duration:0.5)){
            state = true
            opacity = 1
        }
        withAnimation(.easeInOut(duration:0.4).delay(0.5)){
            opacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1){
            state = false
            cycle()
        }
    }
}
