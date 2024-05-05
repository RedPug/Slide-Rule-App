//
//  TutorialGestureView.swift
//  Slide Rule
//
//  Created by Rowan on 5/4/24.
//

import SwiftUI

enum GestureHint{
    case none, flip, left, right
}

struct GestureHandView: View {
    var body: some View {
        Image(systemName:"hand.point.up.left")
            .resizable()
            .scaledToFill()
            .frame(width:50, height:50)
            .foregroundStyle(.black)
            .zIndex(1.0)
    }
}

struct TutorialGestureView: View {
    @State  var gestureHint: GestureHint
    @State var isGestureMoving: Bool = false
    @State var isGestureVisible: Bool = true
    @State var isGestureAnimating: Bool = false
    
    var body: some View {
        ZStack{
            if(isGestureVisible){
                //needs to flip.
                if(gestureHint == .flip){
                    GestureHandView()
                        .offset(y:isGestureMoving ? -75 : 75)
                }
                
                if(gestureHint == .left || gestureHint == .right){
                    GestureHandView()
                        .offset(x:(gestureHint == .left ? -1 : 1)*(isGestureMoving ? 75 : -75), y:110)
                }
            }
        }
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
