//
//  AddressTableViewCell.swift
//  Walayem
//
//  Created by MAC on 5/6/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var address: Address!{
        didSet{
            updateUI()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func updateUI(){
        titleLabel.text = address.name
        descriptionLabel.text = address.city + ", " + address.street + ", " + address.extra
    }

}
