//
//  StaticLinker.swift
//  Walayem
//
//  Created by Inception on 8/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation
import UIKit

class StaticLinker
{
    static var discoverViewController : DiscoverTableViewController? = nil
    static var chefViewController : ChefTableViewController? = nil
    public static var loginNav: UINavigationController?
    public static var signupVC : UIViewController? = nil
    public static var loginVC : UIViewController? = nil
    public static var mainVC : UITabBarController? = nil
    public static var selectedCuisine : Cuisine? = nil
    
    public static var chefLoginFromHome : Bool = false
    
    public static var showSkip : Bool = true
}
