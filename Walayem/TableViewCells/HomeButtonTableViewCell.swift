//
//  HomeButtonTableViewCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/4/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class HomeButtonTableViewCell: UITableViewCell {

    var parent: UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func browseMealsPressed(_ sender: Any) {
        print("This will take you towards Root of Discover food tab.")
        
        let viewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        StaticLinker.mainVC = viewController
        self.parent!.present(viewController, animated: true, completion: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
