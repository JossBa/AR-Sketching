//
//  Utilities.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 15.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import ARKit

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        @unknown default:
            return "Unknown"
        }
    }
}
