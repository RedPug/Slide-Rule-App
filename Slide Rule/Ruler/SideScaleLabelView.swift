//
//  SideScaleLabelView.swift
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
//  Created by Rowan on 11/28/24.
//

import SwiftUI

struct SideScaleLabelView: View {
    @Binding var posData: PosData
    
    
    var body: some View {
        
        Color(.gray)
            .frame(width:45*(1+0.5*(posData.zoomLevel-1))+10)
            .overlay(alignment:.leading){
                LeftSlideLabelView(scales: posData.isFlippedTemp ? ScaleLists.slideScalesBack : ScaleLists.slideScalesFront, minIndex: 0, maxIndex: 10, zoom:posData.zoomLevel, zoomAnchor:posData.zoomAnchor)
                    .frame(width:70, height:240, alignment:.leading)
                    .scaleEffect(1.4, anchor: .leading)
                    .padding(5)
            }
            .opacity(min(1,max(0.7, 1-(-250.0-min(posData.framePos,posData.framePos + posData.slidePos))/50.0)))
    }
}

//extension SideScaleLabelView{
    struct LeftSlideLabelView: View{
        
        let scales: [RulerScale]
        
        let minIndex: Int
        let maxIndex: Int
        
        let zoom:CGFloat
        let zoomAnchor:CGPoint
        
        let textOffsetX: CGFloat = 0
        let textOffsetY: CGFloat = -120
        
        @State var smoothScales: [RulerScale]
        
        init(scales: [RulerScale], minIndex:Int, maxIndex:Int, zoom:CGFloat, zoomAnchor:CGPoint){
            self.scales = scales
            self.minIndex = minIndex
            self.maxIndex = maxIndex
            self.zoom = zoom
            self.zoomAnchor = zoomAnchor
            smoothScales = scales
        }
        
        var body: some View {
            ZStack(alignment: .trailing){
                ForEach(minIndex...maxIndex, id: \.self){
                    //scaleIndex, scale in
                    scaleIndex in
                    let scale = smoothScales[scaleIndex]
                    let maxZoom = 3.0
                    let fac = 1+0.5*(zoom-1)
                    
                    Text(scale.name)
                        .font(.system(size: 9*fac*maxZoom, weight:.bold))
                        .foregroundStyle(Color.theme.text)
                        .fixedSize()
                        .scaleEffect(1/maxZoom, anchor:.trailing)
                        .frame(width:30*fac, alignment:.trailing)
                        .offset(x: 0 + textOffsetX, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                }
            }.onChange(of:scales){
                withAnimation(.easeInOut(duration: 0.1)){
                    smoothScales = scales
                }
            }
        }
        
        func getScaleLabelHeight(_ index: Int) -> CGFloat{
            let spacing = 18.0
            let y = spacing*0.5 + spacing*CGFloat(index) + 19
            return (y-zoomAnchor.y)*zoom + zoomAnchor.y - (zoomAnchor.y-202/2)*(zoom-1)/3
        }
    }

//}
