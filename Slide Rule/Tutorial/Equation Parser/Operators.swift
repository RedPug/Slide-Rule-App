//
//  Operators.swift
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
//  Created by Rowan on 11/26/24.
//

import Foundation


enum OperatorError: Error{
    case invalidOperator
	case invalidArgument
}

struct Operator: Equatable{
    let symbol: String
    let numOperands: Int
    let format: String
	let bounds: [any RangeExpression<CGFloat>]
    fileprivate let expression: ([CGFloat])->CGFloat
    fileprivate let _getKeyframes: ([CGFloat]) -> [Keyframe]
    
    
	init(symbol: String, numOperands: Int, range: any RangeExpression<CGFloat>, _ moreRanges: any RangeExpression<CGFloat>..., format: String, expression: @escaping ([CGFloat])->CGFloat, getKeyframes: @escaping ([CGFloat])->[Keyframe]){
        self.symbol = symbol
        self.numOperands = numOperands
        self.format = format
		
		var arr = [range]
		arr.append(contentsOf: moreRanges)
		self.bounds = arr
        
        self.expression = expression
        self._getKeyframes = getKeyframes
    }
	
	//overload for default range of all positive (not including 0)
	init(symbol: String, numOperands: Int, format: String, expression: @escaping ([CGFloat])->CGFloat, getKeyframes: @escaping ([CGFloat])->[Keyframe]){
		self.init(symbol: symbol, numOperands: numOperands, range:0.00001..., format:format,expression:expression,getKeyframes: getKeyframes)
	}
	
	func evaluate(_ values: [CGFloat]) throws -> CGFloat{
		for v in values{
			if !(isValidInput(v)){
				print("Operator '\(symbol)' recieved invalid input of '\(v)'.")
				
				throw OperatorError.invalidArgument
			}
		}

		return expression(values)
	}
	
	func getKeyframes(_ values: [CGFloat]) throws -> [Keyframe]{
		for v in values{
			if !(isValidInput(v)){
				print("Operator '\(symbol)' recieved invalid input of '\(v)'.")
				
				throw OperatorError.invalidArgument
			}
		}
		
		return self._getKeyframes(values)
	}
	
	func isValidInput(_ value: CGFloat) -> Bool{
		for range in bounds{
			if range.contains(value){
				return true
			}
		}
		return false
	}
    
    static func == (lhs: Operator, rhs: Operator) -> Bool{
        return lhs.symbol == rhs.symbol
    }
}





enum Operators{
    static let allOperators = [times, divide, inverse, square, cube, squareroot, cuberoot, euler, power, commonLog, naturalLog, logb, sine, cosecant, tangent, piTimes, minutes, seconds, seconds2, none]
    
	static let times = Operator(symbol: "*", numOperands: 2, format: "{a} X {b}"){args in
        return args[0] * args[1]
    }getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        let b = args[1]
        let b1 = mapOnC(b)
        let out = a*b
        let out1 = mapOnC(out)
        return [
            Keyframe(scaleNum:8, x:a1,     action:"cursor",    label:"Calculate $\(format(a)) \\times \(format(b))$: Place the cursor at $\(format(a1))$ on the D scale"),
            Keyframe(scaleNum:8, x:a1,     action:"indexL",    label:"Move the index of the C scale to the cursor"),
            Keyframe(scaleNum:7, x:b1,     action:"cursor",    label:"Place the cursor at $\(format(b))$ on the C scale"),
            Keyframe(scaleNum:8, x:out1,   action:"read",      label:"Read \(format(out)) on the D scale.")
        ]
    }
    
    static let divide = Operator(symbol: "/", numOperands: 2, format: "{a} / {b}"){args in return args[0] / args[1]}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        let b = args[1]
        let b1 = mapOnC(b)
        let out = a/b
        let out1 = mapOnC(out)
        return [
            Keyframe(scaleNum:8, x:a1, scaleNum2:7, x2:b1, action:.alignScales, label:"Calculate $\(format(a)) / \(format(b))$: Align $\(format(a1))$ on the D scale with $\(format(b1))$ on the C scale"),
            Keyframe(scaleNum:7, x:1,       action:.alignCursor,    label:"Move the cursor to the left index of the C scale (1)"),
            Keyframe(scaleNum:8, x:out1,    action:.readValue,      label:"Read \(format(out)) on the D scale at the index of the C scale"),
        ]
    }
    
    static let inverse = Operator(symbol: "1/", numOperands: 1, format: "1 / {b}"){args in return 1/args[0]}getKeyframes: { args in
        let a = args[0]
        let a1 = mapOnC(a)
        let out = 1/a
        let out1 = mapOnC(out)
        return [
            Keyframe(scaleNum: 7, x: a1, action: .alignCursor, label: "Calculate $1 / \(format(a))$: Place the cursor at $\(format(a1))$ on the C scale"),
            Keyframe(scaleNum: 6, x: out1, action: .readValue, label: "Read \(format(out)) on the CI scale.")
        ]
    }
    
    static let square = Operator(symbol: "sqr", numOperands: 1, format: "{a} ^ 2"){args in return args[0]*args[0]}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        let out = a*a
        let out1 = pow(mapOnC(sqrt(out)),2)
        return [
            Keyframe(scaleNum: 19, x: a1, action: .alignCursor, label: "Calculate $\(format(a))^{2}$: Place the cursor at $\(format(a1))$ on the D scale"),
            Keyframe(scaleNum: 13, x: out1, action: .readValue, label: "Read \(format(out)) on the A scale.")
        ]
    }
    
    static let cube = Operator(symbol: "cube", numOperands: 1, format: "{a} ^ 3"){args in return args[0]*args[0]*args[0]}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        let out = a*a*a
        let out1 = pow(mapOnC(pow(out,1/3)),3)
        return [
            Keyframe(scaleNum: 19, x: a1, action: .alignCursor, label: "Calculate $\(format(a))^{3}$: Place the cursor at $\(format(a1))$ on the D scale"),
            Keyframe(scaleNum: 12, x: out1, action: .readValue, label: "Read \(format(out)) on the K scale.")
        ]
    }

    static let squareroot = Operator(symbol: "sqrt", numOperands: 1, format: "sqrt( {a} )"){args in return sqrt(args[0])}getKeyframes:{args in
        let a = args[0]
        let a1 = pow(mapOnC(sqrt(a)),2) //find the value of a such that 1 <= sqrt(a1) <= 10
        let out = sqrt(a)
        let out1 = mapOnC(out) //find the value between 1 and 10
        return [
            Keyframe(scaleNum: 13, x: a1, action: .alignCursor, label: "Calculate $\\sqrt[2]{\(format(a))}$: Place the cursor at $\(format(a1))$ on the A scale"),
            Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) on the D scale.")
        ]
    }
    
    static let cuberoot = Operator(symbol: "cbrt", numOperands: 1, format: "cube root( {a} )"){args in return CGFloat(pow(args[0],1/3))}getKeyframes:{args in
        let a = args[0]
        let a1 = pow(mapOnC(pow(a,1/3)),3) //find the value of a such that 1 <= sqrt(a1) <= 10
        let out = pow(a,1/3)
        let out1 = mapOnC(out) //find the value between 1 and 10
        
        return [
            Keyframe(scaleNum: 12, x: a1, action: .alignCursor, label: "Calculate $\\sqrt[3]{\(format(a))}$: Place the cursor at $\(format(a1))$ on the K scale"),
            Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) on the D scale.")
        ]
    }
    
	static let euler = Operator(symbol: "exp", numOperands: 1, range: 0.01...10, (-10)...(-0.01), format: "e ^ {a}"){args in return CGFloat(exp(args[0]))}getKeyframes:{args in
        let a = args[0]
        var scale = 0
        var scaleName = "ERROR"
        var lower = 0.0
        var upper = 0.0
        
        if a >= 1 {
            scale = 9
            scaleName = "LL3"
            lower = 1
            upper = 10
        }else if a >= 0.1 {
            scale = 10
            scaleName = "LL2"
            lower = 0.1
            upper = 1
        }else if a >= 0.01 {
            scale = 20
            scaleName = "LL1"
            lower = 0.01
            upper = 0.1
        }else if a <= -1 {
            scale = 1
            scaleName = "LL03"
            lower = -10
            upper = -1
        }else if a <= -0.1 {
            scale = 0
            scaleName = "LL02"
            lower = -1
            upper = -0.1
        }else if a <= -0.01 {
            scale = 11
            scaleName = "LL01"
            lower = -0.1
            upper = -0.01
        }
        
        let a1 = mapOnC(abs(a))
        
        let out = exp(a)
        
        return [
            Keyframe(scaleNum: scale <= 10 ? 8 : 19, x: a1, action: .alignCursor, label: "Calculate $e^{\(format(a))}$: Place the cursor at $\(format(a1))$ on the D scale"),
            Keyframe(scaleNum: scale, x: out, action: .readValue, label: "Read the answer $\(format(out))$ on the \(scaleName) scale (with a range from $\(lower)x$ to $\(upper)x$)")
        ]
    }
    
    //a^b
    static let power = Operator(symbol:"^", numOperands: 2, format: "{a} ^ {b}"){args in return CGFloat(pow(args[0], args[1]))}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        let b = args[1]
        let b1 = mapOnC(b)
        
        let fullLog = log10(a)
        let fullLog1 = mapOnC(fullLog)
        let mantissa = fullLog.truncatingRemainder(dividingBy: 1)
        
        let logProd = fullLog*b
        let logProd1 = mapOnC(fullLog*b)
        
        let shiftAmount = Int(logProd)
        let prodMantissa = logProd.truncatingRemainder(dividingBy: 1)
        
        let out = pow(a,b)
        let out1 = mapOnC(out)
        
        return [
            Keyframe(scaleNum: 7, x: a1, action: .alignCursor, label: "Calculate $\(format(a))^{\(format(b))}$: Place the cursor at $\(format(a1))$ on the C scale"),
            Keyframe(scaleNum: 5, x: mantissa, action: .readValue, label: "Read $\(format(mantissa))$ on the L scale"),
            Keyframe(label: "Note that since the L scale only provides the mantissa of the logarithm, the logarithm is actually $\(format(fullLog))$"),
            Keyframe(scaleNum: 8, x: fullLog1, action: .alignCursor, label: "Move the cursor to $\(format(fullLog1))$ on the D scale"),
            Keyframe(scaleNum: 8, x: fullLog1, action: .alignIndexLeft, label: "Move the index of the C scale to the cursor"),
            Keyframe(scaleNum: 7, x: b1, action: .alignCursor, label: "Place the cursor at $\(format(b1))$ on the C scale"),
            Keyframe(scaleNum: 8, x: logProd1, action: .readValue, label: "Read $\(format(logProd))$ on the D scale"),
            Keyframe(scaleNum: 5, x: prodMantissa, action: .alignCursor, label: "Move the cursor to $\(format(prodMantissa))$ (mantissa of $\(format(logProd))$) on the L scale"),
            Keyframe(scaleNum: 7, x: out1, action: .readValue, label: "Read $\(out1)$ on the C scale. Because we cut a $\(shiftAmount)$ from $\(format(logProd))$, we shift $\(shiftAmount)$ places to get $\(out)$ as our final answer")
        ]
    }
    
    
    //ln(a)
    static let naturalLog = Operator(symbol:"ln", numOperands: 1, format: "ln( {a} )"){args in return CGFloat(log(args[0]))}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        
        let fullLog = log10(a)
        let mantissa = fullLog.truncatingRemainder(dividingBy: 1)
        
        let out = fullLog*2.303
        let out1 = mapOnC(out)
        
        return [
            Keyframe(scaleNum: 7, x: a1, action: .alignCursor, label: "Calculate ln$(\(format(a))$: Place the cursor at $\(format(a1))$ on the C scale"),
            Keyframe(scaleNum: 5, x: mantissa, action: .readValue, label: "Read \(format(mantissa)) on the L scale"),
            Keyframe(label: "Note that since the L scale only provides the mantissa of the logarithm, the logarithm is actually $\(format(fullLog))$"),
            Keyframe(scaleNum: 8, x: fullLog, action: .alignCursor, label: "Move the cursor to $\(format(fullLog))$ on the D scale"),
            Keyframe(scaleNum: 8, x: fullLog, action: .alignIndexLeft, label: "Move the index of the C scale to the cursor"),
            Keyframe(scaleNum: 7, x: 2.303, action: .alignCursor, label: "Place the cursor at $2.303$ (log -> ln conversion factor) on the C scale"),
            Keyframe(scaleNum: 8, x: out1, action: .readValue, label: "Read the answer $\(out)$ on the D scale")
        ]
    }
    
    //log(a)
    static let commonLog = Operator(symbol:"log", numOperands: 1, format: "log({a})"){args in return CGFloat(log10(args[0]))}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        
        let fullLog = log10(a)
        let mantissa = fullLog.truncatingRemainder(dividingBy: 1)
        
        return [
            Keyframe(scaleNum: 7, x: a1, action: .alignCursor, label: "Calculate log$(\(format(a))$: Place the cursor at $\(format(a1))$ on the C scale"),
            Keyframe(scaleNum: 5, x: mantissa, action: .readValue, label: "Read \(format(mantissa)) on the L scale"),
            Keyframe(label: "Note that since the L scale only provides the mantissa of the logarithm, the logarithm is actually $\(format(fullLog))$"),
        ]
    }

    //log_b (a)
    static let logb = Operator(symbol:"logb", numOperands: 2, format: "log {a} ( {b} )"){args in return log10(args[1])/log10(args[0])}getKeyframes:{args in
        let a = args[1]
        let a1 = mapOnC(a)
        
        let b = args[0]
        let b1 = mapOnC(b)
        
        let fullLogA = log10(a)
        let fullLogA1 = mapOnC(fullLogA)
        let mantissaA = fullLogA.truncatingRemainder(dividingBy: 1)
        
        let fullLogB = log10(b)
        let fullLogB1 = mapOnC(fullLogB)
        let mantissaB = fullLogB.truncatingRemainder(dividingBy: 1)
        
        let out = fullLogA/fullLogB
        let out1 = mapOnC(out)
        
        return [
            Keyframe(scaleNum: 7, x: a1, action: .alignCursor, label: "Calculate log$_{\(format(b))}(\(format(a)))$: Place the cursor at $\(format(a1))$ on the C scale"),
            Keyframe(scaleNum: 5, x: mantissaA, action: .readValue, label: "Read \(format(mantissaA)) on the L scale"),
            Keyframe(label: "Note that since the L scale only provides the mantissa of the logarithm, the logarithm is actually $\(format(fullLogA))$"),
            
            Keyframe(scaleNum: 7, x: b1, action: .alignCursor, label: "Place the cursor at $\(format(b1))$ on the C scale"),
            Keyframe(scaleNum: 5, x: mantissaB, action: .readValue, label: "Read \(format(mantissaB)) on the L scale"),
            Keyframe(label: "Note that since the L scale only provides the mantissa of the logarithm, the logarithm is actually $\(format(fullLogB))$"),
            
            Keyframe(label: "Next, divide the first logarithm ($\(format(fullLogA))$) by the second ($\(format(fullLogB))$)"),
            
            Keyframe(scaleNum:8, x:fullLogA1, scaleNum2:7, x2:fullLogB1, action:.alignScales, label:"Align $\(format(fullLogA))$ on the D scale with $\(format(fullLogB))$ on the C scale"),
            Keyframe(scaleNum:7, x:1,       action:.alignCursor,    label:"Move the cursor to the left index of the C scale (1)"),
            Keyframe(scaleNum:8, x:out1,    action:.readValue,      label:"Read \(format(out)) on the D scale at the index of the C scale"),
        ]
    }
    
    //sin(a)
	static let sine = Operator(symbol:"sin", numOperands: 1, range: 0.571...90, format: "sin( {a} )"){args in return CGFloat(sin(args[0]*Double.pi/180))}getKeyframes:{args in
        let a = args[0]
        let out = sin(a*Double.pi/180)
        let out1 = mapOnC(out)
        
        if a > 5.73917{
            return [
                Keyframe(scaleNum: 18, x: a, action: .alignCursor, label: "Calculate sin($\(format(a))°$): Place the cursor at $\(format(a))$ on the S scale"),
                Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) on the D scale.")
            ]
        }
        
        return [
            Keyframe(scaleNum: 17, x: a, action: .alignCursor, label: "Calculate sin($\(format(a))°$): Place the cursor at $\(format(a))$ on the ST scale"),
            Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) on the D scale.")
        ]
    }
    
    //csc(a)
    static let cosecant = Operator(symbol:"csc", numOperands: 1, range: 0.571...90, format: "csc( {a} )"){args in return 1/sin(args[0]*Double.pi/180)}getKeyframes:{args in
        let a = args[0]
        let out = 1/sin(a*Double.pi/180)
        let out1 = mapOnC(out)
        
        if a > 5.73917{
            return [
                Keyframe(scaleNum: 18, x: a, action: .alignCursor, label: "Calculate sin($\(format(a))°$): Place the cursor at $\(format(a))$ on the S scale"),
                Keyframe(scaleNum: 20, x: out1, action: .readValue, label: "Read \(format(out)) on the DI scale.")
            ]
        }
        
        return [
            Keyframe(scaleNum: 17, x: a, action: .alignCursor, label: "Calculate sin($\(format(a))°$): Place the cursor at $\(format(a))$ on the ST scale"),
            Keyframe(scaleNum: 20, x: out1, action: .readValue, label: "Read \(format(out)) on the DI scale.")
        ]
    }
    
    //tan(a)
	static let tangent = Operator(symbol:"tan", numOperands: 1, range: 0.571...84.3, format: "tan( {a} )"){args in return CGFloat(tan(args[0]*Double.pi/180))}getKeyframes:{args in
        let a = args[0]
        let out = tan(a*Double.pi/180)
        let out1 = mapOnC(out)
        
        if a < 5.73917{
            
            return [
                Keyframe(scaleNum: 17, x: a, action: .alignCursor, label: "Calculate tan($\(format(a))°$): Place the cursor at $\(format(a))$ on the ST scale"),
                Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) on the D scale.")
            ]
        }else if a < 45{
            return [
                Keyframe(scaleNum: 15, x: a, action: .alignCursor, label: "Calculate tan($\(format(a))°$): Place the cursor at $\(format(a))$ on the T < 45° scale"),
                Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) on the D scale.")
            ]
        }
        
        return [
            Keyframe(scaleNum: 16, x: a, action: .alignCursor, label: "Calculate tan($\(format(a))°$): Place the cursor at $\(format(a))$ on the T > 45° scale"),
            Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) on the D scale.")
        ]
    }
    
    //pi*x
    static let piTimes = Operator(symbol:"pi*", numOperands: 1, format: "π x {a}"){args in return args[0]*Double.pi}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        
        let out = Double.pi*a
        let out1 = mapOnC(out)
        
        return [
            Keyframe(scaleNum: 7, x: a1, action: .alignCursor, label: "Calculate $\\pi*\(format(a))$: Place the cursor at $\(format(a1))$ on the C scale"),
            Keyframe(scaleNum: 3, x: out1, action: .readValue, label: "Read \(format(out)) on the CF scale.")
        ]
    }

    //minutes and seconds
    static let minutes = Operator(symbol:"'", numOperands: 1, format: "{a} minutes to radians"){args in return args[0]*Double.pi/180/60}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        
        let out = a*Double.pi/180/60
        let out1 = mapOnC(out)
        
        return [
            Keyframe(scaleNum: 19, x: a1, action: .alignCursor, label: "Convert \(format(a)) minutes to radians: Place the cursor at $\(format(a1))$ on the D scale"),
            Keyframe(scaleNum: 19, x: a1, action: .alignIndexLeft, label: "Move the index of the slide to the cursor"),
            Keyframe(scaleNum: 17, x: 1.667, action: .alignCursor, label: "Move the cursor to the minutes mark (') on the ST scale"),
            Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) radians on the D scale.")
        ]
    }
    
    static let seconds = Operator(symbol:"\"", numOperands: 1, format: "{a} seconds to radians"){args in return args[0]*Double.pi/180/60/60}getKeyframes:{args in
        let a = args[0]
        let a1 = mapOnC(a)
        
        let out = a*Double.pi/180/60/60
        let out1 = mapOnC(out)
        
        return [
            Keyframe(scaleNum: 19, x: a1, action: .alignCursor, label: "Convert \(format(a)) seconds to radians: Place the cursor at $\(format(a1))$ on the D scale"),
            Keyframe(scaleNum: 19, x: a1, action: .alignIndexLeft, label: "Move the index of the slide to the cursor"),
            Keyframe(scaleNum: 17, x: 2.778, action: .alignCursor, label: "Move the cursor to the seconds mark (\") on the ST scale"),
            Keyframe(scaleNum: 19, x: out1, action: .readValue, label: "Read \(format(out)) radians on the D scale.")
        ]
    }
    
    //alias symbol
    static let seconds2 = Operator(symbol:"''", numOperands: 1, format: seconds.format, expression: seconds.expression, getKeyframes: seconds._getKeyframes)
    
    static let none = Operator(symbol:"none", numOperands: 0, format:"No Operator"){args in return args[0]}getKeyframes:{args in return []}
    
    static func fromSymbol(_ symbol: String) throws -> Operator{
        for op in Operators.allOperators {
            if op.symbol == symbol {
                return op
            }
        }
        throw OperatorError.invalidOperator
    }
    
    
    /// returns a number between 1 and 10, scaling the input by factors of 10 at a time.
    /// - Parameter x: the input value to convert
    /// - Returns: x multiplied by powers of 10 to be between 1 and 10
    private static func mapOnC(_ val:CGFloat)->CGFloat{
        var x = val
        if x > 10 {
            while x > 10 {
                x = x/10
            }
        }else if x < 1 {
            while x < 1 {
                x = x*10
            }
        }
        return x
    }
    
    private static func format(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        formatter.minimumSignificantDigits = 4
        formatter.maximumSignificantDigits = 4
        
        if let formattedString = formatter.string(from: NSNumber(value: number)) {
            return formattedString
        }
        return "\(number)"
    }
}
