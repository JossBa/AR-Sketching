//
//  ARSketchViewController+Multipeer.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 21.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.


//import Foundation
//import ARKit
//import MultipeerConnectivity
//
//extension ARSketchViewController {
//
//
//    /// - Tag: ReceiveData
//    func receivedData(_ data: Data, from peer: MCPeerID) {
//
//        do {
//            if !worldMapInitiated {
//                if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
//                    // Run the session with the received world map.
//                    let configuration = ARWorldTrackingConfiguration()
//                    // configuration.planeDetection = .horizontal
//                    configuration.initialWorldMap = worldMap
//                    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//
//                    // Remember who provided the map for showing UI feedback.
//                    mapProvider = peer
//                    self.worldMapInitiated = true
//                }
//            }
//            else
//                if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: CustomLineAnchor.self, from: data) {
//                    // Add anchor to the session, ARSCNView delegate adds visible content.
//                    sceneView.session.add(anchor: anchor)
//                }
//                else {
//                    print("unknown data recieved from \(peer)")
//            }
//        } catch {
//            print("can't decode data recieved from \(peer)")
//        }
//    }
//}
