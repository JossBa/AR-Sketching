//
//  ARKitError.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 21.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.


import Foundation

enum ARKitError: Error {
    
    case worldTrackingNotSupported
    
    var localizedDescription: String {
        switch self {
        case .worldTrackingNotSupported:
            return """
                ARKit is not available on this device, because ARKit configurations
                require an iOS device with an A9 or later processor, which means
                only devices like iPhone 6s or newer generations support this application.
            """
        }
    }
}
