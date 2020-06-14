//
//  UpdateProfileViewController.swift
//  Walayem
//
//  Created by Inception on 6/1/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import os.log

class UpdateProfileViewController: UITableViewController, ChefCoverageAreaDelegate, LocationSelectionDelegate {
	
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var coverageAreaBtn: UIButton!
    @IBOutlet weak var locationBtn: UIButton!
    
    var selectedLat: Double?
    var selectedLng: Double?
    var selectedAreas: [Int]?
    private var selectedEmirates: [Int]?
	
    var user: User?
    
    // MARK: Actions
    
    @IBAction func unwindToProfile(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? ChangeNameViewController, let user = sourceVC.user{
            self.user = user
            nameLabel.text = user.name
        }else if let sourceVC = sender.source as? ChangePhoneViewController, let user = sourceVC.user{
            self.user = user
            phoneLabel.text = user.phone
        }
        if let navigationVC = self.splitViewController?.viewControllers.first as? UINavigationController, let chefProfileVC = navigationVC.topViewController as? ChefProfileTableViewController{
            chefProfileVC.user = self.user
            chefProfileVC.updateUI()
        }
        if let navigationVC = self.splitViewController?.viewControllers.first as? UINavigationController, let profileVC = navigationVC.topViewController as? ProfileTableViewController{
            profileVC.user = self.user
            profileVC.updateUI()
        }
    }
    
    private func showCoverageSelectionScreen() {
        let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "ChefCoverageArea") as! ChefCoverageArea
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    private func showLocationSelection() {
        let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "LocationSelectionVCId") as! LocationSelectionViewController
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func didSelectMultipleAreas(selectedAreas: [Int], selectedEmirates: [Int], title: String) {
        self.coverageAreaBtn.setTitle(title, for: .normal)
        self.selectedAreas = selectedAreas
        self.selectedEmirates = selectedEmirates
        var color: UIColor!
        if #available(iOS 13.0, *) {
             color = .label
        } else {
            color = .black
        }
        self.coverageAreaBtn.titleLabel?.textColor = color
        self.coverageAreaBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
		updateProfile()
    }
    
    func locationSelected(_ location: Location, title: String, address: UserAddress) {
        self.locationBtn.setTitle(title, for: .normal)
        self.selectedLat = location.latitude
        self.selectedLng = location.longitude
        var color: UIColor!
        if #available(iOS 13.0, *) {
             color = .label
        } else {
            color = .black
        }
        self.locationBtn.titleLabel?.textColor = color
        self.locationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        Utils.setupNavigationBar(nav: self.navigationController!)
        updateUI()
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        guard self.checkAreaAndLocation() else {
            return
        }
        self.updateProfile()
    }
    
    private func checkAreaAndLocation() -> Bool {
        if self.selectedAreas == nil {
            self.showMessagePrompt(title: "Error", message: "Please select area coverage")
            return false
        }
        
        if self.selectedLat == nil || self.selectedLng == nil {
            self.showMessagePrompt(title: "Error", message: "Please select your location")
            return false
        }
        return true
    }
    
    func updateProfile() {
        let partnerId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.PARTNER_ID)
        var params: [String: Any] = ["partner_id": partnerId]
        params["location"] = ["lat": self.selectedLat!, "lon": self.selectedLng!]
        params["areas"] = self.selectedAreas!
        params["emirates"] = self.selectedEmirates ?? []
        RestClient().request(WalayemApi.editProfile, params) { (result, error) in
            if let error = error {
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as? String
                self.showMessagePrompt(title: "Error", message: errmsg ?? error.localizedDescription)
                return
            }
            guard let result = result else {
                let errmsg = "No result found, please try again"
                self.showMessagePrompt(title: "Error", message: errmsg)
                return
            }
            let record = result["result"] as? [String: Any]
            if let errmsg = record?["error"] as? String {
                self.showMessagePrompt(title: "Error", message: errmsg)
                return
            }
            self.showMessagePrompt(title: "Success", message: "Successfully Updated Profile")
            let isChef = UserDefaults.standard.bool(forKey: UserDefaultsKeys.IS_CHEF)
            if isChef {
                let coverage = ChefAreaCoverage(areaIds: self.selectedAreas!,
                                                areaTitles: [self.coverageAreaBtn.title(for: .normal)!])
                coverage.saveToUserDefaults()
                let location = ChefLocation(lat: self.selectedLat!,
                                            long: self.selectedLng!,
                                            title: self.locationBtn.title(for: .normal)!)
                location.saveToUserDefaults()
            }
        }
    }
    
    private func showMessagePrompt(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    // MARK: Private methods

    private func updateUI(){
        if let user = user{
            nameLabel.text = user.name
            emailLabel.text = user.email
            phoneLabel.text = user.phone
        }
        let isChef = UserDefaults.standard.bool(forKey: UserDefaultsKeys.IS_CHEF)
        if isChef {
            if let coverage = ChefAreaCoverage.loadFromUserDefaults() {
                let title = coverage.areaTitles.joined(separator: ",")
                self.coverageAreaBtn.setTitle(title, for: .normal)
                var color: UIColor!
                if #available(iOS 13.0, *) {
                     color = .label
                } else {
                    color = .black
                }
                self.coverageAreaBtn.titleLabel?.textColor = color
                self.coverageAreaBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                self.selectedAreas = coverage.areaIds
            }
            if let location = ChefLocation.loadFromUserDefaults() {
                self.locationBtn.setTitle(location.title, for: .normal)
                var color: UIColor!
                if #available(iOS 13.0, *) {
                     color = .label
                } else {
                    color = .black
                }
                self.locationBtn.titleLabel?.textColor = color
                self.locationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                self.selectedLat = location.lat
                self.selectedLng = location.long
            }
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: TableView delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let _ = UserDefaults.standard.string(forKey: UserDefaultsKeys.AUTH_TOKEN), indexPath.row == 4{
            return 0
        }
        if indexPath.row == 3{
            return 0
        }
        
        let isChef = UserDefaults.standard.bool(forKey: UserDefaultsKeys.IS_CHEF)
        if !isChef && (indexPath.row == 5 || indexPath.row == 6) {
			if let _ = UserDefaults.standard.string(forKey: "authToken"), indexPath.row == 4{
				return 0
			}
		}
        //remove update emirates id row if not chef
//        if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.IS_CHEF) && indexPath.row == 3{
        
        if indexPath.row == 3{
            return 0
        }
        return 70
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row == 5 {
            self.showCoverageSelectionScreen()
        }
        if indexPath.section == 0, indexPath.row == 6 {
            self.showLocationSelection()
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? ""{
        case "ChangeNameVCSegue":
            guard let destinationVC = segue.destination as? ChangeNameViewController else {
                fatalError("Unexpected destination \(segue.identifier)")
            }
            destinationVC.user = user
        case "ChangePhoneVCSegue":
            guard let destinationVc = segue.destination as? ChangePhoneViewController else {
                fatalError("Unexpected destination \(segue.identifier)")
            }
            destinationVc.user = user
        case "ChangePasswordVCSegue":
            os_log("Change password segue", log: .default, type: .debug)
            
        case "UpdateEmiratesIDSegue":
            os_log("Change emirates id segue", log: .default, type: .debug)
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

}
