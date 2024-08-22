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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                }
                .onDisappear {
                    UIDevice.current.endGeneratingDeviceOrientationNotifications()
                }
                .task{
                    //try? Tips.resetDatastore()
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
    }
}
