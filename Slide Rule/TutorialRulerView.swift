//
//  TutorialRulerView.swift
//  Slide Rule
//
//  Created by Rowan on 5/4/24.
//

import SwiftUI

import LaTeXSwiftUI



extension View {
    @inlinable
    public func reverseMask<Mask: View>(alignment: Alignment = .center, @ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

struct PulsingCircleView: View{
    var beginWidth: CGFloat = 0
    var endWidth: CGFloat = 0
    var color: Color = .red
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


struct TutorialRulerView: View{
    var keyframes: [Keyframe]
    @State var states: [posData] = []
    
    @State var posDat: posData = posData()
    @State var angle: CGFloat = 0.0
    
    @State var selectionX: CGFloat = 0.0
    @State var selectionX0: CGFloat = 0.0
    @State var selectionNum: Int = 1
    
    @State var selectionX2: CGFloat = 0.0
    @State var selectionX20: CGFloat = 0.0
    @State var selectionNum2: Int = -1
    
    @State var instructionNum: Int = 0
    @State var label: String = "_"
    @State var action: String = ""
    @State var gestureHint: GestureHint = .none
    
    @State var needsNextInput: Bool = false
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(alignment:.center){
                ZStack{
                    RulerView(posDat: $posDat, angle: $angle)
                    if(gestureHint != .flip){ //make sure to only display gui on the correct side of the ruler
                        if (action == "cursor" || action == "indexR" || action == "indexL" || action == "read") && selectionNum >= 0{
                            Rectangle()
                                .stroke(.red)
                                .frame(width:6,height:12)
                                .offset(x:selectionX + posDat.framePos, y:calcSelectionHeight(slideNum: selectionNum)-3.9-202/2)
                            //.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                        }
                        
                        if selectionNum2 >= 0 && action == "slideToSlide"{
                            //ZStack{
                                Rectangle()
                                    .stroke(.red)
                                    .frame(width:6,height:12)
                                    .offset(x:selectionX + posDat.framePos, y:calcSelectionHeight(slideNum: selectionNum)-3.9-202/2)
                                
                                Rectangle()
                                    .stroke(.red)
                                    .frame(width:6,height:12)
                                    .offset(x:selectionX2 + posDat.framePos, y:calcSelectionHeight(slideNum: selectionNum2)-3.9-202/2)
                                
                                Rectangle()
                                    .frame(width:1,height:190)
                                    .reverseMask{
                                        //crop out selected box
                                        Rectangle()
                                            .frame(width:6,height:12)
                                            .offset(y:calcSelectionHeight(slideNum: selectionNum)-3.9-202/2)
                                    }
                                    .offset(x:selectionX + posDat.framePos)
                                    .foregroundStyle(.red)
                                
                                Rectangle()
                                    .frame(width:1,height:190)
                                    .reverseMask{
                                        //crop out selected box
                                        Rectangle()
                                            .frame(width:6,height:12)
                                            .offset(y:calcSelectionHeight(slideNum: selectionNum2)-3.9-202/2)
                                    }
                                    .foregroundStyle(.red)
                                    .offset(x:selectionX2 + posDat.framePos)
                            //}
                        }
                        if action == "indexR" || action == "indexL" {
                            Rectangle()
                                .fill(.red)
                                .frame(width:0.6,height:190)
                                .offset(x: posDat.framePos + posDat.slidePos + (action == "indexL" ? 124.25 : 1600-124.25))
                            //.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                        }
                    }
                    if(gestureHint != .none){
                        TutorialGestureView(gestureHint: gestureHint)
                    }
                }
                .frame(maxWidth:geometry.size.width-0)
                .clipShape(Rectangle().size(width:UIScreen.main.bounds.width, height:300).offset(x:-geometry.safeAreaInsets.leading))
                
                HStack{
                    Button{
                        decInstructionNum()
                    }label:{
                        Image(systemName:"arrow.left.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.theme.text)
                            .frame(width:30,height:30)
                    }
                    Spacer()
                    Text("Step \(instructionNum+1)/\(keyframes.count)")
                        .foregroundColor(.white)
                    Spacer()
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
                }.padding()
            }
            
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar{
                ToolbarItem(placement: .principal){
                    HStack{
                        LaTeX("\(label)")
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear(){
            states = [posData](repeating: posData(), count: keyframes.count)
            
            if instructionNum < 0 || instructionNum >= keyframes.count {return}
            let key = keyframes[instructionNum]
            if key.frame != nil {posDat.framePos = center(x:key.frame!); posDat.framePos0 = posDat.framePos}
            if key.slide != nil {posDat.slidePos = key.slide! ;posDat.slidePos0 = posDat.slidePos}
            if key.cursor != nil {posDat.cursorPos = key.cursor!-50; posDat.cursorPos0 = posDat.cursorPos}
            if key.selectionNum != nil {selectionNum = key.selectionNum!}
            if key.selectionX != nil {selectionX0 = calcXValue(x: key.selectionX!, slideNum: selectionNum)}
            if key.selectionNum2 != nil {selectionNum2 = key.selectionNum2!}
            if key.selectionX2 != nil {selectionX20 = calcXValue(x: key.selectionX2!, slideNum: selectionNum2)}
            if key.label != nil {label = key.label!}
            //if key.action != nil {action = key.action!}
            action = key.action ?? ""
        }
        .onChange(of: posDat.timesPlaced){
            checkActionChange()
        }
        .onChange(of: posDat.slidePos){
            if selectionNum >= 3 && selectionNum <= 7 || selectionNum >= 14 && selectionNum <= 18 {
                selectionX = selectionX0 + posDat.slidePos
            }
            if selectionNum2 >= 3 && selectionNum2 <= 7 || selectionNum2 >= 14 && selectionNum2 <= 18 {
                selectionX2 = selectionX20 + posDat.slidePos
            }
        }
        .onChange(of: selectionX0){
            if selectionNum >= 3 && selectionNum <= 7 || selectionNum >= 14 && selectionNum <= 18 {
                selectionX = selectionX0 + posDat.slidePos
            }else{
                selectionX = selectionX0;
            }
        }
        .onChange(of:selectionNum){
            updateGestureHintState()
        }
        .onChange(of: selectionX20){
            if selectionNum2 >= 3 && selectionNum2 <= 7 || selectionNum2 >= 14 && selectionNum2 <= 18 {
                selectionX2 = selectionX20 + posDat.slidePos
            }else{
                selectionX2 = selectionX20;
            }
        }
        .onChange(of:selectionNum2){
            updateGestureHintState()
        }
        .onChange(of:posDat.framePos){
            updateGestureHintState()
        }
        .onChange(of:posDat.isFlipped){
            updateGestureHintState()
        }
        .onChange(of:action){
            checkIfNeedsNextInput()
        }
        .onChange(of:instructionNum){
            checkIfNeedsNextInput()
        }
    }
    
    func checkIfNeedsNextInput(){
        needsNextInput = action == "read" && instructionNum < keyframes.count - 1
    }
    
    func updateGestureHintState(){
        var newGesture = GestureHint.none
        if(posDat.isFlipped && selectionNum <= 10 && selectionNum >= 0 || !posDat.isFlipped && selectionNum > 10){
            newGesture = .flip
        }else{
            if(-posDat.framePos - selectionX > 300){
                newGesture = .right
            }else if(selectionX - -posDat.framePos > 300){
                newGesture = .left
            }
        }
        
        gestureHint = newGesture
    }
    
    func incInstructionNum(shouldMove: Bool = false){
        var num = instructionNum + 1;
        if num < 0 {num = 0}
        else if num >= keyframes.count {num = keyframes.count-1}
        
        if num == instructionNum {return}
        
        states[instructionNum] = posDat
        
        if(shouldMove){
            moveToKeyframe()
            let seconds = (action == "read" || action == "none") ? 0 : 1.5;
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds){setInstructionNum0(num: num)}
        }else{
            setInstructionNum0(num: num)
        }
    }
    
    func decInstructionNum(){
        var num = instructionNum - 1;
        if num < 0 {num = 0}
        else if num >= keyframes.count {num = keyframes.count-1}
        
        if num == instructionNum {return}
        
        withAnimation(.easeInOut(duration:1)){
            copyPosDat(dat: states[num])
        }
        
        setInstructionNum0(num: num)
    }
    
    func copyPosDat(dat: posData){
        posDat.framePos = dat.framePos
        posDat.framePos0 = dat.framePos0
        
        posDat.slidePos = dat.slidePos
        posDat.slidePos0 = dat.slidePos0
        
        posDat.cursorPos = dat.cursorPos
        posDat.cursorPos0 = dat.cursorPos0
        
        posDat.isFlipped = dat.isFlipped
    }
    
    func setInstructionNum0(num: Int){
        instructionNum = num;
        
        let key = keyframes[instructionNum]
        withAnimation(.easeInOut(duration:key.t ?? 1)){
            action = key.action ?? ""
            if key.selectionNum != nil {
                selectionNum = key.selectionNum!
            }
            if key.selectionX != nil {
                selectionX0 = calcXValue(x: key.selectionX!, slideNum: key.selectionNum!)
            }
            if key.selectionNum2 != nil {
                selectionNum2 = key.selectionNum2!
            }
            if key.selectionX2 != nil {
                selectionX20 = calcXValue(x: key.selectionX2!, slideNum: key.selectionNum2!)
            }
        }
        if key.label != nil {label = key.label!}
    }
    
    func moveToKeyframe(){
        let key = keyframes[instructionNum]
        withAnimation(.easeInOut(duration:key.t ?? 1)){
            switch action{
            case "cursor":
                posDat.cursorPos = selectionX
                posDat.cursorPos0 = posDat.cursorPos
            case "indexL":
                posDat.slidePos = selectionX-124.25
                posDat.slidePos0 = posDat.slidePos
            case "indexR":
                posDat.slidePos = selectionX-1600+124.25
                posDat.slidePos0 = posDat.slidePos
            default:
                return
            }
        }
    }
    
    /**
        Checks if the finish conditions of the current stage have been met, and dispatches the next stage.
     */
    func checkActionChange(){
        if selectionNum < 0 {return}
        
        switch action{
        case "cursor":
            if abs(posDat.cursorPos - selectionX) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        case "indexL":
            if abs(posDat.slidePos+124.25 - selectionX) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        case "indexR":
            if abs(posDat.slidePos+1600-124.25 - selectionX) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        case "slideToSlide":
            if abs(selectionX - selectionX2) < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {incInstructionNum()})
            }
        default:
            return
        }
    }
    
    func calcXValue(x : CGFloat, slideNum : Int) -> CGFloat {
        let x0 = 124.25
        let w = 1350.0
        switch slideNum {
        case 11: //LL01
            return x0 + w * (log10(log(x) * -1.0) + 2.0)
        case 0: //LL02
            return x0 + w * (log10(log(x) * -1.0) + 1.0)
        case 1: //LL03
            return x0 + w * (log10(log(x) * -1.0) + 0.0)
        case 9: //LL3
            return x0 + w * (log10(log(x)) + 0.0)
        case 10: //LL2
            return x0 + w * (log10(log(x)) + 1.0)
        case 21: //LL1
            return x0 + w * (log10(log(x)) + 2.0)
        case 2, 3: //DF CF
            return x0 + w * (log10(x) - log10(CGFloat.pi))
        case 4: //CIF
            return x0 + w * (1 - (log10(x) - log10(CGFloat.pi)))
        case 5: //L
            return x0 + w * x
        case 6, 20: //CI DI
            return x0 + w * (1-log10(x))
        case 7, 8, 19: //C D
            return x0 + w * log10(CGFloat(x))
        case 12: //K
            return x0 + w * log10(CGFloat(x))/3
        case 13, 14: //A B
            return x0 + w * log10(CGFloat(x))/2
        case 15: //T<45
            return x0 + w * (log10(tan(x*Double.pi/180)) + 1)
        case 16: //T>45
            return x0 + w * log10(tan(x*Double.pi/180))
        case 17: //ST
            return x0 + w * (log10(sin(x*Double.pi/180)) + 2)
        case 18: //S
            return x0 + w * (log10(sin(x*Double.pi/180)) + 1)
        default: return 0
        }
    }
    
    func calcSelectionHeight(slideNum: Int) -> CGFloat{
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
