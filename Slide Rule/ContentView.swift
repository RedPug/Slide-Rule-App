//
//  ContentView.swift
//  Slide Rule
//
//  Created by Rowan on 11/21/23.
//

import SwiftUI

let coloredNavAppearance = UINavigationBarAppearance()

struct ContentView: View {
    @State var isActive = true
    @StateObject var settings = Settings()
    @StateObject var orientationInfo = OrientationInfo()
    
    @AppStorage("GRAVITY") var gravity: Double = 1.0
    @AppStorage("FRICTION") var friction: Double = 0.4
    @AppStorage("HAS_PHYSICS") var hasPhysics: Bool = true

    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
                .zIndex(0.0)
            
            SlideRuleView()
                .padding(.horizontal, 1)
                .zIndex(1.0)
        }
            .environmentObject(settings)
            .environmentObject(orientationInfo)
            .persistentSystemOverlays(.hidden)
            .onAppear{
                //                    withAnimation(.easeInOut(duration:1).delay(2)){
                //                        isActive = true
                //                    }
                Task{await GuidesTip.openedApp.donate()}
                
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
