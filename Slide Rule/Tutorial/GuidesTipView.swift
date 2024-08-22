//
//  GuidesTipView.swift
//  Slide Rule
//
//  Created by Rowan on 8/21/24.
//

import Foundation
import TipKit

struct GuidesTip: Tip {
    static let openedGuides = Event(id:"opened-guides")
    static let openedApp = Event(id:"opened-app")
    
    var title: Text {
        Text("Check out Guides!")
    }
    var message: Text? {
        Text("Guides can help you learn operations on the slide rule!")
    }
    
    var rules: [Rule] {
        #Rule(Self.openedGuides){event in
            //event.donations.count == 0
            event.donations.count == 0
        }
//        #Rule(Self.openedApp){event in
//            //print("count = \(event.donations.count)")
//            event.donations.count > 2
//        }
    }
    
    var options: [any Option]{
        MaxDisplayCount(5)
    }
}
