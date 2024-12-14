//
//  TutorialStepListView.swift
//  Slide Rule
//
//  Created by Rowan on 11/28/24.
//

import SwiftUI
import LaTeXSwiftUI

struct TutorialStepListView: View {
    var instructionNum: Int
    var keyframes: [Keyframe]
    let setInstructionNum: (Int)->Void
    
    let bg = Color.theme.background_dark
    
    var body: some View {
        List(Array(keyframes.enumerated()), id: \.offset){index, keyframe in
            HStack{
                let label = keyframe.label ?? ""
                let text = "\(label)"
                if index == instructionNum{
                    Text("Step \(index+1)")
                        .foregroundStyle(bg)
                        .frame(width:100,height:30)
                        .background(Color.theme.text, in:RoundedRectangle(cornerRadius: 10))
                    
                    HStack{
                        LaTeX(text)
                        Spacer()
                    }
                        .foregroundStyle(bg)
                        .padding(5)
                        .background(Color.theme.text, in:RoundedRectangle(cornerRadius: 10))
                }else{
                    Text("Step \(index+1)")
                        .foregroundStyle(Color.theme.text)
                        .frame(width:100,height:30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.theme.text, lineWidth: 3)
                        )
                    HStack{
                        LaTeX(text)
                        Spacer()
                    }
                    .foregroundStyle(Color.theme.text)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.theme.text, lineWidth: 3)
                    )
                }
            }
            .onTapGesture{
                setInstructionNum(index)
            }
            .listRowBackground(bg)
            .listRowSeparatorTint(Color.theme.background)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}
