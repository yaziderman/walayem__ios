//
//  ChefAreaTabelViewCell.swift
//  Walayem
//
//  Created by Creative Empire on 5/1/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

protocol ChefAreaTableViewDelegate {
    func itemSelected(item: String, isSelected: Bool, section: Int, row: Int)
}

class ChefAreaTabelViewCell: UITableViewCell {

    var delegate: ChefAreaTableViewDelegate!
    
    @IBOutlet weak var AreaName: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
    @IBOutlet weak var itemBtn: UIButton!
    
    var itemName: String!
    var isItemSelected: Bool!
    var section: Int!
    var row: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
        
    @objc func itemClicked(_ sender: UIButton) {
        self.delegate.itemSelected(item: itemName, isSelected: isItemSelected, section: section, row: row)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(itemName: String, isSelected: Bool, section: Int, row: Int) {
        self.itemName = itemName
        self.isItemSelected = isSelected
        self.section = section
        self.row = row
        
        if delegate != nil {
            itemBtn.addTarget(self, action: #selector(self.itemClicked(_:)), for: .touchUpInside)
        }
        
        self.AreaName.text = itemName
        if isSelected {
            self.selectionImage.image = UIImage(named: "areaChecked")
        } else {
            self.selectionImage.image = UIImage(named: "areaUnchecked")
        }
    }

}
