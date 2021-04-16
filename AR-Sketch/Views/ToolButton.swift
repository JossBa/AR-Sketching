//
//  ToolButton.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 01.08.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit


protocol RadioButtonDelegate {
    func didTap(_ sender: UIView)
}
/// - Tag: ToolButton
class ToolButton: UIButton {

    var buttonStyle: ToolButtonStyle = .pen
    var delegate: RadioButtonDelegate?

    var defaultImage: UIImage? {
        buttonStyle.backgroundImage
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setImage(defaultImage, for: .normal)
        self.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        self.tintColor = #colorLiteral(red: 0.01176470588, green: 0.6, blue: 0.4862745098, alpha: 1)
    }
        
      @objc func buttonTapped (_ sender:UIButton) {
        if sender == self {
            delegate?.didTap(self)
        }
      }
}

enum ToolButtonStyle {
    
    case pen
    case marker
    case erasor
    case transform
    
    var backgroundImage: UIImage? {
        switch self {
        case .pen:
            return UIImage(named: "icons8-bleistiftspitze-100")
        case .marker:
            return UIImage(named: "icons8-marker-100")
        case .erasor:
            return UIImage(named: "icons8-löschen-100")
        case .transform:
            return UIImage(named: "icons8-bewegen-100")
        }
    }
}
