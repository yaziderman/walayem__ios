//
//  CustomColor.swift
//  Walayem
//
//  Created by MAC on 4/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

extension UIColor{
    
    static var colorPrimary: UIColor{
        return UIColor(red: 80.0 / 255.0, green: 227.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
    }
    
    static var slateGrey: UIColor{
        return UIColor(red: 90.0 / 255.0, green: 95.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
    }
    
    static var steel: UIColor {
        return UIColor(red: 122.0 / 255.0, green: 130.0 / 255.0, blue: 143.0 / 255.0, alpha: 1.0)
    }
    
    static var silver: UIColor{
        return UIColor(red: 224.0 / 255.0, green: 226.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
    }
    
    static var silverTen: UIColor {
        return UIColor(red: 198.0 / 255.0, green: 202.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
    }
    
    static var silverEleven: UIColor {
        return UIColor(red: 237.0 / 255.0, green: 239.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
    }
    
    static var amber: UIColor {
        return UIColor(red: 240.0 / 255.0, green: 207.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)
    }
    
    static var rosa: UIColor {
        return UIColor(red: 1.0, green: 143.0 / 255.0, blue: 164.0 / 255.0, alpha: 1.0)
    }
    
   static var peach: UIColor {
        return UIColor(red: 1.0, green: 194.0 / 255.0, blue: 122.0 / 255.0, alpha: 1.0)
    }
    
    static var perrywinkle: UIColor {
        return UIColor(red: 177.0 / 255.0, green: 138.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    }
    
    static var babyBlue: UIColor {
        return UIColor(red: 150.0 / 255.0, green: 208.0 / 255.0, blue: 1.0, alpha: 1.0)
    }
    
    static var seafoamBlue: UIColor {
        return UIColor(red: 95.0 / 255.0, green: 211.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0)
    }
    
    static var textColor: UIColor {
        return UIColor(red: 100.0 / 255.0, green: 105.0 / 255.0, blue: 110.0 / 255.0, alpha: 1.0)
    }
    
    static var placeholderColor: UIColor {
        return UIColor(red: 130.0 / 255.0, green: 135.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0)
    }
     // custom color methods
       class func colorWithHex(rgbValue: UInt32) -> UIColor
       {
           return UIColor( red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                         green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                          blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                         alpha: CGFloat(1.0))
       }
       
       class func colorWithHexString(hexStr: String) -> UIColor
       {
           var cString:String = hexStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

           if (hexStr.hasPrefix("#"))
           {
               cString.remove(at: cString.startIndex)
           }
           if (cString.isEmpty || (cString.count) != 6)
           {
               return colorWithHex(rgbValue: 0xFF5300);
           }
           else
           {
               var rgbValue:UInt32 = 0
               Scanner(string: cString).scanHexInt32(&rgbValue)
               
               return colorWithHex(rgbValue: rgbValue);
           }
       }
       
       func changeImageColor(theImageView: UIImageView, newColor: UIColor)
       {
           theImageView.image = theImageView.image?.withRenderingMode(.alwaysOriginal)
           theImageView.tintColor = newColor;
       }

}
