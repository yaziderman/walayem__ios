//
//  AccountsTableViewController.swift
//  Walayem
//
//  Created by MACBOOK PRO on 5/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class AccountsTableViewController: UITableViewController, OrderHeaderCellDelegate {
    
    // MARK: Properties
    
    var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var emptyView: UIView!
    
    var user: User?
    struct AccountObject{
        var date: String?
        var accounts: [Account]?
        var opened: Bool?
    }
    var accountObjectList = [AccountObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
        navigationItem.title = "My Accounts"
        
        
        tableView.register(OrderHeaderCell.self, forHeaderFooterViewReuseIdentifier: "AccountHeaderCell")
        tableView.tableFooterView = UIView()
        getOrderHistory()
        Utils.setupNavigationBar(nav: self.navigationController!)
    }
    
    // MARK: Private methods
    
    private func getOrderHistory(){
        showActivityIndicator()
        let params: [String: Int] = ["partner_id": user!.partner_id!]
        RestClient().request(WalayemApi.chefAccountsHistory, params) { (result, error) in
            self.hideActivityIndicator()
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                self.showAlert(title: "Error", msg: errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.accountObjectList.removeAll()
            let records = value["data"] as! [Any]
            if records.count == 0{
                self.changeView(true)
                return
            }
            for record in records{
                if let record = record as? [String: Any]{
                    var accounts = [Account]()
                    let date = record["year"] as! String
                    let items = record["orders"] as! [Any]
                    
                    for item in items{
                        let account = Account(record: item as! [String: Any])
                        accounts.append(account)
                    }
                    self.accountObjectList.append(AccountObject(date: date, accounts: accounts, opened: true))
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private func changeView(_ isEmpty: Bool){
        if isEmpty{
            tableView.backgroundView = emptyView
        }else{
            tableView.backgroundView = nil
        }
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
        
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator(){
        activityIndicator.stopAnimating()
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return accountObjectList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if accountObjectList[section].opened!{
            return accountObjectList[section].accounts!.count
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AccountHeaderCell") as? OrderHeaderCell else {
            fatalError("Unexpected header view")
        }
        headerView.section = section
        headerView.delegate = self
        headerView.iconView.tintColor = UIColor.perrywinkle
        
        let accountObject =  accountObjectList[section]
        headerView.titleLabel.text = accountObject.date
        if accountObject.opened!{
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as? AccountTableViewCell else {
            fatalError("Unexpected cell")
        }
        let account = accountObjectList[indexPath.section].accounts![indexPath.row]
        cell.account = account
        return cell
    }
    
    // MARK: HeaderCellDelegate
    
    func toggleSection(section: Int) {
        accountObjectList[section].opened = !accountObjectList[section].opened!
        tableView.reloadSections([section], with: .automatic)
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    
    }
    */
    
}
