//
//  Operators.swift
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


enum OperatorError: Error{
    case invalidOperator
}

struct Operator{
    let symbol: String
    let numOperands: Int
    let expression: ([CGFloat])->CGFloat
    let getKeyframes: ([CGFloat]) -> [Keyframe]
}


enum Operators{
    static let allOperators = [times, plus, minus, divide, sin1]
    
    static let times = Operator(symbol: "*", numOperands: 2){args in
        return args[0] * args[1]
    }getKeyframes:{args in
        let a = args[0]
        let b = args[1]
        
        return [
            Keyframe(scaleNum:8, x:a,     action:"cursor",    label:"Calculate $\(a) \\times \(b)$: Place the cursor at $\(a)$ on the D scale"),
            Keyframe(scaleNum:8, x:a,     action:"indexL",    label:"Move the index of the C scale to the cursor"),
            Keyframe(scaleNum:7, x:b,     action:"cursor",    label:"Place the cursor at $\(b)$ on the C scale"),
            Keyframe(scaleNum:8, x:a*b,   action:"read",      label:"Read \(a*b) on the D scale. Move the decimal to get \(a*b)")
        ]
    }
    
    static let plus = Operator(symbol: "+", numOperands: 2){args in
        return args[0] + args[1]
    }getKeyframes:{args in
        return []
    }
    
    static let minus = Operator(symbol: "-", numOperands: 2){args in
        return args[0] - args[1]
    }getKeyframes:{args in
        return []
    }
    
    static let divide = Operator(symbol: "/", numOperands: 2){args in
        return args[0] / args[1]
    }getKeyframes:{args in
        return []
    }
    
    static let sin1 = Operator(symbol: "sin", numOperands: 1){args in
        return CGFloat(sin(args[0]))
    }getKeyframes:{args in
        return []
    }
    
    
    static let doNothing = Operator(symbol:"do nothing", numOperands: 1){args in return args[0]}getKeyframes:{args in return []}
    
    static func getOperator(_ token: String)throws -> Operator{
        for op in Operators.allOperators {
            if op.symbol == token {
                return op
            }
        }
        throw OperatorError.invalidOperator
    }
}
