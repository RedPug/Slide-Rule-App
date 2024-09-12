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
        ZStack{
            Color.black.ignoresSafeArea()
                .zIndex(0.0)
            
            SlideRuleView()
                .padding(.horizontal, 1)
                .zIndex(1.0)
        }
        .persistentSystemOverlays(.hidden)
            .onAppear{
                Task{await GuidesTip.openedApp.donate()}
            }
    }
}
