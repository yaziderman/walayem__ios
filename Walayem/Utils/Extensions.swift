//
//  Extensions.swift
//  Walayem
//
//  Created by Nasbeer Ahammed on 1/8/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitlet(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        
        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
    
   
}



extension UIViewController {
    
    func getSpinnerView() -> UIView{
        
        let tint: UIColor = {
            if #available(iOS 13, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        return .black
                    } else {
                        return .white
                    }
                }
            } else {
                return .white
            }
        }()
        
        
        let aView = UIView(frame: self.view.frame)
        aView.backgroundColor = tint
        let v = self.view.frame
        let h = v.height
        let w = v.width
        let imageView = UIImageView.init(frame: CGRect(x: w/2 - 30, y: h/2 - 60 - 50, width: 60, height: 120))
        imageView.image = #imageLiteral(resourceName: "logo no text")
        var frame = imageView.frame
        UIView.animate(withDuration: 2, delay: 0.2, options: .repeat, animations: {
             frame.origin.y = h/2 - 130 - 50
            imageView.alpha = 0.1
             imageView.frame = frame
        }) { (success) in
            UIView.animate(withDuration: 2) {
                frame.origin.y = h/2 - 130 + 50
                imageView.alpha = 1
            }
        }
        aView.addSubview(imageView)
        self.view.addSubview(aView)
        return aView
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
      func showAlertBeforeLogin(message: String) {
         
          StaticLinker.skipToSameView = true
          
          let alert = UIAlertController(title: message, message: "", preferredStyle: .actionSheet)
              alert.addAction(UIAlertAction(title: "Login / Signup", style: .default, handler: { (action) in
                      let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateInitialViewController()!
                      self.present(viewController, animated: true, completion: nil)
                
                     }
                 ))
                 alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                  alert.dismiss(animated: true, completion: nil)
                 }))
          
          
          self.present(alert, animated: true, completion: nil)
      }
    
    
      func alertBeforeLogin(message: String) -> UIAlertController {
         
          StaticLinker.skipToSameView = true
          
          let alert = UIAlertController(title: message, message: "", preferredStyle: .actionSheet)
              alert.addAction(UIAlertAction(title: "Login / Signup", style: .default, handler: { (action) in
                      let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateInitialViewController()!
                      self.present(viewController, animated: true, completion: nil)
                     }
                 ))
                 alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                  alert.dismiss(animated: true, completion: nil)
                 }))
        
        return alert
          
      }
}


extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
        let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}

extension UITableView {

    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }

    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                     let indexPath = IndexPath(row: 0, section: 0)
                     self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }

    enum scrollsTo {
        case top,bottom
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}


extension UIViewController {

  func scrollToTop(animated: Bool) {
    if let tv = self as? UITableViewController {
        tv.tableView.setContentOffset(CGPoint.zero, animated: animated)
    } else if let cv = self as? UICollectionViewController{
        cv.collectionView?.setContentOffset(CGPoint.zero, animated: animated)
    } else {
        for v in view.subviews {
            if let sv = v as? UIScrollView {
                sv.setContentOffset(CGPoint.zero, animated: animated)
            }
        }
    }
  }
}

//public var tint: UIColor = {
//    if #available(iOS 13, *) {
//        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
//            if UITraitCollection.userInterfaceStyle == .dark {
//                /// Return the color for Dark Mode
//                return .black
//            } else {
//                /// Return the color for Light Mode
//                return .white
//            }
//        }
//    } else {
//        /// Return a fallback color for iOS 12 and lower.
//        return .white
//    }
//}()

extension UIColor {
    func getTint()-> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return .black
                } else {
                    /// Return the color for Light Mode
                    return .white
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return .white
        }
    }
}

extension UIButton {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
//        animation.repeatDuration = 1.0
        animation.repeatCount = 1
        animation.duration = 0.9
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }

}


public extension UIColor {

    /// Creates a color object that generates its color data dynamically using the specified colors. For early SDKs creates light color.
    /// - Parameters:
    ///   - light: The color for light mode.
    ///   - dark: The color for dark mode.
    convenience init(light: UIColor, dark: UIColor) {
        if #available(iOS 13.0, tvOS 13.0, *) {
            self.init { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                }
                return light
            }
        }
        else {
            self.init(cgColor: light.cgColor)
        }
    }
}
