//
//  SCNNode+Extensions.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 24.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//
//  Extension taken from a post by Allen Humphreys, 21.02.2018
//  URL: https://stackoverflow.com/a/48911022


import Foundation
import SceneKit


extension SCNNode {
    
    /// The local unit Y axis (0, 1, 0) in parent space.
    var parentUp: SCNVector3 {

        let transform = self.transform
        return SCNVector3(transform.m21, transform.m22, transform.m23)
    }

    /// The local unit X axis (1, 0, 0) in parent space.
    var parentRight: SCNVector3 {

        let transform = self.transform
        return SCNVector3(transform.m11, transform.m12, transform.m13)
    }

    /**
     The local unit -Z axis (0, 0, -1) in parent space.
     This property is used in order to rotate objects relative to the camera view direction [Rotate](x-source-tag://Rotate).
     */
    var parentFront: SCNVector3 {

        let transform = self.transform
        return SCNVector3(-transform.m31, -transform.m32, -transform.m33)
    }
}
