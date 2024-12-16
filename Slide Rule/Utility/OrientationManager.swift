//
//  OrientationManager.swift
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
//  Created by Rowan on 6/6/24.
//

import SwiftUI
import Combine

class OrientationInfo: ObservableObject {
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation	

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                let newOrientation = UIDevice.current.orientation
                // Only update for landscape orientations
                if newOrientation == .landscapeLeft || newOrientation == .landscapeRight {
                    self?.orientation = newOrientation
                }
                
                
            }
    }

    deinit {
        cancellable?.cancel()
    }
}
