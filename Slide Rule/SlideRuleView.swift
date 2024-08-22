//
//  SlideRuleView.swift
//  Slide Rule
//
//  Created by Rowan on 1/1/24.
//

import SwiftUI
import LaTeXSwiftUI
//import TipKit
//import CoreMotion
//import SceneKit


struct PosDat: Equatable {
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
    
    let guideTip = GuidesTip()
    
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
                                .padding(.top, 10)
                                
                                Spacer()
                                
                                NavigationLink(destination: HelpMenuView(), label:{
                                    Image(systemName:"book.closed.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.theme.text)
                                        .frame(width:30,height:30)
                                })
                                .padding(.bottom, 10)
                                .popoverTip(guideTip)
                                
//                                NavigationLink(destination: SettingsView(), label:{
//                                    Image(systemName:"gearshape.circle")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .foregroundColor(.theme.text)
//                                        .frame(width:30,height:30)
//                                })
//                                .padding(.bottom, 10)
                                
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
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.gray)
            appearance.titleTextAttributes = [
                .foregroundColor : UIColor(Color.white)
            ]
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().standardAppearance = appearance
            //self.navigationController?.navigationBar.standardAppearance = appearance
            //self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        .accentColor(.white)
    }
}


