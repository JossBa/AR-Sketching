//
//  ViewController.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 12.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

/**
 Protocol that defines delegate methods to notify view about changes regarding
 [CustomNodes](x-source-tag://CustomNodePrototcol) in the AR scene.
 */
protocol ARSceneNodeManagerDelegate {
    
    /**
    Adds a [CustomNode](x-source-tag://CustomNodeProtocol) as a child node to the AR scene.
     */
    /// - Tag: ARSceneNodeManagerDelegate
    func didAdd(node: CustomNodeProtocol)
    
    /**
    Removes a [CustomNode](x-source-tag://CustomNodeProtocol) from the AR scene.
     */
    func didDelete(node: CustomNodeProtocol)
    
    /**
      Removes all [CustomNode](x-source-tag://CustomNodeProtocol) objects from the AR scene.
    */
    func didRemoveAllNodes()
}

/// Protocol that defines delegate methods for collaboration.
protocol ARCollaborationDelegate {
    
    /**
     Shows alert that the peer connection is lost and asks
     whether to proceed with drawing in the current map or restart the AR scene.
     */
    /// - Tag: ARCollaborationDelegate
    func didLosePeer()
}


/**
 * The main controller of the view of this application. For additional information see the README.md in this project.
 */
/// - Tag: ARSketchViewController
class ARSketchViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var toolPickerView: ToolPickerView!
    @IBOutlet weak var messageLabel: MessageLabel! {
        didSet {
            messageLabel.isHidden = true
            messageLabel.layer.cornerRadius = 10
            messageLabel.layer.masksToBounds = true
            messageLabel.backgroundColor = #colorLiteral(red: 0.01176470588, green: 0.6, blue: 0.4862745098, alpha: 1).withAlphaComponent(0.8)
        }
    }
    @IBOutlet weak var strokeWidthPicker: StrokeWidthPicker! {
        didSet { strokeWidthPicker.isHidden = true }
    }
    @IBOutlet weak var colorPicker: UIButton! {
        didSet {
            colorPicker.layer.borderColor = UIColor.white.cgColor
            colorPicker.layer.borderWidth = 2
            colorPicker.layer.cornerRadius = 15
            colorPicker.layer.masksToBounds = true
            colorPicker.backgroundColor = drawingManager.strokeColor
        }
    }
    @IBOutlet weak var colorPickerView: ColorPickerView!
    @IBOutlet weak var collaborationButton: UIButton!
    @IBOutlet weak var undoStackView: UIStackView!
    @IBOutlet weak var sktechToolStackView: UIStackView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var connectionView: UIView! {
        didSet {
            connectionView.isHidden = true
        }
    }
    @IBOutlet weak var bottomToolBar: ColorPickerView!
   
    // MARK: Properties
    var configuration: ARWorldTrackingConfiguration?
    let generator = UIImpactFeedbackGenerator(style: .light)
    let coachingOverlay = ARCoachingOverlayView()
    let drawingManager = ARDrawingManager()
    var nodeManager: CustomNodeManagerProtocol = CustomNodeManager()
    var multipeerSession: MultipeerSessionManager?
    
    // MARK: View Life Cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        createGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError(ARKitError.worldTrackingNotSupported.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    /**
     Sets up delegates for the application and configurations related to ARKit and MultipeerConnectivity.
     */
    func setupScene() {
        
        /// Set the ARSCNView and ARSession delegates
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        /// Set UI delegates
        colorPickerView.collectionView.delegate = self
        strokeWidthPicker.delegate = self
        toolPickerView.toolStackView.arrangedSubviews.forEach({ button in
            if let btn = button as? ToolButton {
                btn.delegate = self
            }
        })
        
        /// Show statistics such as fps and timing information
        /// for debugging set this to true and comment in the debugOptions
        sceneView.showsStatistics = false
        //sceneView.debugOptions = [.showWorldOrigin, .showBoundingBoxes]
        
        /// set up configuration for AR session
        configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration!)
        
        /// initialize multipeer connection
        multipeerSession = MultipeerSessionManager(receivedDataHandler: receivedData)
        multipeerSession?.set(delegate: self)

        /// Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        /// set delegate for node manager
        nodeManager.set(delegate: self)
        
        /// add coaching overlay for initial AR tracking onboarding routine
        addCoaching()
    }
    
    /// Sets up UI for collaboration meaning that undo, redo and transform functionality is disabled and collaboration button is colored green.
    func updateUIForCollaboration() {
        collaborationButton.tintColor = #colorLiteral(red: 0.01176470588, green: 0.6, blue: 0.4862745098, alpha: 1)
        undoStackView.isHidden = true
        toolPickerView.mover.isHidden = true
    }
    
    /// Sets up the UI so that all tools and editing functions are enabled.
    func updateUIForSingleUse() {
        collaborationButton.tintColor = .white
        undoStackView.isHidden = false
        connectionView.isHidden = true
    }
    
    /**
     Creates the GesutreRecognizers for the [TouchGestures](x-source-tag://TouchGestures) of this view
     in order to be able to detect if the user is drawing, transforming or deleting [CustomNodes](x-source-tag://CustomNodeProtocol).
    */
    func createGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        sceneView.addGestureRecognizer(longPress)
      
        let scale = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        scale.delegate = self
        sceneView.addGestureRecognizer(scale)

        let oneFingerPan = UIPanGestureRecognizer(target: self, action: #selector(draw(gesture:)))
        oneFingerPan.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(oneFingerPan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        sceneView.addGestureRecognizer(tap)
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotation(_:)))
        sceneView.addGestureRecognizer(rotation)
    }
    
    /**
     Resets the AR session and any related objects by deleting all stored [CustomNodes](x-source-tag://CustomNodeProtocol) and [CustomLineAnchor](x-source-tag://CustomLineAnchor)
     and [ARConfiguration](https://developer.apple.com/documentation/arkit/arconfiguration).
     It also notifies any connected peer of this action and resets the MultipeerSession properties.
     */
    func resetARTracking() {
        guard let configuration = sceneView.session.configuration else {
            print("A configuration is required")
            return
        }
        nodeManager.deleteAllNodes()
        multipeerSession?.notifyPeers(didRemoveAllNodes: self.drawingManager.identifier.uuidString)
        removeAllAnchors(with: drawingManager.identifier.uuidString)
        multipeerSession?.reset()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    /**
     Presents alert message, that peer wants to connect with the device.
     */
    func showAlertInstructions(peerName: String) {
        let alert = UIAlertController(title: "Received Invite from \(peerName)", message: "Hold your phone next to your friends to join their workspace!", preferredStyle: .alert)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
            
            Timer.scheduledTimer(withTimeInterval: 4.0,
                                 repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        }
    }
}

// MARK: IBActions
extension ARSketchViewController {
    
    /**
     Shows reset tracking alert message ensuring that user wants to proceed with this action.
     */
    /// - Tag: IBActions
    @IBAction func resetTracking(_ sender: UIButton?) {
        let alert = UIAlertController(title: "restart_title".localized,
                                      message: "restart_message".localized,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "yes".localized, style: .destructive, handler: { (action: UIAlertAction) in
            self.resetARTracking()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /**
     Shows different alerts depending if a user is currently in the area and able to connect to another peer, if peers are already connected or if no user is in the area
     in order to give options on how to proceed.
     */
    @IBAction func enableCollaboration(_ sender: Any) {
        
        guard let multipeerSession = multipeerSession else { return }
 
        if !multipeerSession.connectedPeers.isEmpty && !multipeerSession.worldMapInitiated {
            let connectedPeer: String = multipeerSession.connectedPeers.first?.displayName ?? "unknown"
            let message: String = "\nDo you want to share your workspace with \(connectedPeer)"
            let alert = UIAlertController(title: "collaborate_title".localized,
                                          message: message,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            alert.addAction(
                UIAlertAction(title: "yes".localized, style: .destructive,
                              handler: { (action: UIAlertAction) in
                self.shareSession()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        else if multipeerSession.worldMapInitiated {
            let alert = UIAlertController(title: "Already connected",
                                          message: "You are already connected with \(String(describing: multipeerSession.mapProvider?.displayName))",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            
        else {
            
            let alert = UIAlertController(title: "collaboration_failed_title".localized,
                                          message: "collaboration_failed_message".localized,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     Performs undo action on [CustomNodes](x-source-tag://CustomNodeProtocol)
     via the [CustomNodeManager](x-source-tag://CustomNodeManager).
     */
    @IBAction func undoButtonTapped(_ sender: Any) {
        nodeManager.undoLastNode()
    }
    
    /**
     Performs redo action on [CustomNodes](x-source-tag://CustomNodeProtocol)
     via the [CustomNodeManager](x-source-tag://CustomNodeManager).
     */
    @IBAction func redoButtonTapped(_ sender: Any) {
        nodeManager.redoLastNode()
        
    }
    
    /**
     Shows alert message for deleting the entire sketch ensuring
     that user wants to proceed with this action.
     */
    @IBAction func deleteAllButtonTapped(_ sender: Any) {
        
        if !nodeManager.nodeCollection.isEmpty {
        
        let alert = UIAlertController(title: "Delete Sketch?", message: "Do you really want to delete your sketch?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction) in
            
            self.nodeManager.deleteAllNodes()
            self.multipeerSession?.notifyPeers(didRemoveAllNodes: self.drawingManager.identifier.uuidString)
            
        })
        alert.addAction(yes)
        alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Nothing to delete", message: "There is nothing to delete", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    /**
     Shows or hides the [ColorPickerView](x-source-tag://ColorPickerView)
     depending on the selected state of the color picker button.
     */
    @IBAction func didTapColorPicker(_ sender: Any) {
        colorPickerView.isHidden = !colorPickerView.isHidden
        colorPicker.isSelected = !colorPickerView.isHidden
    }
}

// MARK: ARSceneNodeManagerDelegate
extension ARSketchViewController: ARSceneNodeManagerDelegate {

    /// - Tag: ARSceneNodeManagerDelegate
    func didAdd(node: CustomNodeProtocol) {
        sceneView.scene.rootNode.addChildNode(node)
    }

    func didDelete(node: CustomNodeProtocol) {
        sceneView.scene.rootNode.enumerateChildNodes({ n, _ in
            if let n = n as? CustomNodeProtocol {
                if n.uuid == node.uuid {
                    n.removeFromParentNode()
                }
            }
        })
    }

    func didRemoveAllNodes(){
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if let node = node as? CustomNodeProtocol {
                node.removeFromParentNode()
            }
        }
    }
}

// MARK: UICollectionViewDelegate
extension ARSketchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CustomColorPickerCell
        drawingManager.strokeColor = cell?.backgroundColor ?? UIColor.systemPink
        self.colorPicker.backgroundColor = drawingManager.strokeColor
        self.colorPickerView.isHidden = true
        self.colorPicker.isSelected = false
    }
}

// MARK: CustomStrokeWithDelegate
extension ARSketchViewController: CustomStrokeWithDelegate {

    func didSelectStroke(strokeWidthSettings: PencilSettings.StrokeWidth) {
        drawingManager.currentPencilSettings.strokeWidthSettings = strokeWidthSettings
    }
}

// MARK: ARCollaborationDelegate
extension ARSketchViewController: ARCollaborationDelegate {
    
    func didLosePeer() {
        let alert = UIAlertController(title: "lost_connection_title".localized,
                                      message: "lost_connection_message".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "keep_drawing".localized, style: .cancel, handler:{  (action: UIAlertAction) in

            self.multipeerSession?.reset()
            self.updateUIForSingleUse()
        }))
        
        alert.addAction(UIAlertAction(title: "restart".localized, style: .destructive, handler: {  (action: UIAlertAction) in
            // das gesamte Tracking wird geupdated inclusive Collaboration
            self.resetARTracking()
            self.updateUIForSingleUse()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
