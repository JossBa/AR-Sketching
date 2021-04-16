//
//  ARSketchViewController+CoachingOverlay.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 06.06.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit
import ARKit


extension ARSketchViewController: ARCoachingOverlayViewDelegate {
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {}

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = true
    }

    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        resetARTracking()
    }
    
    /// - Tag: ARCoachingOverlayView
    func addCoaching() {
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.session = sceneView.session
        sceneView.addSubview(coachingOverlay)
        
        coachingOverlay.topAnchor.constraint(equalTo: sceneView.topAnchor).isActive = true
        coachingOverlay.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor).isActive = true
        coachingOverlay.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor).isActive = true
        coachingOverlay.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor).isActive = true
        
        /// Specify a goal for the coaching overlay, in this case, the goal is to establish world tracking
        coachingOverlay.goal = .tracking
        
        /// set activates automatically so the view appears whenever tracking quality is not sufficient
        coachingOverlay.activatesAutomatically = true
    }
}
