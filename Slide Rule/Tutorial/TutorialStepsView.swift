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
    private var operation: Operator
    
    private var format: [Substring]
    
    @State private var inputs: [String]
    
    @State private var isNav: Bool = false
    
    @State private var keyframes: [Keyframe] = []
	
	@State private var focusIndex: Int = -1
	
	@State private var isErrorDisplayed: Bool = false
    
    
    init(operation: Operator){
        self.operation = operation
        
        self.inputs = [String](repeating:"1.0", count: operation.numOperands)
        
        self.format = " \(operation.format)".split(whereSeparator: { $0 == "{" || $0 == "}" })
        

    }
    
    var body: some View {
        
        
        return ZStack{
            Color.background.ignoresSafeArea(.all)
				.onTapGesture{
					focusIndex = -1
				}
			VStack{
				HStack{
					VStack{
						Text("Enter the equation parameters:")
							.bold()
							.foregroundStyle(Color.theme.text)
						
						
						argsView
						
						
						Button(){
							focusIndex = -1
							
							let result = try? parseEquation("\(inputs.map{"\($0)"}.joined(separator: " ")) \(operation.symbol)")
							
							if let result = result {
								keyframes = result
								isNav = true
							}
						}label:{
							HelpButtonView("Start")
						}
						.navigationDestination(isPresented: $isNav){
							ZStack{
								Color.background.ignoresSafeArea(.all)
								TutorialRulerView(keyframes: keyframes)
							}
						}
					}
					
					KeypadView(value: focusIndex >= 0 ? $inputs[focusIndex]: nil)
				}
				
				if isErrorDisplayed {
					Text("There is an error in one or more inputs!")
				}
			}
        }
		.onChange(of:focusIndex){
			isErrorDisplayed = !validateInputs()
		}
    }
}

extension TutorialStepsView{
	var argsView: some View {
		HStack{
			ForEach(0 ..< format.count, id: \.self){index in
				Group{
					if index % 2 == 1{
						let char = format[index].first ?? Character("a")
						
						//argument index. a -> 0, b -> 1, etc.
						let i = char.isASCII ? (Int(char.asciiValue!) - 97) : 0
						
						let focusBinding: Binding<Bool> = Binding(
							get: {
								return i == focusIndex
							},
							set: {state in
								if state {
									focusIndex = i
								}else{
									focusIndex = -1
								}
							}
						)
						
						NumberInputView(value: $inputs[i], isFocused: focusBinding)
							.background(Color.theme.background_dark, in:Capsule())
							.foregroundStyle(Color.white)
						
					}else{
						Text(format[index])
							.foregroundStyle(Color.theme.text)
							.font(.system(size:30, weight:.bold))
					}
				}
			}
		}
	}
}


extension TutorialStepsView{
	private func validateInputs() -> Bool{
		for input in inputs{
			if let n = Double(input) {
				if !operation.isValidInput(CGFloat(n)){
					return false
				}
			}else{
				return false
			}
		}
		return true
	}
}
