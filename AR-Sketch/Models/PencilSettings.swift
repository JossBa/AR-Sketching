//
//  PencilSettings.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 03.08.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit

/**
 Pencil settings define the different types of pencils that are available in this application such as [PencilNode](x-source-tag://PencilNode)
 and [MarkerNode](x-source-tag://MarkerNode) as well as stroke width and color settings.
 */
/// - Tag: PencilSettings
struct PencilSettings {
    
    enum PencilType: Int, Codable {
        case pencil, marker
    }
    
    enum StrokeWidth: Int, Codable {
        case small, medium, large
    }
    
    var pencilType: PencilType
    var strokeWidthSettings: StrokeWidth
    var strokeColor: UIColor
    
    var type: NSString {
        switch pencilType {
        case .pencil:
            return "0"
        case .marker:
            return "1"
        }
    }
    
    var strokeWidth: Float {
        switch strokeWidthSettings {
        case .small:
            return 0.003
        case .medium:
            return 0.01
        case .large:
            return 0.03
        }
    }
}

