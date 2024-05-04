//
//  HelpMenu.swift
//  Slide Rule
//
//  Created by Rowan on 11/22/23.
//

import SwiftUI

struct HelpMenuView: View {
    var body: some View {
        ZStack{
            Color.theme.background.ignoresSafeArea(.all)
            VStack{
                HStack{
                    NavigationLink(destination: HelpBodyView(instruction: Instruction(title:"Controls", 
                        body: "To Slide... Drag the Slide, Frame, or Cursor.\nTo Flip... Swipe up or down on the Frame, or press the Flip Icon.\nTo Summon... Hold down on the Frame where you want the Cursor, then release.\nTo Zoom... Double tap anywhere on the ruler."
                        )), label:{
                        HelpButtonView(string:"Controls")
                    })
                    .navigationTitle("Guides")
                    Spacer()
                }.padding(.top,20)
                Spacer()
            }
            HelpListView()
        }
        
    }
}

struct HelpListView: View {
    private var instructionColumns: [InstructionColumn] = InstructionColumn.allColumns
    
    var body: some View {
        VStack(){
            HStack(spacing:50){
                ForEach(instructionColumns, id:\.header){instructionCol in
                    VStack{
                        ForEach(instructionCol.instructions, id:\.title){ instruction in
                            NavigationLink(destination: HelpBodyView(instruction: instruction), label:{
                                HelpButtonView(string: instruction.title)
                            })
                            .navigationTitle("Guides")
                        }
                        Spacer()
                    }
                }
            }
            .padding(.top,20)
            Spacer()
        }
    }
}

struct HelpBodyView: View {
    var instruction: Instruction
    
    var body: some View {
        ZStack{
            Color.backgroundGreen.ignoresSafeArea(.all)
            ScrollView{
                VStack{
                    HStack{
                        let markedText = try! AttributedString(markdown:instruction.body, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
                        Text(markedText)
                            .lineSpacing(10.0)
                            .foregroundColor(.white)
                        Spacer()
                    }
                        .padding(.top,50)
                        .navigationTitle(instruction.title)
                    Spacer()
                    if !instruction.animation.isEmpty {
                        NavigationLink(destination: AnimatedRulerView(keyframes: instruction.animation),label:{
                            Text("press me")
                        })
                    }
                }
            }
        }
    }
}

struct HelpButtonView: View {
    var string: String
    
    var body: some View {
        Text(string)
            .frame(width:100,height:30)
            .background(Color.theme.text)
            .foregroundColor(.theme.background)
            .fontWeight(.heavy)
            .cornerRadius(10)
    }
}
