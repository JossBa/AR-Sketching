//
//  PencilSettingsManager.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 12.11.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit
import SceneKit

/// - Tag: ARDrawingManager
class ARDrawingManager {
    
    /// the currently selected pencil settings of the user
    /// - Tag: CurrentPencilSettings
    var currentPencilSettings: PencilSettings = PencilSettings(pencilType: .pencil, strokeWidthSettings: .small, strokeColor: .systemPink)
   
    /// starting orientation of a node for the rotation
    var startingOrientation = GLKQuaternion.identity
    
    /// axis of rotation for node rotation
    var rotationAxis = GLKVector3Make(0, 0, 0)
    
    /// stores previously added node position in 3D
    var previousNodePosition: SCNVector3?
    
    /// stores current touch point of user on the screen in 2D
    var currentTouchPoint: CGPoint?
    
    /// the depth in view direction  that is used to determing the distance of objects from the camera
    var zDepth: Float?
    
    /// boolean stating if user is currently drawing
    var isDrawing: Bool = false
    
    /// boolean stating if user is currently editing the sketch (transforming)
    var isEditingSketch: Bool = false
    
    /// boolean stating if user is currently erasing nodes
    var isErasingNodes: Bool = false
    
    /// boolean stating if user is currently moving a node
    var isDragging: Bool = false
    
    /// the unique identifier of the current user
    var identifier = UUID()
    
    /// The currently selected stroke color
    var strokeColor: UIColor {
        get {
            return currentPencilSettings.strokeColor
        }
        set {
            currentPencilSettings.strokeColor = newValue
        }
    }
    
    /// The currently selected pencil type
    var peniclType: PencilSettings.PencilType {
        get {
            return currentPencilSettings.pencilType
        }
        set {
            currentPencilSettings.pencilType = newValue
        }
    }
    
    /// The currently selected stroke width
    var strokeWidth: Float {
        get {
            return currentPencilSettings.strokeWidth
        }
        set {
        }
    }
    
    /// Resets drawing properties to initial values meaning that `previousNodePosition`,  `currentTouchPoint` are set to `nil` and `isDrawing`is set to `true`.
    func resetDrawing() {
        isDrawing = false
        previousNodePosition = nil
        currentTouchPoint = nil
    }
    
}

/// Struct that defines the constants of this application.
struct Constants {
    
    /// Defines the distance of nodes to the  camera.
    /// In this application the value is set to 0.1 which means that if the user is drawing, strokes are placed 10cm in front of the camera view.
    static let distanceToCamera: Float = 0.2
    
    /// The minimum distance of two points being drawn in the AR scene.
    static let minimumStrokeLength: Float = 0.002
}
