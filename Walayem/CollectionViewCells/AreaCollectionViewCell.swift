//
//  AreaCollectionViewCell.swift
//  Walayem
//
//  Created by Naveed on 01/05/2020.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

protocol AreaCollectionViewCellDelegate {
    func itemCicked(index: Int)
    func didSelectArea(value: String)
}

class AreaCollectionViewCell: UICollectionViewCell, LabelViewDelegate {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleText: UILabel!
    
    var delegate: AreaCollectionViewCellDelegate!
    var index: Int!
    var isExpanded: Bool = false
    
    func setData(data: [String: Any], index: Int, isExpanded: Bool) {
        self.titleText.text = data["title"] as! String
        self.index = index
        self.isExpanded = isExpanded
        if let array = data["sub_items"] as? [String], isExpanded == true {
            self.populateStackView(array: array)
        } else {
            self.stackView.removeAllSubviews()
            self.stackViewHeightConstraint.constant = 1
        }
    }
    
    @IBAction func itemClicked(_ sender: Any) {
        self.delegate.itemCicked(index: self.index)
    }
    
    func populateStackView(array: [String]) {
        self.stackView.removeAllSubviews()
        self.stackViewHeightConstraint.constant = 0
        self.stackView.distribution = .fillEqually
        for item in array {
            let view = Bundle.main.loadNibNamed("LabelView", owner: self, options: nil)?.last as! LabelView
//            view.frame = CGRect(x: 0, y: 0, width: self.stackView.frame.size.width, height: 40)
            view.titleText.text = item
            view.delegate = self
            self.stackView.addArrangedSubview(view)
            self.stackViewHeightConstraint.constant = self.stackViewHeightConstraint.constant + 40
        }
        print(self.stackViewHeightConstraint.constant)
    }
    
    class func getHeight(data: [String: Any]) -> Int {
        var initialHeight = 40
        if let array = data["sub_items"] as? [String], let isExpanded = data["isExpanded"] as? Bool, isExpanded == true  {
            for item in array {
                initialHeight = initialHeight + 40
            }
        }
        return initialHeight
    }
    
    func didTapItem(value: String) {
        self.delegate.didSelectArea(value: value)
    }
}
