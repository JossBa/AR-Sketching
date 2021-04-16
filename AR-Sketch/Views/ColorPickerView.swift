//
//  ColorPickerView.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 06.06.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import UIKit

/**
 The ColorPickerView represents the color overlay for selecting different colors.
 */
/// - Tag: ColorPickerView
class ColorPickerView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("ColorPickerView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.collectionView.register(UINib(nibName: "CustomColorPickerCell", bundle: nil), forCellWithReuseIdentifier: "CustomColorPickerCell")
        collectionView.dataSource = self
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
}

extension ColorPickerView: UICollectionViewDataSource {
    
    var colors: [UIColor]  {
        
        return [UIColor.red,
                UIColor.systemRed,
                UIColor.orange,
                UIColor.systemOrange,
                UIColor.systemYellow,
                UIColor.yellow,
                UIColor.green,
                UIColor.systemGreen,
                UIColor.systemTeal,
                UIColor.systemBlue,
                UIColor.systemIndigo,
                UIColor.blue,
                UIColor.systemPink,
                UIColor.magenta,
                UIColor.systemPurple,
                UIColor.purple,
                UIColor.white,
                UIColor.lightGray,
                UIColor.systemGray,
                UIColor.darkGray,
                UIColor.black]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomColorPickerCell", for: indexPath) as! CustomColorPickerCell
        cell.layer.cornerRadius = 20 ;
        cell.layer.masksToBounds = true;
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }
    
}
