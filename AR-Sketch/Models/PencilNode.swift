//
//  PencilNode.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 23.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import SceneKit

/**
 Objects of this class inherit from SCNNode and represent the standard type of a stroke conforming to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol) 
 */
/// - Tag: PencilNode
class PencilNode: SCNNode, CustomNodeProtocol {
    
    var vertices: [SCNVector3] = []
    var centerPoints: [SCNVector3] = []
    var indices: [Int32] = []
    
    var color: UIColor
    var strokeWidth: Float
    var uuid: UUID
    var ownerID: NSString
    
    init(color: UIColor, strokeWidth: Float, uuid: UUID, id: NSString) {
        self.color = color
        self.strokeWidth = strokeWidth
        self.uuid = uuid
        self.ownerID = id
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not implemented for Pencil")
    }
    
    /**
     Adds new triangle meshes to the node according to the given touch point in 3D and the camera view vector.
    - Parameter point: the point of the new line segment in 3D space as SCNVector3.
    - Parameter cameraViewVector: the direction of the cameraView as SCNVector3
    - Parameter color: the color that is currently selected.
    - Parameter strokeWidth: the stroke width that is currently selected
     */
    /// - Tag: AddVertices
    func addVertices(for point: SCNVector3, cameraViewVector: SCNVector3, color: UIColor, strokeWidth: Float) {
        self.color = color
        
        if centerPoints.count == 0 {
            centerPoints.append(point)
            return
        }
        
        /// need at least 2 Points to draw new Triangles
        guard let start = centerPoints.last else { return }
        
        /**
         Calculate the vector between two points
         * this [post](https://stackoverflow.com/a/54459758) by user ' Jaykob', 31.01.2019,
         helped me finding a solution for calculating the vector between two points (line 63-65)
         */
        let dir = (point - start).normalized()
        let orthoVec = dir.cross(vector: cameraViewVector) * strokeWidth / 2
        var newVertices: [SCNVector3] = []
        
        if centerPoints.count == 1 {
            newVertices = [
                start + orthoVec, // First
                start - orthoVec, // Second
                point + orthoVec, // Third
                
                start - orthoVec, // Second
                point + orthoVec, // Third
                point - orthoVec  // Fourth
            ]
        } else if centerPoints.count > 1 && vertices.count > 2 {
            newVertices = [
                vertices[vertices.count - 2],
                vertices[vertices.count - 1],
                point + orthoVec,
                vertices[vertices.count - 1],
                point + orthoVec,
                point - orthoVec
            ]
        }
        
        /// saves the newly added point as well as the calculated vertices
        centerPoints.append(point)
        updateVertices(with: newVertices)
        
        /// every time new vertices are added, the geometry needs to be updated
        updateGeometry()
        
        /// update pivot is called in order to shift the pivot  of the node to the center of the object
        updatePivot()
    }
    
    /**
       Adds newly created verices and their indices to the according collection of the PencilNode class.
     - Parameter newVertices: the vertice as SCNVector3
     */
    func updateVertices(with newVertices: [SCNVector3]) {
        let count = indices.count
        newVertices.enumerated().forEach({ offset, vertex in
            vertices.append(vertex)
            indices.append(Int32(count + offset))
        })
    }
    
    /**
     Updates the geometry of the PencilNode according to the vertices and indices saved in the according collections.
     Adds material properties such as color and doubleSided property to this geometry.
    */
    func updateGeometry() {
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        geometry = SCNGeometry(sources: [source], elements: [element])
        
        if let material = geometry?.firstMaterial {
            material.diffuse.contents = color
            material.isDoubleSided = true
        }
    }
    
    /**
     Updates the pivot point of the node so that it matches the center of the object.
     This is neccessary in order to get an intuitive transform behavior for node objects.
     */
    func updatePivot() {
        let newPivot = (self.boundingBox.min ) + ((self.boundingBox.max - self.boundingBox.min) * 0.5)
        let newPivotMatrix = SCNMatrix4MakeTranslation(newPivot.x, newPivot.y, newPivot.z)
        self.pivot = newPivotMatrix
        self.transform = newPivotMatrix
    }
}
