//
//  ChefFoodCell.swift
//  Walayem
//
//  Created by MAC on 5/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChefFoodCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var food: Food!{
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        foodImageView.layer.cornerRadius = 15
        foodImageView.layer.masksToBounds = true
        
        if !food.paused{
            nameLabel.text = food.name
        }else{
            nameLabel.text = "\u{23F8} " + (food.name ?? "")
        }
        
        priceLabel.text = "AED \(food.price ?? 0)"
        var tagString = ""
        for tag in food.tags{
            tagString.append(tag.name ?? "")
            if let lastTag = food.tags.last, lastTag !== tag{
                tagString.append(" \u{2022} ")
            }
        }
        tagsLabel.text = tagString
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id ?? 0)/image")
        foodImageView.kf.setImage(with: imageUrl)
    }
}
