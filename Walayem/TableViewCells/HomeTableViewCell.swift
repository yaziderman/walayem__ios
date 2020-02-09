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
    
    var mealImagesURLS = [URL]()
    var recommendedImagesURLS = [URL]()
    
    var identifier = ""
//    var todays_meals = [PromotedItem]()
    var bestSellers = [PromotedItem]()
//    var recommendedMeals = [PromotedItem]()
    
    var cuisine = ["Arabic", "Emirati", "Asian", "Chinese"]
    var cuisineImages: [UIImage] = [
        UIImage(named: "arabic.jpg")!,
        UIImage(named: "hindi.jpg")!,
        UIImage(named: "phalasteeni.jpg")!,
        UIImage(named: "arabic.jpg")!,
        UIImage(named: "arabic.jpg")!
    ]
    
    var recommendedMeals: [PromotedItem]!{
        didSet{
            updateUI()
        }
    }
    
    var todays_meals: [PromotedItem]!{
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if identifier == "recommendedCell0" {
            return recommendedMeals.count
//            return 4
        }
        else if identifier == "mealDayCell1"{
            return todays_meals.count
        }
        else if identifier == "cuisinesCell4"{
            return cuisine.count
        }
        else{
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if identifier == "recommendedCell0"{

            var price: String!
            let recommendedCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            let cellPriceLabel = recommendedCell.viewWithTag(8801) as? UILabel
            let cellImage = recommendedCell.viewWithTag(8800) as? UIImageView
            let cellView = recommendedCell.viewWithTag(8802)
            let cellNameLabel = recommendedCell.viewWithTag(8803) as? UILabel
    
            cellPriceLabel?.text = "\(recommendedMeals[indexPath.row].item_details?.list_price ?? 0). AED"
            cellNameLabel?.text = String(recommendedMeals[indexPath.row].item_details?.name ?? "")
            
            cellView?.roundCorners([.bottomRight,.bottomLeft], radius: 15)
            cellImage?.kf.setImage(with: recommendedImagesURLS[indexPath.row])
            
            return recommendedCell
        }
        
            else if identifier == "mealDayCell1"{

            let mealCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            let mealImage = mealCell.viewWithTag(600) as? UIImageView
            mealImage?.kf.setImage(with: mealImagesURLS[indexPath.row])
            
            return mealCell
        }
        
        else if identifier == "cuisinesCell4"{

            let cuisineCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            
            print(indexPath.row)
            print("Section --- \(indexPath.section)")
            
            let cuisineImg = cuisineCell.viewWithTag(500) as? UIImageView
            let cuisineLabel = cuisineCell.viewWithTag(501) as? UILabel
            
            cuisineLabel?.text = self.cuisine[indexPath.row]
            cuisineImg?.image = self.cuisineImages[indexPath.row]
            
            return cuisineCell
        }
        else{
            return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            
        }
            
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
