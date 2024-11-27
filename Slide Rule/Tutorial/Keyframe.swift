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


struct InstructionColumn: Codable {
    let header: String
    let instructions: [Instruction]
    
    static let allColumns: [InstructionColumn] = Bundle.main.decode(file: "SlideRuleInstructions.json")
}

struct Instruction: Codable {
    let title: String
    let body: String
    var animation: [Keyframe] = []
}

struct Keyframe: Codable{
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
    
    enum CodingKeys: String, CodingKey{
        case selectionNum
        case selectionX
        case selectionNum2
        case selectionX2
        case label
        case action
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        selectionNum = try values.decodeIfPresent(Int.self, forKey:.selectionNum)
        selectionX = try values.decodeIfPresent(CGFloat.self, forKey:.selectionX)
        selectionNum2 = try values.decodeIfPresent(Int.self, forKey:.selectionNum2)
        selectionX2 = try values.decodeIfPresent(CGFloat.self, forKey:.selectionX2)
        
        label = try values.decodeIfPresent(String.self, forKey:.label)
        
        let ac = try values.decode(String.self, forKey:.action)
        action = KeyframeActions.from(ac)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(selectionNum, forKey:.selectionNum)
        try container.encode(selectionX, forKey:.selectionX)
        try container.encode(selectionNum2, forKey:.selectionNum2)
        try container.encode(selectionX2, forKey:.selectionX2)
        
        try container.encode(label, forKey:.label)
        
        try container.encode(action.rawValue, forKey:.action)
    }
}

enum KeyframeActions: String{
    case alignCursor = "cursor"
    case alignIndexLeft = "indexL"
    case alignIndexRight = "indexR"
    case readValue = "read"
    case alignScales = "slideToSlide"
    case none = "none"
    
    static func from(_ action: String) -> KeyframeActions{
        switch action{
        case "cursor":
            return .alignCursor
        case "indexL":
            return .alignIndexLeft
        case "indexR":
            return .alignIndexRight
        case "read":
            return .readValue
        case "slideToSlide":
            return .alignScales
        default:
            return .none
        }
    }
}
