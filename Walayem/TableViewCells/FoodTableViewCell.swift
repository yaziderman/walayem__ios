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
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
	@IBOutlet weak var indicatorLabel: UILabel!
	@IBOutlet weak var strikethroughLabelWidth: NSLayoutConstraint!
	
    
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
        
        if food.name != nil {
            nameLabel.text = food.name
        }
//        let time = Int(max(1, round( Double(food.preparationTime) / 60.0)))
//        timeLabel.text = "\(time) hour(s)"
        
        
//        if(food.original_price != 0.0){
//            if food.original_price > food.price {
//                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "AED \(food.original_price)")
//                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
//
//                priceLabel.attributedText = attributeString
//                discountedPriceLabel.text = "AED \(food.price ?? 0)"
//            }else{
//                priceLabel.text = "AED \(food.price ?? 0)"
//                discountedPriceLabel.isHidden = true
//            }
//        }else{
//            priceLabel.text = "AED \(food.price ?? 0)"
//            discountedPriceLabel.isHidden = true
//        }
        
        numberOfServesLabel = "Serves \(food.servingQunatity) people"
		
		if Int(food.original_price ?? 0) > 0 {
			strikethroughLabelWidth.constant = 43
			priceLabel.isHidden = false
			
			let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "AED \(food.original_price ?? 0)")
			attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
			
			priceLabel.attributedText = attributeString
			
			discountedPriceLabel.text = "AED \(food.price)"
			discountedPriceLabel.textColor = UIColor(hexString: "#f07a7a")
			indicatorLabel.isHidden = true
		} else {
			discountedPriceLabel.text = "AED \(food.price)"
			priceLabel.isHidden = true
			strikethroughLabelWidth.constant = 0
			discountedPriceLabel.textColor = UIColor(hexString: "#d3d3d3")
			indicatorLabel.isHidden = true
		}
		
        
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
