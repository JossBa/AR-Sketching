//
//  CustomNodeManagerProtocol.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 04.08.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import SceneKit

/**
 * Protocol that defines the properties and functions of CustomNodeObjects
 * such as [PencilNode](x-source-tag://PencilNode) and [MarkerNode](x-source-tag://MarkerNode)
 */
/// - Tag: CustomNodeProtocol
protocol CustomNodeProtocol {
    
    var constraints: [SCNConstraint]? { get set }
    var eulerAngles: SCNVector3 { get set }
    var worldTransform: SCNMatrix4 { get  }
    var worldOrientation: SCNQuaternion { get set }
    var worldPosition: SCNVector3 { get set }
    var pivot: SCNMatrix4 { get set }
    var parent: SCNNode? { get }
    var simdOrientation: simd_quatf {get set }
    var simdWorldOrientation: simd_quatf {get set }
    
    var ownerID: NSString { get }
    var transform: SCNMatrix4 { get set }
    var color: UIColor { get set }
    var strokeWidth: Float { get set }
    var uuid: UUID { get }
    var position: SCNVector3 { get set }
    var scale: SCNVector3 { get set }
    var rotation: SCNVector4 { get set }
    var orientation: SCNQuaternion { get set }

    func removeFromParentNode()
    func look(at worldTarget: SCNVector3)
    func look(at worldTarget: SCNVector3, up worldUp: SCNVector3, localFront: SCNVector3)
    func setWorldTransform(_ worldTransform: SCNMatrix4)
    func localTranslate(by translation: SCNVector3)
    func convertVector(_ vector: SCNVector3, from node: SCNNode?) -> SCNVector3
    
    func addVertices(for point: SCNVector3, cameraViewVector: SCNVector3, color: UIColor, strokeWidth: Float)
    func updateGeometry()
    func updatePivot()
}

