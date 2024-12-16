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


/// Evaluates the given expression and gives a list of instructions for the user to complete
/// - Parameter text: Space-seperated tokens for operations and numbers, written in post-fix notation
/// - Returns: An array of keyframes which guide the user to evaluate the expression on the ruler.
func parseEquation(_ text: String) throws -> [Keyframe]{
    let phrases: [String] = text.components(separatedBy: " ")
    
    //a token is a single operator or number
    let tokens: [EquationToken] = phrases.map{token in return EquationToken(token)}
    
    //stores the current list of items. Numbers are added directly
    //operators apply to numbers at the top of the stack
    var stack: [CGFloat] = []
    var keyframes: [Keyframe] = []
    
    
    for token in tokens{
        if token.isNumeric{
            stack.append(token.numericValue!)
        }else if let op = token.operation{
            let n = op.numOperands
            if n <= stack.count && n > 0{
                let args = Array(stack.suffix(n))
                
                stack.removeLast(n)
                
				let result = try op.evaluate(args)
                
                stack.append(result)
                
                keyframes.append(contentsOf: try op.getKeyframes(args))
            }
        }
    }
    
//    print("Expression evaluated to: \(stack[0])")
    
    return keyframes
}
