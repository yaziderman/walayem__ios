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
        
        var statusImage: UIImage?
        switch order.state {
        case .sale, .done, .cooking, .ready:
            statusImage = UIImage(named: "ongoing")
        case .delivered:
            statusImage = UIImage(named: "completed")
        case .cancel, .rejected, .draft:
            statusImage = UIImage(named: "cancelled")
        }
        statusImageView.image = statusImage!
    }

}
