//
//  SlideView.swift
//  Slide Rule
//
//  Created by Rowan on 8/21/24.
//

import SwiftUI

struct SlideView: View {
    @Binding var posDat: PosData
    
    @State var isDragging = false
    
    let maxSlide = 1500.0
    let minSlide = -1500.0
    
    var body: some View {
        //Image(posDat.isFlippedTemp ? "slideFlippedHD" : "slideHD")
        ZStack{
            Rectangle()
                .fill(Color.theme.rulerSlide)
                .stroke(.gray, lineWidth:0.5)
                .zIndex(1.0)
            
            //former height = 88
            SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesFront, minIndex: 3, maxIndex:7)
                .zIndex(posDat.isFlippedTemp ? 0.5 : 1.5)
                .frame(width:1600, height:88)
            SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesBack, minIndex: 3, maxIndex:7)
                .zIndex(posDat.isFlippedTemp ? 1.5 : 0.5)
                .frame(width:1600, height:88)
        }
        .frame(width:1600, height:88)
        .preciseOffset(x: posDat.slidePos+posDat.framePos+800,y:0)
        .defersSystemGestures(on: .all)
        .gesture(
            DragGesture(minimumDistance: 5.0)
                .onChanged({value in
                    if posDat.isLocked {return}
                    posDat.physicsEnabled = false
                    
                    if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                    isDragging = true
                    posDat.slidePos = max(minSlide, min(maxSlide,posDat.slidePos0+value.translation.width))
                })
                .onEnded({value in
                    if posDat.isLocked {return}
                    posDat.physicsEnabled = true
                    isDragging = false
                    posDat.slidePos0 = posDat.slidePos
                    posDat.timesPlaced += 1
                })
        )
        .onChange(of: posDat.slidePos) {
            clampPosition()
        }
    }
    
    func clampPosition(){
        if(posDat.slidePos > maxSlide){
            posDat.slidePos = maxSlide
            posDat.velocity = 0
        }else if(posDat.slidePos < minSlide){
            posDat.slidePos = minSlide
            posDat.velocity = 0
        }
        
        if(posDat.slidePos0 > maxSlide){
            posDat.slidePos0 = maxSlide
            posDat.velocity = 0
        }else if(posDat.slidePos0 < minSlide){
            posDat.slidePos0 = minSlide
            posDat.velocity = 0
        }
    }
}

