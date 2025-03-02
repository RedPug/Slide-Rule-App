//
//  RulerLockState.swift
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

struct RulerLockState: OptionSet{
	let rawValue: Int
	
	static let slide = RulerLockState(rawValue: 1<<0)
	static let frame = RulerLockState(rawValue: 1<<1)
	static let cursor = RulerLockState(rawValue: 1<<2)
	static let zoom = RulerLockState(rawValue: 1<<3)
	
	static let none: RulerLockState = []
	static let all: RulerLockState = [.slide, .frame, .cursor, zoom]
	static let motion: RulerLockState = [.slide, .frame, .cursor]
}
