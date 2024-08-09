//
//  String.swift
//  Slide Rule
//
//  Created by Rowan on 8/6/24.
//

import SwiftUI

extension String{
    func sizeUsingFont(_ font: UIFont) -> CGSize{
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
