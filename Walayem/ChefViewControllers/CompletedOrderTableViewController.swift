//
//  CompletedOrderTableViewController.swift
//  Walayem
//
//  Created by MAC on 5/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class CompletedOrderTableViewController: UITableViewController, OrderHeaderCellDelegate {

    static let STATE_COMPLETED = 1
    static let STATE_CANCELLED = 2
    
    // MARK: Properties
    @IBOutlet weak var emptyView: UIView!
    var activityIndicator: UIActivityIndicatorView?
    
    var state: Int = 1
    var user: User?
    struct OrderObject{
        var date: String!
        var orders: [Order]!
        var opened: Bool!
    }
    var orderList = [OrderObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0)
        tableView.tableFooterView = UIView()
        tableView.register(OrderHeaderCell.self, forHeaderFooterViewReuseIdentifier: "OrderHeaderCell")
        if state == CompletedOrderTableViewController.STATE_COMPLETED{
            getCompletedOrders()
        }else if state == CompletedOrderTableViewController.STATE_CANCELLED{
            getCancelledOrders()
        }
        
        setupRefreshControl()
    }

    override func viewDidAppear(_ animated: Bool) {
        if state == CompletedOrderTableViewController.STATE_COMPLETED{
            getCompletedOrders()
        }else if state == CompletedOrderTableViewController.STATE_CANCELLED{
            getCancelledOrders()
        }
    }
    
    private func setupRefreshControl(){
        let refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        }else{
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
    }
    
    @objc private func refreshData(sender: UIRefreshControl){
        if state == CompletedOrderTableViewController.STATE_COMPLETED{
            getCompletedOrders()
        }else if state == CompletedOrderTableViewController.STATE_CANCELLED{
            getCancelledOrders()
        }
        sender.endRefreshing()
    }
    
    // MARK: Private methods
    
    private func getCompletedOrders(){
        let states = [OrderState.delivered.rawValue]
        let params: [String: Any] = ["partner_id": user?.partner_id as Any, "states": states]
        
        callServer(params: params)
    }
    
    private func getCancelledOrders(){
        let states = [OrderState.cancel.rawValue, OrderState.rejected.rawValue]
        let params: [String: Any] = ["partner_id": user?.partner_id as Any, "states": states]
        
        callServer(params: params)
    }
    
    private func callServer(params: [String: Any]){
        showActivityIndicator()
        RestClient().request(WalayemApi.chefOrders, params) { (result, error) in
            self.hideActivityIndicator()
           
            if let error = error{
                let errmsg: String = error.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
                    self.onSessionExpired()
                }else{
                   self.showAlert(title: "Cannot get orders", msg: errmsg)
                }
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            let records = value["orders"] as! [Any]
            if records.count == 0{
                self.changeView(isEmpty: true)
                return
            }
            self.orderList.removeAll()
            self.changeView(isEmpty: false)
            for record in records{
                guard let record = record as? [String: Any] else{
                    fatalError("Invalid data")
                }
                var orders = [Order]()
                let date = record["date"] as! String
                let items = record["orders"] as! [Any]
                for item in items{
                    let order = Order(record: item as! [String: Any])
                    orders.append(order)
                }
                
                let orderObject = OrderObject(date: date, orders: orders, opened: true)
                self.orderList.append(orderObject)
            }
            self.tableView.reloadData()
        }
    }
    
    private func changeView(isEmpty: Bool){
        if isEmpty{
            tableView.backgroundView = emptyView
        }else{
            tableView.backgroundView = nil
        }
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator?.color = UIColor.colorPrimary
            activityIndicator?.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
       
        activityIndicator?.startAnimating()
    }
    
    private func hideActivityIndicator(){
        activityIndicator?.stopAnimating()
        tableView.backgroundView = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return orderList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orderList[section].opened{
            return orderList[section].orders.count
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderHeaderCell") as? OrderHeaderCell else {
            fatalError("Unexpected header cell")
        }
        
        headerView.delegate = self
        headerView.section = section
        
        let sectionItem = orderList[section]
        headerView.titleLabel.text = Utils.getMonthYear(sectionItem.date)
        if state == CompletedOrderTableViewController.STATE_COMPLETED{
            headerView.iconView.tintColor = UIColor.babyBlue
        }else if state == CompletedOrderTableViewController.STATE_CANCELLED{
            headerView.iconView.tintColor = UIColor.rosa
        }
        if sectionItem.opened{
            UIView.animate(withDuration: 1) {
                headerView.caret.transform = CGAffineTransform(rotationAngle: .pi/2)
            }
        }else{
            UIView.animate(withDuration: 1) {
                headerView.caret.transform = CGAffineTransform.identity
            }
        }
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChefOrderCell", for: indexPath) as? ChefOrderTableViewCell else {
            fatalError("Unexpected cell")
        }

        let order = orderList[indexPath.section].orders![indexPath.row]
        cell.order = order
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orderList[indexPath.section].orders[indexPath.row]
        guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "ChefOrderDetailVC") as? ChefOrderDetailViewController else {
            fatalError("Unexpected view controller")
        }
        destinationVC.orderId = order.id
        destinationVC.orderState = order.state ?? OrderState(rawValue: "")!
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    // MARK: OrderHeaderCell delegate
    
    func toggleSection(section: Int) {
        orderList[section].opened = !orderList[section].opened
        
        tableView.reloadSections([section], with: .automatic)
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
