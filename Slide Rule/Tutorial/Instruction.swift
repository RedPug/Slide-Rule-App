//
//  Instruction.swift
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
//  Created by Rowan on 12/14/24.
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
    let operation: Operator
    
    init(title: String, body: String, operation: Operator){
        self.title = title
        self.body = body
        self.operation = operation
    }
    
    
    enum CodingKeys: String, CodingKey{
        case title
        case body
        case operation
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try values.decode(String.self, forKey:.title)
        body = try values.decode(String.self, forKey:.body)
        
        let symbol = try values.decode(String.self, forKey:.operation)
        operation = try Operators.fromSymbol(symbol)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey:.title)
        try container.encode(body, forKey:.body)
        try container.encode(operation.symbol, forKey:.operation)
    }
}
