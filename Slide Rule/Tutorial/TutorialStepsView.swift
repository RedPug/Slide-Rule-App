//
//  TutorialStepsView.swift
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

import SwiftUI

struct TutorialStepsView: View {
    var operation: Operator
    
    var format: [Substring]
    
    @State var inputs: [CGFloat]
    
    @State var isNav: Bool = false
    
    @State var keyframes: [Keyframe] = []
    
    
    init(operation: Operator){
        self.operation = operation
        
        self.inputs = [CGFloat](repeating:1.0, count: operation.numOperands)
        
        self.format = " \(operation.format)".split(whereSeparator: { $0 == "{" || $0 == "}" })
    }
    
    var body: some View {
        let formatter = NumberFormatter()
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 4
        
        return ZStack{
            Color.background.ignoresSafeArea(.all)
            VStack{
                HStack{
                    ForEach(0 ..< format.count, id: \.self){index in
                        Group{
                            if index % 2 == 1{
                                let char = format[index].first ?? Character("a")
                                
                                let i = char.isASCII ? (Int(char.asciiValue!) - 97) : 0 //start lower case letters at 0
                                
                                
                                TextField("Arg \(i)", value: $inputs[i], formatter: formatter)
                                    .keyboardType(.decimalPad)
                                    .padding(10)
                                    .background(Color.theme.background_dark, in:Capsule())
                                    .foregroundStyle(Color.white)
                                    .frame(width: 100, height: 20)
                                
                                
                            }else{
                                Text(format[index])
                            }
                        }
                    }
                }
                
                
                Button(){
                    isNav = true
                    keyframes = parseEquation("\(inputs.map{"\($0)"}.joined(separator: " ")) \(operation.symbol)")
                }label:{
                    HelpButtonView("Start")
                }
                .navigationDestination(isPresented: $isNav){
                    ZStack{
                        Color.background.ignoresSafeArea(.all)
                        TutorialRulerView(keyframes: keyframes)
                    }
                }
                .padding(10);
            }
        }
    }
}
