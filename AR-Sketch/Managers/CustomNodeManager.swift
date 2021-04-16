//
//  CustomNodeManager.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 23.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation
import SceneKit

protocol CustomNodeManagerProtocol {
    
    /**
     Represents the current node, that is being drawn.
     The current node conforms to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol).
     */
    /// - Tag: OwnNodes
    var currentNode: CustomNodeProtocol? { get set }
    var nodeCollection: [CustomNodeProtocol] { get set }

    /**
     Represents the current guest node, that has been drawn by the connected peer.
     The current node conforms to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol).
     */
    /// - Tag: GuestNodes
    var currentGuestNode: CustomNodeProtocol { get set }
    var guestNodes: [CustomNodeProtocol] { get set }
    
    /**
        Sets the delegate property of [CustomNodeManager](x-source-tag://CustomNodeManager).
     - Parameter delegate: The delegate conforming to [ARSceneNodeManagerDelegate](x-source-tag://ARSceneNodeManagerDelegate).
     */
    func set(delegate: ARSceneNodeManagerDelegate)
    
    /**
     Adds a node to the [node manager collection  ](x-source-tag://OwnNodes).
     Notifies the [ARSceneNodeManagerDelegate](x-source-tag://ARSceneNodeManagerDelegate) of completion.
     - Parameter customNode: a node conforming to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol).
     */
    func add(customNode: CustomNodeProtocol)
    
    /**
     Deletes a node from the [node manager collection  ](x-source-tag://OwnNodes).
     Notifies the [ARSceneNodeManagerDelegate](x-source-tag://ARSceneNodeManagerDelegate) of completion.
     - Parameter node: a node conforming to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol).
     */
    func delete(node: CustomNodeProtocol)
    
    /**
     Undoes the last  node of [node manager collection  ](x-source-tag://OwnNodes).
     Notifies the [ARSceneNodeManagerDelegate](x-source-tag://ARSceneNodeManagerDelegate) of completion.
     */
    func undoLastNode()
    
    /**
     Adds last deleted node of the [node manager collection  ](x-source-tag://OwnNodes).
     Notifies the [ARSceneNodeManagerDelegate](x-source-tag://ARSceneNodeManagerDelegate) of completion.
     */
    func redoLastNode()
    
    /**
     Deletes all node of the [node manager collection  ](x-source-tag://OwnNodes).
     Notifies the [ARSceneNodeManagerDelegate](x-source-tag://ARSceneNodeManagerDelegate) of completion.
     */
    func deleteAllNodes()
    
    /**
     Returns the id of the [current node  ](x-source-tag://OwnNodes).
     - returns: NSString representing the id of the node.
     */
    func currentNodeId() -> NSString
    
    /**
    Adds a guest node to the [guest node collection ](x-source-tag://GuestNodes).
    - Parameter guestnode: a node conforming to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol).
    */
    func add(guestNode: CustomNodeProtocol)
    
    /**
     Deletes all nodes of the [guest node collection ](x-source-tag://GuestNodes).
     */
    func deleteAllGuestNodes()
    
    /**
     Returns the id of the [ current guest node](x-source-tag://GuestNodes).
     - returns: NSString representing the id of the node.
     */
    func currentGuestNodeId() -> NSString
    
    /**
     Deletes a guest node from the [guest node collection ](x-source-tag://GuestNodes).
     - Parameter guestNode: a node conforming to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol).
     */
    func delete(guestNode: CustomNodeProtocol)
}

/// - Tag: CustomNodeManager
class CustomNodeManager: CustomNodeManagerProtocol {
    
    var currentNode: CustomNodeProtocol?
    var nodeCollection: [CustomNodeProtocol] = []
    var deletedNodes: [CustomNodeProtocol] = []
    
    /// set to default empty node and will be overwritten by incoming data from connected peers
    var currentGuestNode: CustomNodeProtocol = PencilNode(color: .magenta,
                                                          strokeWidth: 0.005,
                                                          uuid: UUID(),
                                                          id: "000")
    var guestNodes: [CustomNodeProtocol] = []

    
    var delegate: ARSceneNodeManagerDelegate?
    
    func set(delegate: ARSceneNodeManagerDelegate) {
        self.delegate = delegate
    }
    
    
    func add(customNode: CustomNodeProtocol) {
        self.nodeCollection.append(customNode)
        self.currentNode = customNode
    }
    
    func delete(node: CustomNodeProtocol) {
        if node.uuid == currentNode?.uuid {
            currentNode = nodeCollection.last
        }
        nodeCollection.removeAll(where: { $0.uuid == node.uuid })
        deletedNodes.append(node)
        delegate?.didDelete(node: node)
    }
    
    func undoLastNode() {
        guard let lastNode = nodeCollection.last else { return }
        deletedNodes.append(lastNode)
        nodeCollection.removeLast()
        currentNode = nil
        delegate?.didDelete(node: lastNode)
    }
    
    func redoLastNode() {
        guard let lastDeletedNode = deletedNodes.last else { return }
        nodeCollection.append(lastDeletedNode)
        deletedNodes.removeLast()
        delegate?.didAdd(node: lastDeletedNode)
    }
       
    func deleteAllNodes() {
        self.nodeCollection.removeAll()
        self.deletedNodes.removeAll()
        self.currentNode = nil
        delegate?.didRemoveAllNodes()
    }
    
    func currentNodeId() -> NSString {
        return NSString(string: currentNode?.uuid.uuidString ??  "unknown")
    }
    
    func add(guestNode: CustomNodeProtocol) {
        self.guestNodes.append(guestNode)
        self.currentGuestNode = guestNode
    }
    
    func deleteAllGuestNodes(){
        self.currentGuestNode = PencilNode(color: .magenta,
                                           strokeWidth: 0.005,
                                           uuid: UUID(),
                                           id: "000")
        self.guestNodes.removeAll()
    }
    
    func currentGuestNodeId() -> NSString {
        return NSString(string: currentGuestNode.uuid.uuidString)
    }
    
    func delete(guestNode: CustomNodeProtocol) {
        if guestNode.uuid == currentNode?.uuid {
            currentNode = guestNodes.last
        }
        guestNodes.removeAll(where: { $0.uuid == guestNode.uuid })
    }
}
