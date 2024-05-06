//
//  SlideRuleView.swift
//  Slide Rule
//
//  Created by Rowan on 1/1/24.
//

import SwiftUI

struct posData {
    var framePos: CGFloat = -200.0
    var framePos0: CGFloat = -200.0
    var slidePos: CGFloat = 0.0
    var slidePos0: CGFloat = 0.0
    var cursorPos: CGFloat = 104.0
    var cursorPos0: CGFloat = 104.0
    var isFlipped: Bool = false
    var isFlippedTemp: Bool = false
    var shouldFlip: Bool = false
    var timesPlaced: Int = 0;
}

struct MagnificationEffect<Content: View>: View{
    var scale: CGFloat
    var size: CGFloat
    var isVisible: Bool
    var content: Content
    
    init(scale: CGFloat, size:CGFloat, isVisible: Bool, @ViewBuilder content: @escaping ()->Content){
        self.scale = scale
        self.size = size
        self.isVisible = isVisible
        self.content = content()
    }
    
    @State var offset: CGSize = CGSize.zero
    @State var pastOffset: CGSize = CGSize.zero
    
    var body: some View{
        content
            .overlay{
                if(isVisible){
                    GeometryReader{geometry in
                        let bounds = geometry.size
                        ZStack{
                            Circle()
                                .fill(Color.theme.background)
                                .frame(width: size, height: size)
                                .offset(offset)
                            content
                                .offset(x: -offset.width, y:-offset.height)
                                .frame(width: size, height: size)
                                .scaleEffect(scale)
                                .clipShape(Circle())
                                .contentShape(.interaction, Circle())
                                .offset(offset)
                            
                            Circle()
                                .stroke(.black, lineWidth: 5)
                                .frame(width: size, height: size)
                                .contentShape(.interaction, Circle())
                                .offset(offset)
                                .gesture(
                                    DragGesture()
                                        .onChanged(){value in
                                            offset = CGSize(
                                                width: pastOffset.width + value.translation.width,
                                                height: pastOffset.height + value.translation.height
                                            )
                                            offset.width = min(max(offset.width,-UIScreen.main.bounds.width/2+size/2),UIScreen.main.bounds.width/2-size/2)
                                            offset.height = min(max(offset.height,-bounds.height/2),bounds.height/2)
                                        }
                                        .onEnded(){value in
                                            pastOffset = offset
                                        }
                                )
                            
                            
                        }
                            .frame(width: bounds.width, height: bounds.height)
                    }
                }
            }
    }
}


struct SlideRuleView: View {
    @State var isFlipped: Bool = false
    
    @State var posDat: posData = posData()
    @State var isMagnifyerVisible: Bool = false
    @State var magnifyLevel: CGFloat = 1.0
    @State var angle: CGFloat = 0.0
    
    var body: some View {
        NavigationView{
            ZStack(){
                //Color(Color.theme.background).edgesIgnoringSafeArea(.all)
                VStack(){
                    Spacer()
                    MagnificationEffect(scale: 1+pow(magnifyLevel/5, 2)*3, size: 100, isVisible: isMagnifyerVisible){
                        RulerView(posDat: $posDat, angle: $angle)
                    }
                    Spacer()
                    HStack{
                        Button{
                            posDat.shouldFlip = true
                        } label:{
                            Image(systemName:"arrow.clockwise.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.theme.text)
                                .frame(width:30,height:30)
                        }
                        Spacer()
                            .frame(width:30)
                        
                        Button{
                            isMagnifyerVisible.toggle()
                        } label:{
                            
                            Image(systemName: isMagnifyerVisible ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.theme.text)
                                .frame(width:30,height:30)
                        }
                        Button{
                            if(magnifyLevel < 5){
                                magnifyLevel += 1
                            }
                        } label:{
                            Image(systemName:"plus.magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.theme.text)
                                .frame(width:30,height:30)
                        }
                        Button{
                            if(magnifyLevel > 1){
                                magnifyLevel -= 1
                            }
                        } label:{
                            Image(systemName:"minus.magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.theme.text)
                                .frame(width:30,height:30)
                        }
                        
                        Spacer()
                        NavigationLink(destination: HelpMenuView(), label:{
                            Image(systemName:"questionmark.square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.theme.text)
                                .frame(width:30,height:30)
                        })
                    }
                    
                }
                .navigationTitle("Slide Rule")
                .toolbar(.hidden, for:.navigationBar)
                .background(Color.theme.background)
                
            }
            
        }
        .onAppear{
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(Color.gray)
            appearance.titleTextAttributes = [
                .foregroundColor : UIColor(Color.white)
            ]
            UINavigationBar.appearance().scrollEdgeAppearance=appearance
        }
        .accentColor(.white)
    }
}

struct RulerView: View {
    var isLocked: Bool = false
    
    
    @Binding var posDat: posData
    @Binding var angle: CGFloat
    
    //@State var isFlippedTemp: Bool = false
    
    let flipTime = 0.7
    
    var body: some View {
        Frame(isLocked: isLocked, angle:angle, posDat: $posDat)
                .rotation3DEffect(Angle(degrees:angle), axis: (x:1,y:0,z:0))
                .frame(height:250, alignment: .center)
                .contentShape(.interaction, Rectangle())
                .simultaneousGesture(
                    DragGesture()
                        .onEnded({value in
                            if abs(value.translation.height) > 30 && abs(value.velocity.height) > 100 && abs(value.velocity.height) > abs(value.velocity.width) {
                                flip(dir: value.translation.height < 0)
                            }
                        })
                )
                .onChange(of: posDat.shouldFlip){ oldState, newState in
                    if oldState == false && newState{
                        flip(dir: true);
                    }
                }
                //.clipped()
    }
    
    func flip(dir: Bool) -> Void {
        let f = dir ? 1.0 : -1.0
        withAnimation(.easeIn(duration: flipTime/2)){
            angle += 90.0*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+flipTime/2){
            posDat.isFlippedTemp.toggle()
            posDat.isFlipped = posDat.isFlippedTemp
            angle += 180*f
        }
        withAnimation(.easeOut(duration: flipTime/2).delay(flipTime/2)){
            angle += 90*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+flipTime){
            posDat.shouldFlip = false
        }
    }
}

struct Cursor: View {
    var isLocked: Bool = false
    
    @Binding var posDat: posData
    
    @State var isDragging = false
    
    var body: some View {
        Image("Cursor")
            .resizable()
            .frame(width:100,height:240)
            .offset(x:posDat.cursorPos+floor(posDat.framePos))
            .gesture(
                DragGesture()
                    .onChanged({value in
                        if isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        isDragging = true
                        posDat.cursorPos = posDat.cursorPos0+value.translation.width
                    })
                    .onEnded({value in
                        if isLocked {return}
                        isDragging = false
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
}

struct Slide: View {
    var isLocked: Bool = false
    @Binding var posDat: posData
    
    @State var isDragging = false
    
    var body: some View {
        Image(posDat.isFlippedTemp ? "slideFlippedHD" : "slideHD")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width:1600, height:202)
            .offset(x:posDat.slidePos+800+floor(posDat.framePos),y:0)
            .gesture(
                DragGesture()
                    .onChanged({value in
                        if isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        isDragging = true
                        posDat.slidePos = posDat.slidePos0+value.translation.width
                    })
                    .onEnded({value in
                        if isLocked {return}
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
        posDat.slidePos = min(1500,max(-1500,posDat.slidePos))
        posDat.slidePos0 = min(1500,max(-1500,posDat.slidePos0))
    }
}

struct Frame: View {
    var isLocked: Bool
    var angle: Double
    
    @State var isDragging = false
    
    @Binding var posDat: posData

    
    var body: some View {
        ZStack(){
            Slide(isLocked:isLocked, posDat: $posDat)
            //.offset(x:position,y:0)
            Image(posDat.isFlippedTemp ? "frameFlippedHD" : "frameHD")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:1600,height:202)
                .offset(x:floor(posDat.framePos)+800,y:0)
                .gesture(
                    DragGesture()
                        .onChanged({value in
                            if isLocked {return}
                            if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                            isDragging = true
                            posDat.framePos = posDat.framePos0+value.translation.width
                        })
                        .onEnded({value in
                            if isLocked {return}
                            isDragging = false
                            posDat.framePos0 = posDat.framePos
                        })
                )
                .gesture(
                    LongPressGesture(minimumDuration: 0.3).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                        .onEnded{ value in
                            if isLocked {return}
                            switch value {
                            case .second(true, let drag):
                                let longPressLocation = drag?.startLocation ?? .zero
                                if abs(drag?.translation.width ?? 0) > 10 {
                                    break
                                }
                                //print(longPressLocation.x)
                                withAnimation(.snappy(duration: 0.3)){
                                    posDat.cursorPos = longPressLocation.x - posDat.framePos - 800
                                    posDat.cursorPos0 = posDat.cursorPos
                                }
                                
                            default:
                                break
                            }
                        }
                )
                .contentShape(.interaction,
                              Rectangle()
                    .size(width: 1600, height: 57)
                    .offset(x:0,y:145)
                    .union(
                        Rectangle()
                            .size(width: 1600, height: 57)
                    )
                )
            
            
            Cursor(isLocked:isLocked, posDat: $posDat)
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
