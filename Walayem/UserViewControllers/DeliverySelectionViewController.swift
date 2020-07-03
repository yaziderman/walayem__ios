//
//  DeliverySelectionViewController.swift
//  Walayem
//
//  Created by D4ttatraya on 31/05/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

protocol DeliverySelectionDelegate: class {
    func deliveryLocationSelected(_: Location?, title: String)
}

class DeliverySelectionViewController: UIViewController {
    
    var user: User!
    weak var delegate: DeliverySelectionDelegate?
    weak var areaSelectionDelegate: AreaSelectionProtocol?
    var locationWrapper: LocationWrapper?
    var shouldShowTabbar = true
    @IBOutlet weak var btnOtherAddress: UIButton!
    @IBOutlet weak var btnSavedAddress: UIButton!
    @IBOutlet weak var addressScrollView: UIScrollView!
    
    var previousContentOffset = CGPoint.zero
    var otherAddressVC: AreaSelectionViewController?
    var addressVC: AddressTableViewController?
    
    //    @IBOutlet weak var addressesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        setUpScrollView()

        if user.partner_id != 0 {
            addressScrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width * 2, height: addressScrollView.bounds.height)
            btnSavedAddress.isHidden = false
        } else {
            addressScrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width * 1, height: addressScrollView.bounds.height)
            btnSavedAddress.isHidden = true
           
        }
        
        self.navigationItem.title = "Choose your location"
        
        otherAddressVC?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: addressScrollView.bounds.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldShowTabbar = true
        self.tabBarController?.tabBar.isHidden = true
    }

	@IBAction func currentLocationButtonClicked() {
       /* let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "LocationSelectionVCId") as! LocationSelectionViewController
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil) */
		locationWrapper = LocationWrapper(locationDelegate: self, vc: self)
    }
	
	func selectCurrentLocation() {
		
	}
    @IBAction func closeButtonClicked() {
        self.navigationController?.popViewController(animated: true)
        //        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Privates -
    
    private func setUpScrollView() {
        otherAddressVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "AreaSelectionViewController") as? AreaSelectionViewController
        otherAddressVC?.areaSelectionProtocol = areaSelectionDelegate
        self.addChild(otherAddressVC!)
        addressScrollView.addSubview(otherAddressVC?.view ?? UIView())
        addressScrollView.delegate = self
    }
    
    private func addAddressesVC() {
        if addressVC == nil {
            addressVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "AddressTableVC") as? AddressTableViewController
            addressVC?.partnerId = user.partner_id
            addressVC?.selectionDelegate = self
            addressVC?.isFromChooseAddress = true
            self.addressVC?.view.frame = CGRect(x: UIScreen.main.bounds.size.width , y: 0, width: UIScreen.main.bounds.size.width , height: self.addressScrollView.bounds.height)
            addChild(addressVC!)
            self.addressScrollView.addSubview(addressVC?.view ?? UIView())
            addressVC?.didMove(toParent: self)
        }
        UIView.animate(withDuration: 0.5) {
            self.addressScrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width, y: 0), animated: false)
//            self.viewIndicatorLeadingConstraint.constant = Device.SCREEN_WIDTH / 2
            self.view.layoutIfNeeded()
        }
        btnOtherAddress.isSelected = false
        btnSavedAddress.isSelected = true
        btnOtherAddress.backgroundColor = .white
        btnSavedAddress.backgroundColor = UIColor(hexString: "#50E3C2").withAlphaComponent(0.27)
    }
    
    func setUpOtherAddress() {
        UIView.animate(withDuration: 0.5) {
            self.addressScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//            self.viewIndicatorLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        btnOtherAddress.isSelected = true
        btnSavedAddress.isSelected = false
        btnSavedAddress.backgroundColor = .white
        btnOtherAddress.backgroundColor = UIColor(hexString: "#50E3C2").withAlphaComponent(0.27)
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldShowTabbar {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    @IBAction func btnOtherAddressPressed(_ sender: Any) {
        setUpOtherAddress()
    }
    
    @IBAction func btnSavedAddressPessed(_ sender: Any) {
        addAddressesVC()
    }
}

extension DeliverySelectionViewController: AddressSelectionDelegate, LocationSelectionDelegate {
    
    func addressSelected(_ address: Address) {
        print("addressSelected....")
        guard let location = address.location else {
            let msg = "This address can not be used for delivery, please edit this address by adding map location."
            let alert = UIAlertController(title: "Location Missing", message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        //		AreaFilter.shared.setselectedLocation(location, title: address.name, addressId: address.id)
        AreaFilter.shared.setSelectedAddress(addressId: address.id, title: address.name)
        self.delegate?.deliveryLocationSelected(location, title: address.name)
        closeButtonClicked()
    }
    
    func locationSelected(_ location: Location, title: String, address: UserAddress) {
        AreaFilter.shared.setselectedLocation(location, title: title)
        self.delegate?.deliveryLocationSelected(location, title: title)
        if let parentVC = self.presentingViewController {
            parentVC.dismiss(animated: true, completion: nil)
        } else {
            closeButtonClicked()
        }
    }
    
}

extension DeliverySelectionViewController: LocationDelegate {
    
    func getLocation(location: Location, address: UserAddress, title: String) {
        AreaFilter.shared.setselectedLocation(location, title: title)
        self.delegate?.deliveryLocationSelected(location, title: title)
        closeButtonClicked()
    }
    
    func locationPermissionDenied() {
        DLog(message: "Permission not available")
        locationWrapper?.checkLocationAvailability()
    }
    
}

extension DeliverySelectionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if previousContentOffset.x > scrollView.contentOffset.x {
            setUpOtherAddress()
        } else if previousContentOffset.x < scrollView.contentOffset.x {
            addAddressesVC()
        }
        
        previousContentOffset = scrollView.contentOffset
    }
    
}
