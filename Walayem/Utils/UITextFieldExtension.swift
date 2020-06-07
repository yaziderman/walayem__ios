//
//  UITextFieldExtension.swift
//  Walayem
//
//  Created by Wang Dan on 2019/12/19.
//  Copyright © 2019 Inception Innovation. All rights reserved.
//

import UIKit

extension UITextField{
    
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    func addImageAtLeft(_ image: UIImage?) {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imgView.image = image
        imgView.contentMode = .left
        imgView.tintColor = UIColor.colorPrimary
        let viewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        viewLeft.addSubview(imgView)
        self.leftView = viewLeft
        self.leftViewMode = .always
    }
}
