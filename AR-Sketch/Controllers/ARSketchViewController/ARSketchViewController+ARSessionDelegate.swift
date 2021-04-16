//
//  ARSketchViewController+ARSessionDelegate.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 22.08.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import ARKit

extension ARSketchViewController: ARSessionDelegate {
    
    /// - Tag: ARSessionDelegate
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        /// moves the selected node according to the current touch location if long press had been detected (isDragging) previously
        if drawingManager.isDragging {
            guard var currentNode = nodeManager.currentNode,
                let currentTouchLocation = drawingManager.currentTouchPoint,
                let zDepth = drawingManager.zDepth else { return }
            
            currentNode.position = sceneView.unprojectPoint(
                SCNVector3(x: Float(currentTouchLocation.x),
                           y: Float(currentTouchLocation.y),
                           z: zDepth))
        }
        /// if user is drawing (pan gesture has been detected)
        if drawingManager.isDrawing && !drawingManager.isEditingSketch {
            
            /// determine current touch point camera location and calculate the nodePosition for the stroke
            guard let currentTouchPoint = drawingManager.currentTouchPoint,
                let cameraTransform = sceneView.session.currentFrame?.camera.transform,
                let nodePosition = getCurrentNodePosition(with: cameraTransform,
                                                          for: currentTouchPoint,
                                                          in: sceneView) else { return }
            
            /// add new anchor to the scene only if previous touchpoint distance is larger than 0.002 cm
            if let previousNodePosition = drawingManager.previousNodePosition {
                if abs(nodePosition.distance(vector: previousNodePosition)) > Constants.minimumStrokeLength {
                    
                    addCustomAnchor(to: sceneView, at: nodePosition)
                    drawingManager.previousNodePosition = nodePosition
                }
            } else {
                
                /**
                 Otherwise only updates the current touch point variable.
                 Please note: The addCustomAnchor function can be commented out here as well.
                 This would trigger the creation of more anchors in the scene, regardless of the distance between touchpoints.
                 */
                
                //addCustomAnchor(to: sceneView, at: nodePosition)
                drawingManager.previousNodePosition = nodePosition
            }
        }
    }
    
    /**
     Adds a [CustomLineAnchor](x-source-tag://CustomLineAnchor) to the scene and sends it connected peers.
     Whenever a custom line anchor is being added to the scene, the rendering function of [ARSCNViewDelegate](x-source-tag://ARSCNViewDelegate)
     is being triggered and a new CustomNode is being added to the AR scene.
     - the nodePosition is previously calculated by the [getCurrentNodePosition()](x-source-tag://CurrentNodePosition) functon.
     - Parameter scene: the current AR scene
     - Parameter nodePosition:the current node position as SCNVector3
     */
    /// - Tag: addCustomAnchor
    private func addCustomAnchor(to scene: ARSCNView, at nodePosition: SCNVector3) {
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else { return }
        
        var anchorTransform = cameraTransform
        anchorTransform.columns.3.x = nodePosition.x
        anchorTransform.columns.3.y = nodePosition.y
        anchorTransform.columns.3.z = nodePosition.z
        
        let anchorName = drawingManager.identifier.uuidString
        let customLineAnchor = CustomLineAnchor(name: anchorName,
                                                transform: anchorTransform,
                                                sourcePoint: cameraViewVector(for: cameraTransform),
                                                destinationPoint: nodePosition,
                                                color: drawingManager.strokeColor,
                                                id: nodeManager.currentNodeId(),
                                                type: drawingManager.peniclType,
                                                strokeWidth: drawingManager.strokeWidth)
        
        sceneView.session.add(anchor: customLineAnchor)
        multipeerSession?.notifyPeers(didAdd: customLineAnchor)
    }
    
    /**
     Calculates the node's position according to the user's current touch point on the screen  in the  AR scene.
     This function is the transformation from 2D-touch positions to 3D-world coordinates of strokes.
     - Parameter cameraTransform: the current position of the camrea
     - Parameter touchPoint: the current touch point on the screen  in 2D
     - Parameter sceneView: the current AR scene
     - Returns: The 3D-position of the node as a SCNVector3
     */
    /// - Tag: CurrentNodePosition
    private func getCurrentNodePosition(with cameraTransform: simd_float4x4, for touchPoint: CGPoint, in sceneView: ARSCNView) -> SCNVector3? {
        
        /// save world coordinates of current camera position (3D)
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        
        /// unproject a point whose z-coordinate is 1.0, which returns a point on the far clipping plane
        let unprojectedPoint  = sceneView.unprojectPoint(SCNVector3Make(Float(touchPoint.x), Float(touchPoint.y), 1))
        
        /// normalize the vector
        let normalizedDirection = unprojectedPoint.normalized()
        
        /// scale the vector by the constant distance of nodes from the cameraView and add it to the world coordinates of current camera position
        return normalizedDirection * Constants.distanceToCamera + cameraPosition
    }
    
    /**
     Removes all anchors with the given ids from the AR scene.
     - Parameter id: The String representing the anchor id
     */
    func removeAllAnchors(with id: String) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Could not retrieve world map.")
                return
            }
            map.anchors.removeAll(where: { $0.name  == self.drawingManager.identifier.uuidString })
        }
    }
    
    /**
     Removes all anchors from the AR scene.
     */
    func removeAllAnchors() {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Could not retrieve world map.")
                return
            }
            map.anchors.removeAll()
        }
    }
}
