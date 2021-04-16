//
//  MultipeerSession.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 15.05.20.
//  https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience

import MultipeerConnectivity

/// TODO: clean up and add copyright
/// - Tag: MultipeerSession
class MultipeerSessionManager: NSObject {
    
    static let serviceType = "ar-multi-sample"
    
    /// identifies users inside a session
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    /// handles multipeer connectivity
     var session: MCSession!
    
    /// advertise sessions and handles invitations
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    ///Searches (by service type) for services offered by nearby devices
    private var serviceBrowser: MCNearbyServiceBrowser!
    
    private let receivedDataHandler: (Data, MCPeerID) -> Void
    
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
    
    func set(delegate: ARCollaborationDelegate) {
        self.delegate = delegate
    }
    
    func sendToAllPeers(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }

    
    
    var notifiedPeer: Bool = false
    var mapProvider: MCPeerID?
    var worldMapInitiated: Bool = false
    var sharedSession: Bool = false
    
    // TODO: Move these to Peer Class
    func notifyPeers(didRemove node: CustomNodeProtocol) {
        
        
        let uuid: NSString = NSString(string: node.uuid.uuidString)
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: uuid, requiringSecureCoding: true)
            else { fatalError("can't encode anchor") }
        
        sendToAllPeers(data)
    }
    
    func notifyPeers(didAdd anchor: CustomLineAnchor) {
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
            else { fatalError("can't encode anchor") }
        
        sendToAllPeers(data)
    }
    
    func notifyPeers(initializedWorldMap: Bool) {
        
        let receivedWorldMap: NSString = NSString(string: "receivedMap")
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: receivedWorldMap,requiringSecureCoding: true) else {
            fatalError("can't encode owner id")
        }
        
        sendToAllPeers(data)
    }
    
    func notifyPeers(didRemoveAllNodes ownerId: String) {
        
        let ownerID: NSString = NSString(string: ownerId)
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: ownerID, requiringSecureCoding: true)
            else { fatalError("can't encode owner id") }
        
        sendToAllPeers(data)
    }
    
}

extension MultipeerSessionManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //delegate?.lostPeer()
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

extension MultipeerSessionManager: MCNearbyServiceBrowserDelegate {
    
    /// - Tag: FoundPeer
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // Invite the new peer to the session.
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
         if notifiedPeer || sharedSession {
            delegate?.lostPeer()
        }
    }
    
}

extension MultipeerSessionManager: MCNearbyServiceAdvertiserDelegate {
    
    /// - Tag: AcceptInvite
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
       
        // Call handler to accept invitation and join the session.
        invitationHandler(true, self.session)
        
        // wenn einer entdeckt wurde
        print("connected...")
        
    }
}



