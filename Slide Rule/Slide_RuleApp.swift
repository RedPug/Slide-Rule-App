//
//  Slide_RuleApp.swift
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
