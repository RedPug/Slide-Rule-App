//
//  SlideRuleView.swift
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
//  Created by Rowan on 1/1/24.
//

import SwiftUI
import LaTeXSwiftUI



struct SlideRuleView: View {
    @EnvironmentObject var settings: SettingsManager
    
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
                            .frame(width:70, height:240, alignment:.leading)
                            .scaleEffect(1.4, anchor: .leading)
                            .padding(5)
                    }
                    .zIndex(2)
                    .opacity(min(1,max(0, (-250.0-min(posDat.framePos,posDat.slidePos))/50.0)))
                
                RulerView(posDat: $posDat)
                    .offset(x:-zoomAnchor.x, y:-zoomAnchor.y)
                    .scaleEffect(zoomLevel, anchor: .topLeading)
                    .offset(x:zoomAnchor.x, y:zoomAnchor.y)
                    .defersSystemGestures(on: .all)
                    .simultaneousGesture(rulerMagnificationGesture)
                    .simultaneousGesture(rulerMagTapGesture)
                    .offset(x:-(zoomAnchor.x-1600/2)*(zoomLevel-1)/3, y:-(zoomAnchor.y-202/2)*(zoomLevel-1)/3)
                    .scaleEffect(1.4, anchor:.center) //make bigger
                    .frame(width:100,height:100) //avoid making whole screen wonky
                    .frame(maxWidth:.infinity,maxHeight:.infinity) //takes up visible screen area
                
                ButtonBarView
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
        .onChange(of:zoomLevel){
            updateMovementSpeed()
        }
        .onChange(of: settings.slowZoom){
            updateMovementSpeed()
        }
    }
    
    func updateMovementSpeed() -> Void{
        if settings.slowZoom {
            let factor = (zoomLevel-1)*1/2 + 1
            posDat.movementSpeed = 1.0/factor
        }else{
            posDat.movementSpeed = 1.0
        }
    }
}


extension SlideRuleView{
    private var rulerMagTapGesture: some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded{value in
                let val = 2.0
                
                let shouldZoomIn = zoomLevel <= 1.1
                
                var newScale = shouldZoomIn ? val : 1.0
                
                newScale = min(3,max(1,newScale))
                
                let start = value.location
                
                let x = start.x
                let y = start.y
                
                if shouldZoomIn{
                    zoomAnchor = CGPoint(x:x, y:y)
                }
                withAnimation(.smooth){
                    zoomLevel = newScale
                }
            }
    }
    
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


extension SlideRuleView{
    
    private var ButtonBarView: some View {
        Color(.gray)
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
                    
                    NavigationLink(destination: MathNotesView(), label:{
                        Image(systemName:"pencil.and.list.clipboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.theme.text)
                            .frame(width:30,height:30)
                    })
                    .padding(.bottom, 10)
                    
                    Spacer()
                    
                    NavigationLink(destination: HelpMenuView(), label:{
                        Image(systemName:"book.closed")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.theme.text)
                            .frame(width:30,height:30)
                            .overlay{
                                Text("?")
                                    .font(.system(size: 18))
                                    .foregroundColor(.theme.text)
                                    .offset(x:1,y:-3)
                            }
                    })
                    .padding(.bottom, 10)
                    .popoverTip(guideTip)
                    
                    NavigationLink(destination: SettingsView(), label:{
                        Image(systemName:"gear")
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
