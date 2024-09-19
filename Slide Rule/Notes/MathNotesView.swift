//
//  MathNotesView.swift
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
//  Created by Rowan on 9/12/24.
//

import SwiftUI
import LaTeXSwiftUI

enum KeyCommandType{
    case typed
    case special
    case command
    case createLine
}

struct KeyCommand: Equatable{
    var text: String
    var commandType: KeyCommandType
    
    init(_ text:String, type: KeyCommandType){
        self.text = text
        self.commandType = type
    }
}



struct MathNotesView: View {
    @AppStorage("Note") private var savedJson: String = "[\"\"]"
    @State private var saveTask: DispatchWorkItem?
    @State private var isUpToDate: Bool = false
    
    @State var json: String = "[\"\"]"
    @State var keyCommand: KeyCommand?
    @State var shouldRefresh: Bool = false
    @State var hasWebviewLoaded: Bool = false
    
    
    var body: some View {
        VStack{
            HStack {
                let webVw = WebView(json:$json, keyCommand:$keyCommand, shouldRefresh: $shouldRefresh, hasLoaded:$hasWebviewLoaded)
                ZStack{
                    webVw
                        //.background(Color.white)
                    
                    if !hasWebviewLoaded{
                        ProgressView("Loading...")
                            .frame(maxWidth:.infinity, maxHeight:.infinity)
                            .background(.gray.opacity(0.5))
                        
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .clipped()
                .padding()
                
                keypad
                    .padding()
            }
            .ignoresSafeArea(edges:.bottom)
        }
        .onChange(of: json) {
            isUpToDate = false
            saveTask?.cancel()
            let task = DispatchWorkItem {
                savedJson = json
                isUpToDate = true
            }
            saveTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: task)
        }
        .onAppear {
            json = savedJson
            isUpToDate = true
            shouldRefresh = true
            
        }
        .background(Color.theme.background)
        .navigationTitle("Notes")
        .toolbar(){
            Text(isUpToDate ? "(saved)":"(not saved)")
        }
        .ignoresSafeArea(edges:.bottom)
        
    }
}

extension MathNotesView{
    func keyButtonView(_ displayText: String, action commandText: String = "", type commandType: KeyCommandType) -> some View {
        keyButtonView(action: commandText, type: commandType){
            LaTeX(displayText)
                .foregroundStyle(Color.theme.background_dark)
        }
    }
    
    func keyButtonView<Content: View>(action commandText: String, type commandType: KeyCommandType, @ViewBuilder content: () -> Content) -> some View {
        Button{
            keyCommand = KeyCommand(commandText, type: commandType)
        }label:{
            RoundedRectangle(cornerRadius: 5)
                .frame(width:30,height:30)
                .background(Color.theme.text)
                .overlay(content: content)
                .clipped()
        }
    }
    
    var keypad: some View {
        VStack(spacing:5){
            Group{
                
                Grid{
                    GridRow{
                        keyButtonView("7", action:"7", type:.typed)
                        keyButtonView("8", action:"8", type:.typed)
                        keyButtonView("9", action:"9", type:.typed)
                        keyButtonView("$\\div$", action:"/", type:.typed)
                    }
                    GridRow{
                        keyButtonView("4", action:"4", type:.typed)
                        keyButtonView("5", action:"5", type:.typed)
                        keyButtonView("6", action:"6", type:.typed)
                        keyButtonView("$\\times$", action:"*", type:.typed)
                    }
                    GridRow{
                        keyButtonView("1", action:"1", type:.typed)
                        keyButtonView("2", action:"2", type:.typed)
                        keyButtonView("3", action:"3", type:.typed)
                        keyButtonView("$-$", action:"-", type:.typed)
                    }
                    GridRow{
                        keyButtonView("del", action:"Backspace", type:.special)
                        keyButtonView("0", action:"0", type:.typed)
                        keyButtonView("$.$", action:".", type:.typed)
                        keyButtonView("$+$", action:"+", type:.typed)
                    }
                }
                
                
                Grid{
                    GridRow{
                        keyButtonView("$a^2$", action:"^2", type:.typed)
                        keyButtonView("$a^b$", action:"^", type:.typed)
                        keyButtonView("$\\sqrt{}$", action:"\\sqrt", type:.command)
                        keyButtonView("$\\sqrt[n]{}$", action:"\\nthroot", type:.command)
                        
                    }
                    GridRow{
                        keyButtonView("|$a$|", action:"|", type:.typed)
                        keyButtonView("$\\pi$", action:"\\pi", type:.command)
                        keyButtonView("(", action:"(", type:.typed)
                        keyButtonView(")", action:")", type:.typed)
                    }
                }
                Grid{
                    GridRow{
                        keyButtonView("←", action:"Left", type:.special)
                        
                        keyButtonView("↑", action:"Up", type:.special)
                        keyButtonView("→", action:"Right", type:.special)
                    }
                    GridRow{
                        keyButtonView("↵", type:.createLine)
                        keyButtonView("↓", action:"Down", type:.special)
                    }
                }
            }
            .padding(5)
            .background(Color.theme.background_dark, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
