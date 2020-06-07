//
//  DeliveryLocationView.swift
//  Walayem
//
//  Created by D4ttatraya on 31/05/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

protocol DeliveryLocationViewDelegate: class {
    func locationButtonClicked()
}

class DeliveryLocationView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var downArrowImageView: UIImageView!
    @IBOutlet weak var locationLable: UILabel!
    
    weak var delegate: DeliveryLocationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @IBAction func locationButtonClicked() {
        self.delegate?.locationButtonClicked()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("DeliveryLocationView", owner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        downArrowImageView.image = downArrowImageView.image?.withRenderingMode(.alwaysTemplate)
        downArrowImageView.tintColor = UIColor.colorPrimary
        
        locationUpdated()
    }
    
    func locationUpdated() {
        warningView.isHidden = AreaFilter.shared.selectedLocation != nil
        locationView.isHidden = AreaFilter.shared.selectedLocation == nil
        if let title = AreaFilter.shared.selectedCoverageTitle {
            locationLable.text = "Delivery to: \(title)"
        }
    }
    
}
