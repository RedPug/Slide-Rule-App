//
//  ValueRansge.swift
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

// Enum to represent the different range states
enum RangeType<T: Comparable> {
    case none
    case openRange(Range<T>)
    case closedRange(ClosedRange<T>)
    case multipleRanges([RangeType])
    case rangeFrom(PartialRangeFrom<T>)
    case rangeThrough(PartialRangeThrough<T>)
}

// Struct that optionally stores a range of values
struct ValueRange<T: Comparable> {
    var ranges: [RangeType<T>]
    
    init() {
        self.ranges = [.none]
    }
    
    init(openRange: Range<T>) {
        self.ranges = [.openRange(openRange)]
    }
    
    init(closedRange: ClosedRange<T>) {
        self.ranges = [.closedRange(closedRange)]
    }
    
    init(multipleRanges: [RangeType<T>]) {
        self.ranges = multipleRanges
    }
    
    init(rangeFrom: PartialRangeFrom<T>) {
        self.ranges = [.rangeFrom(rangeFrom)]
    }
    
    init(rangeThrough: PartialRangeThrough<T>) {
        self.ranges = [.rangeThrough(rangeThrough)]
    }
    
    func contains(_ value: T) -> Bool {
        for rangeType in ranges {
            switch rangeType {
            case .none:
                continue
            case .openRange(let range):
                if range.contains(value) {
                    return true
                }
            case .closedRange(let range):
                if range.contains(value) {
                    return true
                }
            case .multipleRanges(let ranges):
                for subRange in ranges {
                    if subRange.contains(value) {
                        return true
                    }
                }
            case .rangeFrom(let range):
                if value >= range.lowerBound {
                    return true
                }
                
            case .rangeThrough(let range):
                if value <= range.upperBound {
                    return true
                }
            }
        }
        return false
    }
}

// Extend RangeType to support contains method for multipleRanges
extension RangeType {
    func contains(_ value: T) -> Bool {
        switch self {
        case .none:
            return false
        case .openRange(let range):
            return range.contains(value)
        case .closedRange(let range):
            return range.contains(value)
        case .multipleRanges(let ranges):
            for subRange in ranges {
                if subRange.contains(value) {
                    return true
                }
            }
            return false
        case .rangeFrom(let range):
            return value >= range.lowerBound
            
        case .rangeThrough(let range):
            return value <= range.upperBound
        }
    }
}

//// Example usage
//let noRange = ValueRange<Int>()
//let openRange = ValueRange(openRange: 1..<10)
//let closedRange = ValueRange(closedRange: 1...10)
//let brokenRange = ValueRange(multipleRanges: [.closedRange(1...10), .closedRange(20...30)])
//let unboundedRange = ValueRange(unboundedRange: 5...)
