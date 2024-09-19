//
//  PlainLaTeXStyle.swift
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
//  Created by Rowan on 8/5/24.
//

import Foundation
import LaTeXSwiftUI
import SwiftUI


public struct PlainLaTeXStyle: LaTeXStyle {
    let fontSize: CGFloat
    var color: Color = .black
    var weight: Font.Weight = .bold
    
    public func makeBody(content: LaTeX) -> some View {
        content
            .font(.system(size: fontSize, weight: weight))
            .foregroundStyle(color)
    }
}
