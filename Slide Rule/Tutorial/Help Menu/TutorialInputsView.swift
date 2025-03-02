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

struct TutorialInputsView: View {
    private var operations: [Operator]
    
    @State private var format: [String]
	
	@State private var selectedOperator: Operator
    
    @State private var inputs: [String]
    
    @State private var isNav: Bool = false
    
    @State private var keyframes: [Keyframe] = []
	
	@State private var focusIndex: Int = 0
	
	@State private var isErrorDisplayed: Bool = false
	
	@Environment(\.dismiss) var dismiss //used for the back button
    
    
    init(operations: [Operator]){
        self.operations = operations
		let selectedOperator = operations[0]
		self.selectedOperator = selectedOperator
        
        self.inputs = [String](repeating:"1.0", count: selectedOperator.numOperands)
        
		self.format = selectedOperator.format
    }
    
    var body: some View {
		
		ZStack{
			TutorialRulerView(keyframes: keyframes, title:"\(selectedOperator.getFormatWithInputs(inputs.map{CGFloat(Double($0) ?? 0)}))")
			
			if !isNav {
				Color.black
					.opacity(0.5)
					.ignoresSafeArea(.all)
				
				
				VStack(alignment:.leading){
					Button{
						dismiss()
					}label:{
						HStack(spacing:0){
							Image(systemName:"chevron.left")
								.resizable()
								.scaledToFit()
								.frame(width:20, height: 20)
								.foregroundStyle(Color.theme.text)
							
							Text("Exit")
								.foregroundStyle(Color.theme.text)
						}
					}
					.offset(x:-10)
					
					HStack{
						VStack{
							Text("Enter the equation parameters:")
								.bold()
								.foregroundStyle(Color.theme.text)
							
							argsView
							
							Button(){
								focusIndex = -1
								
//								let result = try? parseEquation("\(inputs.map{"\($0)"}.joined(separator: " ")) \(selectedOperator.symbol)")
								print("attemping to parse equation")
								let result = try? parseEquation(phrases: inputs + [selectedOperator.symbol])
								
								if let result = result {
									keyframes = result
//									print("setting keyframes with count \(keyframes.count)")
									isNav = true
								}else{
									print("Something went wrong when parsing the equation...")
								}
							}label:{
								Text("start")
									.frame(width:100, height:30)
									.foregroundStyle(.gray)
									.background(Color.theme.text, in:Capsule())
							}
						}
						
						KeypadView(value: focusIndex >= 0 ? $inputs[focusIndex]: nil)
					}
					
					if isErrorDisplayed {
						Text("There is an error in one or more inputs!")
					}
				}
				.padding(.horizontal, 30)
				.padding(.bottom, 30)
				.padding(.top, 20)
				.background(Color.lightGray, in: RoundedRectangle(cornerRadius:10))
				.onTapGesture{
					focusIndex = -1
				}
			}
        }
		.onChange(of:focusIndex){
			isErrorDisplayed = !validateInputs()
		}
    }
}

extension TutorialInputsView{
	var argsView: some View {
		return HStack{
			ForEach(0 ..< format.count, id: \.self){index in
				Group{
					if format[index].hasPrefix("{"){
						let char = format[index].last ?? Character("a")
						
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
						if inputs.indices.contains(i) {
							NumberInputView(value: $inputs[i], isFocused: focusBinding)
								.font(.system(size:30, weight:.bold))
								.padding(5)
								.frame(width: 130, alignment: .leading)
								.background(Color.gray, in:Capsule())
								.foregroundStyle(Color.white)
						}else{
							EmptyView()
								.onAppear{
									print("Error creating NumberInputView because index is out of range.")
								}
						}
					}else if format[index].hasPrefix("$") && operations.count > 1{
						Menu{
							ForEach(operations, id:\.symbol){operation in
								Button{
									selectedOperator = operation
									format = selectedOperator.format
								}label:{
									Text(operation.format[index].dropFirst())
										.foregroundStyle(Color.theme.text)
										.font(.system(size:30, weight:.bold))
								}
									
							}
						}label:{
							HStack{
								Text(format[index].dropFirst())
									.foregroundStyle(Color.theme.text)
									.font(.system(size:30, weight:.bold))
								Text("+")
									.foregroundStyle(Color.lightGray)
									.font(.system(size:30, weight:.bold))
							}
							.padding(5)
							.background(Color.gray, in:Capsule())
						}
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


extension TutorialInputsView{
	private func validateInputs() -> Bool{
		for (index, input) in inputs.enumerated(){
			if let n = Double(input) {
				if !selectedOperator.isValidInput(CGFloat(n), position:index){
					return false
				}
			}else{
				return false
			}
		}
		return true
	}
}
