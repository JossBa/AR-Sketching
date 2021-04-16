//
//  ARSketchViewController+RadioButtonDelegate.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 21.11.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit


extension ARSketchViewController: RadioButtonDelegate {
    
    /**
    Handles selection of items in the [ToolPickerView](x-source-tag://ToolPickerView).
    */
    /// - Tag: RadioButtonDelegate
    func didTap(_ sender: UIView) {
        guard let sender = sender as? ToolButton else { return }
        
        toolPickerView.toolStackView.arrangedSubviews.forEach( { button in
            if let btn = button as? ToolButton {
                btn.isSelected = false
            }
        })
        
        sender.isSelected = true
        
        switch sender.buttonStyle {
        case .pen:
            drawingManager.peniclType = PencilSettings.PencilType.pencil
            colorPicker.isSelected = false
            strokeWidthPicker.isHidden = false
            
            drawingManager.isErasingNodes = false
            drawingManager.isEditingSketch = false
            
        case .marker:
            colorPicker.isSelected = false
            strokeWidthPicker.isHidden = false
            drawingManager.peniclType = PencilSettings.PencilType.marker
            
            drawingManager.isErasingNodes = false
            drawingManager.isEditingSketch = false
            
        case .erasor:
            colorPicker.isSelected = false
            strokeWidthPicker.isHidden = true
            
            drawingManager.isErasingNodes = true
            drawingManager.isDrawing = false
            drawingManager.isEditingSketch = false
        
        case .transform:
            strokeWidthPicker.isHidden = true
        
            drawingManager.isEditingSketch = true
            drawingManager.isErasingNodes = false
            let message: String = "transform_message".localized
            messageLabel.displayMessage(message, duration: 8)
        }
    }
}
