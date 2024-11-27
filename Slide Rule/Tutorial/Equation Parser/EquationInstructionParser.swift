//
//  EquationInstructionParser.swift
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


func parseEquation(_ text: String) -> [Keyframe]{
    let phrases: [String] = text.components(separatedBy: " ")
    
    let tokens: [EquationToken] = phrases.map{token in return EquationToken(token)}
    
    var stack: [CGFloat] = []
    var keyframes: [Keyframe] = []
    
    for token in tokens{
        if token.isNumeric{
            stack.append(token.numericValue!)
        }else if let op = token.operation{
            let n = op.numOperands
            let args = Array(stack.suffix(op.numOperands))
            
            stack.removeLast(n)
            
            let result = op.expression(args)
            
            stack.append(result)
            
            keyframes.append(contentsOf: op.getKeyframes(args))
        }
    }
    
    return keyframes
}
