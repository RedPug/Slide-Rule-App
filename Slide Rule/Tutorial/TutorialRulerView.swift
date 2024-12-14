//
//  TutorialRulerView.swift
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

import LaTeXSwiftUI


struct TutorialRulerView: View{
    var keyframes: [Keyframe]
    @State var states: [PosData] = []
    
    @State var posData: PosData = PosData()
    
    @State var selectionX: CGFloat = 0.0
    @State var selectionX0: CGFloat = 0.0
    @State var selectionNum: Int = 1
    
    @State var selectionX2: CGFloat = 0.0
    @State var selectionX20: CGFloat = 0.0
    @State var selectionNum2: Int = -1
    
    @State var instructionNum: Int = 0
    @State var label: String = ""
    @State var action: KeyframeActions = .none
    @State var gestureHint: GestureHint = .none
    
    @State var needsNextInput: Bool = false
    
    @State var sensoryTrigger: Bool = false
    
    @State var isInfoPopoverDisplayed: Bool = false
    
    var body: some View {
        GeometryReader{ geometry in
            HStack{
                SideScaleLabelView(posData: $posData)
                    .overlay(
                        HStack{
                            VStack(alignment: .leading){
                                Spacer()
                                
                            }
                            Spacer()
                        }
                    )
                
                RulerView(posData: $posData){
                    tutorialOverlayView
                }.scaleEffect(1)
                    .zIndex(-1)
                
                rulerButtonView
                    .sensoryFeedback(.impact, trigger: sensoryTrigger)
            }
            
            .frame(width: geometry.size.width, height: geometry.size.height+geometry.safeAreaInsets.bottom)
            .clipped()
            .toolbar{
                ToolbarItem(placement: .principal){
                    toolbarContent
                }
            }
            .sheet(isPresented: $isInfoPopoverDisplayed){
                ZStack{
                    RoundedRectangle(cornerRadius:5)
                        .fill(Color.theme.background)
                    VStack{
                        TutorialStepListView(instructionNum: instructionNum, keyframes: keyframes, setInstructionNum:{i in return setInstructionNum(i)})
                        Spacer()
                        Button{
                            isInfoPopoverDisplayed = false
                        }label:{
                            HelpButtonView("Done")
                        }
                    }
                }
                .frame(minWidth:geometry.size.width*0.9)
                .padding(10)
                .presentationCompactAdaptation(.sheet)
                .presentationBackground(.gray)
            }
        }
        
        .onAppear(){
            setInitialState()
        }
        .onChange(of: posData.timesPlaced){
            checkActionChange()
        }
        .onChange(of: posData.slidePos){
            if selectionNum >= 3 && selectionNum <= 7 || selectionNum >= 14 && selectionNum <= 18 {
                selectionX = selectionX0 + posData.slidePos
            }
            if selectionNum2 >= 3 && selectionNum2 <= 7 || selectionNum2 >= 14 && selectionNum2 <= 18 {
                selectionX2 = selectionX20 + posData.slidePos
            }
        }
        .onChange(of: selectionX0){
            onSelectionChange()
        }
        .onChange(of:selectionNum){
            updateGestureHintState()
        }
        .onChange(of: selectionX20){
            onSelection2Change()
        }
        .onChange(of:selectionNum2){
            updateGestureHintState()
        }
        .onChange(of:posData){
            updateGestureHintState()
        }
        .onChange(of:action){
            checkIfNeedsNextInput()
        }
        .onChange(of:instructionNum){
            checkIfNeedsNextInput()
        }
    }
    
    func onSelectionChange(){
        if selectionNum >= 3 && selectionNum <= 7 || selectionNum >= 14 && selectionNum <= 18 {
            selectionX = selectionX0 + posData.slidePos
        }else{
            selectionX = selectionX0;
        }
    }
    
    func onSelection2Change(){
        if selectionNum2 >= 3 && selectionNum2 <= 7 || selectionNum2 >= 14 && selectionNum2 <= 18 {
            selectionX2 = selectionX20 + posData.slidePos
        }else{
            selectionX2 = selectionX20;
        }
    }
    
    
    func setPosData(data: PosData){
        posData.framePos = data.framePos
        posData.framePos0 = data.framePos0
        
        posData.slidePos = data.slidePos
        posData.slidePos0 = data.slidePos0
        
        posData.cursorPos = data.cursorPos
        posData.cursorPos0 = data.cursorPos0
        
        posData.isFlipped = data.isFlipped
    }
    
    private func setInitialState(){
        states = [PosData](repeating: PosData(), count: keyframes.count)
        
        if instructionNum < 0 || instructionNum >= keyframes.count {return}
        let key = keyframes[instructionNum]
        if key.selectionNum != nil {selectionNum = key.selectionNum!}
        if key.selectionX != nil {selectionX0 = calcXValue(x: key.selectionX!, slideNum: selectionNum)}
        if key.selectionNum2 != nil {selectionNum2 = key.selectionNum2!}
        if key.selectionX2 != nil {selectionX20 = calcXValue(x: key.selectionX2!, slideNum: selectionNum2)}
        if key.label != nil {label = key.label!}
        action = key.action
    }
    
    
}

extension TutorialRulerView{
    private var rulerButtonView: some View {
        Color(.gray)
            .frame(width:50)
            .overlay{
                VStack{
                    Button{
                        posData.shouldFlip = true
                        sensoryTrigger.toggle()
                    } label:{
                        Image("FlipButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.theme.text)
                            .frame(width:30,height:30)
                    }
                    .frame(width:30)
                    .padding(.top, 10)
                    
                    Button{
                        withAnimation(.snappy(duration: 0.3)){
                            posData.cursorPos = -posData.framePos
                            posData.cursorPos0 = posData.cursorPos
                        }
                        
                        sensoryTrigger.toggle()
                    }label:{
                        Image("CursorButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.theme.text)
                            .frame(width:30,height:30)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    
                }
            }
    }
    
    private var toolbarContent: some View {
        HStack{
            Text("Step \(instructionNum+1)/\(keyframes.count):")
                .foregroundStyle(.white)
            
            LaTeX("\(label)")
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button{
                isInfoPopoverDisplayed = true
            }label:{
                Image(systemName:"list.number")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.theme.text)
                    .frame(width:30,height:30)
            }
            
            Button{
                decInstructionNum()
            }label:{
                Image(systemName:"arrow.left.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.theme.text)
                    .frame(width:30,height:30)
            }
            .frame(width:30)
            
            Button{
                incInstructionNum(shouldMove: true)
            }label:{
                Image(systemName:"arrow.right.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.theme.text)
                    .frame(width:30,height:30)
                    .overlay{
                        if(needsNextInput){
                            PulsingCircleView(beginWidth: 30, endWidth: 50, color: .theme.text)
                        }
                    }
            }
            .frame(width:30)
            
        }
    }
}




extension TutorialRulerView{
    private func calcXValue(x : CGFloat, slideNum : Int) -> CGFloat {
        let x0 = 125.0
        let w = 1350.0
        
        let scales = slideNum >= 11 ? ScaleLists.slideScalesBack : ScaleLists.slideScalesFront
        
        let f: (CGFloat)->(CGFloat) = scales[slideNum%11].data.equation
        
        return x0 + w * f(x)
    }
    
    private func calcSelectionHeight(slideNum: Int) -> CGFloat{
        switch slideNum {
        case 0: return 20.0
        case 1: return 37.0
        case 2: return 56.5
        case 3: return 65.25
        case 4: return 83.0
        case 5: return 107.0
        case 6: return 128.0
        case 7: return 144.75
        case 8: return 153.0
        case 9: return 173.0
        case 10: return 188.75
        case 11: return 20.0
        case 12: return 37.0
        case 13: return 56.5
        case 14: return 65.25
        case 15: return 83.0
        case 16: return 107.0
        case 17: return 128.0
        case 18: return 144.75
        case 19: return 153.0
        case 20: return 173.0
        case 21: return 188.75
        default: return -1
        }
    }
    
    func center(x: CGFloat) -> CGFloat{
        return -x
    }
}




extension TutorialRulerView{
    private func setInstructionNum0(num: Int, isInstant: Bool = false){
        instructionNum = num;
        
        let key = keyframes[instructionNum]
        action = key.action
        if key.selectionNum != nil {
            selectionNum = key.selectionNum!
        }
        if key.selectionX != nil {
            selectionX0 = calcXValue(x: key.selectionX!, slideNum: key.selectionNum!)
            onSelectionChange()
        }
        if key.selectionNum2 != nil {
            selectionNum2 = key.selectionNum2!
        }
        if key.selectionX2 != nil {
            selectionX20 = calcXValue(x: key.selectionX2!, slideNum: key.selectionNum2!)
            onSelection2Change()
        }
        
        if key.label != nil {label = key.label!}
    }
    
    private func setInstructionNum(_ num: Int){
        if num < instructionNum {
            for _ in 1...(instructionNum-num){
                decInstructionNum(isInstant: true)
            }
        }else if num > instructionNum {
            for _ in 1...(num - instructionNum){
                incInstructionNum(shouldMove:true, isInstant: true)
            }
        }
    }
    
    private func incInstructionNum(shouldMove: Bool = false, isInstant: Bool = false){
        var num = instructionNum + 1;
        if num < 0 {num = 0}
        else if num >= keyframes.count {num = keyframes.count-1}
        
        if num == instructionNum {return}
        
        states[instructionNum] = posData
        
        if(shouldMove){
            
//            if isInstant{
//                setInstructionNum0(num: num, isInstant: true)
//            }else{
//                let seconds = (action == .readValue || action == .none) ? 0 : 1.5;
//                DispatchQueue.main.asyncAfter(deadline: .now() + seconds){}
//            }
            moveToKeyframe(isInstant: isInstant) //move to the current target keyframe
            setInstructionNum0(num: num, isInstant: isInstant) //change the target keyframe to be the next one
        }else{
            setInstructionNum0(num: num)
        }
    }
    
    private func decInstructionNum(isInstant: Bool = false){
        var num = instructionNum - 1;
        if num < 0 {num = 0}
        else if num >= keyframes.count {num = keyframes.count-1}
        
        if num == instructionNum {return}
        
        if(isInstant){
            setPosData(data: states[num])
        }else{
            withAnimation(.easeInOut(duration:1)){
                setPosData(data: states[num])
            }
        }
        
        setInstructionNum0(num: num, isInstant: isInstant)
    }
    
    private func moveToKeyframe(isInstant: Bool = false){
        let f = {()->() in
            switch action{
            case .alignCursor:
                posData.cursorPos = selectionX
                posData.cursorPos0 = posData.cursorPos
            case .alignIndexLeft:
                posData.slidePos = selectionX-124.25
                posData.slidePos0 = posData.slidePos
            case .alignIndexRight:
                posData.slidePos = selectionX-1600+124.25
                posData.slidePos0 = posData.slidePos
            default:
                return
            }
        }
        
        if isInstant{
            f()
        }else{
            withAnimation(.easeInOut(duration:1)){
                f()
            }
        }
    }
    
    /**
        Checks if the finish conditions of the current stage have been met, and dispatches the next stage.
     */
    private func checkActionChange(){
        if selectionNum < 0 {return}
        
        switch action{
        case .alignCursor:
            if abs(posData.cursorPos - selectionX) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        case .alignIndexLeft:
            if abs(posData.slidePos+124.25 - selectionX) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        case .alignIndexRight:
            if abs(posData.slidePos+1600-124.25 - selectionX) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        case .alignScales:
            if abs(selectionX - selectionX2) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        default:
            return
        }
    }
}




extension TutorialRulerView{
    private func checkIfNeedsNextInput(){
        needsNextInput = (action == .readValue || action == .none) && instructionNum < keyframes.count - 1
    }
    
    private func updateGestureHintState(){
        //print("updating gesture hint! \(posDat.isFlipped), \(posDat.framePos), \(selectionNum)")
        var newGesture = GestureHint.none
        if(posData.isFlipped && selectionNum <= 10 || !posData.isFlipped && selectionNum > 10){
            newGesture = .flip
        }else{
            if(-posData.framePos - selectionX > 300){
                newGesture = .right
            }else if(selectionX - -posData.framePos > 300){
                newGesture = .left
            }
        }
        //print(newGesture)
        gestureHint = newGesture
    }
}


extension TutorialRulerView{
    private var tutorialOverlayView: some View {
        
        return Group{
            if(gestureHint != .flip){ //make sure to only display gui on the correct side of the ruler
                if (action == .alignCursor || action == .alignIndexLeft || action == .alignIndexRight || action == .readValue) && selectionNum >= 0{
                    Capsule()
                        .stroke(.red)
                        .frame(width:6,height:12)
                        .offset(x:selectionX + posData.framePos, y:calcSelectionHeight(slideNum: selectionNum)-3.9-202/2)
                    //.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                }
                
                if selectionNum2 >= 0 && action == .alignScales{
                    //ZStack{
                    Capsule()
                        .stroke(.red)
                        .frame(width:6,height:12)
                        .offset(x:selectionX + posData.framePos, y:calcSelectionHeight(slideNum: selectionNum)-3.9-202/2)
                    
                    Capsule()
                        .stroke(.red)
                        .frame(width:6,height:12)
                        .offset(x:selectionX2 + posData.framePos, y:calcSelectionHeight(slideNum: selectionNum2)-3.9-202/2)
                    
                    Capsule()
                        .frame(width:1,height:190)
                        .reverseMask{
                            //crop out selected box
                            Rectangle()
                                .frame(width:6,height:12)
                                .offset(y:calcSelectionHeight(slideNum: selectionNum)-3.9-202/2)
                        }
                        .offset(x:selectionX + posData.framePos)
                        .foregroundStyle(.red)
                    
                    Capsule()
                        .frame(width:1,height:190)
                        .reverseMask{
                            //crop out selected box
                            Rectangle()
                                .frame(width:6,height:12)
                                .offset(y:calcSelectionHeight(slideNum: selectionNum2)-3.9-202/2)
                        }
                        .foregroundStyle(.red)
                        .offset(x:selectionX2 + posData.framePos)
                    //}
                }
                if action == .alignIndexRight || action == .alignIndexLeft{
                    Capsule()
                        .fill(.red)
                        .frame(width:0.6,height:190)
                        .offset(x: posData.framePos + posData.slidePos + (action == .alignIndexLeft ? 124.25 : 1600-124.25))
                    //.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                }
            }
            if(gestureHint != .none){
                TutorialGestureView(gestureHint: $gestureHint)
            }
        }
    }
}
