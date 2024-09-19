//
//  GuidesTipView.swift
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
