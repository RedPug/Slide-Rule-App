//
//  OrientationManager.swift
//  Slide Rule
//
//  Created by Rowan on 6/6/24.
//

import SwiftUI
import Combine

class OrientationInfo: ObservableObject {
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
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
