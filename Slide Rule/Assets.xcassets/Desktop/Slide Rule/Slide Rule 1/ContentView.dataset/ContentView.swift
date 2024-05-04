//
//  ContentView.swift
//  Slide Rule
//
//  Created by Rowan on 11/21/23.
//

import SwiftUI

let coloredNavAppearance = UINavigationBarAppearance()

struct ContentView: View {

    var body: some View {
        SlideRuleView()
    }
}

struct AnimatedRulerView: View{
    var keyframes: [Keyframe]?
    
    @State var posDat: posData = posData()
    @State var selection: CGFloat = -1.0
    
    var body: some View {
        VStack{
            Spacer()
            ZStack{
                if selection != -1.0 {
                    Image("selectionCircle")
                        .resizable()
                        .frame(width:40,height:40)
                        .offset(x:posDat.cursorPos+50+floor(posDat.framePos)-UIScreen.main.bounds.width/2, y:selection-202/2)
                        .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                }
                RulerView(isLocked: true, isFlipped: .constant(false), angle: .constant(0), isZoomed: .constant(false), zoomPos: .constant(UnitPoint(x:0,y:0)), posDat:$posDat)
                    .onAppear(){
                        posDat.framePos += 1
                        posDat.framePos -= 1
                        
                        if let keyframes0 = keyframes{
                            var count = 0.0;
                            keyframes0.forEach{key in
                                withAnimation(.easeInOut(duration:key.t).delay(count)){
                                    posDat.framePos = center(x:key.frame)
                                    posDat.slidePos = key.slide
                                    posDat.cursorPos = key.cursor-50
                                    selection = key.selection
                                }
                                count += key.t
                            }
                        }

                    }
                    .clipped()

            }
            Spacer()
        }
        .background(Color.theme.background).ignoresSafeArea()
    }
    
    func center(x: CGFloat) -> CGFloat{
        return -x + UIScreen.main.bounds.width*0.5
    }
}

struct SlideRuleView: View {
    @State var isFlipped: Bool = false
    @State var angle: Double = 0.0
    @State var isZoomed = false
    @State var zoomPos: UnitPoint = UnitPoint(x:0.5,y:0.5)
    
    @State var posDat: posData = posData()
    
    let flipTime = 0.5
    
    var body: some View {
        NavigationView{
            VStack(){
                Spacer()
                RulerView(isFlipped: $isFlipped, angle:$angle, isZoomed:$isZoomed,zoomPos:$zoomPos, posDat: $posDat)
                    .simultaneousGesture(
                        DragGesture()
                            .onEnded({value in
                                if abs(value.translation.height) > 30 && abs(value.velocity.height) > 100 && abs(value.velocity.height) > abs(value.velocity.width) {
                                    flip(dir: value.translation.height < 0)
                                }
                            })
                    )
                Spacer()
                HStack{
                    if !isZoomed {
                        Button{
                            flip(dir:true)
                        } label:{
                            Image(systemName:"arrow.clockwise.circle")
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
            }
            .navigationTitle("Slide Rule")
            .toolbar(.hidden, for:.navigationBar)
            .background(Color.theme.background)
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
    
    func flip(dir: Bool) -> Void {
        let f = dir ? 1.0 : -1.0
        if isFlipped{
            withAnimation(.easeInOut(duration: flipTime/2)){
                angle += 90.0*f
            }
            withAnimation(.linear(duration:0.00001).delay(flipTime/2)){
                isFlipped.toggle()
                angle += 180*f
            }
            withAnimation(.easeInOut(duration: flipTime/2).delay(flipTime/2)){
                angle += 90*f
            }
        }else{
            withAnimation(.easeInOut(duration: flipTime/2)){
                angle += 90*f
            }
            withAnimation(.linear(duration:0.00001).delay(flipTime/2)){
                isFlipped.toggle()
                angle += 180*f
            }
            withAnimation(.easeInOut(duration: flipTime/2).delay(flipTime/2)){
                angle += 90*f
            }
        }
    }
}

struct RulerView: View {
    var isLocked: Bool = false
    
    @Binding var isFlipped: Bool
    @Binding var angle: Double
    @Binding var isZoomed: Bool
    @Binding var zoomPos: UnitPoint
    
    @Binding var posDat: posData
    
    var body: some View {
        
        Frame(isLocked: isLocked, isFlipped:isFlipped, isZoomed:isZoomed, angle:angle, posDat: $posDat)
                .rotation3DEffect(Angle(degrees:angle), axis: (x:1,y:0,z:0))
                
                .frame(width:UIScreen.main.bounds.width, height:250, alignment: .center)
                .contentShape(.interaction, Rectangle())
                .gesture(
                    SpatialTapGesture(count:2, coordinateSpace:.local)
                        .onEnded{value in
                            if !isZoomed {
                                zoomPos = UnitPoint(x:value.location.x/UIScreen.main.bounds.width, y:0.5)//value.location.y/250)
                            }
                            withAnimation(.easeInOut(duration:0.4)){
                                isZoomed.toggle()
                            }
                        }
                )
                //.border(.red)
                //.offset(x:-UIScreen.main.bounds.width*0.5)
                .scaleEffect(isZoomed ? 0.9*UIScreen.main.bounds.height/202 : 1, anchor: zoomPos)
    }
}

struct Cursor: View {
    var isLocked: Bool = false
    var isFlipped: Bool
    var isZoomed: Bool
    
    @Binding var posDat: posData
    
    @State var isDragging = false
    
    var body: some View {
        Image("Cursor")
            .resizable()
            .frame(width:100,height:240)
            .offset(x:posDat.cursorPos+50+floor(posDat.framePos))
            .gesture(
                DragGesture()
                    .onChanged({value in
                        if isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        isDragging = true
                        posDat.cursorPos = posDat.cursorPos0+value.translation.width*(isZoomed ? 0.5 : 1)
                    })
                    .onEnded({value in
                        if isLocked {return}
                        isDragging = false
                        posDat.cursorPos0 = posDat.cursorPos
                    })
            )
            .onChange(of: posDat.cursorPos) {
                clampPosition()
            }
    }
    
    func clampPosition(){
        //from 1600-100-64+10 to 64-10
        posDat.cursorPos = Double(min(1446.0,max(54.0,posDat.cursorPos)))
        posDat.cursorPos0 = Double(min(1446.0,max(54.0,posDat.cursorPos0)))
    }
}

struct Slide: View {
    var isLocked: Bool = false
    var isFlipped: Bool
    var isZoomed: Bool
    @Binding var posDat: posData
    
    @State var isDragging = false
    
    var body: some View {
        Image(isFlipped ? "slideFlippedHD" : "slideHD")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width:1600, height:88)
            .offset(x:posDat.slidePos+800+floor(posDat.framePos),y:0)
            .gesture(
                DragGesture()
                    .onChanged({value in
                        if isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        isDragging = true
                        posDat.slidePos = posDat.slidePos0+value.translation.width*(isZoomed ? 0.5 : 1)
                    })
                    .onEnded({value in
                        if isLocked {return}
                        isDragging = false
                        posDat.slidePos0 = posDat.slidePos
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

struct posData {
    var framePos: CGFloat = 200.0
    var framePos0: CGFloat = 200.0
    var slidePos: CGFloat = 0.0
    var slidePos0: CGFloat = 0.0
    var cursorPos: CGFloat = 54.0
    var cursorPos0: CGFloat = 54.0
}

struct Frame: View {
    var isLocked: Bool
    var isFlipped: Bool
    var isZoomed: Bool
    var angle: Double
    
    @State var isDragging = false
    
    @Binding var posDat: posData

    
    var body: some View {
        ZStack(){
            Slide(isLocked:isLocked, isFlipped:isFlipped, isZoomed: isZoomed, posDat: $posDat)
                //.offset(x:position,y:0)
            Image(isFlipped ? "frameFlippedHD" : "frameHD")
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
                    LongPressGesture(minimumDuration: 0.3).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
                        .onEnded{ value in
                            if isLocked {return}
                            switch value {
                            case .second(true, let drag):
                                let longPressLocation = drag?.startLocation ?? .zero
                                if abs(drag?.translation.width ?? 0) > 10 {
                                    break
                                }
                                withAnimation(.snappy(duration: 0.3)){
                                    posDat.cursorPos = longPressLocation.x - posDat.framePos - 50
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
                
                
            Cursor(isLocked:isLocked, isFlipped:isFlipped, isZoomed: isZoomed, posDat: $posDat)
        }
            .offset(x:-UIScreen.main.bounds.width/2)
            .onChange(of: posDat.framePos) {
                clampPosition()
            }
    }
    
    func clampPosition() -> Void{
        posDat.framePos = min(200, max(-1600-200+UIScreen.main.bounds.width,posDat.framePos))
        posDat.framePos0 = min(200, max(-1600-200+UIScreen.main.bounds.width,posDat.framePos0))
    }
}

#Preview {
    ContentView()
}
