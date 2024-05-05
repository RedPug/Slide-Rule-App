//
//  HelpMenu.swift
//  Slide Rule
//
//  Created by Rowan on 11/22/23.
//

import SwiftUI

import Foundation
import LaTeXSwiftUI
//import SwiftMath

struct HelpMenuView: View {
    var body: some View {
        ZStack{
            Color.theme.background.ignoresSafeArea(.all)
            VStack{
                    
                
                HStack{
                    NavigationLink(destination: HelpBodyView(instruction: Instruction(title:"Controls", 
                        body: "$\\begin{array}{ll}\\text{To Slide:} & \\text{Drag the Slide, Frame, or Cursor.} \\\\ \\text{To Flip:} & \\text{Swipe up or down on the Frame, or press the Flip Icon.} \\\\ \\text{To Summon:} & \\text{Hold down on the Frame where you want the Cursor, then release.} \\\\ \\text{To Zoom:} & \\text{Press the Magnifying Glass icon to toggle the zoom bubble} \\\\ \\end{array}$"
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
                            NavigationLink(
                                destination: HelpBodyView(instruction: instruction),
                                label:{
                                HelpButtonView(string: instruction.title)
                                }
                            )
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
            VStack{
                ScrollView{
                    HStack{
                        LaTeX(instruction.body)
                            .lineSpacing(10.0)
                            .foregroundColor(.white)
                            //.imageRenderingMode(.original)
                            .padding(.top,50)
                        Spacer()
                    }
                    
                }
                Spacer()
                if !instruction.animation.isEmpty {
                    NavigationLink(destination: ZStack{Color.backgroundGreen.ignoresSafeArea(.all); TutorialRulerView(keyframes: instruction.animation)}, label:{
                        Text("Step-by-Step")
                            .frame(width:200,height:30)
                            .background(Color.theme.text)
                            .foregroundColor(.theme.background)
                            .fontWeight(.heavy)
                            .cornerRadius(10)
                    })
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                HStack{
                    LaTeX("Guide: \(instruction.title)")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct HelpButtonView: View {
    var string: String
    
    var body: some View {
        LaTeX(string)
            .font(.system(size:18, weight:.bold))
            .frame(width:100,height:30)
            .background(Color.theme.text)
            .foregroundColor(.theme.background)
            .cornerRadius(10)
    }
}


