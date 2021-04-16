//
//  ToolPickerView.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 01.08.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit

/**
 The ToolPickerView represents the overlay for selecting different stroke widths.
 */
/// - Tag: ToolPickerView
class ToolPickerView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var toolStackView: UIStackView!

    @IBOutlet weak var pen: ToolButton! {
        didSet { pen.buttonStyle = .pen
            pen.isSelected = true
        }
    }
    
    @IBOutlet weak var marker: ToolButton! {
        didSet { marker.buttonStyle = .marker }
    }
    
    @IBOutlet weak var erasor: ToolButton! {
        didSet { erasor.buttonStyle = .erasor }
    }
    
    @IBOutlet weak var mover: ToolButton! {
        didSet { mover.buttonStyle = .transform }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("ToolPickerView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
}
