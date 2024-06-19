//
//  ContentView.swift
//  Slide Rule
//
//  Created by Rowan on 11/21/23.
//

import SwiftUI

let coloredNavAppearance = UINavigationBarAppearance()

struct ContentView: View {
    @State var isActive = false
    @StateObject var settings = Settings()
    @StateObject var orientationInfo = OrientationInfo()
    
    @AppStorage("GRAVITY") var gravity: Double = 1.0
    @AppStorage("FRICTION") var friction: Double = 0.4
    @AppStorage("HAS_PHYSICS") var hasPhysics: Bool = true

    var body: some View {
                ZStack{
                    SlideRuleView()
                        .zIndex(1.0)
                    
                    if(!isActive){
                        Group{
                            Image("SlideRuleLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width:200, height:200)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                            Color(Color.black)
                                .ignoresSafeArea(.all)
        
                        }.zIndex(2.0)
                    }
                }
                .environmentObject(settings)
                .environmentObject(orientationInfo)
                .persistentSystemOverlays(.hidden)
                .onAppear{
                    withAnimation(.easeInOut(duration:1).delay(2)){
                        isActive = true
                    }
                    
                    settings.gravity = gravity
                    settings.friction = friction
                    settings.hasPhysics = hasPhysics
                }
                .onChange(of: settings.gravity){
                    gravity = settings.gravity
                }.onChange(of: settings.friction){
                    friction = settings.friction
                }.onChange(of: settings.hasPhysics){
                    hasPhysics = settings.hasPhysics
                }
    }
}
