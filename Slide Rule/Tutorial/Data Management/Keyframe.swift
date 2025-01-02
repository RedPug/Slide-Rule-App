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
    let scaleIndex: Int?
    let scaleValue: CGFloat?
    let scaleIndex2: Int?
    let scaleValue2: CGFloat?
	let description: String?
    var label: String
    let action: KeyframeActions
    
	init(scaleNum:Int, x:CGFloat, action:KeyframeActions, label:String? = nil, description:String? = nil){
		self.scaleIndex = scaleNum
		self.scaleValue = x
		self.scaleIndex2 = nil
		self.scaleValue2 = nil
		self.description = description
		
		if action == .alignIndexAuto {
			let fac1 = RulerScales.getFactorAlongScale(scaleNum: scaleNum, value: x) //where the cursor is
			
			//cover the most area possible
			if fac1 < 0.5{ //needs to cover area to the right
				self.action = .alignIndexLeft
			}else{			//needs to cover area to the left
				self.action = .alignIndexRight
			}
		}else{
			self.action = action
		}
		
		self.label = ""
		self.label = (label ?? generateLabel())
	}
    
    init(scaleNum:Int, x:CGFloat, scaleNum2:Int, x2:CGFloat, action:KeyframeActions, label:String? = nil, description:String? = nil){
        self.scaleIndex = scaleNum
        self.scaleValue = x
        self.scaleIndex2 = scaleNum2
        self.scaleValue2 = x2
		self.description = description
		
		if action == .alignIndexAuto {
			let fac1 = RulerScales.getFactorAlongScale(scaleNum: scaleNum, value: x) //where the cursor is
			let fac2 = RulerScales.getFactorAlongScale(scaleNum: scaleNum2, value: x2) //where the cursor will end up needing to be, on the scale
			
			if fac1 + fac2 < 1 { //needs to cover area to the right
				self.action = .alignIndexLeft
			}else{			//needs to cover area to the left
				self.action = .alignIndexRight
			}
		}else{
			self.action = action
		}
		
        self.label = ""
		self.label = (label ?? generateLabel())
    }
    
    init(label:String, description:String? = nil){
        self.scaleIndex = nil
        self.scaleValue = nil
        self.scaleIndex2 = nil
        self.scaleValue2 = nil
		self.description = description
        self.action = .none
        self.label = label
    }
	
	private func generateLabel() -> String {
		let scaleName = 	RulerScales.getScaleName(index: scaleIndex ?? -1) ?? "null"
		let scaleName2 =	RulerScales.getScaleName(index: scaleIndex2 ?? -1) ?? "null"
		
		switch action {
		case .alignCursor:
			return "Place the cursor at $\(format(scaleValue!))$ on the \(scaleName) scale"
		case .alignIndexLeft:
			return "Move the left index of the C scale (1) to the cursor"
		case .alignIndexRight:
			return "Move the right index of the C scale (10) to the cursor"
		case .readValue:
			return "Read \(format(scaleValue!)) on the \(scaleName) scale"
		case .alignScales:
			return "Align $\(format(scaleValue!))$ on the \(scaleName) scale with $\(format(scaleValue2!))$ on the \(scaleName2) scale"
		default:
			return "Error Computing Label!"
		}
	}
	
	private func format(_ number: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.usesSignificantDigits = true
		formatter.minimumSignificantDigits = 4
		formatter.maximumSignificantDigits = 4
		
		if let formattedString = formatter.string(from: NSNumber(value: number)) {
			return formattedString
		}
		return "\(number)"
	}
}

enum KeyframeActions: String, CaseIterable{
    case alignCursor = "cursor"
    case alignIndexLeft = "indexL"
    case alignIndexRight = "indexR"
	case alignIndexAuto = "indexAuto"
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
