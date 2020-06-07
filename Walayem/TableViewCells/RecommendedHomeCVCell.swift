//
//  RecommendedHomeCVCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/2/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher
import SDWebImage

class RecommendedHomeCVCell: UICollectionViewCell {
    
    // MARK: Prpoerties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var food: Food!{
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        foodImageView.layer.cornerRadius = 15
        foodImageView.layer.masksToBounds = true
        bottomView.roundCorners([.bottomLeft, .bottomRight], radius: 15)
                
        nameLabel.text = food.name
        priceLabel.text = "AED \(food.price ?? 0)"
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id ?? 0)/image")
//        foodImageView.kf.setImage(with: imageUrl)
//        foodImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        foodImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
    }
    
}
