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
                    VStack{
                        NavigationLink(destination: HelpBodyView(instruction: Instruction(title:"Controls",
                          body: """
To slide: Drag the cursor, slide, or body left to right.
To flip:  Drag on the cursor, slide, or body up or down, or press the circular arrow button.
To zoom:  Pinch to zoom in anywhere.

"""
                            )), label:{
                            HelpButtonView(string:"Controls")
                        })
                        .navigationTitle("Guides")
                        
                        NavigationLink(destination: HelpBodyView(instruction: Instruction(title:"General",
                          body: """
    The Slide Rule (also referred to as the Slipstick) is an analog calculator popular in the 1950s and 60s. These devices have lost popularity due to digital calculaters coming along and ruining the fun with "speed" and "accuracy", but you don't want that. Instead, you can brag about having a Slide Rule to all of your friends.

    A general rule to know is that decimal places have to be kept in your head.
    For example, the C and D scales only range between 1 and 10, so any multiplication is limited to numbers between 1 and 10.
    However, because of the distributive property of multiplication, you can multiply by a constant offset, such as a power of 10, which effectively re-writes numbers in scientific notation.
    For example, 102 = 1.02 * 100, so 102 * 5 = 100 * 1.02 * 5, or 100 * (1.02 * 5) which can be calculated.

    In most cases, a scale will either provide decimal places (for example, the LL scales)
    Or, the left and right ends of the scale will specify the value at the respective side, which can be used to infer the values between.
    For example, the S scale specifies a range between 0.1x and 1.0x to indicate that the left side (5.74 degrees on the S scale) produces 0.1 on the D scale, and the right side (90 degrees on the S scale) produces 1 on the D scale. In this context, "0.1x" refers to "0.1 times the value on the D scale".

    When dealing with the scale indices (the ends such as 1 or 10 on the C or D scale), keep in mind that you can use either end for an operation, but only one will typically provide enough space.
    If you find that you need to multiply 5 by 3, putting the left index of the C scale on 5 means that 3 is too far. Instead, put the right index of the C scale on 5 and then go to 3 on the C scale to see 1.5, or 15 because moving the scale back essentially divided by 10.

    Any operation can be reversed from that found in a guide. Simply reverse the steps to undo an operation.

    There are often many ways to calculate an expression, and these guides cannot cover them all.
"""
                            )), label:{
                            HelpButtonView(string:"General")
                        })
                        .navigationTitle("Guides")
                    }
                    Spacer()
                }.padding(.top,20)
                Spacer()
            }
            .padding(.leading, 10)
            HelpListView()
                
        }
        .onAppear(){
            print("opened guides! Count = \(GuidesTip.openedGuides.donations.count), opens = \(GuidesTip.openedApp.donations.count)")
            Task{await GuidesTip.openedGuides.donate()}
            
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
            Color.background.ignoresSafeArea(.all)
            VStack{
                ScrollView{
                    HStack{
                        LaTeX(instruction.body)
                            .lineSpacing(10.0)
                            .foregroundColor(.white)
                            //.imageRenderingMode(.original)
                            .padding(.top,50)
                            .padding(.leading,10)
                        Spacer()
                    }
                    
                }
                Spacer()
                if !instruction.animation.isEmpty {
                    NavigationLink(destination:
                        ZStack{
                            Color.background.ignoresSafeArea(.all)
                            TutorialRulerView(keyframes: instruction.animation)
                        }, label:{
                            Text("Step-by-Step")
                                .frame(width:200,height:30)
                                .background(Color.theme.text)
                                .foregroundColor(.theme.background)
                                .fontWeight(.heavy)
                                .cornerRadius(10)
                        }
                    )
                }
            }
        }
        //.toolbarBackground(.hidden, for: .navigationBar)
        .toolbar{
            ToolbarItem(placement: .principal){
                HStack{
                    LaTeX("Guide: \(instruction.title)")
                        .foregroundColor(.white)
                }
                //.background(.gray)
            }
        }
    }
}

struct HelpButtonView: View {
    var string: String
    
    var body: some View {
        LaTeX(string)
            .latexStyle(PlainLaTeXStyle(fontSize: 18, color: Color.theme.background, weight: Font.Weight.bold))
            .frame(width:100,height:30)
            .background(Color.theme.text)
            .cornerRadius(10)
    }
}


