//
//  PlainLaTeXStyle.swift
//  Slide Rule
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
