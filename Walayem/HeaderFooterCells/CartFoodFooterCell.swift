//
//  CartFoodFooterCell.swift
//  Walayem
//
//  Created by Inception on 5/25/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

protocol CartFoodFooterDelegate{
    func updateNote(sender: UITextField, section: Int)
}

class CartFoodFooterCell: UITableViewHeaderFooterView, UITextFieldDelegate{

    // MARK: Properties
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        let icon = UIImage(named: "information")
        imageView.image = icon
        imageView.tintColor = UIColor.silver
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let noteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Tap to enter a note for the chef"
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.tintColor = UIColor.colorPrimary
        textField.textColor = UIColor.lightGray
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    var delegate: CartFoodFooterDelegate?
    var section: Int?
    
    // MARK: Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: Private methods
    
    private func setViews(){
        self.contentView.backgroundColor = UIColor.white
        self.addSubview(iconView)
        self.addSubview(noteTextField)
        noteTextField.delegate = self
        
        iconView.heightAnchor.constraint(equalToConstant: 17).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 17).isActive = true
        
        let guide = self.readableContentGuide
        iconView.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        iconView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        noteTextField.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        noteTextField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12).isActive = true
        noteTextField.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        noteTextField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
        
        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13.5-[v0]-13.5-|", options: [], metrics: nil, views: ["v0" : iconView]))
        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-12-[v1]-20-|", options: .alignAllCenterY, metrics: nil, views: ["v0": iconView, "v1": noteTextField]))
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.updateNote(sender: textField, section: section!)
    }

}
