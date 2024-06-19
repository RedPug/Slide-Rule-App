//
//  SettingsView.swift
//  Slide Rule
//
//  Created by Rowan on 6/5/24.
//

import SwiftUI
import Observation

class Settings: ObservableObject{
    @Published var gravity: CGFloat = 1.0
    @Published var friction: CGFloat = 0.4
    @Published var hasPhysics: Bool = true
}

struct SettingsView: View {
    
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        HStack{
            VStack{
                Toggle("Apply Forces", isOn: $settings.hasPhysics)
                    .frame(width:200)

                if(settings.hasPhysics){
                    Text("Gravity Strength")
                    Slider(value: $settings.gravity, in:0...1){
                        Text("Gravity")
                    } minimumValueLabel:{
                        Text("0")
                    } maximumValueLabel:{
                        Text("1")
                    }
                    .frame(width:200)
                    
                    Text("Friction Strength")
                    Slider(value: $settings.friction, in:0...1){
                        Text("Friction")
                    } minimumValueLabel:{
                        Text("0")
                    } maximumValueLabel:{
                        Text("1")
                    }
                    .frame(width:200)
                }

                
                Spacer()
            }
            Spacer()
        }
        .background(Color.theme.background)
    }
}
