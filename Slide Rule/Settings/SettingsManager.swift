//
//  SettingsManager.swift
//  Slide Rule
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
