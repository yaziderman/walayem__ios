//
//  ChefTableViewCell.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher

class ChefTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var chefImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var chefTableVC: ChefTableViewController?
    var favChefTableVC: FavChefTableViewController?
    
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
            description.append(tag.name)
            if let lastTag = chef.foods[0].tags.last, lastTag !== tag{
                description.append(" \u{2022} ")
            }
        }
        
        nameLabel.text = "\(chef.name) \u{2022} \(chef.kitchen)"
        countLabel.text = String (chef.foods.count)
        descriptionLabel.text = description
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/api/chefImage/\(chef.id)-\(chef.image!)/image_medium")
        chefImageView.kf.setImage(with: imageUrl)
        
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
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(id)/image")
        cell.foodImageView.kf.setImage(with: imageUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let food = chef.foods[indexPath.row]
        food.chefId = chef.id
        food.chefName = chef.name
        food.kitcherName = chef.kitchen
        if let chefTableVC = chefTableVC{
            chefTableVC.showFoodDetailVC(food: food)
        }
        
        if let favChefTableVC = favChefTableVC{
            favChefTableVC.showFoodDetailVC(food: food)
        }
    }
    
}
