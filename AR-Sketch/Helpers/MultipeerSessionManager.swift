//
//  MultipeerSession.swift
//  AR-Sketch
//
// Created by Josephine Battiston on 15.05.20.
//
// class taken from sample project with url:
// https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience
// altered this class with additional properties and functions.
//
// Copyright © 2020 Apple Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



import MultipeerConnectivity

/// - Tag: MultipeerSessionManager
class MultipeerSessionManager: NSObject {
    
    /// name of the service
    static let serviceType = "ar-sketch"
    
    /// boolean stating whether peer had been notified that worldmap had been initialized.
    var notifiedPeer: Bool = false

    /// the peer id of provider of the world map.
    var mapProvider: MCPeerID?
    
    /// boolean stating whether world map had been initialized correctly.
    var worldMapInitiated: Bool = false
    var sharedSession: Bool = false
    
    /// identifies users inside a session
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    /// handles multipeer connectivity
    var session: MCSession!
    
    /// advertise sessions and handles invitations
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    /// Searches (by service type) for services offered by nearby devices
    private var serviceBrowser: MCNearbyServiceBrowser!
    
    /// data handler function that is passed for initialization
    private let receivedDataHandler: (Data, MCPeerID) -> Void
    
    /// delegate property conforming to [ARCollaborationDelegate](x-source-tag://ARCollaborationDelegate)
    private var delegate: ARCollaborationDelegate?
    
    /// - Tag: MultipeerSetup
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void ) {
        
        self.receivedDataHandler = receivedDataHandler
        
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerSessionManager.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerSessionManager.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
    }
    
    /**
     Sets delegate property conforming to [ARCollaborationDelegate](x-source-tag://ARCollaborationDelegate).
     - Parameter delegate: object conforming to [ARCollaborationDelegate](x-source-tag://ARCollaborationDelegate).
     */
    func set(delegate: ARCollaborationDelegate) {
        self.delegate = delegate
    }
    
    /// returns the connected peer.
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }

    /**
     Notifies connected peers that a node has been removed from the scene
     - Parameter node: a node conforming to [CustomNodeProtocol](x-source-tag://CustomNodeProtocol).
     */
    func notifyPeers(didRemove node: CustomNodeProtocol) {
        let uuid: NSString = NSString(string: node.uuid.uuidString)
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: uuid, requiringSecureCoding: true)
            else { fatalError("can't encode anchor") }
        
        sendToAllPeers(data)
    }
    
    /**
     Notifies connected peers that a anchor has been added to the scene
     - Parameter anchor: anchor  conforming to [CustomLineAnchor](x-source-tag://CustomLineAnchor).
     */
    func notifyPeers(didAdd anchor: CustomLineAnchor) {
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
            else { fatalError("can't encode anchor") }
        
        sendToAllPeers(data)
    }
    
    /**
     Notifies connected peers that world map has been initialiezed successfully.
     - Parameter initializedWorldMap: a  Boolean stating if operation has been successful.
     */
    func notifyPeers(initializedWorldMap: Bool) {
        let receivedWorldMap: NSString = NSString(string: "receivedMap")
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: receivedWorldMap,requiringSecureCoding: true) else {
            fatalError("can't encode owner id")
        }
        sendToAllPeers(data)
    }
    
    /**
     Notifies connected peers that connected peer did remove all anchors from the scene.
     - Parameter ownerId: the id of the current owner.
     */
    func notifyPeers(didRemoveAllNodes ownerId: String) {
        
        /// since this application supports only 2 devices, it is not neccessary to determine who deleted the sketch
        /// otherwise a owner id could be passed like commented out below
        // let ownerID: NSString = NSString(string: ownerId)
        
        /// a string saying `delete-all` is passed to the connected peer and triggers the deletion of all nodes in the scene
        let deleteAllCode = NSString(string: "delete-all")
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: deleteAllCode, requiringSecureCoding: true)
            else { fatalError("can't encode owner id") }
        sendToAllPeers(data)
    }
    
    /**
     Sends a message encapsulated in a Data instance to nearby peers.
     - Parameter data: An instance of Data containing the message to send.
     - Throws:
     */
    func sendToAllPeers(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("sent anchor")
        } catch {
            //print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    /**
     Resets worldMapInitiated, notifiedPeer, sharedSession Booleans to false.
     */
    func reset(){
        worldMapInitiated = false
        notifiedPeer = false
        sharedSession = false
    }
}

/// - Tag: MCSessionDelegate
extension MultipeerSessionManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedDataHandler(data, peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        fatalError("This service does not send/receive streams.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError("This service does not send/receive resources.")
    }
}

/// - Tag: MCNearbyServiceBrowserDelegate
extension MultipeerSessionManager: MCNearbyServiceBrowserDelegate {
    
    /// - Tag: FoundPeer
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        
        /// Invite the new peer to the session.
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        /// if the peer connection stops, the delegate ( which in this case is the ARSketchViewController) is notified in order to display the notification that the peer is lost
         if notifiedPeer || sharedSession {
            delegate?.didLosePeer()
        }
    }
}

/// - Tag: MCNearbyServiceAdvertiserDelegate
extension MultipeerSessionManager: MCNearbyServiceAdvertiserDelegate {
    
    /// - Tag: AcceptInvite
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        /// Call handler to accept invitation and join the session.
        invitationHandler(true, self.session)
    }
}



