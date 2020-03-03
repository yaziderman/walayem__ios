//
//  RecommendationCollectionViewCell.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher
import SDWebImage
import ImageLoader

class RecommendationCollectionViewCell: UICollectionViewCell {
    
    // MARK: Prpoerties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var food: Food!{
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        foodImageView.layer.cornerRadius = 15
        foodImageView.layer.masksToBounds = true
        
        nameLabel.text = food.name
        priceLabel.text = "AED \(food.price ?? 0)"
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id ?? 0)/image")
//        foodImageView.kf.setImage(with: imageUrl)
        foodImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        foodImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
//        foodImageView.load.request(with: imageUrl!) // using ImageLoader
    }
    
}
