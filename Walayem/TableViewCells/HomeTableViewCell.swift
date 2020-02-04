//
//  HomeTableViewCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/3/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher

class HomeTableViewCell: UITableViewCell, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var bookmarkText: UILabel!
    
    var cellPriceLabel = UILabel()
    var cellNameLabel = UILabel()
    var foods = [Food]()
    
//
//    var food: Food!{
//        didSet{
//            updateUI()
//        }
    }
    
    private func updateUI(){
        
//        cellNameLabel.text = food.name
//        collectionView.reloadData()
    }
    
    
    
    var identifier = "cell1"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if identifier == "cell0"{
            let cellPriceLabel = collectionView.viewWithTag(8801) as? UILabel
            let cellImage = collectionView.viewWithTag(8800) as? UIImageView
            let cellView = collectionView.viewWithTag(8802) as? UIView
            let cellNameLabel = collectionView.viewWithTag(8803) as? UILabel
            
            cellPriceLabel?.text = "1,200 AED"
//            let food = foods[indexPath.section]
            cellNameLabel?.text = food.name
            cellView?.roundCorners([.bottomRight,.bottomLeft], radius: 15)
            
//            let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(876)/image")
//            cellImage?.image?.kf.setImage(with: imageUrl)
        }
        
        if identifier == "cuisinesCVCell"{
            print(cell.tag)
        }

        
        return cell
    }
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
