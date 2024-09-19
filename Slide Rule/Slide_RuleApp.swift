//
//  Slide_RuleApp.swift
//  Slide Rule
//
//  Created by Rowan on 11/21/23.
//

import SwiftUI
import TipKit

@main
struct Slide_RuleApp: App {
    @StateObject var settings = SettingsManager()
    @StateObject var orientationInfo = OrientationInfo()
    @StateObject var store: TipStore = TipStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                    WebView.preload()
                }
                .onDisappear {
                    UIDevice.current.endGeneratingDeviceOrientationNotifications()
                    WebView.unload()
                }
                .task{
                    //try? Tips.resetDatastore()
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
                .environmentObject(settings)
                .environmentObject(orientationInfo)
                .environmentObject(store)
        }
    }
    
    
}
