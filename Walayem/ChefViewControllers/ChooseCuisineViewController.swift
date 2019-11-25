//
//  ChooseCuisineViewController.swift
//  Walayem
//
//  Created by MAC on 5/21/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit


class ChooseCuisineViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    
    var cuisines = [Cuisine]()
    var selectedCuisine: Cuisine?
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 50, right: 20)
        self.collectionView?.allowsSelection = true

        getCuisines()
    }

    // MARK: Private methods
    
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
            
            self.collectionView?.reloadData()
            self.setSelectedCuisine()
        }
    }
    
    private func setSelectedCuisine(){
        for index in 0...cuisines.count - 1{
            if selectedCuisine?.id == cuisines[index].id{
                let indexPath = IndexPath(row: index, section: 0)
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                break
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return cuisines.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CuisineCell", for: indexPath) as? FilterCollectionViewCell else{
            fatalError("Unexpected collection view cell")
        }
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.layer.shadowRadius = 5
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 12).cgPath
        
        let cuisine = cuisines[indexPath.row]
        cell.titleLabel.text = cuisine.name
        
        if cell.isSelected{
            cell.backgroundColor = UIColor.colorPrimary
            cell.titleLabel.textColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.white
            cell.titleLabel.textColor = UIColor.colorPrimary
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 30, height: 52)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCuisine = cuisines[indexPath.row]
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        selectedCell.backgroundColor = UIColor.colorPrimary
        selectedCell.titleLabel.textColor = UIColor.white
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        selectedCell.backgroundColor = UIColor.white
        selectedCell.titleLabel.textColor = UIColor.colorPrimary
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

}
