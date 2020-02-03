//
//  MealOfDayCollectionViewCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/2/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import UIKit

class MealOfDayCollectionViewCell:UICollectionViewCell {
    
    // MARK: Prpoerties
    
    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var bottomView: UIView!
    
    var food: Food!{
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
                
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id)/image")
        imageView.kf.setImage(with: imageUrl)
    }
    
}
