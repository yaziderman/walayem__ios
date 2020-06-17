//
//  PendingOrderTableViewController.swift
//  Walayem
//
//  Created by MAC on 5/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class PendingOrderTableViewController: UITableViewController, OrderHeaderCellDelegate {
   
    @IBOutlet var pendingTableView: UITableView!
    // MARK: Properties
    
    @IBOutlet weak var emptyView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    var user: User?
    
    struct Section{
        var opened: Bool!
        var hidden: Bool!
        var iconColor: UIColor!
        var orderState: String?
        var orders: [Order]!
    }
    var sections: [Section]?
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0)
        tableView.tableFooterView = UIView()
        tableView.register(OrderHeaderCell.self, forHeaderFooterViewReuseIdentifier: "OrderHeaderCell")
        getPendingOrders()
        setupRefreshControl()
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
        getPendingOrders()
        sender.endRefreshing()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        getPendingOrders();
    }

    // MARK: Private methods
    
    private func getPendingOrders(){
        let states = [OrderState.sale.rawValue, OrderState.done.rawValue, OrderState.cooking.rawValue, OrderState.ready.rawValue]
        let params: [String: Any] = ["partner_id": user?.partner_id as Any, "states": states]
        
        showActivityIndicator()
        RestClient().request(WalayemApi.chefOrders, params, self) { (result, error) in
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
            self.emptyOrders()
            let records = value["orders"] as! [Any]
            if records.count == 0{
                self.changeView(isEmpty: true)
                self.tableView.reloadData()
                return
            }
            self.changeView(isEmpty: false)
            self.sections = [Section(opened: true, hidden: true, iconColor: UIColor.amber, orderState: "Sale", orders: [Order]()),
                        Section(opened: true, hidden: true, iconColor: UIColor.rosa, orderState: "Accepted", orders: [Order]()),
                        Section(opened: true, hidden: true, iconColor: UIColor.amber, orderState: "Cooking", orders: [Order]()),
                        Section(opened: true, hidden: true, iconColor: UIColor.babyBlue, orderState: "Ready", orders: [Order]())]
            for record in records{
                guard let record = record as? [String: Any] else{
                    fatalError("Invalid data")
                }
                let orders = record["orders"] as! [Any]
                for item in orders{
                    let order = Order(record: item as! [String : Any])
                    switch order.state{
                    case .sale:
                        self.sections![0].orders.append(order)
                    case .done:
                        self.sections![1].orders.append(order)
                    case .cooking:
                        self.sections![2].orders.append(order)
                    case .ready:
                        self.sections![3].orders.append(order)
                    default:
                        print("Invalid order state")
                    }
                }
                self.tableView.reloadData()
            }
        
            for section in self.sections!{
                let index = self.sections?.firstIndex(where: { (sec) -> Bool in
                    sec.orderState == section.orderState
                })
                if(section.orders.count>0){
                   self.sections![index!].hidden = false
                }else{
                    self.sections![index!].hidden = true
//                    section.hidden = true
                }
            }
             self.tableView.reloadData()
        }
    }
    
    private func emptyOrders(){
        if sections != nil{
            sections?.removeAll()
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
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator(){
        activityIndicator.stopAnimating()
    }
    
    private func changeView(isEmpty: Bool){
        if isEmpty{
            tableView.backgroundView = emptyView
        }else{
            tableView.backgroundView = nil
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let sections = sections{
            return sections.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections![section].opened{
            return sections![section].orders.count
        }else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderHeaderCell") as? OrderHeaderCell else {
            fatalError("Unexpected header cell")
        }
        
        headerView.delegate = self
        headerView.section = section
        
        let sectionItem = sections![section]
        headerView.titleLabel.text = sectionItem.orderState
        headerView.iconView.tintColor = sectionItem.iconColor

        if sectionItem.opened{
            UIView.animate(withDuration: 1) {
                headerView.caret.transform = CGAffineTransform(rotationAngle: .pi/2)
            }
        }else{
            UIView.animate(withDuration: 1) {
                headerView.caret.transform = CGAffineTransform.identity
            }
        }
//        tableView.reloadSections([section], with: .automatic)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as? ChefOrderTableViewCell else {
            fatalError("Unexpected cell")
        }
        let order = sections![indexPath.section].orders[indexPath.row]
        
        cell.order = order
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = sections![indexPath.section].orders[indexPath.row]
        guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "ChefOrderDetailVC") as? ChefOrderDetailViewController else {
            fatalError("Unexpected view controller")
        }
        destinationVC.orderId = order.id
        destinationVC.orderState = order.state!
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         let sectionItem = sections![section]
        if(sectionItem.hidden){
            return section == 0 ? 0 : 0
        }else{
           return section == 0 ? 0 : 44
        }
    }
    
    // MARK: OrderHeaderCell delegate
    
    func toggleSection(section: Int) {
        sections![section].opened = !sections![section].opened
        
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
