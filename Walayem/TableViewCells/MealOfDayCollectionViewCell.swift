//
//  MealOfDayCollectionViewCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/2/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

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
                
//          let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id)/image")
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/987/image")
//        imageView.kf.setImage(with: imageUrl)

                imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                imageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
    }
    
}
