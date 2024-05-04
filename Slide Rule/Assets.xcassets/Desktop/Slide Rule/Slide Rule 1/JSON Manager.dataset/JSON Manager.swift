//
//  JSON Manager.swift
//  Slide Rule
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
    let t: CGFloat
    let frame: CGFloat
    let slide: CGFloat
    let cursor: CGFloat
    let selection: CGFloat
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
