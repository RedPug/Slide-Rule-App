//
//  PosData.swift
//  Slide Rule
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
    var isLocked: Bool = false
    var timesPlaced: Int = 0
    var velocity: CGFloat = 0
    var physicsEnabled: Bool = true
}
