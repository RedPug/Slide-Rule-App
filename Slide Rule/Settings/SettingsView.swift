//
//  SettingsView.swift
//  Slide Rule
//
//  Created by Rowan on 6/5/24.
//

import SwiftUI


struct SettingsView: View {
    
    @EnvironmentObject var settings: SettingsManager
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown Build"
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Form{
            Section(header: Text("Interactive Physics")){
                Toggle("Apply Forces", isOn: $settings.hasPhysics)
                
                if(settings.hasPhysics){
                    VStack{
                        Text("Gravity Strength")
                        Slider(value: $settings.gravity, in:0...1){
                            Text("Gravity Strength")
                        } minimumValueLabel:{
                            Text("0")
                        } maximumValueLabel:{
                            Text("1g")
                        }
                        .frame(width:200)
                    }
                    
                    VStack{
                        Text("Friction Coefficient (Static)")
                        Slider(value: $settings.friction, in:0...1){
                            Text("Friction Coefficient (Static)")
                        } minimumValueLabel:{
                            Text("0")
                        } maximumValueLabel:{
                            Text("1")
                        }
                        .frame(width:200)
                    }
                }
            }
            .tint(Color.green)
            .listRowBackground(Color.theme.background_dark)
            .listRowSeparatorTint(Color.theme.background)
            
            Section(header: Text("Support my work")){
                Link("Rate this app or leave a review", destination: URL(string: "https://apps.apple.com/us/app/ultimate-slide-rule/id6636523467?action=write-review")!)
                
                NavigationLink(destination: TipMenuView()){
                    HStack{
                        Text("Love the app? Consider giving a tip")
                        Image(systemName: "dollarsign.circle")
                            .foregroundStyle(.green)
                    }
                }
                
                Link("View this app on GitHub", destination: URL(string: "https://github.com/RedPug/Slide-Rule-App")!)
            }
            .listRowBackground(Color.theme.background_dark)
            .listRowSeparatorTint(Color.theme.background)
            
            Section(header: Text("Contact Me")){
                Link("Email me at slideruledesk@gmail.com", destination: URL(string: "mailto:slideruledesk@gmail.com")!)
                Link("Visit my Linkedin", destination: URL(string: "https://www.linkedin.com/in/rowan-richards/")!)
            }
            .listRowBackground(Color.theme.background_dark)
            .listRowSeparatorTint(Color.theme.background)
            
            Section{
                Text("Version: \(appVersion)(\(buildNumber))")
            }
            .listRowBackground(Color.theme.background_dark)
            .listRowSeparatorTint(Color.theme.background)
            
        }
        
        .foregroundStyle(Color.theme.text)
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(Color.theme.background)
    }
}
