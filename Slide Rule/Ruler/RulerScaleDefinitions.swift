//
//  RulerScaleDefinitions.swift
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
//  Created by Rowan on 5/13/24.
//

import SwiftUI

enum TickSize : CGFloat{
    case small = 3.5
    case medium = 6
    case large = 8
    case xlarge = 10
}

struct TextFlags: OptionSet{
    let rawValue: Int
    
    static let short = TextFlags(rawValue: 1 << 0)
    static let large = TextFlags(rawValue: 1 << 1)
    static let italic = TextFlags(rawValue: 1 << 2)
    static let alignLeft = TextFlags(rawValue: 1 << 3)
    static let alignRight = TextFlags(rawValue: 1 << 4)
    static let thin = TextFlags(rawValue: 1 << 5)
    static let small = TextFlags(rawValue:1 << 6)
}

enum TickDirection {
    case up
    case down
}


struct MarkingInterval {
    let ticks: [(x: CGFloat, size: TickSize)]
    
    ///
    /// - Parameters:
    ///   - min: initial value, inclusive only when skipping < 1
    ///   - max: maximum end value. Will terminate early if the spacing doesn't land on the end.
    ///   - spacing: how often to place a tick mark
    ///   - skipping: skip after this many of ticks are placed. Always skips first tick.
    ///   - size: how tall the tick marks in this interval should be
    init(min:CGFloat, max:CGFloat, spacing:CGFloat, skipping:Int = -1, size:TickSize){
        var arr: [(CGFloat, TickSize)] = []
        
        if spacing <= 0{
            arr.append((min, size))
        }else{
            let range = Int(floor((max-min)/spacing + 0.01))
            
            for i in 0...range{
                if(skipping > 0 && i%skipping == 0){continue}
                
                let x = min + CGFloat(i)*spacing
                arr.append((x, size))
            }
        }
        ticks = arr
    }
    
    /// Creates a marking interval starting with ticks of the largest provided size, then being divided progressively.
    /// - Parameters:
    ///   - min: Where to start placing tick marks
    ///   - max: Where to place the last tick mark
    ///   - xlargeDivs: How many regions to create with the xlarge tick size.
    ///   - largeDivs: How many regions to create with the large tick size.
    ///   - mediumDivs: How many regions to create with the medium tick size.
    ///   - smallDivs: How many regions to create with the small tick size.
    ///   - includesStart: If true, there will be one missing tick mark at *min* but will be the same elsewhere.
    init(min:CGFloat, max:CGFloat, xlargeDivs:Int=1, largeDivs:Int=1, mediumDivs:Int=1, smallDivs:Int=1, includesStart:Bool=true, includesEnd:Bool=false){
        var arr: [(CGFloat, TickSize)] = []
        
        let totalTicks = xlargeDivs*largeDivs*mediumDivs*smallDivs
        
        for i in (includesStart ? 0 : 1)...(totalTicks - (includesEnd ? 0 : 1)){
            let size: TickSize
            if i%(largeDivs*mediumDivs*smallDivs) == 0{
                size = .xlarge
            }else if i%(mediumDivs*smallDivs) == 0{
                size = .large
            }else if i%(smallDivs) == 0{
                size = .medium
            }else{
                size = .small
            }
            let t = CGFloat(i)/CGFloat(totalTicks)
            let x = min+t*(max-min)
            arr.append((x, size))
        }
        ticks = arr
    }
    
    init(_ ticks: [(CGFloat, TickSize)]){
        self.ticks = ticks
    }
    
    init(_ x:CGFloat, _ size: TickSize){
        self.ticks = [(x,size)]
    }
}

struct LabelingInterval{
    let labels: [(x:CGFloat, text:String, flags:TextFlags)]
    
    init(min:CGFloat, max:CGFloat, spacing:CGFloat, skipping:Int = -1, flags:TextFlags = [], textGen: (CGFloat)->(String) = {x in return "\(Int(x))"}){
        var arr: [(CGFloat, String, TextFlags)] = []
        
        let diff: CGFloat = max-min
        let dist: CGFloat = diff/spacing
        let range: Int = Int(floor(dist + 0.0001))
        
        for i in 0...range{
            if skipping > 0 && i%skipping == 0{continue}

            let x = min + CGFloat(i)*spacing
            
            arr.append((x,textGen(x), flags))
        }

        labels = arr
    }
    
    init(x:CGFloat, text:String, flags:TextFlags = []){
        labels = [(x,text,flags)]
    }
}

struct RulerScaleData{
    let equation: (CGFloat) -> (CGFloat) //outputs on the interval [0,1], using inputs from the MarkingIntervals provided
    let markingIntervals: [MarkingInterval]
    let labels: [(x:CGFloat, text:String, flags:TextFlags)]
    
    func reversed() -> RulerScaleData{
        return RulerScaleData(
        equation: {x in return 1-equation(x)},
        markingIntervals: markingIntervals,
        labels: labels
        )
    }
    
    init(equation:@escaping (CGFloat)->(CGFloat), markingIntervals: [MarkingInterval], labelingIntervals: [LabelingInterval]){
        self.equation = equation
        self.markingIntervals = markingIntervals
        var arr: [(x:CGFloat,text:String, flags:TextFlags)] = []
        for i in 0..<labelingIntervals.count{
            arr.append(contentsOf: labelingIntervals[i].labels)
        }
        self.labels = arr
    }
    
    init(equation:@escaping (CGFloat)->(CGFloat), markingIntervals: [MarkingInterval], labels: [(CGFloat,String,TextFlags)]){
        self.equation = equation
        self.markingIntervals = markingIntervals
        self.labels = labels
    }
}

struct RulerScale: Equatable{
    let data: RulerScaleData
    let name: String
    var leftLabel: String = ""
    var rightLabel: String = ""
    
    static func == (lhs: RulerScale, rhs: RulerScale) -> Bool {
        return lhs.name == rhs.name
    }
}

enum ScaleLists{
    static let slideScalesFront : [RulerScale] = [
        RulerScale(data:RulerScales.LL02, name:"LL02", leftLabel:"$\\left [ \\begin{array}{l} \\large \\textbf{e}^{\\textbf{-0.1x}}\\end{array} \\right.$", rightLabel: "$\\large \\textbf{e}^{\\textbf{-1.0x}} ]$"),
        RulerScale(data:RulerScales.LL03, name:"LL03", leftLabel:"$\\left [ \\begin{array}{l} \\large \\textbf{e}^{\\textbf{-1.0x}}\\end{array} \\right.$", rightLabel: "$\\large \\textbf{e}^{\\textbf{-10.0x}} ]$"),
        RulerScale(data:RulerScales.CF, name:"DF", rightLabel: "$\\textbf{𝝅x}$"),
        
        RulerScale(data:RulerScales.CF, name:"CF", rightLabel: "$\\textbf{𝝅x}$"),
        RulerScale(data:RulerScales.CF.reversed(), name:"CIF", rightLabel: "$\\frac{\\textbf{1}}{\\textbf{𝝅x}}$"),
        RulerScale(data:RulerScales.L, name:"L", rightLabel: "$\\small \\textbf{LOG x}$"),
        RulerScale(data:RulerScales.C.reversed(), name:"CI", rightLabel: "$\\frac{\\textbf{1}}{\\textbf{x}}$"),
        RulerScale(data:RulerScales.C, name:"C", rightLabel: "$\\textbf{x}$"),
        
        RulerScale(data:RulerScales.C, name:"D", rightLabel: "$\\textbf{x}$"),
        RulerScale(data:RulerScales.LL3, name:"LL3", leftLabel:"$\\left [ \\begin{array}{l} \\large \\textbf{e}^{\\textbf{1.0x}}\\end{array} \\right.$", rightLabel: "$\\large \\textbf{e}^{\\textbf{10.0x}} ]$"),
        RulerScale(data:RulerScales.LL2, name:"LL2", leftLabel:"$\\left [ \\begin{array}{l} \\large \\textbf{e}^{\\textbf{0.1x}}\\end{array} \\right.$", rightLabel: "$\\large \\textbf{e}^{\\textbf{1.0x}} ]$"),
    ]
    //"$ \\left[ \\tiny \\begin{array}{l}0 1x \\\\0 1x \\end{array} \\right. $"
    static let slideScalesBack : [RulerScale] = [
        RulerScale(data:RulerScales.LL01, name:"LL01", leftLabel:"$\\left [ \\begin{array}{l} \\large \\textbf{e}^{\\textbf{-0.01x}}\\end{array} \\right.$", rightLabel: "$\\large \\textbf{e}^{\\textbf{-0.1x}} ]$"),
        RulerScale(data:RulerScales.K, name:"K", rightLabel: "$\\textbf{x}^{\\textbf{3}}$"),
        RulerScale(data:RulerScales.A, name:"A", rightLabel: "$\\textbf{x}^{\\textbf{2}}$"),
        
        RulerScale(data:RulerScales.A, name:"B", rightLabel: "$\\textbf{x}^{\\textbf{2}}$"),
        RulerScale(data:RulerScales.TL, name:"T <45°", leftLabel:"$ \\left [ \\begin{array}{l} \\textbf{0.1x} \\\\[-5px] \\textbf{0.1x} \\end{array} \\right. $", rightLabel:"$\\small \\begin{array}{l} \\textbf{1.0x} \\\\[-5px] \\textbf{1.0x} \\end{array} \\Large ] \\small \\begin{array}{l} \\textbf{TAN} \\\\[-5px] \\textit{c \\;o \\;t} \\end{array}$"),
        RulerScale(data:RulerScales.TG, name:"T >45°", leftLabel:"$ \\left[ \\begin{array}{l} \\textbf{1.0x} \\\\[-5px] \\textbf{1.0x} \\end{array} \\right. $", rightLabel:"$\\small \\begin{array}{l} \\textbf{10.0x} \\\\[-5px] \\textbf{10.0x} \\end{array} \\Large ] \\small \\begin{array}{l} \\textbf{TAN} \\\\[-5px] \\textit{c \\;o \\;t} \\end{array}$"),
        RulerScale(data:RulerScales.ST, name:"ST", leftLabel:"$ \\left[ \\textbf{0.01x} \\right. $",
                   rightLabel:"$\\small\\begin{array}{l} \\textbf{0.1x} \\end{array} \\Large ] \\small \\begin{array}{l} \\textbf{S I N} \\\\[-5px] \\textbf{TAN}\\end{array}$"),
        RulerScale(data:RulerScales.S, name:"S", leftLabel:"$ \\left[ \\textbf{0.1x} \\right. $",
                   rightLabel:"$\\small\\begin{array}{l} \\textbf{1.0x} \\end{array} \\Large ] \\small \\begin{array}{l} \\textbf{S I N} \\\\[-5px] \\textit{c \\;o \\;s}\\end{array}$"),
        
        RulerScale(data:RulerScales.C, name:"D", rightLabel: "$\\textbf{x}$"),
        RulerScale(data:RulerScales.C.reversed(), name:"DI", rightLabel: "$\\frac{\\textbf{1}}{\\textbf{x}}$"),
        RulerScale(data:RulerScales.LL1, name:"LL1", leftLabel:"$\\left [ \\begin{array}{l} \\large \\textbf{e}^{\\textbf{0.01x}}\\end{array} \\right.$", rightLabel: "$\\large \\textbf{e}^{\\textbf{0.1x}} ]$"),
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
            
            MarkingInterval(min: 2, max: 2.7, spacing: 0.02, skipping: 5, size:.small),
            MarkingInterval(2.71828, .xlarge),
            MarkingInterval(2.74, .small),
            MarkingInterval(2.76, .small),
            MarkingInterval(2.78, .small),
            MarkingInterval(min: 2.8, max: 3.1, spacing: 0.02, skipping: 5, size:.small),
            MarkingInterval(3.12, .small),
            MarkingInterval(3.14159, .xlarge),
            MarkingInterval(3.16, .small),
            MarkingInterval(3.18, .small),
            MarkingInterval(min: 3.2, max: 4, spacing: 0.02, skipping: 5, size:.small),
            
            MarkingInterval(min: 4.05, max: 10, spacing: 0.1, size:.small),
            
            
        ],
        labelingIntervals: [
            LabelingInterval(min: 1, max: 10, spacing: 1){x in return "\(Int(x))".first!.description},
            LabelingInterval(min: 1.1, max: 1.9, spacing: 0.1, flags:.short){x in return String(format:"%.1f", x)},
            LabelingInterval(x: 2.71828, text: "e"),
            LabelingInterval(x: 3.14159, text: "π"),
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
            LabelingInterval(min: 0, max: 0, spacing: 0.1){x in return "0"},
            LabelingInterval(min: 0.1, max: 0.9, spacing: 0.1){x in return ".\(Int(x*10))"},
            LabelingInterval(min: 1, max: 1, spacing: 0.1){x in return "1"}
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
        ],
        labelingIntervals: [
            LabelingInterval(x: Double.pi, text:"π"),
            LabelingInterval(x: Double.pi*10, text:"π"),
            
            LabelingInterval(min: 4, max: 10, spacing: 1){x in return "\(Int(x))".first!.description},
            LabelingInterval(min: 10, max: 31, spacing: 10){x in return "\(Int(x))".first!.description},
            
            LabelingInterval(min: 11, max: 19, spacing: 1, flags:.short){x in return "\(Int(x))"}
        ]
    )
    
    static let A = RulerScaleData(
        equation: { x in
            return log10(x)/2
        },
        markingIntervals: [
            MarkingInterval(min: 1.5, max: 5, spacing: 1, size:.xlarge),
            MarkingInterval(min: 1, max: 10, spacing: 1, size:.xlarge),
            MarkingInterval(min: 5.5, max: 10, spacing: 1, size:.medium),
            MarkingInterval(min: 1, max: 5, spacing: 0.1, skipping:5, size:.medium),
            MarkingInterval(min: 1, max: 2, spacing: 0.02, skipping: 5, size:.small),
            MarkingInterval(min: 2.05, max: 5, spacing: 0.1, size:.small),
            MarkingInterval(min: 5, max: 10, spacing: 0.1, skipping:5, size:.small),
            
            MarkingInterval(min: 15, max: 50, spacing: 10, size:.xlarge),
            MarkingInterval(min: 10, max: 100, spacing: 10, size:.xlarge),
            MarkingInterval(min: 55, max: 100, spacing: 10, size:.medium),
            MarkingInterval(min: 10, max: 50, spacing: 1, skipping:5, size:.medium),
            MarkingInterval(min: 10, max: 20, spacing: 0.2, skipping: 5, size:.small),
            MarkingInterval(min: 20.5, max: 50, spacing: 1, size:.small),
            MarkingInterval(min: 50, max: 100, spacing: 1, skipping:5, size:.small),
        ],
        labelingIntervals: [
            LabelingInterval(min: 1, max: 10, spacing: 1){x in return "\(Int(x))"},
            LabelingInterval(min: 10, max: 100, spacing: 10){x in return "\(Int(x))"},
        ]
    )
    
    static let K = RulerScaleData(
        equation: { x in
            return log10(x)/3
        },
        markingIntervals: [
            MarkingInterval(min: 1.5, max: 4, spacing: 1, size:.xlarge),
            MarkingInterval(min: 1, max: 10, spacing: 1, size:.xlarge),
            MarkingInterval(min: 4.5, max: 10, spacing: 1, size:.medium),
            MarkingInterval(min: 1, max: 4, spacing: 0.1, skipping:5, size:.medium),
            MarkingInterval(min: 1.05, max: 4, spacing: 0.1, size:.small),
            MarkingInterval(min: 4, max: 10, spacing: 0.1, skipping:5, size:.small),
            
            MarkingInterval(min: 15, max: 40, spacing: 10, size:.xlarge),
            MarkingInterval(min: 10, max: 100, spacing: 10, size:.xlarge),
            MarkingInterval(min: 45, max: 100, spacing: 10, size:.medium),
            MarkingInterval(min: 10, max: 40, spacing: 1, skipping:5, size:.medium),
            MarkingInterval(min: 10.5, max: 40, spacing: 1, size:.small),
            MarkingInterval(min: 40, max: 100, spacing: 1, skipping:5, size:.small),
            
            MarkingInterval(min: 150, max: 400, spacing: 100, size:.xlarge),
            MarkingInterval(min: 100, max: 1000, spacing: 100, size:.xlarge),
            MarkingInterval(min: 450, max: 1000, spacing: 100, size:.medium),
            MarkingInterval(min: 100, max: 400, spacing: 10, skipping:5, size:.medium),
            MarkingInterval(min: 105, max: 400, spacing: 10, size:.small),
            MarkingInterval(min: 400, max: 1000, spacing: 10, skipping:5, size:.small),
        ],
        labelingIntervals: [
            LabelingInterval(min: 1, max: 9, spacing: 1){x in return "\(Int(x))"},
            LabelingInterval(x: 10, text: "10"),
            LabelingInterval(min: 20, max: 90, spacing: 10){x in return "\(Int(x/10))"},
            LabelingInterval(x: 100, text: "100"),
            LabelingInterval(min: 200, max: 900, spacing: 100){x in return "\(Int(x/100))"},
            LabelingInterval(x: 1000, text: "1000"),
        ]
    )
    
    static let LL3 = RulerScaleData(
        equation: { x in
            return log10(abs(log(x)))
        },
        markingIntervals: [
            MarkingInterval(Darwin.M_E, .xlarge),
            MarkingInterval(min: 2.8, max: 3, spacing: 0.1, size:.medium),
            MarkingInterval(min: 2.74, max: 2.8, spacing: 0.02, size:.small),
            MarkingInterval(min: 2.8, max: 3, spacing: 0.02, skipping: 5, size:.small),
            
            MarkingInterval(min: 3, max: 4, xlargeDivs:2, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 4, max: 6, xlargeDivs:4, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 6, max: 10, xlargeDivs:4, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 10, max: 15, xlargeDivs:1, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 15, max: 30, xlargeDivs:3, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 30, max: 50, xlargeDivs:2, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 50, max: 100, xlargeDivs:1, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 100, max: 200, xlargeDivs:2, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 200, max: 500, xlargeDivs:3, mediumDivs:2, smallDivs:5),
            
            MarkingInterval(min: 500, max: 1000, xlargeDivs:1, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 1000, max: 3000, xlargeDivs:2, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 3000, max: 5000, xlargeDivs:2, mediumDivs:1, smallDivs:5),
            MarkingInterval(min: 5000, max: 10000, xlargeDivs:1, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 10000, max: 20000, xlargeDivs:1, mediumDivs:2, smallDivs:5, includesEnd: true),
            
            MarkingInterval(21000, .small),
            MarkingInterval(exp(10), .medium),
        ],
        labelingIntervals: [
            LabelingInterval(x: Darwin.M_E, text: "e"),
            
            LabelingInterval(min: 3, max: 10, spacing: 1),
            LabelingInterval(min: 15, max: 20, spacing: 5),
            LabelingInterval(min: 30, max: 50, spacing: 10),
            LabelingInterval(min: 100, max: 100, spacing: 1),
            LabelingInterval(min: 200, max: 500, spacing: 100){x in return "\(Int(x)/100)"},
            LabelingInterval(x: 1000, text: "10³"),
            LabelingInterval(min: 2000, max: 5000, spacing: 1000){x in return "\(Int(x)/1000)"},
            LabelingInterval(x: 10000, text: "10⁴"),
            LabelingInterval(x: 20000, text: "20000"),
        ]
    )
    
    static let LL2 = RulerScaleData(
        equation: { x in
            return log10(abs(log(x)))+1
        },
        markingIntervals: [
            
            MarkingInterval(1.105, .xlarge),
            MarkingInterval(min: 1.105, max:1.11, spacing:0.001, skipping:5, size:.small),
            MarkingInterval(min: 1.11, max: 1.2, xlargeDivs:8, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 1.2, max: 1.4, xlargeDivs:4, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 1.4, max: 1.8, xlargeDivs:8, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 1.8, max: 2.5, xlargeDivs:7, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 2.5, max: 2.7, xlargeDivs:1, mediumDivs:2, smallDivs:5, includesEnd: false),
            MarkingInterval(2.7, .medium),
            MarkingInterval(Darwin.M_E, .xlarge)
        ],
        labelingIntervals: [
            LabelingInterval(x: Darwin.M_E, text: "e"),
            LabelingInterval(x: 1.11, text: "1.11"),
            LabelingInterval(min: 1.15, max: 1.4, spacing: 0.05){x in return "\((x*100).rounded()/100)"},
            LabelingInterval(min: 1.5, max: 1.9, spacing: 0.1){x in return "\((x*100).rounded()/100)"},
            LabelingInterval(x: 2, text: "2"),
            LabelingInterval(x: 2.5, text: "2.5"),
        ]
    )
    
    static let LL1 = RulerScaleData(
        equation: { x in
            return log10(abs(log(x)))+2
        },
        markingIntervals: [
            MarkingInterval(min: 1.01, max: 1.02, xlargeDivs:10, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 1.02, max: 1.05, xlargeDivs:6, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 1.05, max: 1.105, xlargeDivs:11, mediumDivs:5, smallDivs:2, includesEnd: true),
        ],
        labelingIntervals: [
            LabelingInterval(min: 1.01, max: 1.10, spacing: 0.01){x in return String(format:"%.2f",x)},
            LabelingInterval(x:1.015, text:"1.015")
        ]
    )
    
    static let LL01 = RulerScaleData(
        equation: { x in
            return log10(abs(log(x)))+2
        },
        markingIntervals: [
            MarkingInterval(exp(-0.01), .xlarge),
            MarkingInterval(min: 0.99, max: 0.98, xlargeDivs:10, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 0.98, max: 0.96, xlargeDivs:4, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 0.96, max: 0.91, xlargeDivs:10, mediumDivs:5, smallDivs:2, includesEnd: true),
            MarkingInterval(min: 0.906, max: 0.909, spacing:0.001, size: .medium),
            MarkingInterval(min: 0.9055, max: 0.9095, spacing:0.0005, size: .small),
            
            MarkingInterval(exp(-0.1), .xlarge),
        ],
        labelingIntervals: [
            LabelingInterval(x:0.9899, text:".99"),
            LabelingInterval(min: 0.91, max: 0.98, spacing: 0.01){x in return String(format:".%2d",Int(x*100))},
            LabelingInterval(x:0.985, text:".985"),
        ]
    )
    
    static let LL02 = RulerScaleData(
        equation: { x in
            return log10(abs(log(x)))+1
        },
        markingIntervals: [
            MarkingInterval(0.905, .xlarge),
            MarkingInterval(min: 0.9, max: 0.904, spacing:0.001, skipping:5, size:.small),
            
            MarkingInterval(min: 0.9, max: 0.8, xlargeDivs:10, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 0.8, max: 0.4, xlargeDivs:8, mediumDivs:5, smallDivs:5,includesEnd: true),
            MarkingInterval(min: 0.37, max: 0.39, spacing:0.01, size:.medium),
            MarkingInterval(min: 0.37, max: 0.4, spacing:0.002, skipping:5, size:.small),
            MarkingInterval(exp(-1.0), .xlarge),
        ],
        labelingIntervals: [
            LabelingInterval(min: 0.8, max: 0.9, spacing: 0.02){x in return String(format:".%2d",Int(x*100))},
            LabelingInterval(min: 0.4, max: 0.75, spacing: 0.05){x in return String(format:".%2d",Int(x*100))},
        ]
    )
    
    static let LL03 = RulerScaleData(
        equation: { x in
            return log10(abs(log(x)))
        },
        markingIntervals: [
            MarkingInterval(0.368, .xlarge),
            MarkingInterval(min: 0.35, max: 0.368, spacing:0.002, skipping:5, size:.small),
            MarkingInterval(0.36, .medium),
            MarkingInterval(min: 0.35, max: 0.1, xlargeDivs:5, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 0.1, max: 0.02, xlargeDivs:8, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 0.02, max: 0.01, xlargeDivs:2, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 0.01, max: 0.002, xlargeDivs:1, mediumDivs:8, smallDivs:5),
            MarkingInterval(min: 0.002, max: 0.001, xlargeDivs:1, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 0.001, max: 0.0005, xlargeDivs:1, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 0.0005, max: 0.0002, xlargeDivs:3, mediumDivs:1, smallDivs:5),
            MarkingInterval(min: 0.0002, max: 0.0001, xlargeDivs:1, mediumDivs:2, smallDivs:5, includesEnd: true),
            MarkingInterval(min: 0.00006, max: 0.0001, spacing:0.00001, size:.small),
            MarkingInterval(0.00005, .medium),
            MarkingInterval(exp(-10.0), .xlarge),
        ],
        labelingIntervals: [
            LabelingInterval(min: 0.05, max: 0.35, spacing: 0.05){x in return String(format:".%02d",Int(x*100))},
            LabelingInterval(min: 0.01, max: 0.04, spacing: 0.01){x in return String(format:".%02d",Int(x*100))},
            LabelingInterval(x:0.005, text:".005"),
            LabelingInterval(x:0.002, text:".002"),
            LabelingInterval(x:0.001, text:".001"),
            LabelingInterval(x:0.0005, text:".0005"),
            LabelingInterval(x:0.0002, text:".0002"),
            LabelingInterval(x:0.0001, text:".0001"),
            //LabelingInterval(x:1.015, text:"1.015"),
        ]
    )
    
    static let S = RulerScaleData(
        equation: { x in
            return log10(sin(x*Double.pi/180))+1
        },
        markingIntervals: [
            MarkingInterval(5.73917, .xlarge), //start = arcsin(0.1) in degrees
            MarkingInterval(5.8, .medium),
            MarkingInterval(5.9, .medium),
            MarkingInterval(5.85, .small),
            MarkingInterval(5.95, .small),
            
            MarkingInterval(min: 6, max: 10, xlargeDivs:8, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 10, max: 20, xlargeDivs:10, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 20, max: 30, xlargeDivs:2, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 30, max: 60, xlargeDivs:6, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 60, max: 70, xlargeDivs:1, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 70, max: 80, xlargeDivs:1, mediumDivs:2, smallDivs:5, includesEnd: true),
            MarkingInterval(85, .medium),
            MarkingInterval(90, .xlarge),
        ],
        labelingIntervals: [
            LabelingInterval(min: 6, max: 20, spacing: 1, flags:.alignRight){x in return String(format:"%2d",Int(x))},
            LabelingInterval(min: 6, max: 20, spacing: 1, flags:[.alignLeft, .italic, .thin, .small]){x in return String(format:"%2d",Int(90-x))},
            LabelingInterval(min: 20, max: 70, spacing: 10, flags:.alignRight){x in return String(format:"%2d",Int(x))},
            LabelingInterval(min: 20, max: 70, spacing: 10, flags:[.alignLeft, .italic, .thin, .small]){x in return String(format:"%2d",Int(90-x))},
            LabelingInterval(x: 25, text: "25", flags:.alignRight),
            LabelingInterval(x: 25, text: "25", flags:[.alignLeft, .italic, .thin, .small]),
            LabelingInterval(x: 90, text: "90")
        ]
    )
    
    static let ST = RulerScaleData(
        equation: { x in
            return log10(sin(x*Double.pi/180))+2
        },
        markingIntervals: [
            MarkingInterval(0.572967, .xlarge),
            MarkingInterval(0.58, .small),
            MarkingInterval(0.59, .small),
            
            MarkingInterval(min: 0.6, max: 1.5, xlargeDivs:9, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 1.5, max: 1.6, xlargeDivs:1, mediumDivs:2, smallDivs:5, includesEnd: true),
            
            MarkingInterval(min: 1.6, max: 1.65, spacing:0.01, skipping:5, size:.small),
            MarkingInterval(1.65, .medium),
            MarkingInterval(1.66, .small),
            MarkingInterval(1.667, .xlarge),
            MarkingInterval(1.68, .small),
            MarkingInterval(1.69, .small),
            
            MarkingInterval(min: 1.7, max: 2, xlargeDivs:3, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 2, max: 2.5, xlargeDivs:1, mediumDivs:5, smallDivs:5, includesEnd: true),
            
            MarkingInterval(min: 2.5, max: 2.76, spacing:0.02, skipping:5, size:.small),
            MarkingInterval(2.778, .xlarge),
            MarkingInterval(min: 2.8, max: 3, spacing:0.02, skipping:5, size:.small),
            MarkingInterval(min: 2.6, max: 2.9, spacing:0.1, size:.medium),
            
            MarkingInterval(min: 3, max: 5.5, xlargeDivs:5, mediumDivs:5, smallDivs:5, includesEnd: true),
            MarkingInterval(min: 5.5, max: 5.72, spacing:0.02, skipping:5, size:.small),
            MarkingInterval(5.6, .medium),
            MarkingInterval(5.7, .medium),
            MarkingInterval(5.7392, .xlarge),
            //MarkingInterval(min: 1.05, max: 1.105, xlargeDivs:11, mediumDivs:5, smallDivs:2, includesEnd: true),
        ],
        labelingIntervals: [
            LabelingInterval(min:0.6, max:0.9, spacing:0.1){x in return String(format:".%1d",Int(x*10))},
            LabelingInterval(x:1, text:"1°"),
            LabelingInterval(x:1.5, text:"1.5"),
            LabelingInterval(x:2, text:"2"),
            LabelingInterval(x:2.5, text:"2.5"),
            LabelingInterval(x:3, text:"3"),
            LabelingInterval(x:4, text:"4"),
            LabelingInterval(x:5, text:"5"),
            LabelingInterval(x:1.667, text:"'", flags:.short),//minutes
            LabelingInterval(x:2.778, text:"\"", flags:.short),//seconds
        ]
    )
    
    static let TG = RulerScaleData(
        equation: { x in
            return log10(tan(x*Double.pi/180))
        },
        markingIntervals: [
            MarkingInterval(min: 45, max: 60, xlargeDivs:3, mediumDivs:5, smallDivs:5),
            MarkingInterval(min: 60, max: 80, xlargeDivs:20, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 80, max: 84, xlargeDivs:8, mediumDivs:5, smallDivs:2, includesEnd: true),
            MarkingInterval(84.05, .small),
            MarkingInterval(84.1, .medium),
            MarkingInterval(84.15, .small),
            MarkingInterval(84.2, .medium),
            MarkingInterval(84.25, .small),
            MarkingInterval(84.289, .xlarge),
            
        ],
        labelingIntervals: [
            LabelingInterval(x:45, text:"45"),
            
            LabelingInterval(min: 50, max: 70, spacing: 5, flags:.alignRight){x in return String(format:"%2d",Int(x))},
            LabelingInterval(min: 50, max: 70, spacing: 5, flags:[.alignLeft, .italic, .thin, .small]){x in return String(format:"%2d",Int(90-x))},
            
            LabelingInterval(min: 70, max: 84, spacing: 1, flags:.alignRight){x in return String(format:"%2d",Int(x))},
            LabelingInterval(min: 70, max: 84, spacing: 1, flags:[.alignLeft, .italic, .thin, .small]){x in return String(format:"%2d",Int(90-x))},
        ]
    )
    
    static let TL = RulerScaleData(
        equation: { x in
            return log10(tan(x*Double.pi/180))+1
        },
        markingIntervals: [
            MarkingInterval(5.711, .xlarge),
            MarkingInterval(5.75, .small),
            MarkingInterval(5.8, .medium),
            MarkingInterval(5.86, .small),
            MarkingInterval(5.9, .medium),
            MarkingInterval(5.96, .small),
            MarkingInterval(min: 6, max: 10, xlargeDivs:8, mediumDivs:5, smallDivs:2),
            MarkingInterval(min: 10, max: 30, xlargeDivs:20, mediumDivs:2, smallDivs:5),
            MarkingInterval(min: 30, max: 45, xlargeDivs:3, mediumDivs:5, smallDivs:5, includesEnd: true),
            
        ],
        labelingIntervals: [
            LabelingInterval(min: 6, max: 20, spacing: 1, flags:.alignRight){x in return String(format:"%2d",Int(x))},
            LabelingInterval(min: 6, max: 20, spacing: 1, flags:[.alignLeft, .italic, .thin, .small]){x in return String(format:"%2d",Int(90-x))},
            
            LabelingInterval(min: 25, max: 40, spacing: 5, flags:.alignRight){x in return String(format:"%2d",Int(x))},
            LabelingInterval(min: 25, max: 40, spacing: 5, flags:[.alignLeft, .italic, .thin, .small]){x in return String(format:"%2d",Int(90-x))},
            
            LabelingInterval(x:45, text:"45"),
        ]
    )
}
