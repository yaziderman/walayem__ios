//
//  ChooseFilterViewController.swift
//  Walayem
//
//  Created by MAC on 5/21/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit


class ChooseFilterViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    
    var tags = [Tag]()
    var selectedTags = [Tag]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 50, right: 20)
        collectionView?.allowsMultipleSelection = true
        
        getTags()
    }

    // MARK: Private methods
    
    private func getTags(){
        let fields = ["id", "name"]
        OdooClient.sharedInstance().searchRead(model: "product.tag", domain: [], fields: fields, offset: 0, limit: 500, order: "name ASC") { (result, error) in
            if error != nil{
                return
            }
            let records = result!["records"] as! [Any]
            for record in records{
                let tag = Tag(record: record as! [String : Any])
                self.tags.append(tag)
            }
            self.collectionView?.reloadData()
            self.setSelectedItems()
        }
    }

    private func setSelectedItems(){
        for index in 0...tags.count - 1{
            for selectedTag in selectedTags{
                if tags[index].id == selectedTag.id{
                    let indexPath = IndexPath(row: index, section: 0)
                    collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                }
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
        return tags.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCollectionViewCell else {
            fatalError("Unexpected collection view cell")
        }
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.layer.shadowRadius = 5
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 12).cgPath
        
        let tag = tags[indexPath.row]
        cell.titleLabel.text = tag.name
        
        if cell.isSelected{
            cell.backgroundColor = UIColor.colorPrimary
            cell.titleLabel.textColor = UIColor.white
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 30, height: 52)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell else {
            fatalError("Cell does not exist")
        }
        selectedCell.backgroundColor = UIColor.colorPrimary
        selectedCell.titleLabel.textColor = UIColor.white
        let tag = tags[indexPath.row]
        selectedTags.append(tag)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell else {
            fatalError("Cell does not exist")
        }
        selectedCell.backgroundColor = UIColor.white
        selectedCell.titleLabel.textColor = UIColor.colorPrimary
        
        let selectedTag = tags[indexPath.row]
        selectedTags = selectedTags.filter({ (tag) -> Bool in
            tag.id != selectedTag.id
        })
    }
}
