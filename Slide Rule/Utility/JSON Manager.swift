//
//  JSON Manager.swift
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
//  Created by Rowan on 11/22/23.
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
    var animation: [Keyframe] = []
}

struct Keyframe: Codable{
    let t: CGFloat?
    let frame: CGFloat?
    let slide: CGFloat?
    let cursor: CGFloat?
    let selectionNum: Int?
    let selectionX: CGFloat?
    let selectionNum2: Int?
    let selectionX2: CGFloat?
    let label: String?
    let action: String?
}

extension Bundle {
    func decode<T: Decodable>(file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Could not find \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedData = try? decoder.decode(T.self, from: data) else {
            fatalError("Could not decode \(file) from bundle.")
        }
        
        return loadedData
    }
}
