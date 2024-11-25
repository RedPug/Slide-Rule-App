//
//  PosData.swift
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
//  Created by Rowan on 9/11/24.
//

import Foundation

struct PosData: Equatable {
    var framePos: CGFloat = -200.0
    var framePos0: CGFloat = -200.0
    var slidePos: CGFloat = 0.0
    var slidePos0: CGFloat = 0.0
    var cursorPos: CGFloat = 104.0
    var cursorPos0: CGFloat = 104.0
    
    var isFlipped: Bool = false
    var isFlippedTemp: Bool = false
    var flipAngle: CGFloat = 0.0
    var shouldFlip: Bool = false
    var canDragToFlip: Bool = true
    
    var movementSpeed: CGFloat = 1.0
    
    var isLocked: Bool = false
    
    var isDragging: Bool = false
    var timesPlaced: Int = 0
    
    var velocity: CGFloat = 0
    var physicsEnabled: Bool = true
    
    var zoomLevel: CGFloat = 1.0
    var zoomAnchor: CGPoint = .zero
}
