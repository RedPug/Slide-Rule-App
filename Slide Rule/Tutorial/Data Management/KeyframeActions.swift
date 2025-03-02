//
//  KeyframeActions.swift
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
//  Created by Rowan on 3/2/25.
//

import Foundation

struct KeyframeActions: Equatable{
	static let alignCursor = 	KeyframeActions(text: "cursor", 	[.slide])
	static let alignIndexLeft = KeyframeActions(text: "indexL", 	[.cursor])
	static let alignIndexRight = KeyframeActions(text: "indexR", 	[.cursor])
	static let alignIndexAuto = KeyframeActions(text: "indexAuto", 	[.cursor])
	static let readValue = 		KeyframeActions(text: "read", 		[.slide, .cursor])
	static let alignScales = 	KeyframeActions(text: "slideToSlide",[])
	static let answer = 		KeyframeActions(text: "answer", 	[])
	static let none = 			KeyframeActions(text: "none", 		[])
	
	static let allCases: [KeyframeActions] = [
		.alignCursor, .alignIndexLeft, .alignIndexRight, .alignIndexAuto, .readValue, .alignScales, .answer, .none]
	
	static func from(_ action: String) -> KeyframeActions{
		for item in KeyframeActions.allCases {
			if action == item.text {
				return item
			}
		}
		return .none
	}
	
	private let text: String
	private let lockState: RulerLockState
	
	private init(text: String, _ lockState: RulerLockState = []){
		self.text = text
		self.lockState = lockState
	}
	
	public func getLockState() -> RulerLockState {
		return lockState
	}
	
	static func == (lhs: KeyframeActions, rhs: KeyframeActions) -> Bool {
		return lhs.text == rhs.text
	}
}
