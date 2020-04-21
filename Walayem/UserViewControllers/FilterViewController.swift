//
//  FilterViewController.swift
//  Walayem
//
//  Created by MAC on 5/3/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    // MARK: Propterties
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var applyButton: UIButton!
    
    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        return view
    }()
    
    var tags = [Tag]()
    var cuisines = [Cuisine]()
    var selectedTags: [Tag]?
    var selectedCuisines: [Cuisine]?
    
    // mark: Actions
    
    @IBAction func close(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func apply(_ sender: UIButton){
        performSegue(withIdentifier: "filterUnwindSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 50, right: 20)
        collectionView.allowsMultipleSelection = true
        
        contentView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:))))
        getTags()
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
    
    private func getTags(){
        let fields = ["id", "name"]
        OdooClient.sharedInstance().searchRead(model: "product.tag", domain: [], fields: fields, offset: 0, limit: 500, order: "name ASC") { (result, error) in
            if error != nil{
                return
            }
            self.getCuisines()
            let records = result!["records"] as! [Any]
            for record in records{
                let tag = Tag(record: record as! [String : Any])
                self.tags.append(tag)
            }
        }
    }
    
    private func getCuisines(){
        let fields = ["id", "name"]
        OdooClient.sharedInstance().searchRead(model: "product.cuisine", domain: [], fields: fields, offset: 0, limit: 500, order: "name ASC") { (result, error) in
            if error != nil{
                return
            }
            let records = result!["records"] as! [Any]
            for record in records{
                let tag = Cuisine(record: record as! [String : Any])
                self.cuisines.append(tag)
            }
            
            self.collectionView.reloadData()
            self.setSelectedItems()
        }
    }
    
    private func setSelectedItems(){
        for index in 0...tags.count - 1{
            for selectedTag in selectedTags!{
                if tags[index].id == selectedTag.id{
                    let indexPath = IndexPath(row: index, section: 0)
                    collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                }
            }
        }
        
        for index in 0...cuisines.count - 1{
            for selectedCuisine in selectedCuisines!{
                if cuisines[index].id == selectedCuisine.id{
                    let indexPath = IndexPath(row: index, section: 1)
                    collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                }
            }
        }
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

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return tags.count
        }else{
            return cuisines.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            guard let reuseableView  = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterCollectionHeaderView", for: indexPath) as? FilterCollectionHeaderView else {
                fatalError("Unexpected headerview")
            }
            if indexPath.section == 0{
                reuseableView.iconImageView.image = UIImage(named: "filter")
                reuseableView.titleLabel.text = "Filters"
            }else{
                reuseableView.iconImageView.image = UIImage(named: "notes")
                reuseableView.titleLabel.text = "Cuisines"
            }
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
        
        if indexPath.section == 0{
            let tag = tags[indexPath.row]
            cell.titleLabel.text = tag.name
        }else{
            let cuisine = cuisines[indexPath.row]
            cell.titleLabel.text = cuisine.name
        }
        
        if cell.isSelected{
            cell.backgroundColor = UIColor.colorPrimary
            cell.titleLabel.textColor = UIColor.white
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
        selectedCell.backgroundColor = UIColor.colorPrimary
        selectedCell.titleLabel.textColor = UIColor.white
        if indexPath.section == 0{
            let tag = tags[indexPath.row]
            selectedTags?.append(tag)
        }else{
            let cuisine = cuisines[indexPath.row]
            selectedCuisines?.append(cuisine)
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell else {
            fatalError("Cell does not exist")
        }
        selectedCell.backgroundColor = UIColor.white
        selectedCell.titleLabel.textColor = UIColor.colorPrimary
        if indexPath.section == 0{
            let selectedTag = tags[indexPath.row]
            selectedTags = selectedTags?.filter({ (tag) -> Bool in
                tag.id != selectedTag.id
            })
        }else{
            let selectedCuisine = cuisines[indexPath.row]
            selectedCuisines = selectedCuisines?.filter({ (cuisine) -> Bool in
                cuisine.id != selectedCuisine.id
            })
        }
    }
    
}
