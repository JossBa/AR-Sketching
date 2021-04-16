//
//  CustomLineNode.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 18.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import SceneKit

class CustomLineNode: SCNNode {
    
    // TODO: add logic for determine source and destination
    init(from sourcePoint: SCNVector3, to destinationPoint: SCNVector3, radius: CGFloat, color: UIColor) {
        super.init()

        let w = SCNVector3(x: destinationPoint.x-sourcePoint.x,
                           y: destinationPoint.y-sourcePoint.y,
                           z: destinationPoint.z-sourcePoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))

        if l <= radius {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = sourcePoint
            return
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.firstMaterial?.diffuse.contents = color

        self.geometry = cyl

        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((destinationPoint.x - sourcePoint.x)/2.0, (destinationPoint.y - sourcePoint.y)/2.0,
                            (destinationPoint.z-sourcePoint.z)/2.0)

        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)

        //normalized axis vector
        let av_normalized = av.normalized()
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)

        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3

        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0

        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0

        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0

        self.transform.m41 = (sourcePoint.x + destinationPoint.x) / 2.0
        self.transform.m42 = (sourcePoint.y + destinationPoint.y) / 2.0
        self.transform.m43 = (sourcePoint.z + destinationPoint.z) / 2.0
        self.transform.m44 = 1.0
        return
    }
    
    required init?(coder: NSCoder) {
        super.init()
    }
}
