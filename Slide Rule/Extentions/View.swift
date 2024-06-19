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
    
    
    /// Used to detect when the view is pressed and held for a certain time, and then released.
    /// - Parameters:
    ///   - duration: Amount of time, in seconds, to wait until onHeld can be triggered
    ///   - onHeld: This is run every time the position of the press changes, after the initial duration has passed. Recieves a CGPoint location of the press.
    ///   - onReleased: Run one time when the view is no longer pressed. Recieves a CGPoint location of the press.
//    public func longPressDetector(duration: CGFloat, onHeld: @escaping (CGPoint)->(), onReleased: @escaping (CGPoint)->()) -> some View{
//        modifier(LongPressDetector(duration:duration, onHeld:onHeld, onReleased: onReleased))
//    }
}

//struct LongPressDetector: ViewModifier{
//    var duration: CGFloat
//    var onHeld: (CGPoint)->()
//    var onReleased: (CGPoint)->()
//    
//    @State var isHeld: Bool = false
//    
//    func body(content: Content) -> some View {
//        content.gesture(
//            LongPressGesture(minimumDuration: duration).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
//                .onChanged{value in
//                    switch value {
//                    case .second(true, let drag?):
//                        let longPressLocation = drag.location
//                        //if(!isHeld){
//                            onHeld(longPressLocation)
//                        //}
//                        //print("met hold time")
//                        isHeld = true
//                    default:
//                        break
//                        //print("initiated")
//                    }
//                }
//                .onEnded{ value in
//                    //print("ended!")
//                    switch value {
//                    case .second(true, let drag):
//                        let longPressLocation = drag?.location ?? .zero
//                        //print(longPressLocation.x, longPressLocation.y)
//                        isHeld = false
//                        onReleased(longPressLocation)
//                    default:
//                        break
//                    }
//                }
//        )
//    }
//}

//struct LongPressDetector: ViewModifier{
//    var duration: CGFloat
//    var onHeld: (CGPoint)->()
//    var onReleased: (CGPoint)->()
//    
//    @State var isHeld: Bool = false
//    
//    func body(content: Content) -> some View {
//        content.simultaneousGesture(
//            LongPressGesture(minimumDuration: 0.3).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
//                .onChanged{value in
//                    switch value {
//                    case .first(true):
//                        print("1 change")
//                    case .second(true, let drag?):
//                        let longPressLocation = drag.location
//                        print("2 change: \(longPressLocation)")
//                        onHeld(longPressLocation)
//                    default:
//                        break
//                    }
//                }
//                .onEnded{ value in
//                    switch value {
//                    case .second(true, let drag):
//                        
//                        let longPressLocation = drag?.location ?? .zero
//                        print("case 2 \(longPressLocation)")
//                        onReleased(longPressLocation)
//                    case .first(true):
//                        print("case 1")
//                    default:
//                        break
//                    }
//                }
//        )
//
//    }
//}
