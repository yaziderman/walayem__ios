//
//  OrderTableViewCell.swift
//  Walayem
//
//  Created by MAC on 5/9/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    //  MARK: Properties
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cancelledLabel: UILabel!
    
    var order: Order!{
        didSet{
            updateUI()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func updateUI(){
        nameLabel.text = order.chefName
        descriptionLabel.text = "#WA\(order.id) \u{2022} \(order.foods!.compactMap({ $0 }).joined())"
        timeLabel.text = Utils.getDay(order.date)
        priceLabel.text = "AED \(order.amount)"
//        cancelledLabel.layer.borderWidth = 1
        cancelledLabel.layer.borderColor = UIColor.rosa.cgColor
        cancelledLabel.textColor = .rosa
        
        var statusImage: UIImage?
        switch order.state {
        case .sale, .done, .cooking, .ready:
            statusImage = UIImage(named: "ongoing")
            cancelledLabel.isHidden = true
        case .delivered:
            statusImage = UIImage(named: "completed")
            cancelledLabel.isHidden = true
        case .cancel, .rejected:
            statusImage = UIImage(named: "cancelled")
            cancelledLabel.isHidden = false
        default:
            statusImage = UIImage(named: "ongoing")
        }
        statusImageView.image = statusImage!
    }

}
