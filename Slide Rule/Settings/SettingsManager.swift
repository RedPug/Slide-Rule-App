//
//  SettingsManager.swift
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
//  Created by Rowan on 9/19/24.
//

import SwiftUI
import Observation

class SettingsManager: ObservableObject{
    @Published var gravity: CGFloat = 1.0 {
        didSet{
            UserDefaults.standard.setValue(Float(gravity), forKey: "GRAVITY")
        }
    }
    @Published var friction: CGFloat = 0.4 {
        didSet{
            UserDefaults.standard.setValue(Float(friction), forKey: "FRICTION")
        }
    }
    @Published var hasPhysics: Bool = true {
        didSet{
            UserDefaults.standard.setValue(hasPhysics, forKey: "HAS_PHYSICS")
        }
    }
    
    init(){
        let defaultValues = [
            "GRAVITY":1.0,
            "FRICTION":0.4,
            "HAS_PHYSICS":false
        ] as [String : Any]
        UserDefaults.standard.register(defaults: defaultValues)
        
        self.gravity = CGFloat(UserDefaults.standard.float(forKey: "GRAVITY"))
        self.friction = CGFloat(UserDefaults.standard.float(forKey: "FRICTION"))
        self.hasPhysics = UserDefaults.standard.bool(forKey: "HAS_PHYSICS")
        
        
    }
}
