//
//  FilterCollectionViewCell.swift
//  test1
//
//  Created by Curry Lee on 15/07/2019.
//  Copyright © 2019 wanseok lee. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool{
        didSet{
            self.imageView.layer.borderWidth = isSelected ? 4.0 : 0
            self.imageView.alpha = isSelected ? 0.7 : 1.0
            super.isSelected = isSelected
        }
    }
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
}

extension FilterCollectionViewCell{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.filterNameLabel.layer.shadowColor = UIColor.black.cgColor
        filterNameLabel.layer.shadowRadius = 3.0
        filterNameLabel.layer.shadowOpacity = 1.0
        filterNameLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        filterNameLabel.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.imageView.layer.borderWidth = 0
        self.imageView.alpha = 1.0
        self.filterNameLabel.text = nil
    }
}
