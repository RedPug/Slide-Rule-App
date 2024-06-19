//
//  Slide_RuleApp.swift
//  Slide Rule
//
//  Created by Rowan on 11/21/23.
//

import SwiftUI

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
        }
    }
}
