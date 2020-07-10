//
//  Encodable+Dictionary.swift
//  Walayem
//
//  Created by ITRS-348 on 08/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation

extension Encodable {
  func asDictionary() -> [String: Any] {
    let data = try? JSONEncoder().encode(self)
    guard let dictionary = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
        return [:]
    }
    return dictionary
  }
    
    func asDictionary() -> [String: String] {
      let data = try? JSONEncoder().encode(self)
        guard let dictionary = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: String] else {
            return [:]
        }
      return dictionary
    }
    
    func asDictionary() -> [String: NSObject] {
      let data = try? JSONEncoder().encode(self)
      guard let dictionary = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: NSObject] else {
          return [:]
      }
      return dictionary
    }
}
