//
//  FoodTableViewCell.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher
import SDWebImage
//import ImageLoader
//import PINRemoteImage

protocol FoodCellDelegate {
    func didTapAddItem(sender: FoodTableViewCell)
    func didTapRemoveItem(sender: FoodTableViewCell)
//    func refreshTableViewCell()
}

class FoodTableViewCell: UITableViewCell{
    
//    func refreshTableViewCell() {
//        print("refreshTableViewCell------------------------------------------")
////        quantityLabel.text = String(food.quantity)
//    }
    
    
    // MARK: Properties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    
    var numberOfServesLabel: String?
    let db = DatabaseHandler()
    
    var delegate: FoodCellDelegate?
    
    var food: Food!{
        didSet{
            updateUI()
        }
    }
    
    // MARK: Actions
    
    @IBAction func addItem(_ sender: UIButton) {
		delegate?.didTapAddItem(sender: self)
//		let foodList = db.getFoods()
//		for f in foodList {
//			if f.id == food.id {
//				quantityLabel.text = String(f.quantity + 1)
//				break
//			}
//		}
    }
    
    @IBAction func subtractItem(_ sender: UIButton) {
		delegate?.didTapRemoveItem(sender: self)
//        if food.quantity > 0{
//            food.quantity -= 1
//            quantityLabel.text = String(food.quantity)
//            delegate?.didTapRemoveItem(sender: self)
//        }
    }
    
    
    func updateUI(){
//        food.quantity = 0
        foodImageView.layer.cornerRadius = 12
        foodImageView.layer.masksToBounds = true
        nameLabel.text = food.name
//        let time = Int(max(1, round( Double(food.preparationTime) / 60.0)))
//        timeLabel.text = "\(time) hour(s)"
        numberOfServesLabel = "Serves \(food.servingQunatity) people"
        priceLabel.text = "AED \(food.price ?? 0)"
        quantityLabel.text =  String(food.quantity)
        descriptionLabel.text = food.kitcherName! + " \u{2022} " + food.chefName!
        
        timeLabel.text = numberOfServesLabel
        
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id ?? 0)/image_medium")
//        foodImageView.kf.setImage(with: imageUrl)
//        foodImageView.load
//        foodImageView.load.request(with: imageUrl) // using ImageLoader
//        foodImageView.pin_setImage(from: URL(string:imageUrl)!)
        foodImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        foodImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
		refreshCell()
//        ImageLoader
    }
    
    func refreshCell(){
		let foodList = db.getFoods()
		for f in foodList {
			if f.id == food.id {
				quantityLabel.text = String(f.quantity)
				break
			}
		}
    }
    
}
