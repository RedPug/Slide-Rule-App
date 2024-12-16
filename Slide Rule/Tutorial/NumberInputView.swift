//
//  NumberInputView.swift
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
//  Created by Rowan on 12/15/24.
//

import SwiftUI

struct NumberInputView: View {
    
    @Binding var value: String
	@Binding var isFocused: Bool
	
	@State private var hasTypingBar: Bool = false
	
	@State private var dispatch: DispatchWorkItem?
	
	
	init(value: Binding<String>, isFocused: Binding<Bool>){
		self._value = value
		self._isFocused = isFocused
	}
    
    var body: some View {
		Button{
			isFocused.toggle()
		}label:{
			HStack(spacing:0){
				Text(value)
				Text(hasTypingBar ? "|" : " ")
				Spacer()
			}
			.padding(10)
			.frame(width: 100, alignment: .leading)
		}
		.onChange(of:isFocused){
			if isFocused {
				startTicking()
				hasTypingBar = true
			}else{
				hasTypingBar = false
				dispatch?.cancel()
			}
		}
    }
	
	func startTicking(){
		if !isFocused {return}
		
		let task = DispatchWorkItem{
			hasTypingBar.toggle()
			startTicking()
		}
		dispatch = task
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
	}
}
