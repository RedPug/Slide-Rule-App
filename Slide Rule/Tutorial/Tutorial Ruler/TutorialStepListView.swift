//
//  TutorialStepListView.swift
//  Slide Rule
//
//  Created by Rowan on 11/28/24.
//

import SwiftUI
import LaTeXSwiftUI

struct TutorialStepListView: View {
	var title: String
    var instructionNum: Int
    var keyframes: [Keyframe]
    let setInstructionNum: (Int)->Void
	
	let bg = Color.gray
	
	var body: some View {
		VStack{
			Text(title)
				.foregroundStyle(Color.theme.text)
				.padding()
				.background(Color.gray, in:Capsule())
			List(Array(keyframes.enumerated()), id: \.offset){index, keyframe in
				HStack{
					let label = keyframe.label
					let text = "\(label)"
					Button{
						setInstructionNum(index)
					}label:{
						if index == instructionNum{
							Text("Step \(index+1)")
								.foregroundStyle(bg)
								.frame(width:100,height:30)
								.background(Color.theme.text, in:RoundedRectangle(cornerRadius: 10))
						}else{
							Text("Step \(index+1)")
								.foregroundStyle(Color.theme.text)
								.frame(width:100,height:30)
								.overlay(
									RoundedRectangle(cornerRadius: 10)
										.stroke(Color.theme.text, lineWidth: 3)
								)
						}
					}
					
					HStack{
						LaTeX(text)
						Spacer()
					}
					.foregroundStyle(Color.theme.text)
					.padding(5)
				}
				.listRowBackground(bg)
				.listRowSeparatorTint(Color.theme.text)
			}
			.scrollContentBackground(.hidden)
			.padding(.top,-10)
			.mask(
				VStack(spacing: 0) {

					// Top gradient
					LinearGradient(gradient:
					   Gradient(
						   colors: [Color.black.opacity(0), Color.black]),
						   startPoint: .top, endPoint: .bottom
					   )
					   .frame(height: 20)

					// Middle
					Rectangle().fill(Color.black)

					// Bottom gradient
					LinearGradient(gradient:
					   Gradient(
						   colors: [Color.black, Color.black.opacity(0)]),
						   startPoint: .top, endPoint: .bottom
					   )
					   .frame(height: 20)
				}
			 )
//			.background(Color.lightGray, in:RoundedRectangle(cornerRadius:10))
			
		}
	}
}
