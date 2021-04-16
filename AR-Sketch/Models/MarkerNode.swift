//
//  CustomStrokeNode.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 19.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import SceneKit

/**
Objects of this class inherit from SCNNode and represent a special marker type of a stroke conforming to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol)
*/
/// - Tag: MarkerNode
class MarkerNode: SCNNode, CustomNodeProtocol {
   
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
        fatalError("Coder not implemented for CustomStrokeNode")
    }
    
    /**
     Adds new triangle meshes to the node according to the given touch point in 3D and the camera view vector.
     In comparison to [PencilNode](x-source-tag://PencilNode), this implementation creates a marker shaped node
     by shifting the top vertices of start and end point to the left and the bottom vertices of start and endpoint to the right by half of the value of the stroke width.
     The shape of these nodes generally points to the upward direction of the AR scene.
    - Parameter point: the point of the new line segment in 3D space as SCNVector3.
    - Parameter cameraViewVector: the cameraViewVector as SCNVector3.
    - Parameter color: the color that is currently selected.
    - Parameter strokeWidth: the stroke width that is currently selected
     */
    /// - Tag: AddVerticesM
    func addVertices(for point: SCNVector3, cameraViewVector: SCNVector3, color: UIColor, strokeWidth: Float) {
        self.color = color
        
        /// need at least 2 Points to draw new Triangles
        if centerPoints.count < 2 {
            centerPoints.append(point)
            return
        }
        let width = strokeWidth / 2
        guard let start = centerPoints.last else { return }
        
        /// create new vertives by shifting top and bottom vertices by adding / subtracting a quarter of the stroke width
        let newVertices = [
            SCNVector3(start.x - width/2 , start.y + width, start.z),
            SCNVector3(start.x + width/2 , start.y - width, start.z),
            SCNVector3(point.x - width/2 , point.y + width, point.z),
            
            SCNVector3(start.x + width/2, start.y - width, start.z),
            SCNVector3(point.x - width/2, point.y + width, point.z),
            SCNVector3(point.x + width/2, point.y - width, point.z)
        ]
        
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
    func updateVertices(with newVertices: [SCNVector3] = []) {
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
            material.transparency = CGFloat(0.8)
        }
    }
    
    /**
     Updates the pivot point of the node so that it matches the center of the object.
     This is neccessary in order to get an intuitive transform behavior for node objects.
     */
    func updatePivot() {
        let newPivot = (self.boundingBox.min * 0.5) + (self.boundingBox.max * 0.5)
        let newPivotMatrix = SCNMatrix4MakeTranslation(newPivot.x, newPivot.y, newPivot.z)
        self.pivot = newPivotMatrix
        self.transform = newPivotMatrix
    }
}
