//
//  GLK-Extensions.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 04.08.20.
//
//  Extension taken from a post by Allen Humphreys, 21.02.2018
//  URL: https://stackoverflow.com/a/48911022

import Foundation
import SceneKit


extension GLKQuaternion {
    
    init(vector: GLKVector3, scalar: Float) {
        let glkVector = GLKVector3Make(vector.x, vector.y, vector.z)
        self = GLKQuaternionMakeWithVector3(glkVector, scalar)
    }
    
    init(angle: Float, axis: GLKVector3) {
        self = GLKQuaternionMakeWithAngleAndAxis(angle, axis.x, axis.y, axis.z)
    }
    
    func normalized() -> GLKQuaternion {
        return GLKQuaternionNormalize(self)
    }
    
    static var identity: GLKQuaternion {
        return GLKQuaternionIdentity
    }
}

func * (left: GLKQuaternion, right: GLKQuaternion) -> GLKQuaternion {
    return GLKQuaternionMultiply(left, right)
}

extension SCNQuaternion {
    init(_ quaternion: GLKQuaternion) {
        self = SCNVector4(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    }
}

extension GLKQuaternion {
    init(_ quaternion: SCNQuaternion) {
        self = GLKQuaternionMake(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    }
}

extension GLKVector3 {
    init(_ vector: SCNVector3) {
        self = SCNVector3ToGLKVector3(vector)
    }
}
