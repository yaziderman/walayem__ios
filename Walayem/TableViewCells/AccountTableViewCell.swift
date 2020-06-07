//
//  AccountTableViewCell.swift
//  Walayem
//
//  Created by MACBOOK PRO on 5/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var orderslabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
   
    @IBOutlet weak var stateImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var account: Account!{
        didSet{
            updateUI()
        }
    }

    
    private func updateUI(){
        
        
        monthLabel.text = Utils.getMonthName(account.month!)
        orderslabel.text = "\(account.orders_count) orders"
        priceLabel.text = "AED \(String(describing: account.amount_total!))"
        
        var image: UIImage!
        switch account.state {
        case -1:
            image = UIImage(named: "downIcon")
        case 0:
            image = UIImage(named: "sameIcon")
        case 1:
            image = UIImage(named: "upIcon")
        default:
             image = UIImage(named: "sameIcon")
        }
        stateImage.image = image!
    }

}
