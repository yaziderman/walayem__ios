//
//  ChefTableViewCell.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher
import SDWebImage

protocol ChefCellDelegate: class {
    func foodSelected(_: Food)
}

class ChefTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var chefImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: ChefCellDelegate?
    
    var chef: Chef!{
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        chefImageView.layer.cornerRadius = 12
        chefImageView.layer.masksToBounds = true
        countLabel.layer.cornerRadius = countLabel.frame.width / 2
        countLabel.layer.masksToBounds = true
        
        var description: String = ""
        for tag in chef.foods[0].tags{
            description.append(tag.name ?? "")
            if let lastTag = chef.foods[0].tags.last, lastTag !== tag{
                description.append(" \u{2022} ")
            }
        }
        
        nameLabel.text = "\(chef.name) \u{2022} \(chef.kitchen)"
        countLabel.text = String (chef.foods.count)
        descriptionLabel.text = description
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/api/chefImage/\(chef.id)-\(chef.image!)/image_medium")
//        chefImageView.kf.setImage(with: imageUrl)
        chefImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        chefImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
}

extension ChefTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chef.foods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChefFoodCollectionViewCell", for: indexPath) as? ChefFoodCollectionViewCell else{
            fatalError("Unexpected CollectionViewCell")
        }
        let id = chef.foods[indexPath.row].id
        cell.foodImageView.layer.cornerRadius = 15
        cell.foodImageView.layer.masksToBounds = true
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(id ?? 0)/image")
//        cell.foodImageView.kf.setImage(with: imageUrl)
        
        cell.foodImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.foodImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let food = chef.foods[indexPath.row]
        food.chefId = chef.id
        food.chefName = chef.name
        food.kitcherName = chef.kitchen
        self.delegate?.foodSelected(food)
    }
    
}
