//
//  CartFoodTableViewCell.swift
//  Walayem
//
//  Created by MAC on 5/7/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

protocol CartFoodCellDelegate {
    func didTapAddItem(sender: CartFoodTableViewCell)
    func didTapRemoveItem(sender: CartFoodTableViewCell)
}

class CartFoodTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    var delegate: CartFoodCellDelegate?
    
    var food: Food!{
        didSet{
            updateUI()
        }
    }
    
    // MARK: Actions
    @IBAction func addItem(_ sender: UIButton) {
        food.quantity += 1
        quantityLabel.text = String(food.quantity)
        delegate?.didTapAddItem(sender: self)
    }
    
    @IBAction func subtractItem(_ sender: UIButton) {
        if food.quantity > 0{
            food.quantity -= 1
            quantityLabel.text = String(food.quantity)
            delegate?.didTapRemoveItem(sender: self)
        }
    }
    
    private func updateUI(){
        foodImageView.layer.cornerRadius = 12
        foodImageView.layer.masksToBounds = true
        
        nameLabel.text = food.name
        priceLabel.text = "AED \(food.price)"
        quantityLabel.text = String(food.quantity)
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id)/image")
        foodImageView.kf.setImage(with: imageUrl)
    }
}
