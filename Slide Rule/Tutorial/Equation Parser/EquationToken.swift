//
//  EquationToken.swift
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


struct EquationToken: CustomStringConvertible{
    var isNumeric: Bool = false
    let numericValue: CGFloat?
    let operation: Operator?
    
    init(_ token: String){
        if let number = Double(token){
            numericValue = CGFloat(number)
            isNumeric = true
            operation = nil
        }else{
            numericValue = nil
            isNumeric = false
            do{
                operation = try Operators.fromSymbol(token)
            }
            catch OperatorError.invalidOperator{
                print("Invalid Operator Input!")
                operation = Operators.none
            }catch{
                print("Unknown error occured")
                operation = Operators.none
            }
            
        }
    }
    
    var description: String {
        if let number = numericValue{
            return "{numericValue: \(number)}"
        }else if let op = operation{
            return "{operation: \(op.symbol)}"
        }
        return "{unknown state. isNumeric: \(isNumeric)}"
    }
}
