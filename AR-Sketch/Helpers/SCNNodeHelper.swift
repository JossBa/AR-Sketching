//
//  SCNNode+Helpers.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 13.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

/// TODO:  remove this if not needed
class SCNNodeHelper {
    
    /*
    /// adds a new node to the ar session
    func addGeometryNode(in view: ARSCNView, on position: SCNVector3, color: UIColor = .magenta, radius: CGFloat) {
        let node = SCNNode(geometry: SCNSphere(radius: radius))
        node.geometry?.firstMaterial?.diffuse.contents = color
        node.position = position
        view.scene.rootNode.addChildNode(node)
    }
    
    /// return camera position in world space
    func getCurrentCameraPosition(in view: ARSCNView) -> SCNVector3? {
        guard let camera = view.session.currentFrame?.camera else { return nil }
       let transform = camera.transform
       return  SCNVector3(transform.columns.3.x ,transform.columns.3.y, transform.columns.3.z)
    }
    
    
    func getCurrentNodePosition(with cameraTransform: simd_float4x4, for touchPoint: CGPoint, in sceneView: ARSCNView) -> SCNVector3? {
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        
        let unprojectedPoint  = sceneView.unprojectPoint(SCNVector3Make(Float(touchPoint.x), Float(touchPoint.y), 1))
        let normalizedDirection = unprojectedPoint.normalized()
        
        return normalizedDirection * 0.2 + cameraPosition
    }
    
    
    
    /// node position in front of camera
    func convertPosition(for touchPoint: CGPoint, in view: ARSCNView, with distance: Float) -> SCNVector3? {
        guard let cameraPosition = getCurrentCameraPosition(in: view) else { return nil }

        // unprojecting a point whose z-coordinate is 1.0 returns a point on the far clipping plane.
        let unprojectedPoint  = view.unprojectPoint(SCNVector3Make(Float(touchPoint.x), Float(touchPoint.y), 1))
        let normalizedDirection = unprojectedPoint.normalized()
        return normalizedDirection * distance + cameraPosition
    }
    
    // Gets the positions of the points on the line between point1 and point2 with the given spacing
    func getPositionsOnLineBetween(from vector1: SCNVector3,
                                   to vector2: SCNVector3,
                                   withSpacing spacing: Float) -> [SCNVector3] {
        var positions: [SCNVector3] = []
        // Calculate the distance between previous point and current point
        let distance = vector1.distance(vector: vector2)
        let numberOfCirclesToCreate = Int(distance / spacing)

        // https://math.stackexchange.com/a/83419
        // Begin by creating a vector BA by subtracting A from B (A = previousPoint, B = currentPoint)
        let vectorBA = vector2 - vector1
        // Normalize vector BA by dividng it by it's length
        let vectorBANormalized = vectorBA.normalized()
        // This new vector can now be scaled and added to A to find the point at the specified distance
        for i in 0...((numberOfCirclesToCreate > 1) ? (numberOfCirclesToCreate - 1) : numberOfCirclesToCreate) {
            let position = vector1 + (vectorBANormalized * (Float(i) * spacing))
            positions.append(position)
        }
        return positions
    }
    
    func addGeometryNodes(from start: SCNVector3, to end: SCNVector3, in view: ARSCNView, radius: CGFloat) {
        let positionsOfInsertNodes = getPositionsOnLineBetween(from: start, to: end, withSpacing: Float(radius/3))
        positionsOfInsertNodes.forEach( { point in
            addGeometryNode(in: view, on: point, radius: radius)
        })
    }
 **/
}
