//
//  Verification.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Verification{
    
    static func isValidName(_ name: String) -> Bool{
        return name.count > 2
    }
    
    static func isValidEmail(_ email: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool{
        return (9...12).contains(phone.count)
//            && (phone.prefix(1) == "5")
//        return (9...12).contains(phone.count) && (phone.prefix(3) == "971" || phone.prefix(4) == "+971")
    }
    
    static func isValidPassword(_ password: String) -> Bool{
        return password.count >= 1
    }
    static func isValidLoginPassword(_ password: String) -> Bool{
        return password.count >= 2
    }
    
}
