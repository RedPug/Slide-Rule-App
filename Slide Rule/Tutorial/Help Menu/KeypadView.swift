//
//  KeypadView.swift
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

struct KeypadView: View {
	@Binding var value: String
	
	private let formatter: NumberFormatter
	
	init(value: Binding<String>?){
		self._value = value ?? Binding(get:{""},set:{v in return})
		self.formatter = NumberFormatter()
		
		formatter.usesSignificantDigits = true
		formatter.maximumSignificantDigits = 4
	}
	
    var body: some View {
		VStack{
			HStack{
				keyView("7", value: "7")
				keyView("8", value: "8")
				keyView("9", value: "9")
			}
			HStack{
				keyView("4", value: "4")
				keyView("5", value: "5")
				keyView("6", value: "6")
			}
			HStack{
				keyView("1", value: "1")
				keyView("2", value: "2")
				keyView("3", value: "3")
			}
			HStack{
				keyView(".", value: ".")
				keyView("0", value: "0")
				keyView("x", value: "backspace")
			}
		}
		.padding(10)
		.background(Color.theme.background_dark, in:RoundedRectangle(cornerRadius:10))
    }
}

extension KeypadView{
	func keyView(_ text: String, value v: String) -> some View {
		Button{
			var str = value
			if v == "backspace"{
				if str.count > 0 {
					str.removeLast()
				}
			}else if v == "."{
				if !value.contains(/\./){
					str += v
				}
			}else{
				str += v
			}
			
			value = str
		}label:{
			Text(text)
				.frame(width:30,height:30)
				.background(Color.theme.text, in:RoundedRectangle(cornerRadius: 5))
				.foregroundStyle(Color.theme.background_dark)
				
		}
	}
}
