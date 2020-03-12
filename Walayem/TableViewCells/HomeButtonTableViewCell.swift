//
//  HomeButtonTableViewCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/4/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class HomeButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    var parent: UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
//        button.shake()
//         Initialization code
    }

    @IBAction func browseMealsPressed(_ sender: Any) {
        
//        button.shake()
        
        print("This will take you towards Root of Discover food tab.")
        StaticLinker.mainVC?.selectedIndex = 1;
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
