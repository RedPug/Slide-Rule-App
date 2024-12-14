//
//  SlideMarkingView.swift
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
import LaTeXSwiftUI

struct SlideMarkingView: View{
    
    var width: CGFloat
    var height: CGFloat
    
    let scales: [RulerScale]
    
    let minIndex: Int
    let maxIndex: Int
    
    var body: some View {
        ZStack(alignment: .center){
            tickMarkView
                .frame(width:width, height:height)

            let textOffsetX = -width*0.5
            let textOffsetY = -height*0.5
            
            //text
            //iterate by each scale, text inerval, and finally through the interval to draw the text
            ForEach(minIndex...maxIndex, id: \.self){
                //scaleIndex, scale in
                scaleIndex in
                let scale = scales[scaleIndex]
                let eq = scale.data.equation
                let y0 = getScaleHeight(scaleIndex)
                let direction = getScaleDirection(scaleIndex) == .up ? -1.0 : 1.0
                let maxMag = 3.0
                
                Group{
                    Text(scale.name)
                        .font(.system(size: 9*maxMag, weight:.bold))
                        .foregroundStyle(.black)
                        .frame(width:150.0,height:50.0, alignment: .leading)
                        .scaleEffect(1.0/maxMag)
                        .offset(x: -29 + textOffsetX, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                    
                    LaTeX(scale.leftLabel)
                    //.font(.system(size: 8*maxMag, weight:.bold))
                        .foregroundStyle(.black)
                        .frame(width:150.0,height:50.0, alignment: .leading)
                        .scaleEffect(0.35)
                        .offset(x: textOffsetX + 0, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                    
                    LaTeX(scale.rightLabel)
                    //.font(.system(size: 12*maxMag, weight:.bold))
                        .foregroundStyle(.black)
                        .frame(width:150.0,height:50.0, alignment: .trailing)
                        .scaleEffect(1.0/maxMag)
                        .scaleEffect(1.3)
                        .offset(x: textOffsetX + width + 25, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                    
                    ForEach(Array(scale.data.labels.enumerated()), id: \.offset){
                        i, label in
                        //let label: (x:CGFloat, text:String, flags:TextFlags) = scale.data.labels[i]
                        let flags: TextFlags = label.flags
                        let isShort: Bool = flags.contains(.short)
                        
                        let fontSize: CGFloat = isShort || flags.contains(.small) ? 6.0 : 8.0
                        let f: CGFloat = eq(label.x)
                        
                        let text: String = label.text
                        let font: UIFont = UIFont.systemFont(ofSize:fontSize*maxMag, weight:flags.contains(.thin) ? UIFont.Weight.regular : UIFont.Weight.bold)
                        let textSize: CGSize = text.sizeUsingFont(font)
                        let textWidth: CGFloat = textSize.width/maxMag
                        
                        let alignmentOffset: CGFloat = flags.contains(TextFlags.alignLeft) ? (-textWidth/2.0 + (flags.contains(TextFlags.italic) ? -2.0 : 0.0)) : (flags.contains(TextFlags.alignRight) ? textWidth/2.0 : 0.0)
                        
                        let fancyFont: Font = flags.contains(.italic) ? Font(font).italic() : Font(font)
                        
                        Text(text)
                            .font(fancyFont)
                            .foregroundStyle(.black)
                            .scaleEffect(1.0/maxMag)
                            .frame(width:150.0,height:150.0, alignment: .center)
                            .offset(x: f*width, y: y0+(isShort ? 11.0 : 13.0)*direction)
                            .offset(x: alignmentOffset)
                            .offset(x: textOffsetX, y: textOffsetY)
                    }
                }
            }
            //end scale iterations
        }
    }
    
    func getScaleLabelHeight(_ index: Int) -> CGFloat{
        let spacing = 18.0
        return spacing*0.5 + spacing*CGFloat(index)
    }
    
    func getScaleHeight(_ index: Int) -> CGFloat{
        
        switch(index){
        case 0:
            return 20
        case 1:
            return 37
        case 2:
            return 57
            
        case 3:
            return 57
        case 4:
            return 91
        case 5:
            return 110
        case 6:
            return 128
        case 7:
            return 145
            
        case 8:
            return 145
        case 9:
            return 165
        case 10:
            return 183
        default:
            return 0
        }
    }
    
    func getScaleDirection(_ index: Int) -> TickDirection{
        if(index == 3 || index >= 8){
            return .down
        }
        return .up
    }
}

extension SlideMarkingView{
    var tickMarkView: some View {
        Path {path in
            //scales.enumerated().forEach{scaleIndex, scale in
            (minIndex...maxIndex).forEach{scaleIndex in
                let scale = scales[scaleIndex]
                let eq = scale.data.equation
                let y0 = getScaleHeight(scaleIndex)
                let direction = getScaleDirection(scaleIndex) == .up ? -1.0 : 1.0
                scale.data.markingIntervals.forEach{interval in
                    for tick in interval.ticks{
                        let f = eq(tick.x)
                        path.move(to: CGPoint(x: f*width, y: y0))
                        path.addLine(to: CGPoint(x: f*width, y: y0 + tick.size.rawValue * direction))
                    }
                }
            }
        }
        .stroke(.black, lineWidth: 0.6)
    }
}

