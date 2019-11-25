//
//  OrderTableViewController.swift
//  Walayem
//
//  Created by  Rohan Shrestha on 5/8/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController, UISplitViewControllerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var emptyView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    var user: User?
    struct OrderObject{
        var date: String?
        var orders: [Order]?
    }
    var orderObjectList = [OrderObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //intitally empty view
        self.changeView(true)
        
        user = User().getUserDefaults()
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
         Utils.setupNavigationBar(nav: self.navigationController!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getOrderHistory()
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.splitViewController?.tabBarItem.badgeValue = nil
    }

    // MARK: Private methods
    
    func getOrderHistory(){
        showActivityIndicator()
        let params = ["partner_id": user?.partner_id as Any]
        RestClient().request(WalayemApi.orderHistory, params) { (result, error) in
            self.hideActivityIndicator()
            
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                self.changeView(true)
                return
            }
            self.orderObjectList.removeAll()
            let records = value["orders"] as! [Any]
            for record in records{
                if let record = record as? [String: Any]{
                    var orders = [Order]()
                    let date = record["date"] as! String
                    let items = record["orders"] as! [Any]
                    
                    for item in items{
                        let order = Order(record: item as! [String: Any])
                        orders.append(order)
                    }
                    
                    self.orderObjectList.append(OrderObject(date: date, orders: orders))
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private func changeView(_ isEmpty: Bool){
        if isEmpty{
            tableView.backgroundView = emptyView
            tableView.separatorStyle = .none
        }else{
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
    
    private func handleNetworkError(_ error: NSError){
        let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
        if errmsg == OdooClient.SESSION_EXPIRED{
            self.onSessionExpired()
        }else{
            self.showAlert(title: "Cannot get order history", msg: errmsg)
        }
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
        tableView.separatorStyle = .none
        
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator(){
        activityIndicator.stopAnimating()
        tableView.separatorStyle = .singleLine
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return orderObjectList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orderObjectList[section].orders!.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        let imageView = UIImageView(image: UIImage(named: "calendar"))
        imageView.frame.size = CGSize(width: 22, height: 22)
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = Utils.getMonthYear(orderObjectList[section].date!)
        titleLabel.textColor = UIColor.steel
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 21)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(stackView)
        header.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-(>=20)-|", options: [], metrics: nil, views: ["v0" : stackView]))
        header.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: [], metrics: nil, views: ["v0" : stackView]))
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as? OrderTableViewCell else {
            fatalError("Unexpected cell")
        }
        let order = orderObjectList[indexPath.section].orders![indexPath.row]
        cell.order = order
        
        return cell
    }
    

    // MARK: UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "OrderVCSegue":
            if let navigationVC = segue.destination as? UINavigationController, let destinationVC = navigationVC.topViewController as? OrderViewController{
            
                guard let selectedCell = sender as? OrderTableViewCell else{
                    fatalError("Unexpected sender \(sender)")
                }
                guard let indexPath = tableView.indexPath(for: selectedCell) else {
                    fatalError("Cell does not exist")
                }
                let selectedOrder = orderObjectList[indexPath.section].orders![indexPath.row]
                destinationVC.orderId = selectedOrder.id
            }
        default:
            fatalError("Invalid segue")
        }
    }

}
