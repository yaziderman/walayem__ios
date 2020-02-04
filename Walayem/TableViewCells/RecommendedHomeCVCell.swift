//
//  RecommendedHomeCVCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/2/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher

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
        priceLabel.text = "AED \(food.price)"
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id)/image")
        foodImageView.kf.setImage(with: imageUrl)
    }
    
}