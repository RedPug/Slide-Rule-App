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



struct SlideRuleView: View {
    @State var isFlipped: Bool = false
    
    @State var posDat: PosData = PosData()
    @State var zoomLevel: CGFloat = 1.0
    @State var lastZoomLevel: CGFloat = 1.0
    @State var zoomAnchor: CGPoint = .zero
    @State var isZooming: Bool = false
    
    @State var startX: CGFloat = 0
    @State var startY: CGFloat = 0
    
    let guideTip = GuidesTip()
    
    var body: some View {
        NavigationView{
            HStack{
                
                Color(.gray)
                    .frame(width:45*(1+0.5*(zoomLevel-1))+10)
                    .overlay(alignment:.leading){
                        LeftSlideLabelView(scales: posDat.isFlippedTemp ? ScaleLists.slideScalesBack : ScaleLists.slideScalesFront, minIndex: 0, maxIndex: 10, zoom:zoomLevel, zoomAnchor:zoomAnchor)
                        //.border(.red)
                            .frame(width:70, height:240, alignment:.leading)
                        //.border(.blue)
//                            .offset(y:-zoomAnchor.y)
//                            .scaleEffect(zoomLevel, anchor: .topLeading)
//                            .offset(y:zoomAnchor.y)
//                            .offset(y:-(zoomAnchor.y-202/2)*(zoomLevel-1)/3)
                        
                            .scaleEffect(1.4, anchor: .leading)
                            .padding(5)
                        //.border(.green)
                    }
                    .zIndex(2)
                    .opacity(min(1,max(0, (-250.0-min(posDat.framePos,posDat.slidePos))/50.0)))
                
                RulerView(posDat: $posDat)
                    .offset(x:-zoomAnchor.x, y:-zoomAnchor.y)
                    .scaleEffect(zoomLevel, anchor: .topLeading)
                    .offset(x:zoomAnchor.x, y:zoomAnchor.y)
                    .defersSystemGestures(on: .all)
                    .simultaneousGesture(rulerMagnificationGesture)
                    .offset(x:-(zoomAnchor.x-1600/2)*(zoomLevel-1)/3, y:-(zoomAnchor.y-202/2)*(zoomLevel-1)/3)
                    .scaleEffect(1.4, anchor:.center) //make bigger
                    .frame(width:100,height:100) //avoid making whole screen wonky
                    .frame(maxWidth:.infinity,maxHeight:.infinity) //takes up visible screen area
                
                Color(.gray)
                //.ignoresSafeArea()
                    .frame(width:50)
                    .overlay{
                        VStack{
                            Button{
                                posDat.shouldFlip = true
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
                            
                            NavigationLink(destination: SettingsView(), label:{
                                Image(systemName:"gear.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.theme.text)
                                    .frame(width:30,height:30)
                            })
                            .padding(.bottom, 10)
                            
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


extension SlideRuleView{
    private var rulerMagnificationGesture: some Gesture {
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
    }
}
