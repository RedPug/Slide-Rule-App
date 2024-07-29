//
//  View.swift
//  Slide Rule
//
//  Created by Rowan on 6/9/24.
//

import SwiftUI

struct PreciseOffset: ViewModifier{
    var x: CGFloat
    var y: CGFloat
    
    func body(content: Content) -> some View {
        let precision: CGFloat = 5
        content
            .scaleEffect(precision)
            .offset(x: x*precision, y: y*precision)
            .scaleEffect(1.0/precision)
    }
}

extension View {
    @inlinable
    public func reverseMask<Mask: View>(alignment: Alignment = .center, @ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
    
    public func preciseOffset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        modifier(PreciseOffset(x:x, y:y))
    }
}

extension View {

    public func scaledFrame(scale: CGFloat, anchor: UnitPoint = .center) -> some View {
        var size: CGSize = .zero
        return self
            .background(
                GeometryReader{geo in
                    Color.clear
                        .onAppear(){
                            size = geo.size
                        }
                }
            )
            .scaleEffect(scale, anchor: anchor)
            .frame(width: size.width * scale,
                   height: size.height * scale)
    }
}
