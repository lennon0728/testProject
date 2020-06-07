//
//  AlbumCollectionViewCell.swift
//  test1
//
//  Created by Curry Lee on 15/07/2019.
//  Copyright © 2019 wanseok lee. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 5.0
    }
    
    override func prepareForReuse() { //재사용될때 호출될 메세지
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        countLabel.text = nil
    }
    
    
}
