//
//  Keyframe.swift
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
//  Created by Rowan on 11/26/24.
//

import Foundation

struct Keyframe{
    let selectionNum: Int?
    let selectionX: CGFloat?
    let selectionNum2: Int?
    let selectionX2: CGFloat?
    let label: String?
    let action: KeyframeActions
    
    init(scaleNum:Int, x:CGFloat, action:KeyframeActions, label:String){
        self.selectionNum = scaleNum
        self.selectionX = x
        self.selectionNum2 = nil
        self.selectionX2 = nil
        self.action = action
        self.label = label
    }
    
    init(scaleNum:Int, x:CGFloat, scaleNum2:Int, x2:CGFloat, action:KeyframeActions, label:String){
        self.selectionNum = scaleNum
        self.selectionX = x
        self.selectionNum2 = scaleNum2
        self.selectionX2 = x2
        self.action = action
        self.label = label
    }
    
    init(scaleNum:Int, x:CGFloat, action:String, label:String){
        self.init(scaleNum:scaleNum, x:x, action:KeyframeActions.from(action), label:label)
    }
    
    init(scaleNum:Int, x:CGFloat, scaleNum2:Int, x2:CGFloat, action:String, label:String){
        self.init(scaleNum:scaleNum, x:x, scaleNum2:scaleNum2, x2:x2, action:KeyframeActions.from(action), label:label)
    }
    
    init(label:String){
        self.selectionNum = nil
        self.selectionX = nil
        self.selectionNum2 = nil
        self.selectionX2 = nil
        self.action = .none
        self.label = label
    }
}

enum KeyframeActions: String, CaseIterable{
    case alignCursor = "cursor"
    case alignIndexLeft = "indexL"
    case alignIndexRight = "indexR"
    case readValue = "read"
    case alignScales = "slideToSlide"
    case none = "none"
    
    static func from(_ action: String) -> KeyframeActions{
        for item in KeyframeActions.allCases {
            if action == item.rawValue {
                return item
            }
        }
        return .none
    }
}
