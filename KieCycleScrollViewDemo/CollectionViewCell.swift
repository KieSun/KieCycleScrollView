//
//  CollectionViewCell.swift
//  KieCycleScrollViewDemo
//
//  Created by 俞诚恺 on 16/6/17.
//  Copyright © 2016年 Kie. All rights reserved.
//

import UIKit
import SnapKit

class CollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return "\(self)"
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
}
