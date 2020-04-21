//
//  ProfileTableViewController.swift
//  Walayem
//
//  Created by MAC on 4/22/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import FirebaseMessaging

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var session: String?
    
    var user: User?
    
    // MARK: Actions
    
    @IBAction func call(_ sender: UIButton) {
        
        guard let popupVC = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "LanguageSelectionViewController") as? LanguageSelectionViewController else{
            fatalError("Unexpected destination VC")
        }
        
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        self.present(popupVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func openWhatsapp(){
        let urlWhats = "whatsapp://send?phone=+971585668800&abid=12354&text=Hi, I am \(user?.name ?? "CUSTOMER_NAME")"
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
    
    @IBAction func email(_ sender: UIButton) {
        
//        if let urlStr = NSURL(string: "https://apps.apple.com/ae/app/walayem/id1385676754") {
//            let string = "Hi I am using WALAYEM. It is a platform for foodies where anyone at home can prepare food and sell easily to the customer.  Install it using the link "
//            let objectsToShare = [string, urlStr] as! [Any]
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//
//            if UI_USER_INTERFACE_IDIOM() == .pad {
//                if let popup = activityVC.popoverPresentationController {
//                    popup.sourceView = self.view
//                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
//                }
//            }
//
//            self.present(activityVC, animated: true, completion: nil)
//        }
        
//        self.openWhatsapp()
        
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
        } else {
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
    
    @IBAction func pickPhoto(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        let alert = UIAlertController(title: "Photo source", message: "Choose a photo source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print ("Camera not available.")
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
        
        userImageView.layer.cornerRadius = 20
        userImageView.layer.masksToBounds = true
        
    
        self.splitViewController?.preferredDisplayMode = .allVisible
        self.splitViewController?.delegate = self
        
        session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        user = User().getUserDefaults()
        if let image = user?.image{
            userImageView.image = Utils.decodeImage(image)
        }else{
            getUserImage(user!.partner_id!)
        }
        Utils.setupNavigationBar(nav: self.navigationController!)
        self.tableView.separatorColor = UIColor.silverEleven
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
    }
    
    func updateProfileTitle() {
            
            if(session == nil)
            {
                StaticLinker.mainVC?.tabBar.items![4].title = "Log In"
            }
            else
            {
                StaticLinker.mainVC?.tabBar.items![4].title = "Profile"
            }
            
        }
    
    func checkLogin()
    {
        updateProfileTitle()
        if(session == nil)
        {
            onSessionExpired(showSkip: true)
        }
    }
    
    @objc func refresh() {
        user = User().getUserDefaults()
        if let image = user?.image{
            userImageView.image = Utils.decodeImage(image)
        }else{
            getUserImage(user!.partner_id!)
        }
         Utils.setupNavigationBar(nav: self.navigationController!)
        self.tableView.separatorColor = UIColor.silverEleven
        
        updateUI()
    }
    
    private func getAddress(){
        let params = ["partner_id": 0]
        
        RestClient().request(WalayemApi.address, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
                    self.onSessionExpired()
                }
                print (errmsg)
                return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0.01)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        
        checkLogin()
        updateUI()
    }
    
    
    // MARK: Private methods
    
    func updateUI(){
        if let user = user{
            nameLabel.text = user.name
        }
    }
    
    private func getUserImage(_ partnerId: Int){
        let fields = ["image"]
        
        OdooClient.sharedInstance().read(model: "res.partner", ids: [partnerId], fields: fields) { (result, error) in
            if error?.userInfo[NSLocalizedDescriptionKey] != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            if result != nil {
                let records = result!["result"] as! [Any]
                if (records.count > 0){
                    if let record = records[0] as? [String: Any]{
                        if let image = record["image"] as? String {
                            UserDefaults.standard.set(image, forKey: UserDefaultsKeys.IMAGE)
                            self.userImageView.image = Utils.decodeImage(image)
                        }else{
                            print("no image available.")
                        }
                    }
                }
            }
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
    
    private func logout(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let client = OdooClient.sharedInstance()
        client.logout(completionHandler: { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as? String
                self.showAlert(title: "cannot logout", msg: errmsg ?? "No message available!")
                return
            }
            
            Messaging.messaging().unsubscribe(fromTopic: "alli")
            Messaging.messaging().unsubscribe(fromTopic: "\(self.user!.partner_id!)i")
            Messaging.messaging().unsubscribe(fromTopic: "alluseri")
            User().clearUserDefaults()
//            DatabaseHandler().clearDatabase()
            OdooClient.destroy()
            
            StaticLinker.mainVC?.selectedIndex = 0
            
            Utils.notifyRefresh()
//            StaticLinker.mainVC?.dismiss(animated: true, completion: nil)
//            let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateInitialViewController()!
//            self.present(viewController, animated: true, completion: nil)
            
        })
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section, indexPath.row) == (2, 0){
            guard let termsVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermsVC") as? TermsViewController else{
                fatalError("Unexpected view controller")
            }
            showDetailViewController(termsVC, sender: self)
        }else if(indexPath.section, indexPath.row) == (1, 1) {
            let orderVC = UIStoryboard(name: "Order", bundle: Bundle.main).instantiateInitialViewController();
            showDetailViewController(orderVC!, sender: self)
        }else if(indexPath.section, indexPath.row) == (2, 1) {
            guard let privacyVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "PrivacyVC") as? PrivacyViewController else{
                fatalError("Unexpected view controller")
            }
            showDetailViewController(privacyVC, sender: self)
        }else if (indexPath.section, indexPath.row) == (3, 0){
            tableView.deselectRow(at: indexPath, animated: true)
            guard let cell = tableView.cellForRow(at: indexPath) else{
                fatalError("Unexpected cell")
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

    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
        case "AddressTableVCSegue":
            if let navigationVC = segue.destination as? UINavigationController, let destinationVC = navigationVC.topViewController as? AddressTableViewController {
                 destinationVC.partnerId = user!.partner_id
            }
        default:
            print("Nothing to do before sugue")
        }
    }

}

extension ProfileTableViewController: UISplitViewControllerDelegate{
    
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
