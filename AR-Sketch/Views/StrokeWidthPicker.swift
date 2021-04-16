//
//  StrokeWidthPicker.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 31.07.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//


import UIKit

protocol CustomStrokeWithDelegate {
    
    /**
     Updates the stroke settings in [ARDrawingManager](x-source-tag://ARDrawingManager)
     once user selected a different stroke width.
     */
    func didSelectStroke(strokeWidthSettings: PencilSettings.StrokeWidth)
}

/**
 The StrokeWidthPicker represents the overlay for selecting different stroke widths.
 */
/// - Tag: StrokeWidthPicker
class StrokeWidthPicker: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var small: UIButton!
    @IBOutlet weak var medium: UIButton!
    @IBOutlet weak var large: UIButton!
    
    var delegate: CustomStrokeWithDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("StrokeWidthPicker", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
       
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    @IBAction func didTapSmall(_ sender: Any) {
        delegate?.didSelectStroke(strokeWidthSettings: .small)
        self.isHidden = !self.isHidden

    }
    
    @IBAction func didTapMedium(_ sender: Any) {
        delegate?.didSelectStroke(strokeWidthSettings: .medium)
        self.isHidden = !self.isHidden

    }
    
    @IBAction func didTapLarge(_ sender: Any) {
        delegate?.didSelectStroke(strokeWidthSettings: .large)
        self.isHidden = !self.isHidden

    }
}
