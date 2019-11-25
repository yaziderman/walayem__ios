//
//  OrderSuccessViewController.swift
//  Walayem
//
//  Created by MAC on 5/15/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class OrderSuccessViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    var orders: [Any]?
    
    // MARK: Actions
    
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillLayoutSubviews() {
        doneButton.roundCorners([.topLeft, .topRight], radius: 20)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OrderSuccessViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath)
        
        if let order = orders![indexPath.row] as? [String: Any]{
            let chefName = order["chef_name"] as! String
            let orderId = order["order_id"] as! Int
            cell.textLabel?.text = chefName + " #WA\(orderId)"
        }
        
        return cell
    }
}
