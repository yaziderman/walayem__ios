//
//  CartFoodTableViewCell.swift
//  Walayem
//
//  Created by MAC on 5/7/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import ImageLoader
import SDWebImage

protocol CartFoodCellDelegate {
    func didTapAddItem(sender: CartFoodTableViewCell)
    func didTapRemoveItem(sender: CartFoodTableViewCell)
}

class CartFoodTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var subjectToDeliveryLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    var delegate: CartFoodCellDelegate?
    
    private var food: Food!
    
    func set(food: Food, deliveryCharge: Double?) {
        self.food = food
        updateUI(deliveryCharge: deliveryCharge)

//        didSet{
//            updateUI()
//        }
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
    
    private func updateUI(deliveryCharge: Double?) {
        foodImageView.layer.cornerRadius = 12
        foodImageView.layer.masksToBounds = true
        
        nameLabel.text = food.name
        priceLabel.text = "AED \(food.price)"
        quantityLabel.text = String(food.quantity)
        
        if deliveryCharge != nil {
            subjectToDeliveryLabel.isHidden = true
        } else {
            subjectToDeliveryLabel.isHidden = false
            let red = "*"
            let stringValue = "\(red)Subject to delivery fees"
            subjectToDeliveryLabel.textColor = UIColor.rosa
            subjectToDeliveryLabel.text = stringValue
        }
        let red = "*"
        let stringValue = "\(red)Subject to delivery fees"
        subjectToDeliveryLabel.textColor = UIColor.rosa
        subjectToDeliveryLabel.text = stringValue
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id ?? 0)/image")!
        
        foodImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        foodImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
        
    }
	
}
