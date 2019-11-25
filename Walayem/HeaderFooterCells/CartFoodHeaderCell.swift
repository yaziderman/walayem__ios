//
//  CartFoodHeaderCell.swift
//  Walayem
//
//  Created by Inception on 5/23/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher

protocol CartFoodHeaderDelegate{
    func toggleSection(section: Int)
}

class CartFoodHeaderCell: UITableViewHeaderFooterView {

    // MARK: Properties
    
    @IBOutlet weak var chefImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var kitchenLabel: UILabel!
    @IBOutlet weak var caretIcon: UIImageView!
    
    var delegate: CartFoodHeaderDelegate?
    var section : Int?
    var chef: Chef!{
        didSet{
            updateUI()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectAction)))
    }
    
    @objc private func selectAction(sender: UITapGestureRecognizer){
        delegate?.toggleSection(section: section!)
    }
    
    private func updateUI(){
        chefImageView.layer.cornerRadius = 12
        chefImageView.layer.masksToBounds = true
        
        nameLabel.text = chef.name
        kitchenLabel.text = chef.kitchen
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/api/chefImage/\(chef.id)-\(chef.image!)/image_medium")
        chefImageView.kf.setImage(with: imageUrl)
        
    }
}
