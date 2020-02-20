//
//  AreaViewCell.swift
//  Walayem
//
//  Created by Ramzi Shadid on 2/16/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class AreaViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!

     var area: Area!{
           didSet{
               updateUI()
           }
       }
       
    private func updateUI(){
        nameLabel.text = area.name
        arrowImageView.tintColor = area.isSelected ? UIColor.colorPrimary : UIColor.silver
    }

}
