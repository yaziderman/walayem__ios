//
//  LabelView.swift
//  Walayem
//
//  Created by Naveed on 01/05/2020.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

protocol LabelViewDelegate {
    func didTapItem(value: String)
}

class LabelView: UIView {

    @IBOutlet weak var titleText: UILabel!
    
    var delegate: LabelViewDelegate?
    
    @IBAction func didTapItem(_ sender: Any) {
        self.delegate?.didTapItem(value: self.titleText.text!)
    }
}
