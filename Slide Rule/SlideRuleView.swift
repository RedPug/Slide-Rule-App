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
    
    @State var posData: PosData = PosData()
    
    @State var sensoryTrigger: Bool = false
    
    let guideTip = GuidesTip()
    
    
    
    var body: some View {
        NavigationStack{
            HStack{
                SideScaleLabelView(posData: $posData)
                
                RulerView(posData: $posData)
                    .zIndex(-1)
                
//                ZoomSliderView($zoomLevel)
                
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
        
        .sensoryFeedback(.impact, trigger:sensoryTrigger)
    }
    
    
}


extension SlideRuleView{
    
}


extension SlideRuleView{
    
    private struct ZoomSliderView: View {
        @Binding var zoomLevel: CGFloat
        
        init(_ zoomLevel: Binding<CGFloat>){
            self._zoomLevel = zoomLevel
        }
        
        var body: some View {
            Slider(value: $zoomLevel, in: 0.5...3)
        }
    }
    
    private var ButtonBarView: some View {
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
                    
//                    NavigationLink(destination: MathNotesView(), label:{
//                        Image(systemName:"pencil.and.list.clipboard")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .foregroundColor(.theme.text)
//                            .frame(width:30,height:30)
//                    })
//                    .padding(.bottom, 10)
//                    
//                    Spacer()
                    
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
