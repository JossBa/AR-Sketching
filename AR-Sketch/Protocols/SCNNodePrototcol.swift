//
//  SCNNodePrototcol.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 21.11.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import SceneKit

/**
 * Protocol that extends function of SCNNode to also add [CustomNodes](x-source-tag://CustomNodeProtocol) as child nodes.
 */
/// - Tag: SCNNodeProtocol
protocol SCNNodeProtocol {
    func addChildNode(_ node: CustomNodeProtocol)
}

extension SCNNode: SCNNodeProtocol {
    
    /**
     Adds [CustomNode](x-source-tag://CustomNodeProtocol) object as a child node of the current SCNNode object.
     - Parameter node: the child node conforming to [CustomNode](x-source-tag://CustomNodeProtocol).
     */
    func addChildNode(_ node: CustomNodeProtocol) {
        guard let node = node as? SCNNode else {
            fatalError("Could not cast SCNNode to CustomNodeProtocol")
        }
        self.addChildNode(node)
    }
}

