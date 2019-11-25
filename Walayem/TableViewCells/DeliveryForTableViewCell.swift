//
//  DeliveryForTableViewCell.swift
//  Walayem
//
//  Created by Inception on 8/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class DeliveryForTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    var title_text: String!{
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        titleLabel.text = title_text
        icon.tintColor = UIColor.silverTen
    }

}
