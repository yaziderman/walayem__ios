//
//  File.swift
//  Walayem
//
//  Created by Nasbeer Ahammed on 1/5/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation

extension Array {
    
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
//    extension Array {
//        func contains<T where T : Equatable>(obj: T) -> Bool {
//            return self.filter({$0 as? T == obj}).count > 0
//        }
//    }
//    func filterDuplicates(includeElement: (_ lhs:Element,_ rhs:Element) -> Bool) -> [Element]{
//        var results = [Element]()
//
//        forEach { (element) in
//            let existingElements = results.filter {
//                return includeElement(lhs: element, rhs: $0)
//            }
//            if existingElements.count == 0 {
//                results.append(element)
//            }
//        }
//
//        return results
//    }
}
