//
//  ChefOrderFoodCell.swift
//  Walayem
//
//  Created by MAC on 5/18/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChefOrderFoodCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var food: Food!{
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        foodImageView.layer.cornerRadius = 12
        foodImageView.layer.masksToBounds = true
        
        nameLabel.text = food.name
        quantityLabel.text = "Quantity \(food.quantity)"
        priceLabel.text = "AED \(food.price ?? 0)"
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id ?? 0)/image")
        foodImageView.kf.setImage(with: imageUrl)
    }
    
}
