//
//  RulerScaleDefinitions.swift
//  Slide Rule
//
//  Created by Rowan on 5/13/24.
//

import SwiftUI

enum TickSize : CGFloat{
    case small = 3.5
    case medium = 6
    case large = 8
    case xlarge = 10
}

enum TextHeight : CGFloat{
    case tall = 13.0
    case short = 11.0
}

enum TickDirection {
    case up
    case down
}

struct MarkingInterval {
    let min : CGFloat //initial value, inclusive only when skipping < 1
    let max : CGFloat //end value, always inclusive
    let spacing : CGFloat //how often to place a tick mark
    var skipping: Int = -1 //skip after this many of ticks are placed. for example, 5 leads to the original first being gone, then 4, then skip, then 4, etc.
    let size : TickSize //small medium large xlarge
}

struct LabelingInterval: Identifiable{
    let min : CGFloat //initial value, inclusive only when skipping < 1
    let max : CGFloat //end value, always inclusive
    let spacing : CGFloat //how often to place a tick mark
    var skipping: Int = -1 //skip after this many of ticks are placed. for example, 5 leads to the original first being gone, then 4, then skip, then 4, etc.
    var textHeight: TextHeight = .tall
    let textGen: (CGFloat) -> (String) // takes in the number found in this interval, outputs a string to label it.
    var id: String { "l\(min)+\(max)+\(spacing)+\(skipping)" } //unique
}

struct RulerScaleData{
    let equation : (CGFloat) -> (CGFloat) //outputs on the interval [0,1], using inputs from the MarkingIntervals provided
    let markingIntervals : [MarkingInterval]
    let labelingIntervals : [LabelingInterval]
    func reversed() -> RulerScaleData{
        return RulerScaleData(
        equation: {x in return 1-equation(x)},
        markingIntervals: markingIntervals,
        labelingIntervals: labelingIntervals
        )
    }
}

struct RulerScale{
    let data: RulerScaleData
    let name: String
    var leftLabel: String = ""
    var rightLabel: String = ""
}

enum ScaleLists{
    static let slideScalesFront : [RulerScale] = [
        RulerScale(data:RulerScales.CF, name:"CF"),
        RulerScale(data:RulerScales.CF.reversed(), name:"CIF"),
        RulerScale(data:RulerScales.L, name:"L"),
        RulerScale(data:RulerScales.C.reversed(), name:"CI"),
        RulerScale(data:RulerScales.C, name:"C"),
    ]
    //"$ \\left[ \\tiny \\begin{array}{l}0 1x \\\\0 1x \\end{array} \\right. $"
    static let slideScalesBack : [RulerScale] = [
        RulerScale(data:RulerScales.CF, name:"B"),
        RulerScale(data:RulerScales.CF.reversed(), name:"T <45°", leftLabel:"$ \\left [ \\begin{array}{l} \\textbf{0 1x} \\\\[-5px] \\textbf{0 1x} \\end{array} \\right. $", rightLabel:""),
        RulerScale(data:RulerScales.CF, name:"T >45°", leftLabel:"$ \\left[ \\begin{array}{l} \\textbf{1.0x} \\\\[-5px] \\textbf{1.0x} \\end{array} \\right. $", rightLabel:""),
        RulerScale(data:RulerScales.CF, name:"ST", leftLabel:"$ \\left[ \\textbf{0.01x} \\right. $", rightLabel:""),
        RulerScale(data:RulerScales.CF, name:"S", leftLabel:"$ \\left[ \\textbf{0.1x} \\right. $", rightLabel:""),
    ]
}

enum RulerScales{
    static let C = RulerScaleData(
        equation: { x in
            return log10(x)
        },
        markingIntervals: [
            MarkingInterval(min: 2.5, max: 10, spacing: 1, size:.xlarge),
            MarkingInterval(min: 1, max: 10, spacing: 1, size:.xlarge),
            MarkingInterval(min: 1.1, max: 1.9, spacing: 0.1, size:.large),
            MarkingInterval(min: 2, max: 9.9, spacing: 0.1, skipping:5, size:.large),
            
            MarkingInterval(min: 1, max: 2, spacing: 0.05, skipping: 2, size:.medium),
            MarkingInterval(min: 1, max: 2, spacing: 0.01, skipping: 5, size:.small),
            
            MarkingInterval(min: 2, max: 4, spacing: 0.02, skipping: 5, size:.small),
            
            MarkingInterval(min: 4.05, max: 10, spacing: 0.1, size:.small)
        ],
        labelingIntervals: [
            LabelingInterval(min: 1, max: 10, spacing: 1){x in return "\(Int(x))".first!.description},
            LabelingInterval(min: 1.1, max: 1.9, spacing: 0.1, textHeight:.short){x in return "\(Int(x*10))"}
        ]
    )
    
    static let L = RulerScaleData(
        equation: { x in
            return x
        },
        markingIntervals: [
            MarkingInterval(min: 0, max: 1, spacing: 0.05, size:.xlarge),
            MarkingInterval(min: 0, max: 1, spacing: 0.01, skipping:5, size:.large),
            MarkingInterval(min: 0, max: 1, spacing: 0.002, skipping:5, size:.small),
        ],
        labelingIntervals: [
            LabelingInterval(min: 0, max: 0, spacing: 0.1, textHeight:.tall){x in return "0"},
            LabelingInterval(min: 0.1, max: 0.9, spacing: 0.1, textHeight:.tall){x in return ".\(Int(x*10))"},
            LabelingInterval(min: 1, max: 1, spacing: 0.1, textHeight:.tall){x in return "1"}
        ]
    )
    
    static let CF = RulerScaleData(
        equation: { x in
            return log10(x) - log10(Double.pi)
        },
        markingIntervals: [
            MarkingInterval(min: Double.pi, max: Double.pi, spacing: 1, size:.xlarge),
            MarkingInterval(min: Double.pi*10, max: Double.pi*10, spacing: 1, size:.xlarge),
            
            MarkingInterval(min: 3.5, max: 10, spacing: 1, size:.xlarge),
            MarkingInterval(min: 4, max: 10, spacing: 1, size:.xlarge),
            
            MarkingInterval(min: 3.2, max: 3.4, spacing: 0.1, size:.large),
            MarkingInterval(min: 3.5, max: 9.9, spacing: 0.1, skipping:5, size:.large),
            
            MarkingInterval(min: 3.16, max: 3.18, spacing: 0.02, size:.small),
            MarkingInterval(min: 3.2, max: 4, spacing: 0.02, skipping: 5, size:.small),
            MarkingInterval(min: 4.05, max: 10, spacing: 0.1, size:.small),
            
            
            MarkingInterval(min: 25, max: 31, spacing: 10, size:.xlarge),
            MarkingInterval(min: 10, max: 31, spacing: 10, size:.xlarge),
            MarkingInterval(min: 11, max: 19, spacing: 1, size:.large),
            MarkingInterval(min: 20, max: 31, spacing: 1, skipping:5, size:.large),
            
            MarkingInterval(min: 10, max: 20, spacing: 0.5, skipping: 2, size:.medium),
            MarkingInterval(min: 10, max: 20, spacing: 0.1, skipping: 5, size:.small),
            
            MarkingInterval(min: 20, max: 31.2, spacing: 0.2, skipping: 5, size:.small),
            
            //MarkingInterval(min: 40.5, max: 31, spacing: 1, size:.small)
        ],
        labelingIntervals: [
            LabelingInterval(min: Double.pi, max: Double.pi, spacing: 1){x in return "π"},
            LabelingInterval(min: Double.pi*10, max: Double.pi*10, spacing: 1){x in return "π"},
            
            LabelingInterval(min: 4, max: 10, spacing: 1){x in return "\(Int(x))".first!.description},
            LabelingInterval(min: 10, max: 31, spacing: 10){x in return "\(Int(x))".first!.description},
            
            LabelingInterval(min: 11, max: 19, spacing: 1, textHeight:.short){x in return "\(Int(x))"}
        ]
    )
}
