//
//  OrderHeaderCell.swift
//  Walayem
//
//  Created by Inception on 5/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

protocol OrderHeaderCellDelegate {
    func toggleSection(section: Int)
}

class OrderHeaderCell: UITableViewHeaderFooterView {

    // MARK: Properties
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        let icon = UIImage(named: "notes")
        imageView.image = icon
        imageView.tintColor = UIColor.peach
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.slateGrey
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let caret: UIImageView = {
        let imageView = UIImageView()
        let icon = UIImage(named: "caretRight")
        imageView.image = icon
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    var section: Int?
    var delegate: OrderHeaderCellDelegate?
    
    // MARK: Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setViews()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: Private methods
    
    private func setViews(){
        self.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(caret)
        
        iconView.heightAnchor.constraint(equalToConstant: 17).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 17).isActive = true
        caret.heightAnchor.constraint(equalToConstant: 17).isActive = true
        caret.widthAnchor.constraint(equalToConstant: 17).isActive = true
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13.5-[v0]-13.5-|", options: [], metrics: nil, views: ["v0" : iconView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-12-[v1]-12-[v2]-20-|", options: .alignAllCenterY, metrics: nil, views: ["v0": iconView, "v1": titleLabel, "v2": caret]))
    }
    
    @objc private func selectAction(sender: UITapGestureRecognizer){
        delegate?.toggleSection(section: section!)
    }
    
}
