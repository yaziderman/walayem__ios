//
//  AreaFilterViewController.swift
//  Walayem
//
//  Created by Ramzi Shadid on 2/23/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
class AreaFilterViewController: UIViewController {

    // MARK: Propterties
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var applyButton: UIButton!
    var progressAlert: UIAlertController?

    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        return view
    }()
    
    var areas = [Area]()
    var selectedAreas = [Area]()

    
    @IBAction func close(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func apply(_ sender: UIButton){
        
        for area in areas {
            if area.isSelected {
                selectedAreas.append(area)
            }
        }
        
        performSegue(withIdentifier: "areasFilterUnwindSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 50, right: 20)
        collectionView.allowsMultipleSelection = true
        
        contentView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:))))
        getAreas()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.removeFromSuperview()
        }
    }
    
    override func viewWillLayoutSubviews() {
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
        applyButton.roundCorners([.topLeft, .topRight], radius: 20)
        
        self.presentingViewController?.view.addSubview(backgroundView)
        backgroundView.frame = self.presentingViewController?.view.bounds ?? .zero
    }
    
    // MARK: Private methods
    
    @objc private func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        if translation.y > 0{
            view.frame.origin.y = translation.y
        }
        if gesture.state == .ended{
            let velocity = gesture.velocity(in: view)
            let originY = self.view.frame.origin.y
            let dismissableHeight = self.view.bounds.height * 0.2
            
            if originY > dismissableHeight || velocity.y >= 1500 {
                self.dismiss(animated: true, completion: nil)
            }else{
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        }
    }
    
    private func getAreas(){
        
        
    let params: [String : Any] = ["login": ""]
        progressAlert = showProgressAlert()
        
        RestClient().request(WalayemApi.getAreas, params) { (result, error) in
            if error != nil{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt("Unknown Error")
                })
                return
            }
            let record = result!["result"] as! [String: Any]
            if let errmsg = record["error"] as? String{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt(errmsg)
                })
                return
            }
            let value = result!["result"] as! [String: Any]
            let status = value["status"] as! Int
             if (status != 0) {
                self.areas.removeAll()
                 let records = value["data"] as! [Any]
                 if records.count == 0{
                     return
                 }
                
                let area = Area(record: ["name" : "Near Me","city_id" : -1])
                self.areas.append(area)

                 for record in records{
                     let area = Area(record: record as! [String : Any])
                     self.areas.append(area)
                 }
                self.setSelectedItems()
             }
        }
    }

    private func showProgressAlert() -> UIAlertController{
           let alert = UIAlertController(title: "Filter", message: "Please wait...", preferredStyle: .alert)
           let indicator = UIActivityIndicatorView()
           indicator.translatesAutoresizingMaskIntoConstraints = false
           alert.view.addSubview(indicator)
           
           let views = ["pending" : alert.view, "indicator" : indicator]
           
           var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views as [String : Any])
           constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views as [String : Any])
           alert.view.addConstraints(constraints)
           
           indicator.isUserInteractionEnabled = false
           indicator.startAnimating()
           
           present(alert, animated: false, completion: nil)
           
           return alert
       }
       
       private func showMessagePrompt(_ message: String){
           let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
           present(alert, animated: false, completion: nil)
       }
   
    
    
    private func setSelectedItems(){
        for (index,area) in areas.enumerated() {
            if area.isSelected {
                let indexPath = IndexPath(row: index, section: 0)
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
        self.collectionView.reloadData()
    }


}

extension AreaFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return areas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader{
            guard let reuseableView  = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterCollectionHeaderView", for: indexPath) as? FilterCollectionHeaderView else {
                fatalError("Unexpected headerview")
            }
            reuseableView.iconImageView.image = UIImage(named: "filter")
            reuseableView.titleLabel.text = "Areas"

            return reuseableView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.05
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowRadius = 5
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 6).cgPath
        
        let area = areas[indexPath.row]

        cell.titleLabel.text = area.name
        
        if area.isSelected{
            cell.backgroundColor = UIColor.colorPrimary
            cell.titleLabel.textColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.white
            cell.titleLabel.textColor = UIColor.colorPrimary
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 25, height: 42)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell else {
            fatalError("Cell does not exist")
        }
        for area in areas {
            area.isSelected = false
        }
        self.collectionView.reloadData()
        
        selectedCell.backgroundColor = UIColor.colorPrimary
        selectedCell.titleLabel.textColor = UIColor.white
        let area = areas[indexPath.row]
        area.toogle()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell else {
            fatalError("Cell does not exist")
        }
        selectedCell.backgroundColor = UIColor.white
        selectedCell.titleLabel.textColor = UIColor.colorPrimary
        let area = areas[indexPath.row]
        area.toogle()
    }
    
}

