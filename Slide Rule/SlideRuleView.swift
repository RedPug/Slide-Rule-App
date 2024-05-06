//
//  SlideRuleView.swift
//  Slide Rule
//
//  Created by Rowan on 1/1/24.
//

import SwiftUI
import LaTeXSwiftUI

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
    var isLocked: Bool = false
    var timesPlaced: Int = 0;
}

struct MagnifyingGlass<Content: View>: View{
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
                        let r = size*0.3
                        let shape = RoundedRectangle(cornerRadius: r)
                        ZStack{
                            Group{
                                shape
                                    .fill(Color.theme.background)
                                    .frame(width: size, height: size)
                                    .offset(offset)
                                
                                content
                                    .offset(x: -offset.width, y:-offset.height)
                                    .frame(width: size, height: size)
                                    .scaleEffect(scale)
                                    .clipShape(shape)
                                    .contentShape(.interaction, shape)
                                    .offset(offset)
                                
                                shape
                                    .stroke(.black, lineWidth: 5)
                                    .frame(width: size, height: size)
                                    .contentShape(.interaction, shape)
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
                            }.offset(x:size/scale/2+size/2)
                            
                            RoundedRectangle(cornerRadius: r/scale)
                                .stroke(.black, lineWidth: 5)
                                .frame(width: size/scale, height: size/scale)
                                .offset(offset)
                        }
                        .frame(width: bounds.width, height: bounds.height)
                    }
                }
                else{
                    EmptyView()
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
    @State var zoomLevel: CGFloat = 1.0
    @State var lastZoomLevel: CGFloat = 1.0
    @State var zoomAnchor: CGPoint = .zero
    
    var body: some View {
        NavigationView{
            ZStack(){
                //Color(Color.theme.background).edgesIgnoringSafeArea(.all)
                MagnifyingGlass(scale: 1+pow(magnifyLevel/5, 2)*3, size: 150, isVisible: isMagnifyerVisible){
                    RulerView(posDat: $posDat, angle: $angle)
                        .offset(x:-zoomAnchor.x, y:-zoomAnchor.y)
                        .scaleEffect(zoomLevel, anchor: .leading)
                        .offset(x:zoomAnchor.x, y:zoomAnchor.y)
                        .defersSystemGestures(on: .all)
                        .simultaneousGesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    posDat.isLocked = true
                                    
                                    let val = value.magnification
                                    let delta = val / self.lastZoomLevel
                                    self.lastZoomLevel = val
                                    var newScale = zoomLevel * delta
                                    
                                    newScale = min(3,max(1,newScale))
                                    
                                    //print(value.startLocation)
                                    let start = value.startLocation
                                    zoomAnchor = CGPoint(x:start.x, y:(start.y-101)*1.5)
                                    
                                    zoomLevel = newScale
                                }.onEnded { value in
                                    posDat.isLocked = false
                                    self.lastZoomLevel = 1.0
                                }
                        )
                }
                
                VStack{
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
                        .padding(.leading, 30)
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
                        .padding(.trailing, 30)
                        
                    }
                    .ignoresSafeArea(.all)
                    .frame(width:UIScreen.main.bounds.size.width)
                    .padding(.all,5)
                    .background(.gray.opacity(1))
                    
                    Spacer()
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
}

struct RulerView: View {
    
    @Binding var posDat: posData
    @Binding var angle: CGFloat
    
    //@State var isFlippedTemp: Bool = false
    
    let flipTime = 0.7
    
    var body: some View {
        Frame(angle:angle, posDat: $posDat)
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
                        if posDat.isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        isDragging = true
                        posDat.cursorPos = posDat.cursorPos0+value.translation.width
                    })
                    .onEnded({value in
                        if posDat.isLocked {return}
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

struct SlideMarkingView: View{
    
    var width : CGFloat
    var height : CGFloat
    
    let scales : [RulerScale]
    
    var body: some View {
        ZStack(alignment: .center){
            //tick marks
            Path {path in
                scales.enumerated().forEach{scaleIndex, scale in
                    let eq = scale.data.equation
                    let y0 = getScaleHeight(scaleIndex)
                    let direction = getScaleDirection(scaleIndex) == .up ? -1.0 : 1.0
                    scale.data.markingIntervals.forEach{interval in
                        let range = Int(floor((interval.max-interval.min)/interval.spacing + 0.01))
                        if(range < 0){
                            print("Bad range of \(range), with min of \(interval.min), max of \(interval.max), and spacing of \(interval.spacing)")
                        }
                        for i in 0...range{
                            if(interval.skipping > 0 && (i)%interval.skipping == 0){continue}
                            
                            let x = interval.min + CGFloat(i)*interval.spacing
                            let f = eq(x)
                            path.move(to: CGPoint(x: f*width, y: y0))
                            path.addLine(to: CGPoint(x: f*width, y: y0 + interval.size.rawValue * direction))
                        }
                    }
                }
            }
            .stroke(.black, lineWidth: 0.5)
            .frame(width:width, height:height)
            //	.border(.red)
            //.overlay{
            let textOffsetX = -width*0.5
            let textOffsetY = -height*0.5
            
            //text
            //iterate by each scale, text inerval, and finally through the interval to draw the text
            ForEach(Array(scales.enumerated()), id: \.offset){
                scaleIndex, scale in
                
                let eq = scale.data.equation
                let y0 = getScaleHeight(scaleIndex)
                let direction = getScaleDirection(scaleIndex) == .up ? -1.0 : 1.0
                let maxMag = 3.0
                
                //Group{
                Text(scale.name)
                    .font(.system(size: 9*maxMag, weight:.bold))
                    .foregroundStyle(.black)
                    .frame(width:150.0,height:50.0, alignment: .leading)
                    .scaleEffect(1.0/maxMag)
                    .offset(x: -29 + textOffsetX, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                
                LaTeX(scale.leftLabel)
                    .font(.system(size: 8*maxMag, weight:.bold))
                    .foregroundStyle(.black)
                    .frame(width:150.0,height:50.0, alignment: .leading)
                    .scaleEffect(1.0/maxMag)
                    .offset(x: textOffsetX + 0, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                
                
                ForEach(Array(scale.data.labelingIntervals.enumerated()), id: \.offset){
                    intervalIndex, _ in
                    let interval : LabelingInterval = scale.data.labelingIntervals[intervalIndex]
                    let diff: CGFloat = interval.max-interval.min
                    let dist: CGFloat = diff/interval.spacing
                    let range: Int = Int(floor(dist + 0.01))
                    
                    ForEach((0...range).filter{i in return interval.skipping <= 0 || (i)%interval.skipping != 0}, id: \.self){
                        i in
                        let x = interval.min + CGFloat(i)*interval.spacing
                        let f = eq(x)
                        
                        //uses a scale effect in order to keep sharpness when zoomed in via magnifying glass
                        //max magnification = 3x, so the text is rendered at 3x scale to ensure detail
                        let isTall: Bool = interval.textHeight == .tall
                        let fontSize : CGFloat = isTall ? 8.0 : 6.0
                        Text(interval.textGen(x))
                            .font(.system(size: fontSize*maxMag, weight:.bold))
                            .foregroundStyle(.black)
                            .scaleEffect(1.0/maxMag)
                            .frame(width:50.0,height:50.0, alignment: .center)
                            .offset(x: f*width + textOffsetX, y: y0+interval.textHeight.rawValue*direction + textOffsetY)
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
            return 0.0
        case 1:
            return 18.0
        case 2:
            return 52.0
        case 3:
            return 70
        case 4:
            return 88
        default:
            return 0
        }
    }
    
    func getScaleDirection(_ index: Int) -> TickDirection{
        if(index < 2){
            return .down
        }
        return .up
    }
}



struct Slide: View {
    @Binding var posDat: posData
    
    @State var isDragging = false
    
    var body: some View {
        //Image(posDat.isFlippedTemp ? "slideFlippedHD" : "slideHD")
        Rectangle()
            .fill(Color.theme.rulerBase)
            .overlay{
                SlideMarkingView(width:1350, height:88, scales: posDat.isFlippedTemp ? ScaleLists.slideScalesBack : ScaleLists.slideScalesFront)
                //.offset(x:124.5/2)
            }
        //            .resizable()
        //            .aspectRatio(contentMode: .fit)
            .frame(width:1600, height:88)
            .offset(x:posDat.slidePos+800+floor(posDat.framePos),y:0)
            .gesture(
                DragGesture(minimumDistance:50)
                    .onChanged({value in
                        if posDat.isLocked {return}
                        if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                        isDragging = true
                        posDat.slidePos = posDat.slidePos0+value.translation.width
                    })
                    .onEnded({value in
                        if posDat.isLocked {return}
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
    var angle: Double
    
    @State var isDragging = false
    
    @Binding var posDat: posData
    
    
    var body: some View {
        ZStack(){
            Slide(posDat: $posDat)
            //.offset(x:position,y:0)
            Image(posDat.isFlippedTemp ? "frameFlippedHD" : "frameHD")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:1600,height:202)
                .offset(x:floor(posDat.framePos)+800,y:0)
                .gesture(
                    DragGesture(minimumDistance:50)
                        .onChanged({value in
                            if posDat.isLocked {return}
                            if(abs(value.velocity.height) > abs(value.velocity.width)){return}
                            isDragging = true
                            posDat.framePos = posDat.framePos0+value.translation.width
                        })
                        .onEnded({value in
                            if posDat.isLocked {return}
                            isDragging = false
                            posDat.framePos0 = posDat.framePos
                        })
                )
                .gesture(
                    LongPressGesture(minimumDuration: 0.3).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                        .onEnded{ value in
                            if posDat.isLocked {return}
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
            
            
            Cursor(posDat: $posDat)
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
