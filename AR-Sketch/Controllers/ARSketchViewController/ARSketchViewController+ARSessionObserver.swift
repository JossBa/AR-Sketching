//
//  ARSketchViewController+ARSessionObserver.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 21.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//
// functions altered and taken from:
// https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience
//
// Copyright © 2020 Apple Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import Foundation
import ARKit
import MultipeerConnectivity

// MARK: - ARSessionObserver
extension ARSketchViewController: ARSessionObserver {
    
    
    /// - Tag: ARSessionObserver
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let multipeerSession = multipeerSession else { return }
        
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            collaborationButton.isEnabled = true
        case .extending:
            //collaborationButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
            collaborationButton.isEnabled = true
        case .mapped:
            //collaborationButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
            collaborationButton.isEnabled = true
        @unknown default:
            collaborationButton.isEnabled = false
        }
        
        /// for more information see:  https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration/2968180-initialworldmap
        if multipeerSession.worldMapInitiated && !multipeerSession.notifiedPeer && !multipeerSession.sharedSession {
            switch frame.camera.trackingState {
            case .limited(let reason):
                print(reason)
            case .normal:
                multipeerSession.notifyPeers(initializedWorldMap: true)
                multipeerSession.notifiedPeer = true
            case .notAvailable:
                print("somethings not working")
            }
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        // messageLabel.displayMessage("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        // messageLabel.displayMessage("Session interruption ended")
    }
    
    /**
     Function that handles the incoming data from connected peers.
     
     * This function was taken from the sample project [Creating a Multiuser AR Experience](https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience)
     and altered to the needs of this application.
     */
    /// - Tag: ShareSession
    func shareSession() {
        connectionView.isHidden = false
        
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            
            map.anchors.removeAll(where: { $0.name == self.drawingManager.identifier.uuidString })
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            
            guard let multipeerSession = self.multipeerSession else { return }
            multipeerSession.sendToAllPeers(data)
            multipeerSession.sharedSession = true
            multipeerSession.worldMapInitiated = true
        }
        updateUIForCollaboration()
    }
    
    /**
     Function that handles the incoming data from connected peers.
     It was taken from the sample project for [Creating a Multiuser AR Experience](https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience)
     and altered to the needs of this application.
     - Parameter data: the data that is received.
     - Parameter peer: the connected peer id.
     */
    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        guard let multipeerSession = multipeerSession else { return }
        do {
            if !multipeerSession.worldMapInitiated {
                
                /// unarchives the received world map received from peer
                if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                    
                    showAlertInstructions(peerName: peer.displayName)
                    
                    /// Runs the AR session with the newly received world map
                    let configuration = ARWorldTrackingConfiguration()
                    configuration.initialWorldMap = worldMap
                    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                }
                
                updateUIForCollaboration()
                multipeerSession.worldMapInitiated = true
            }
                
            else
                if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: CustomLineAnchor.self, from: data) {
                    /// Add anchor to the session, ARSCNView delegate adds visible content.
                    sceneView.session.add(anchor: anchor)
                }
                    
                else if let uuid = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: data) {
                    
                    if uuid == "receivedMap" {
                        DispatchQueue.main.async {
                            /// hide view if map has been received successfully
                            self.connectionView.isHidden = true
                        }
                    } else if String(uuid) == "delete-all" {
                        /// remove all own nodes and all guest nodes
                        sceneView.scene.rootNode.enumerateChildNodes({ node, _ in
                            if let node = node as? CustomNodeProtocol {
                                node.removeFromParentNode()
                            }
                        })
                        /// remove all own anchors and all guest anchors
                        removeAllAnchors()
                    } else {
                        sceneView.scene.rootNode.enumerateChildNodes({ node, _ in
                            if let node = node as? CustomNodeProtocol {
                                if node.uuid.uuidString == String(uuid)  {
                                    
                                    /// remove node and anchor that match the id which was passed via peer connection
                                    node.removeFromParentNode()
                                    nodeManager.delete(guestNode: node)
                                }
                            }
                        })
                    }
                }
                else {
                    print("unknown data recieved from \(peer)")
            }
        } catch {
            print("can't decode data recieved from \(peer)")
        }
    }
}
