//
//  TermsViewController.swift
//  Walayem
//
//  Created by MACBOOK PRO on 5/22/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {
    
    @IBOutlet weak var contentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
        getTerms()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func getTerms() {

        let params: [String: Any] = [:]
        RestClient().request(WalayemApi.viewTerms, params, self) { (result, error) in
            print(result)
            if error != nil {
                _ = error?.userInfo[NSLocalizedDescriptionKey] as! String
                //error here
                self.contentLabel.text = "No terms and conditions set yet."
            }

            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                //status false
                self.contentLabel.text = "No terms and conditions set yet."
                return
            }

            guard let data = value["data"] as? String else {
                print("error")
                self.contentLabel.text = "No terms and conditions set yet."
                return
            }
            guard let content = data.data(using: String.Encoding.unicode) else { return }
        
            try? self.contentLabel.attributedText = NSAttributedString(data: content, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            self.contentLabel.font = UIFont.init(name: "System", size: 12)

        }
    }

}
