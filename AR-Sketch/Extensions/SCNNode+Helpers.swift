//
//  SCNNode+Helpers.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 21.08.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import SceneKit

/// TODO: Clean up and separate
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

    /// The local unit -Z axis (0, 0, -1) in parent space.
    var parentFront: SCNVector3 {

        let transform = self.transform
        return SCNVector3(-transform.m31, -transform.m32, -transform.m33)
    }
}
