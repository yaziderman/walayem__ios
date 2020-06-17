//
//  ChefProfileTableViewController.swift
//  Walayem
//
//  Created by MAC on 5/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import FirebaseMessaging

class ChefProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currentMonthEarningsLabel: UILabel!
    @IBOutlet weak var totalEarningsLabel: UILabel!
    var user: User?
    @IBOutlet weak var updateIcon: UIImageView!
    @IBOutlet weak var kitchenSwitch: UISwitch!
    
    // MARK: Actions
    @IBAction func `switch`(_ sender: UISwitch) {
        self.setKitchenStatus()
//        if(sender.isOn){
//            let alert = UIAlertController(title: "ON", message: "switch ON", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }else{
//            let alert = UIAlertController(title: "off", message: "switch off", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
    }
	
    @IBAction func call(_ sender: UIButton) {
        
        guard let popupVC = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "LanguageSelectionViewController") as? LanguageSelectionViewController else{
            fatalError("Unexpected destination VC")
        }
        
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        self.present(popupVC, animated: true, completion: nil)

    }

    @IBAction func email(_ sender: UIButton) {
        var email = UserDefaults.standard.string(forKey: "ContactEmail")
        
        if(email == nil)
        {
            email = "walayem@gmail.com"
        }
        
        let url = URL(string: "mailto:\(email!)")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url!)
        }
    }

    @IBAction func connectFacebook(_ sender: UIButton) {
      if let url = URL(string: UserDefaults.standard.string(forKey: "ContactFacebook") ?? "https://www.facebook.com/WalayemApp"){
        
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            else {
                  // Fallback on earlier versions
                  UIApplication.shared.openURL(url)
            }
        }
        else {

        }
    }

    @IBAction func connectInsta(_ sender: UIButton) {
      let url = URL(string: UserDefaults.standard.string(forKey: "ContactInstagram") ?? "https://www.instagram.com/walayem")

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url!)
        }
    }
    
    @IBAction func shareApp(){
     if let urlStr = NSURL(string: Utils.getShareURL()) {
         let string = Utils.getShareText()
                    let objectsToShare = [string, urlStr] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    if UI_USER_INTERFACE_IDIOM() == .pad {
                        if let popup = activityVC.popoverPresentationController {
                            popup.sourceView = self.view
                            popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                        }
                    }

                    self.present(activityVC, animated: true, completion: nil)
                }
    }
    
    @IBAction func openWhatsapp(){
        let urlWhats = "whatsapp://send?phone=971585668800&abid=12354&text=Hi, I am Chef \(user?.name ?? "CHEF_NAME")"
		
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(whatsappURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(whatsappURL)
                    }
                }
                else {
                    print("Install Whatsapp")
                }
            }
        }
    }

    @IBAction func pickPhoto(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        let alert = UIAlertController(title: "Photo source", message: "Choose a photo source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.up]
        }
        present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.splitViewController?.preferredDisplayMode = .allVisible
        self.splitViewController?.delegate = self
        self.tableView.separatorColor = UIColor.silverEleven
        
        userImageView.layer.cornerRadius = 20
        userImageView.layer.masksToBounds = true
        
        user = User().getUserDefaults()
        if let image = user?.image {
            userImageView.image = Utils.decodeImage(image)
        } else {
            getUserImage(user!.partner_id!)
        }
        Utils.setupNavigationBar(nav: self.navigationController!)
        updateIcon.tintColor  = UIColor.amber
        getKitchenStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0.01)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
        getCurrentMonthEarnings()
        getTotalEarnings()
    }

    // MARK: Private methods
    
    func updateUI(){
        if let user = user {
            nameLabel.text = user.name
        }
    }
    
    private func getKitchenStatus(){
        let params: [String: Any] = ["partner_id": user!.partner_id!]
        RestClient().request(WalayemApi.viewKitchenStatus, params, self) { (result, error) in
            if error != nil {
                _ = error?.userInfo[NSLocalizedDescriptionKey] as! String
                //error here
                self.kitchenSwitch.isOn = false
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                //status false
                print("kitchen_status\(status)")
                self.kitchenSwitch.isOn = false
                return
            }
            let is_on = value["is_open"] as! Bool
            print("kitchen_is_open\(is_on)")
            self.kitchenSwitch.isOn = is_on
        }
    }
    private func setKitchenStatus(){
        let params: [String: Any] = ["partner_id": user!.partner_id!, "status":kitchenSwitch.isOn]
        RestClient().request(WalayemApi.changeKitchenStatus, params, self) { (result, error) in
            self.getKitchenStatus()
        }
    }
    
    private func getCurrentMonthEarnings() {

        let params: [String: Any] = ["partner_id": user!.partner_id!, "date": Utils.getCurrentMonthAndYear()]
        RestClient().request(WalayemApi.viewAmountForMonth, params, self) { (result, error) in
            if error != nil {
                _ = error?.userInfo[NSLocalizedDescriptionKey] as! String
                //error here
                self.currentMonthEarningsLabel.text = "AED 0.0"
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                //status false
                self.currentMonthEarningsLabel.text = "AED 0.0"
                return
            }
            let data = value["data"] as! [String: Any]
            let amount = data["amount"] as! Double
            self.currentMonthEarningsLabel.text = "AED \(amount)"
        }
    }

    private func getTotalEarnings() {
        let params: [String: Any] = ["partner_id": user?.partner_id as Any]
        RestClient().request(WalayemApi.viewWalletAmount, params, self) { (result, error) in
            if error != nil {
                _ = error?.userInfo[NSLocalizedDescriptionKey] as! String
                //error here
                self.totalEarningsLabel.text = "AED 0.0"
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                //status false
                self.totalEarningsLabel.text = "AED 0.0"
                return
            }
            let data = value["data"] as! [String: Any]
            let amount = data["amount"] as! Double
            self.totalEarningsLabel.text = "AED \(amount)"
        }
    }

    private func getUserImage(_ partnerId: Int) {
        let fields = ["image"]

        OdooClient.sharedInstance().read(model: "res.partner", ids: [partnerId], fields: fields) { (result, error) in
            if error != nil {
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print(errmsg)
                return
            }
            let records = result!["result"] as! [Any]
            if let record = records[0] as? [String: Any] {
                if let image = record["image"] as? String {
                    UserDefaults.standard.set(image, forKey: UserDefaultsKeys.IMAGE)
                    self.userImageView.image = Utils.decodeImage(image)
                }else{
                    print("no image available.")
                }
            }
        }
    }

    private func logout() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let client = OdooClient.sharedInstance()
        client.logout(completionHandler: { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                self.showAlert(title: "cannot logout", msg: errmsg)
                return
            }
            Messaging.messaging().unsubscribe(fromTopic: "alli")
            Messaging.messaging().unsubscribe(fromTopic: "\(self.user!.partner_id!)i")
            Messaging.messaging().unsubscribe(fromTopic: "allchefi")
            User().clearUserDefaults()
            OdooClient.destroy()
            User().clearUserDefaults();
            
			
			
//            let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
//            self.present(viewController, animated: true, completion: nil)
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			appDelegate.shouldMoveToMainPage()
        })
        
        
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section, indexPath.row) == (4, 0){
            guard let termsVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermsVC") as? TermsViewController else{
                fatalError("Unexpected view controller")
            }
            showDetailViewController(termsVC, sender: self)
        }else if(indexPath.section, indexPath.row) == (4, 1) {
            guard let privacyVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "PrivacyVC") as? PrivacyViewController else{
                fatalError("Unexpected view controller")
            }
            showDetailViewController(privacyVC, sender: self)
        }else if (indexPath.section, indexPath.row) == (5, 0) {
            tableView.deselectRow(at: indexPath, animated: true)
            guard let cell = tableView.cellForRow(at: indexPath) else {
                fatalError("Cell doesnot exist")
            }
            let alert = UIAlertController(title: "Log out", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (action) in
                self.logout()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = cell
                popoverController.sourceRect = CGRect(x: cell.bounds.maxX, y: cell.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.left]
            }
            
            present(alert, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section, indexPath.row) == (0, 0){
            return 193
        }else if (indexPath.section, indexPath.row) == (1, 1){
            return 0
        }else if  (indexPath.section, indexPath.row) == (2, 1){
            return 0
        }else{
            return 70
        }
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        // Set photoImageView to display the selected image.
        userImageView.image = selectedImage

        // Dismiss the picker.
        dismiss(animated: true, completion: nil)

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let image64 = Utils.encodeImage(selectedImage)
        let values: [String: Any ] = ["image": image64 ?? "", "is_image_set": true]
        OdooClient.sharedInstance().write(model: "res.partner", ids: [user!.partner_id!], values: values) { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            UserDefaults.standard.set(image64, forKey: UserDefaultsKeys.IMAGE)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? ""{
        case "UpdateProfileVCSegue":
            if let navigationVC = segue.destination as? UINavigationController, let destinationVC = navigationVC.topViewController as? UpdateProfileViewController {
                destinationVC.user = user
            }
        default:
            print("Nothing to do before sugue")
        }
    }

}

extension ChefProfileTableViewController: UISplitViewControllerDelegate{
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
