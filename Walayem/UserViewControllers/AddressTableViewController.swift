//
//  AddressTableViewController.swift
//  Walayem
//
//  Created by MAC on 4/22/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Alamofire
import os.log

protocol AddressSelectionDelegate: class {
    func addressSelected(_: Address)
}

class AddressTableViewController: UITableViewController {

    // MARK: Properties
    @IBOutlet weak var emptyView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    var partnerId: Int?
    var addressList = [Address]()
    weak var selectionDelegate: AddressSelectionDelegate?
	var isFromChooseAddress = false
	var isFromCart = false
    
    // MARK: Actions
    
    @IBAction func unwindToAddressList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? AddressViewController, let address = sourceViewController.address {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing address.
                addressList[selectedIndexPath.row] = address
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new address.
                let newIndexPath = IndexPath(row: addressList.count, section: 0)
                
                addressList.append(address)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                changeView(false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *){
            navigationItem.largeTitleDisplayMode = .never
        }
        self.tableView.tableFooterView = UIView()
        
        showActivityIndicator()
        if let navController = self.navigationController {
            Utils.setupNavigationBar(nav: navController)
        }
        setupRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getAddress()
    }
    
    // MARK: Private methods
    
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
        getAddress()
    }
    
    private func getAddress(){
        let params = ["partner_id": partnerId!]
        
        RestClient().request(WalayemApi.address, params, self) { (result, error) in
            self.hideActivityIndicator()
            self.refreshControl?.endRefreshing()
            
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
//                    self.onSessionExpired()
                }
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            self.addressList.removeAll()
            let records = value["addresses"] as! [Any]
            if records.count == 0{
                self.changeView(true)
                return
            }
            for record in records{
                let address = Address(record: record as! [String : Any])
                self.addressList.append(address)
            }
            self.tableView.reloadData()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        var user = User().getUserDefaults()
        if(user != nil)
        {
            partnerId = user.partner_id;
        }
    }
    private func deleteAddress(addressId: Int){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let params = ["partner_id": partnerId as Any, "address_id": addressId as Any]
        RestClient().request(WalayemApi.deleteAddress, params, self) { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func changeView(_ isEmpty: Bool){
        if isEmpty && !isFromChooseAddress{
            tableView.backgroundView = emptyView
            tableView.tableFooterView = UIView()
        }else{
            tableView.backgroundView = nil
        }
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(style: .gray)
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as? AddressTableViewCell else {
            fatalError("Unexpected cell")
        }
        let address = addressList[indexPath.row]
        cell.address = address
        if self.selectionDelegate != nil {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let selectedCell = tableView.cellForRow(at: indexPath) as? AddressTableViewCell else {
			fatalError("Cell does not exist")
		}
		if let delegate = self.selectionDelegate {
			let address = addressList[indexPath.row]
			delegate.addressSelected(address)
			if isFromCart {
				self.navigationController?.popViewController(animated: true)
			}
		} else {
			self.performSegue(withIdentifier: "AddressVCSegue", sender: selectedCell)
		}
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (delete, indexPath) in
            self.deleteAddress(addressId: self.addressList[indexPath.row].id)
            self.addressList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if self.addressList.count == 0{
                self.changeView(true)
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (edit, indexPath) in
            guard let selectedCell = tableView.cellForRow(at: indexPath) as? AddressTableViewCell else {
                fatalError("Cell does not exist")
            }
            self.performSegue(withIdentifier: "AddressVCSegue", sender: selectedCell)
        }
        
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? ""{
        case "AddAddressSegue":
            os_log("Add address segue", log: .default, type: .debug)
        case "AddressVCSegue":
            guard let destinationVC = segue.destination as? AddressViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? AddressTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedCell) else{
                fatalError("Cell does not exist")
            }
            
            let selectedAddress = addressList[indexPath.row]
            destinationVC.address = selectedAddress
        default:
            fatalError("Invalid segue")
        }
    }
    
}
