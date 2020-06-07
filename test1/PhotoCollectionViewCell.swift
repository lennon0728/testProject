
//
//  PhotoCollectionViewCell.swift
//  test1
//
//  Created by Curry Lee on 15/07/2019.
//  Copyright © 2019 wanseok lee. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        
    }
    
}
