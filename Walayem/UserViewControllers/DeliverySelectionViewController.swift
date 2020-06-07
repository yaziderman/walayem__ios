//
//  DeliverySelectionViewController.swift
//  Walayem
//
//  Created by D4ttatraya on 31/05/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

protocol DeliverySelectionDelegate: class {
    func deliveryLocationSelected(_: Location, title: String)
}

class DeliverySelectionViewController: UIViewController {

    var user: User!
    weak var delegate: DeliverySelectionDelegate?
    
    @IBOutlet weak var addressesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        if user.partner_id != 0 {
            addAddressesVC()
        }
    }
    
    @IBAction func newAddressButtonClicked() {
        let addressVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "AddressVCId") as! AddressViewController
        let navVC = UINavigationController(rootViewController: addressVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
    }
    @IBAction func currentLocationButtonClicked() {
        let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "LocationSelectionVCId") as! LocationSelectionViewController
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func closeButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Privates -
    private func addAddressesVC() {
        let addressVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "AddressTableVC") as! AddressTableViewController
        addressVC.partnerId = user.partner_id
        addressVC.selectionDelegate = self
        addChild(addressVC)
        addressVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.addressesContainerView.addSubview(addressVC.view)

        NSLayoutConstraint.activate([
            addressVC.view.leadingAnchor.constraint(equalTo: self.addressesContainerView.leadingAnchor),
            addressVC.view.trailingAnchor.constraint(equalTo: self.addressesContainerView.trailingAnchor),
            addressVC.view.topAnchor.constraint(equalTo: self.addressesContainerView.topAnchor),
            addressVC.view.bottomAnchor.constraint(equalTo: self.addressesContainerView.bottomAnchor)
        ])
        addressVC.didMove(toParent: self)
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
        AreaFilter.shared.setselectedLocation(location, title: address.name)
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
