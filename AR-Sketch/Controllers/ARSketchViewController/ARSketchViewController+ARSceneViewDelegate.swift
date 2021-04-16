//
//  ARSketchViewController+ARSceneViewDelegate.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 22.06.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import ARKit


extension ARSketchViewController: ARSCNViewDelegate {
    
    /// - Tag: ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        /// if name matches user's id, a node is being added to the AR scene matching the currently selected pencil settings
        if anchor.name == drawingManager.identifier.uuidString,
            let customLineAnchor = anchor as? CustomLineAnchor,
            let cameraViewVector = customLineAnchor.sourcePoint,
            let destinationPoint = customLineAnchor.destinationPoint,
            let color = customLineAnchor.color,
            let strokeWidth = customLineAnchor.strokeWidth {
            
            if let currentPencilNode = nodeManager.currentNode  {
                
                currentPencilNode.addVertices(for: destinationPoint,
                                              cameraViewVector: cameraViewVector,
                                              color: color,
                                              strokeWidth: strokeWidth)
                sceneView.scene.rootNode.addChildNode(currentPencilNode)
            }
        }
            
        /// if name does not matche user's id, a guest node is being added to the scene matching the currently selected pencil settings
        else if anchor.name != drawingManager.identifier.uuidString,
            let customLineAnchor = anchor as? CustomLineAnchor,
            let cameraViewVector = customLineAnchor.sourcePoint,
            let destinationPoint = customLineAnchor.destinationPoint,
            let color = customLineAnchor.color,
            let id = customLineAnchor.id,
            let ownerID = customLineAnchor.name,
            let pencilType = customLineAnchor.type,
            let strokeWidth = customLineAnchor.strokeWidth {
              
            /// only update vertices if stroke is still being drawn
            if nodeManager.currentGuestNode.uuid.uuidString == String(id) {
                nodeManager.currentGuestNode.addVertices(for: destinationPoint,
                                          cameraViewVector: cameraViewVector,
                                          color: color,
                                          strokeWidth: strokeWidth)
                sceneView.scene.rootNode.addChildNode(nodeManager.currentGuestNode)
            }
            /// otherwise create new guest node according to the received settings from peer and add it to the AR scene
            else {
                switch pencilType {
                case .pencil:
                    nodeManager.currentGuestNode = PencilNode(color: color,
                                           strokeWidth: strokeWidth ,
                                           uuid: UUID(uuidString: id as String)!,
                                           id: NSString(string: ownerID))
                case .marker:
                     nodeManager.currentGuestNode = MarkerNode(color: color,
                                                  strokeWidth: strokeWidth,
                                                  uuid: UUID(uuidString: id as String)!,
                                                  id: NSString(string: ownerID))
                }
                sceneView.scene.rootNode.addChildNode(nodeManager.currentGuestNode)
            }
        }
    }
}
