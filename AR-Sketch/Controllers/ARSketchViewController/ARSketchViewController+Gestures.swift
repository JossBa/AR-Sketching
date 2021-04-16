//
//  ARSketchViewController+TouchGestures.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 21.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//
import UIKit
import SceneKit

// MARK: - Touch Gestures
extension ARSketchViewController {
    
    /**
    Creates a new [CustomNode](x-source-tag://CustomNodeProtocol) depending on the [pencilSettings](x-source-tag://CurrentPencilSettings).
     - Parameter gesture: UIPanGestureRecognizer
     */
    func beginDrawing() {
        drawingManager.isDrawing = true
        
        switch drawingManager.peniclType {
        case .pencil:
            let newPencil = PencilNode(color: .black, strokeWidth: drawingManager.strokeWidth, uuid: UUID(), id: NSString(string: drawingManager.identifier.uuidString))
            nodeManager.add(customNode: newPencil)
        case .marker:
            let newStroke = MarkerNode(color: .green, strokeWidth: drawingManager.strokeWidth, uuid: UUID(), id: NSString(string: drawingManager.identifier.uuidString))
            nodeManager.add(customNode: newStroke)
        }
    }
}

@objc extension ARSketchViewController {
    
    /**
    Detects pan gesture and calls [beginDrawing()](x-source-tag://TouchGestures) and updates [currentTouchPoint](x-source-tag://ARDrawingManager) of drawing manager.
     - Parameter gesture: UIPanGestureRecognizer
     */
    /// - Tag: TouchGestures
    /// - Tag: Draw
    @objc func draw(gesture: UIPanGestureRecognizer) {
        
        guard !drawingManager.isEditingSketch && !drawingManager.isErasingNodes else { return }
        
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: sceneView)
            drawingManager.currentTouchPoint = touchLocation
            beginDrawing()
        case .changed:
            let touchLocation = gesture.location(in: sceneView)
            drawingManager.currentTouchPoint = touchLocation
        case .ended:
            drawingManager.resetDrawing()
        default:
            drawingManager.resetDrawing()
        }
    }
    
    /**
     Scales the selected node object.

     - Parameter gesture: UIPinchGestureRecognizer
     
     this discussion helped me implementing this functionality:
     https://stackoverflow.com/questions/55289106/how-to-scale-and-move-all-nodes-at-once-arkit-swift
     */
    /// - Tag: Scale
    @objc func pinch(gesture: UIPinchGestureRecognizer) {
        
        guard drawingManager.isEditingSketch else { return }
        
        switch gesture.state {
        case .began:
            let location = gesture.location(in: sceneView)
            guard let selectedNode = sceneView.hitTest(location,
                                                       options: [SCNHitTestOption.boundingBoxOnly: true]).first?.node as? CustomNodeProtocol
                else { return }
            nodeManager.currentNode = selectedNode
            
        case .changed:
            guard var currentNode = nodeManager.currentNode else { return }
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((currentNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((currentNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((currentNode.scale.z))
            
            currentNode.scale = SCNVector3(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
        default:
            nodeManager.currentNode = nil
        }
    }
    
    /**
     Moves the selected node object.
     - Parameter gesture: UILongPressGestureRecognizer
    */
    /// - Tag: Move
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        
        guard drawingManager.isEditingSketch else { return }
        
        switch gesture.state {
        case .began:
            generator.impactOccurred()
            
            if let hit = sceneView.hitTest(gesture.location(in: sceneView),
                                           options: [SCNHitTestOption.boundingBoxOnly: true]).first {
                
                nodeManager.currentNode = hit.node as? CustomNodeProtocol
                guard let currentNode = nodeManager.currentNode else { return }
                drawingManager.zDepth = sceneView.projectPoint(currentNode.position).z
                
            }
            drawingManager.isDragging = true
        case .changed:
            drawingManager.currentTouchPoint = gesture.location(in: sceneView)
        case .ended:
            drawingManager.isDragging = false
        default:
            drawingManager.isDragging = false
        }
    }
    
    /**
     Deletes the selected node object.
     - Parameter gesture: UITapGestureRecognizer
    */
    /// - Tag: Delete
    @objc func tap(gesture: UITapGestureRecognizer) {
        guard drawingManager.isErasingNodes else { return }
        
        if let hit = sceneView.hitTest(gesture.location(in: sceneView), options: [SCNHitTestOption.boundingBoxOnly: true]).first {
            
            guard let nodeToDelete = hit.node as? CustomNodeProtocol else { return }
            nodeManager.delete(node: nodeToDelete)
            multipeerSession?.notifyPeers(didRemove: nodeToDelete)
        }
    }
    
    /**
     Rotates' the selected node object.
     - Parameter gesture: UIRotationGestureRecognizer
     * lines (155-170) are taken from [this post](https://stackoverflow.com/a/48911022) by Allen Humphreys, 21.02.2018
     */
    /// - Tag: Rotate
    @objc func rotation(_ rotation: UIRotationGestureRecognizer) {
        
        guard drawingManager.isEditingSketch else { return }
        
        if let hit = sceneView.hitTest(rotation.location(in: sceneView), options: [SCNHitTestOption.boundingBoxOnly: true]).first {
            nodeManager.currentNode = hit.node as? CustomNodeProtocol
        }
        guard var currentNode = nodeManager.currentNode else { return }
       
        if rotation.state == .began {
            drawingManager.startingOrientation = GLKQuaternion(currentNode.orientation)
            let cameraLookingDirection = sceneView.pointOfView!.parentFront
            let cameraLookingDirectionInTargetNodesReference = currentNode.convertVector(cameraLookingDirection,
                                                                                         from: sceneView.pointOfView!.parent!)
            drawingManager.rotationAxis = GLKVector3(cameraLookingDirectionInTargetNodesReference)
        } else if rotation.state == .ended {
            drawingManager.startingOrientation = GLKQuaternionIdentity
            drawingManager.rotationAxis = GLKVector3Make(0, 0, 0)
            
        } else if rotation.state == .changed {
            let quaternion = GLKQuaternion(angle: Float(rotation.rotation), axis: drawingManager.rotationAxis)
            currentNode.orientation = SCNQuaternion((drawingManager.startingOrientation * quaternion).normalized())
        }
    }
}

extension ARSketchViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
