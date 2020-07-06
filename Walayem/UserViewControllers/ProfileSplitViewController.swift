//
//  ProfileSplitViewController.swift
//  Walayem
//
//  Created by ITRS-348 on 06/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import UIKit

class ProfileSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredDisplayMode = .allVisible
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
