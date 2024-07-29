//
//  SlideRuleView.swift
//  Slide Rule
//
//  Created by Rowan on 1/1/24.
//

import SwiftUI
import LaTeXSwiftUI
import CoreMotion
import SceneKit


struct PosDat {
    var framePos: CGFloat = -200.0
    var framePos0: CGFloat = -200.0
    var slidePos: CGFloat = 0.0
    var slidePos0: CGFloat = 0.0
    var cursorPos: CGFloat = 104.0
    var cursorPos0: CGFloat = 104.0
    var isFlipped: Bool = false
    var isFlippedTemp: Bool = false
    var flipAngle: CGFloat = 0.0
    var shouldFlip: Bool = false
    var isLocked: Bool = false
    var timesPlaced: Int = 0
    var velocity: CGFloat = 0
    var physicsEnabled: Bool = true
}


struct SlideRuleView: View {
    @State var isFlipped: Bool = false
    
    @State var posDat: PosDat = PosDat()
    @State var zoomLevel: CGFloat = 1.0
    @State var lastZoomLevel: CGFloat = 1.0
    @State var zoomAnchor: CGPoint = .zero
    @State var isZooming: Bool = false
    
    @State var startX: CGFloat = 0
    @State var startY: CGFloat = 0
    
    var body: some View {
        NavigationView{
            ZStack{
                RulerView(posDat: $posDat)
                    
                    .offset(x:-zoomAnchor.x, y:-zoomAnchor.y)
                    .scaleEffect(zoomLevel, anchor: .topLeading)
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
                                
                                let start = value.startLocation
                                if(!isZooming){
                                    startX = (start.x-zoomAnchor.x)/zoomLevel+zoomAnchor.x
                                    startY = (start.y-zoomAnchor.y)/zoomLevel+zoomAnchor.y
                                }
                                
                                let fac = 1.0/(zoomLevel*zoomLevel)
                                
                                let x = (startX-zoomAnchor.x)*fac+zoomAnchor.x
                                let y = (startY-zoomAnchor.y)*fac+zoomAnchor.y
                                zoomAnchor = CGPoint(x:x, y:y)
                                //print(zoomAnchor.x)
                                
                                zoomLevel = newScale
                                isZooming = true
                            }.onEnded { value in
                                isZooming = false
                                posDat.isLocked = false
                                self.lastZoomLevel = 1.0
                            }
                    )
                    .offset(x:-(zoomAnchor.x-1600/2)*(zoomLevel-1)/3, y:-(zoomAnchor.y-202/2)*(zoomLevel-1)/3)
                    .scaleEffect(1.4, anchor:.center) //make bigger
                    .frame(width:100,height:100) //avoid making whole screen wonky
                
                HStack{
//                    LeftSlideLabelView(scales: posDat.isFlippedTemp ? ScaleLists.slideScalesBack : ScaleLists.slideScalesFront, minIndex: 0, maxIndex: 10)
//                        .border(.red)
//                        .frame(width: 80, height:240)
//                        .border(.blue)
//                        .offset(x:0, y:-zoomAnchor.y)
//                        .scaleEffect(zoomLevel, anchor: .topLeading)
//                        .offset(x:0, y:zoomAnchor.y)
//                        .offset(y:-(zoomAnchor.y-202/2)*(zoomLevel-1)/3)
//                        .background(.gray)
//                        //.offset(x:0, y:-(zoomAnchor.y-202/2)*(zoomLevel-1)/3)
//                        .scaleEffect(1.4, anchor: .leading)
//                        .border(.green)
                    Spacer()
                    Color(.gray.opacity(1))
                        //.ignoresSafeArea()
                        .frame(width:50)
                        .overlay{
                            VStack{
                                Button{
                                    posDat.shouldFlip = true
                                } label:{
                                    Image(systemName:"arrow.clockwise.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.theme.text)
                                        .frame(width:30,height:30)
                                }
                                .frame(width:30)
                                .padding(.top, 10)
                                
                                Spacer()
                                Button{
                                    withAnimation(.snappy(duration: 0.3)){
                                        posDat.cursorPos = -posDat.framePos
                                        posDat.cursorPos0 = posDat.cursorPos
                                    }
                                }label:{
                                    Image("CursorButton")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.theme.text)
                                        .frame(width:30,height:30)
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: SettingsView(), label:{
                                    Image(systemName:"gearshape.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.theme.text)
                                        .frame(width:30,height:30)
                                })
                                .padding(.bottom, 10)
                                
                                NavigationLink(destination: HelpMenuView(), label:{
                                    Image(systemName:"questionmark.square")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.theme.text)
                                        .frame(width:30,height:30)
                                })
                                .padding(.bottom, 10)
                            }
                        }
                }
            }
            .background(Color.theme.background)
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationTitle("Slide Rule")
        .toolbar(.hidden, for:.navigationBar)
        //.ignoresSafeArea(edges: .vertical)
        .onAppear{
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(Color.gray)
            appearance.titleTextAttributes = [
                .foregroundColor : UIColor(Color.white)
            ]
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .accentColor(.white)
    }
}



struct RulerView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var orientationInfo: OrientationInfo
    @Binding var posDat: PosDat
    @State var isFlipping: Bool = false
    
    let flipTime: CGFloat = 1
    
    let motionManager = CMMotionManager()
    
    var body: some View {
        ZStack{
            //            let dir: CGFloat = ((posDat.flipAngle > 0) != (abs(posDat.flipAngle) > 180)) ? -1 : 1
            //            let d2: Bool = abs(posDat.flipAngle) > 80
            
            
            //            Color(Color.theme.rulerBase)
            //                .border(.black)
            //                .frame(width:1600,height:20)
            //                .preciseOffset(x: posDat.framePos+800,y:0)
            //                .rotation3DEffect(Angle(degrees:posDat.flipAngle - 90), axis: (x: 1, y: 0, z: 0), anchorZ:101)
            //                .zIndex(2.0 + (d2 ? 0.1*dir : -1))
            //
            //            Color(Color.theme.rulerBase)
            //                .border(.black)
            //                .frame(width:1600,height:20)
            //                .preciseOffset(x: posDat.framePos+800,y:0)
            //                .rotation3DEffect(Angle(degrees:posDat.flipAngle - 90), axis: (x: 1, y: 0, z: 0), anchorZ:-101)
            //                .zIndex(2.0 + (d2 ? -0.1*dir : -1))
            //
            //            Color(Color.theme.rulerBase)
            //                .border(.black)
            //                .frame(width:1600, height:(202-88)/2)
            //                .preciseOffset(x: posDat.framePos+800,y:44+(202-88)/4)
            //                .rotation3DEffect(Angle(degrees:posDat.flipAngle), axis: (x:1,y:0,z:0), anchorZ:10)
            //                .zIndex(1.1)
            //
            //            Color(Color.theme.rulerBase)
            //                .border(.black)
            //                .frame(width:1600, height:(202-88)/2)
            //                .preciseOffset(x: posDat.framePos+800,y:-44-(202-88)/4)
            //                .rotation3DEffect(Angle(degrees:posDat.flipAngle), axis: (x:1,y:0,z:0), anchorZ:10)
            //                .zIndex(1.1)
            
            Frame(posDat: $posDat)
                .zIndex(2)
                .rotation3DEffect(Angle(degrees:posDat.flipAngle), axis: (x:1,y:0,z:0), anchorZ:0)
                .frame(height:250, alignment: .center)
                .contentShape(.interaction, Rectangle())
                .simultaneousGesture(
                    //flip the ruler
                    DragGesture(minimumDistance: 10)
                        .onChanged{value in
                            if(isFlipping){return}
                            let height = value.translation.height
                            var h = 0.0
                            
                            if(height > 20.0){
                                h = height - 20.0
                            }else if(height < -20.0){
                                h = height + 20.0
                            }
                            posDat.flipAngle = min(45.0,max(-h*0.4,-45.0))
                        }
                        .onEnded{value in
                            
                            if abs(posDat.flipAngle) >= 44.0 {
                                flip(dir: value.translation.height < 0)
                            }else{
                                withAnimation(.spring(dampingFraction: 0.5)){
                                    posDat.flipAngle = 0
                                }
                            }
                        }
                )
                .onChange(of: posDat.shouldFlip){ oldState, newState in
                    if oldState == false && newState{
                        flip(dir: true);
                    }
                }
        }.onAppear{
            motionManager.startAccelerometerUpdates()
            let dt: CGFloat = 0.01
            Timer.scheduledTimer(withTimeInterval: dt, repeats: true){_ in
                if(!posDat.physicsEnabled || !settings.hasPhysics){
                    posDat.velocity = 0
                    return
                }
                
                if let data = motionManager.accelerometerData {
                    //manage if screen is landscale left or right
                    let direction: CGFloat = orientationInfo.orientation == .landscapeLeft ? 1 : -1
                    
                    let g = settings.gravity //gravitational acceleration, in g's
                    let coeff = settings.friction //no units, coefficient of friction
                    
                    var x = data.acceleration.x*direction //top bottom, landscape
                    let y = data.acceleration.y*direction //left right, landscape
                    var z = data.acceleration.z //in out
                    //measured in g's
                    //assume total acceleration = 1 normally
                    //y_g = what the gravity component of y should be
                    var y_g = sqrt(max(0.0, 1.0 - (x*x + z*z)))
                    
                    if(y < 0){
                        y_g = -y_g
                    }
                    
                    //y_f = external force component of y
                    let y_f = y - y_g
                    
                    var sideForce = y_f + y_g * g
                    
                    //print(y_f, y_g, g)
                    
                    //1 g = 386 inches/second^2, and about 20 pixels/inch -> 386*20 pixels/second^2
                    let factor = 386.0 * 20.0
                    
                    //x, y, z now in pixels/sec^2
                    x *= factor
                    sideForce *= factor
                    z *= factor
                    
                    var velocity = posDat.velocity + -sideForce * dt
                    
                    //normal force, all forces except in direction of travel.
                    let normal: CGFloat = sqrt(x*x+z*z) + 10
                    
                    //using acceleration * time = change in velocity
                    //only provie friction to stop, not reverse
                    let friction = min(coeff * normal * dt, abs(velocity))
                    if(velocity > 0){
                        velocity = velocity - friction
                    }else{
                        velocity = velocity + friction
                    }
                    
                    posDat.velocity = velocity
                    posDat.slidePos = posDat.slidePos + velocity*dt
                    posDat.slidePos0 = posDat.slidePos
                    
                }
            }
        }
    }
    
    func flip(dir: Bool) -> Void {
        if(isFlipping){return}
        
        let f = dir ? 1.0 : -1.0
        let t0 = abs(posDat.flipAngle)/90 //portion of first turn time already completed by manual turn
        let t1 = flipTime*0.5*(1-t0) //flip time for first bit
        let t2 = flipTime*0.5 //flip time for second bit
        isFlipping = true
        
        withAnimation(.easeIn(duration: t1)){
            posDat.flipAngle = 90.0*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+t1){
            posDat.isFlippedTemp.toggle()
            posDat.isFlipped = posDat.isFlippedTemp
            posDat.flipAngle += 180*f
        }
        withAnimation(.easeOut(duration: t2).delay(t1)){
            posDat.flipAngle += 90*f
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+t1+t2){
            posDat.flipAngle = 0
            posDat.shouldFlip = false
            isFlipping = false
        }
    }
}

struct CursorView: View {
    @Binding var posDat: PosDat
    
    @State var isDragging = false
    
    var body: some View {
        Image("Cursor")
            .resizable()
            .frame(width:100,height:240)
            .preciseOffset(x:posDat.cursorPos+posDat.framePos)
            .defersSystemGestures(on: .all)
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

struct LeftSlideLabelView: View{
    
    let scales: [RulerScale]
    
    let minIndex: Int
    let maxIndex: Int
    
    let textOffsetX: CGFloat = 0
    let textOffsetY: CGFloat = -101
    
    var body: some View {
        ZStack(alignment:.leading){
            ForEach(minIndex...maxIndex, id: \.self){
                //scaleIndex, scale in
                scaleIndex in
                let scale = scales[scaleIndex]
                let maxMag = 3.0
                
                //Group{
                    Text(scale.name)
                        .font(.system(size: 9*maxMag, weight:.bold))
                        .foregroundStyle(Color.theme.text)
                        //.frame(maxWidth:100,maxHeight:50.0, alignment: .leading)
                        .scaleEffect(1.0/maxMag, anchor:.leading)
                        //.frame(width:40)
                        .offset(x: 0 + textOffsetX, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                    
                    LaTeX(scale.leftLabel)
                        .font(.system(size: 8*maxMag, weight:.bold))
                        .foregroundStyle(Color.theme.text)
                        //.frame(maxWidth:100.0,maxHeight:50.0, alignment: .leading)
                        .scaleEffect(1.0/maxMag, anchor:.leading)
                        .offset(x: 29 + textOffsetX, y: getScaleLabelHeight(scaleIndex) + textOffsetY)
                //}
            }
        }
        
    }
    
    func getScaleLabelHeight(_ index: Int) -> CGFloat{
        let spacing = 18.0
        return spacing*0.5 + spacing*CGFloat(index)
    }
}

struct SlideMarkingView: View{
    
    var width: CGFloat
    var height: CGFloat
    
    let scales: [RulerScale]
    
    let minIndex: Int
    let maxIndex: Int
    
    var body: some View {
        ZStack(alignment: .center){
            //tick marks
            Path {path in
                //scales.enumerated().forEach{scaleIndex, scale in
                (minIndex...maxIndex).forEach{scaleIndex in
                    let scale = scales[scaleIndex]
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
            //ForEach(Array(scales.enumerated()), id: \.offset){
            ForEach(minIndex...maxIndex, id: \.self){
                //scaleIndex, scale in
                scaleIndex in
                let scale = scales[scaleIndex]
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
            return 20
        case 1:
            return 37
        case 2:
            return 57
            
        case 3:
            return 57
        case 4:
            return 75
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
        if(index == 3 || index == 4 || index >= 8){
            return .down
        }
        return .up
    }
}



struct Slide: View {
    @Binding var posDat: PosDat
    
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

struct Frame: View {
    
    @State var isDragging = false
    
    @State var isSummoning: Bool = false
    @State var summonLocation: CGPoint = .zero
    
    @Binding var posDat: PosDat
    
    let radius = 15.0
    
    var body: some View {
        ZStack(){
            Slide(posDat: $posDat)
                

            ZStack{
                RoundedRectangle(cornerRadius:radius)
                    .size(width: 1600, height: 57)
                    .offset(x:0,y:145)
                    .fill(Color.theme.rulerBase)
                    .stroke(.gray, lineWidth: 0.5)
                    .zIndex(1.0)
                
                RoundedRectangle(cornerRadius:radius)
                    .size(width: 1600, height: 57)
                    .fill(Color.theme.rulerBase)
                    .stroke(.gray, lineWidth: 0.5)
                    .zIndex(1.0)
                
                
                Path{path in
                    let r0 = 44.0
                    let cx = -30.0
                    let r = sqrt(r0*r0+cx*cx)
                    let alpha = Double.pi/2.0 + atan(cx/r0)
                    
                    let dh = 57.0
                    
                    let width = 60.0
                    let height = 202.0
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: 0,y: height-dh))
                    path.addArc(
                        center: CGPoint(x:cx, y:height/2),
                        radius: r,
                        startAngle: Angle(radians: alpha),
                        endAngle: Angle(radians: -alpha),
                        clockwise: true
                    )
                    path.closeSubpath()
                    
                    path.move(to: CGPoint(x: 1600-0, y: 0))
                    path.addLine(to: CGPoint(x: 1600-width, y: 0))
                    path.addLine(to: CGPoint(x: 1600-width, y: height))
                    path.addLine(to: CGPoint(x: 1600-0, y: height))
                    path.addLine(to: CGPoint(x: 1600-0,y: height-dh))
                    path.addArc(
                        center: CGPoint(x:1600-cx, y:height/2),
                        radius: r,
                        startAngle: Angle(radians: Double.pi-alpha),
                        endAngle: Angle(radians: Double.pi+alpha),
                        clockwise: false
                    )
                    path.closeSubpath()
                    
                }.fill(
                    //LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue, Color.gray]), startPoint: .top, endPoint: .bottom)
                    Color(#colorLiteral(red: 0.71716851, green: 0.71716851, blue: 0.71716851, alpha: 1))
                )
                .stroke(.gray, lineWidth: 0.5)
                .zIndex(2.0)
                
                //former height = 88
                Group{
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesFront, minIndex: 0, maxIndex:2)
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesFront, minIndex: 8, maxIndex:10)
                }
                    .zIndex(posDat.isFlippedTemp ? 0.5 : 1.5)
                Group{
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesBack, minIndex: 0, maxIndex:2)
                    SlideMarkingView(width:1350, height:202, scales: ScaleLists.slideScalesBack, minIndex: 8, maxIndex:10)
                }
                    .zIndex(posDat.isFlippedTemp ? 1.5 : 0.5)
            }
            .frame(width:1600, height:202)
            .preciseOffset(x: posDat.framePos+800,y:0)
            .defersSystemGestures(on: .all)
            .gesture(
                DragGesture(minimumDistance: 5.0)
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
//            .longPressDetector(duration: 0.3){value in
//                print("onHeld \(value)")
//                isSummoning = true
//                summonLocation = value
//            }onReleased:{value in
//                //print("onReleased")
//                withAnimation(.snappy(duration: 0.3)){
//                    posDat.cursorPos = value.x - posDat.framePos - 800
//                    posDat.cursorPos0 = posDat.cursorPos
//                }
//                isSummoning = false
//                        }
//            .onTouch(limitToBounds: true){location in
//                print("Updated to \(location)")
//            }
//            .gesture(
//                ClickGesture(coordinateSpace: .local)
//                    .onEnded(){location in
//                        print(location)
//                    }
//            )
//            
//            if(isSummoning){
//                PulsingCircleView(beginWidth:30, endWidth:50, color: .theme.text)
//                    .offset(x: 800-summonLocation.x, y: summonLocation.y-101)
//                    
//            }

//            .contentShape(.interaction,
//                Rectangle()
//                .size(width: 1600, height: 57)
//                .offset(x:0,y:145)
//                .union(
//                    Rectangle()
//                        .size(width: 1600, height: 57)
//                )
//            )
            
            
            CursorView(posDat: $posDat)
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
