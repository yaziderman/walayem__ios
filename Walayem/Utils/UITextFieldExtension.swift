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
}
