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
    private var deliveryCharge: Double?
    
    private var iconView: UIImageView!
	
    private func setupIconView() {
        let imageView = UIImageView()
        if self.deliveryCharge != nil {
            imageView.image = UIImage(named: "delivery")
        } else {
            imageView.image = UIImage(named: "money")
        }
//        imageView.tintColor = UIColor.silver
//        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.init(light: .white, dark: .black)
        self.iconView = imageView
    }

	public var foods = [Food]()
    
//    let iconView: UIImageView = {
//        let imageView = UIImageView()
//        let icon = UIImage(named: "money")
//        imageView.image = icon
//        imageView.tintColor = UIColor.silver
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = UIColor.init(light: .white, dark: .black)
//        return imageView
//    }()
    
    
    let iconView1: UIImageView = {
        let imageView = UIImageView()
        let icon = UIImage(named: "information")
        imageView.image = icon
        imageView.tintColor = UIColor.silver
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.init(light: .white, dark: .black)
        
        return imageView
    }()
    
    
    let iconView2: UIImageView = {
        let imageView = UIImageView()
        let icon = UIImage(named: "information")
        imageView.image = icon
        imageView.tintColor = UIColor.colorPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = UIColor.init(light: .white, dark: .black)
        
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
//        textField.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
        return textField
    }()
    

	private var homeLabel: UILabel!
    private func setupHomeLable() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if let deliveryCharge = self.deliveryCharge {
            label.text = "+Delivery Fees AED \(deliveryCharge)"
            if #available(iOS 13.0, *) {
                label.textColor = .label
            } else {
                label.textColor = .black
            }
        } else {
            label.text = "Cash on delivery"
            label.textColor = UIColor.lightGray
        }
        label.font = label.font.withSize(16)
        label.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
        self.homeLabel = label
    }

//	let homeLabel: UILabel = {
//        let textField = UILabel()
//        textField.textColor = UIColor.lightGray
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.text = "Cash on delivery"
//        textField.font = textField.font.withSize(16)
//        textField.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
//        return textField
//    }()

	
    let deliveryLabel: UILabel = {
        let textField = UILabel()
        textField.textColor = UIColor.lightGray
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Delivery in approximately"
        textField.font = textField.font.withSize(16)
        textField.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)

        return textField
    }()
    
    var delegate: CartFoodFooterDelegate?
    var section: Int?
    
    // MARK: Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(foods: [Food], deliveryCharge: Double?) {
        self.deliveryCharge = deliveryCharge
        setupIconView()
        setupHomeLable()
	}
        
    
    // MARK: Private methods
    
    private func setViews(){

        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13.5-[v0]-13.5-|", options: [], metrics: nil, views: ["v0" : iconView]))
        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-12-[v1]-20-|", options: .alignAllCenterY, metrics: nil, views: ["v0": iconView, "v1": noteTextField]))
    }
    
    public func update()
    {
        iconView.removeFromSuperview()
        iconView2.removeFromSuperview()
        iconView1.removeFromSuperview()
        homeLabel.removeFromSuperview()
        deliveryLabel.removeFromSuperview()
        noteTextField.removeFromSuperview()
        
            self.contentView.backgroundColor = UIColor.white
            let guide = self.readableContentGuide
           let orderType = UserDefaults.standard.string(forKey: "OrderType") ?? "asap"
            
            if(orderType == "asap")
            {

                self.addSubview(iconView)
                self.addSubview(iconView2)
                self.addSubview(iconView1)
                self.addSubview(homeLabel)
                self.addSubview(deliveryLabel)
                self.addSubview(noteTextField)
                
                noteTextField.delegate = self
                
                iconView.heightAnchor.constraint(equalToConstant: 17).isActive = true
                iconView.widthAnchor.constraint(equalToConstant: 17).isActive = true
                
                iconView1.heightAnchor.constraint(equalToConstant: 17).isActive = true
                iconView1.widthAnchor.constraint(equalToConstant: 17).isActive = true
                
                iconView2.heightAnchor.constraint(equalToConstant: 17).isActive = true
                iconView2.widthAnchor.constraint(equalToConstant: 17).isActive = true
                
                iconView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
                iconView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
                
                iconView1.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8).isActive = true
                iconView1.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
                
                iconView2.topAnchor.constraint(equalTo: iconView1.bottomAnchor, constant: 8).isActive = true
                iconView2.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
                
                
                noteTextField.centerYAnchor.constraint(equalTo: iconView2.centerYAnchor).isActive = true
                noteTextField.leadingAnchor.constraint(equalTo: iconView2.trailingAnchor, constant: 12).isActive = true
                noteTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
                noteTextField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
                
                
                
                homeLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
                homeLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12).isActive = true
                homeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
                homeLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
                
                
                
                deliveryLabel.centerYAnchor.constraint(equalTo: iconView1.centerYAnchor).isActive = true
                deliveryLabel.leadingAnchor.constraint(equalTo: iconView1.trailingAnchor, constant: 12).isActive = true
                deliveryLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
                deliveryLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
            }
            else
            {

                self.addSubview(iconView)
                self.addSubview(iconView2)
                self.addSubview(homeLabel)
                self.addSubview(noteTextField)
                noteTextField.delegate = self
                
                iconView.heightAnchor.constraint(equalToConstant: 17).isActive = true
                iconView.widthAnchor.constraint(equalToConstant: 17).isActive = true
                            
                iconView2.heightAnchor.constraint(equalToConstant: 17).isActive = true
                iconView2.widthAnchor.constraint(equalToConstant: 17).isActive = true
                
                iconView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
                iconView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
                           
                iconView2.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8).isActive = true
                iconView2.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        //        iconView2.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
                
                
                
                noteTextField.centerYAnchor.constraint(equalTo: iconView2.centerYAnchor).isActive = true
                noteTextField.leadingAnchor.constraint(equalTo: iconView2.trailingAnchor, constant: 12).isActive = true
                noteTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
                noteTextField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
                
                
                homeLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
                homeLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12).isActive = true
                homeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
                homeLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
            }
            
        
        self.contentView.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
        
        var preparationTime = 0
        for i in 0..<foods.count
        {
            if(preparationTime < foods[i].preparationTime)
            {
                preparationTime = foods[i].preparationTime
            }
        }
        
        let hour = Int(max(1, round( Double(preparationTime) / 60.0)))
        
        deliveryLabel.text = "Delivery in approximately \(hour) hour(s) 30 mins"
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
