//
//  AddressViewController.swift
//  Walayem
//
//  Created by MAC on 4/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var extraTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var cityPickerView = UIPickerView()
    var cities = [String]()
    
    var user: User?
    var address: Address?
    
    private var location: Location?
    private var firstTimeAppeared = true
    // MARK: Actions
    
    @IBAction func close(_ sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func locationBtnClicked() {
        let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "LocationSelectionVCId") as! LocationSelectionViewController
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
	
    @IBAction func saveAddress(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let street = streetTextField.text ?? ""
        let city = cityTextField.text ?? ""
        let extra = extraTextField.text ?? ""
        
        if name.isEmpty{
            showAlert("Error", "Please enter an address name")
        }else if street.isEmpty{
            showAlert("Error", "Please enter a street address")
        }else if city.isEmpty{
            showAlert("Error", "Please enter your city")
        } else if self.location == nil {
            showAlert("Error", "Please select your location on map")
        } else {
            if address == nil{
                createAddress(name: name, city: city, street: street, extra: extra)
            }else{
                editAddress(name: name, city: city, street: street, extra: extra)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        navigationItem.title = "New Address"
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
        
        setViews()
        setupCityPickerView()
        getCities()
        
        nameTextField.delegate = self
        streetTextField.delegate = self
        extraTextField.delegate = self
        //updateSaveButtonState()
        
        if let address = address{
            navigationItem.title = address.name
            navigationItem.leftBarButtonItem = nil
            
            nameTextField.text = address.name
            cityTextField.text = address.city
            streetTextField.text = address.street
            extraTextField.text = address.extra
            self.location = address.location
        }
        if let navController = self.navigationController {
            Utils.setupNavigationBar(nav: navController)
        }
        
        nameTextField.textColor = UIColor.textColor
        nameTextField.placeHolderColor = UIColor.placeholderColor
        
        streetTextField.textColor = UIColor.textColor
        streetTextField.placeHolderColor = UIColor.placeholderColor
        
        cityTextField.textColor = UIColor.textColor
        cityTextField.placeHolderColor = UIColor.placeholderColor
        
        extraTextField.textColor = UIColor.textColor
        extraTextField.placeHolderColor = UIColor.placeholderColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.firstTimeAppeared && self.address == nil {
            self.locationBtnClicked()
        }
        self.firstTimeAppeared = false
    }
	
    override func viewWillLayoutSubviews() {
        nameTextField.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        streetTextField.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        cityTextField.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        extraTextField.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        
        saveButton.roundCorners([.topLeft, .topRight], radius: 20)
    }

    // MARK: Private methods
    
    private func setViews(){
        nameTextField.addImageAtLeft(UIImage(named: "information"))
        streetTextField.addImageAtLeft(UIImage(named: "locationPin"))
        cityTextField.addImageAtLeft(UIImage(named: "city"))
        extraTextField.addImageAtLeft(UIImage(named: "notes"))

		let nameImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        nameImageView.image = UIImage(named: "information")
        nameImageView.tintColor = UIColor.colorPrimary
        nameImageView.contentMode = .left
        nameTextField.leftViewMode = .always
        nameTextField.leftView = nameImageView
        
        let streetImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        streetImageView.image = UIImage(named: "locationPin")
        streetImageView.contentMode = .left
        streetImageView.tintColor = UIColor.colorPrimary
        streetTextField.leftViewMode = .always
        streetTextField.leftView = streetImageView
        
        let cityImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        cityImageView.image = UIImage(named: "city")
        cityImageView.contentMode = .left
        cityTextField.leftViewMode = .always
        cityTextField.leftView = cityImageView
        
        let descriptionImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        descriptionImageView.image = UIImage(named: "notes")
        descriptionImageView.contentMode = .left
        descriptionImageView.tintColor = UIColor.colorPrimary
        extraTextField.leftViewMode = .always
        extraTextField.leftView = descriptionImageView
    }
    
    private func getCities(){
        let fields = ["id", "name"]
        let sort = "name ASC"
        
        OdooClient.sharedInstance().searchRead(model: "walayem.city", domain: [], fields: fields, offset: 0, limit: 500, order: sort) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print(errmsg)
                return
            }
            
            let records = result!["records"] as! [Any]
            for record in records{
                if let record = record as? [String: Any]{
                    let cityName = record["name"] as! String
                    self.cities.append(cityName)
                }
            }
            self.cityPickerView.reloadAllComponents()
        }
    }
    
    private func setupCityPickerView(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = UIColor.colorPrimary
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(setCity))
        toolbar.setItems([done], animated: false)
        
        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        
        cityTextField.inputAccessoryView = toolbar
        cityTextField.inputView = cityPickerView
    }
    
    @objc private func setCity(){
        if cities.count > 0{
            let city = cities[cityPickerView.selectedRow(inComponent: 0)]
            cityTextField.text = city
        }
        cityTextField.resignFirstResponder()
    }
    
    private func createAddress(name: String, city: String, street: String, extra: String){
        let activityIndicator = showActivityIndicator()
        let params: [String : Any] = ["address_name": name,
                                      "street": street,
                                      "city": city,
                                      "street2": extra,
                                      "partner_id": user!.partner_id!,
                                      "location": ["lat": self.location!.latitude,
                                                   "long": self.location!.longitude]]
        RestClient().request(WalayemApi.createAddress, params, self) { (result, error) in
            activityIndicator.stopAnimating()
            if error != nil{
                return
            }
            
            let record = result!["result"] as! [String: Any]
            let id = record["id"] as! Int
            
            self.address = Address(id: id, name: name, city: city, street: street, extra: extra, location: nil)
            let alert = UIAlertController(title: "", message: "Address successfully created", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: {
                    self.presentingViewController?.navigationController?.popViewController(animated: false)
                })
                                
                //self.performSegue(withIdentifier: "unwindToAddressList", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func editAddress(name: String, city: String, street: String, extra: String){
        let activityIndicator = showActivityIndicator()
        let params: [String : Any] = ["address_name": name,
                                      "street": street,
                                      "city": city,
                                      "street2": extra,
                                      "partner_id": user!.partner_id!,
                                      "address_id": address!.id,
                                      "location": ["lat": self.location!.latitude,
                                                   "long": self.location!.longitude]]
		
        RestClient().request(WalayemApi.editAddress, params, self) { (result, error) in
            activityIndicator.stopAnimating()
            if error != nil{
                return
            }
            self.address?.name = name
            self.address?.city = city
            self.address?.street = street
            self.address?.extra = extra
            
            let alert = UIAlertController(title: "", message: "Address successfully updated", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "unwindToAddressList", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func updateSaveButtonState(){
        let name = nameTextField.text ?? ""
        let street = streetTextField.text ?? ""
        let city = cityTextField.text ?? ""
        
        if !name.isEmpty && !street.isEmpty && !city.isEmpty{
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
    
    private func showAlert(_ title: String, _ msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showActivityIndicator() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        let rightBarButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

extension AddressViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row]
    }
    
}

extension AddressViewController: LocationSelectionDelegate {
    
    func locationSelected(_ location: Location, title: String, address: UserAddress) {
        self.location = location
        self.streetTextField.text = address.street
        self.cityTextField.text = address.city
    }
    
}
