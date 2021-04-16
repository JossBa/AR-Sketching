//
//  CustomLineGeometry.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 18.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import SceneKit

class CustomLineGeometry {
    
    static func Stroke(from start: SCNVector3 = SCNVector3Zero, to end: SCNVector3 = SCNVector3Zero, strokeWidth: Float) -> SCNGeometry {
        
        let width: Float = 0.02 / 2
        
        let src = SCNGeometrySource(vertices: [
            SCNVector3(start.x, start.y + width, start.z),
            SCNVector3(start.x, start.y - width, start.z),
            SCNVector3(end.x, end.y + width, end.z),
            
            SCNVector3(start.x, start.y - width, start.z),
            SCNVector3(end.x, end.y + width, end.z),
            SCNVector3(end.x, end.y - width, end.z)
        ])
        
        
        let normals = SCNGeometrySource(normals: [SCNVector3](repeating: SCNVector3(0, 0, 1), count: 6))
        
        
        let indices: [UInt32] = [
            0, 1, 2, 3, 4, 5
        ]
        let inds = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry.init(sources: [src, normals], elements: [inds])
    }
}
