//
//  PrivacyViewController.swift
//  Walayem
//
//  Created by MACBOOK PRO on 5/22/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var contentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        getPrivacy()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Private methods
    
    private func getPrivacy() {

        let params: [String: Any] = [:]
        RestClient().request(WalayemApi.viewPrivacy, params, self) { (result, error) in

            print(result!)
            if error != nil {
                _ = error?.userInfo[NSLocalizedDescriptionKey] as! String
                //error here
                self.contentLabel.text = "No privacy policy set yet."
            }

            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                //status false
                self.contentLabel.text = "No privacy policy set yet."
                return
            }

            guard let data = value["data"] as? String else {
                print("error")
                self.contentLabel.text = "No privacy policy set yet."
                return
            }
            guard let content = data.data(using: String.Encoding.unicode) else { return }

            try? self.contentLabel.attributedText = NSAttributedString(data: content, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)

        }
    }
}

