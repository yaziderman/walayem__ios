//
//  HomeTableViewCell.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/3/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher

class HomeTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var bookmarkText: UILabel!
    
    var cellPriceLabel = UILabel()
    var cellNameLabel = UILabel()
    var mealImagesURLS = [URL]()
    var recommendedImagesURLS = [URL]()
    weak var navigationController: UINavigationController?
    
    var identifier = ""
    var bestSellers = [PromotedItem]()
    var cuisinesObj = [Cuisine]()
    
    var staticCuisines = [Cuisine]()
    
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
        }
        else if identifier == "mealDayCell1"{
            return todays_meals.count
        }
        else if identifier == "cuisinesCell4"{
            return staticCuisines.count
        }
        else{
            return 0
        }

        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if identifier == "recommendedCell0"{
//            print(recommendedMeals[indexPath.row].item_details?.name)
            let storyboard : UIStoryboard = UIStoryboard(name: "Discover", bundle: nil)
            guard let destinationVC = storyboard.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else{
                fatalError("Unexpected destination VC")
            }
            
            let food = Food(id: recommendedMeals[indexPath.row].item_details?.id ?? 0, name: recommendedMeals[indexPath.row].item_details?.name! ?? "", price: recommendedMeals[indexPath.row].item_details?.list_price ?? 0.0, quantity: recommendedMeals[indexPath.row].item_details?.serves ?? 0, preparationTime: recommendedMeals[indexPath.row].item_details?.preparation_time ?? 0, kitcherName:recommendedMeals[indexPath.row].kitchen_name  ?? "---", description: recommendedMeals[indexPath.row].item_details?.description_sale ?? "", chefName: recommendedMeals[indexPath.row].chef_name ?? "No Chef Name" , foodType: recommendedMeals[indexPath.row].item_details?.food_type! ?? "", imageIds: recommendedMeals[indexPath.row].item_details?.food_image_ids ?? [0], chefId: recommendedMeals[indexPath.row].item_details?.chef_id ?? 0, chefImage: recommendedMeals[indexPath.row].chef_image_hash ?? "no-Image", cuisine: recommendedMeals[indexPath.row].item_details?.cuisine_id ?? Cuisine(id: 0, name: ""), tags: recommendedMeals[indexPath.row].item_details?.food_tags ?? [Tag(id: 0, name: "")], serves: recommendedMeals[indexPath.row].item_details?.serves ?? 0)
            
            
            destinationVC.food = food
            navigationController?.pushViewController(destinationVC, animated: true)
        }
        
        if identifier == "mealDayCell1"{
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Discover", bundle: nil)
            guard let destinationVC = storyboard.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else{
                fatalError("Unexpected destination VC")
            }
            let food = Food(id: todays_meals[indexPath.row].item_details?.id ?? 0,
                name: todays_meals[indexPath.row].item_details?.name! ?? "",
                price: todays_meals[indexPath.row].item_details?.list_price ?? 0.0,
                quantity: todays_meals[indexPath.row].item_details?.serves ?? 0,
                preparationTime: todays_meals[indexPath.row].item_details?.preparation_time ?? 0,
                kitcherName:todays_meals[indexPath.row].kitchen_name  ?? "-",
                description: todays_meals[indexPath.row].item_details?.description_sale ?? "",
                chefName: todays_meals[indexPath.row].chef_name ?? "No Chef Name" ,
                foodType: todays_meals[indexPath.row].item_details?.food_type! ?? "",
                imageIds: todays_meals[indexPath.row].item_details?.food_image_ids ?? [0],
                chefId: todays_meals[indexPath.row].item_details?.chef_id ?? 0,
                chefImage: todays_meals[indexPath.row].chef_image_hash ?? "no-Image",
                cuisine: todays_meals[indexPath.row].item_details?.cuisine_id ?? Cuisine(id: 0, name: ""),
                tags: todays_meals[indexPath.row].item_details?.food_tags ?? [Tag(id: 0, name: "")],
                serves: todays_meals[indexPath.row].item_details?.serves ?? 0
            )
            
            destinationVC.food = food
            navigationController?.pushViewController(destinationVC, animated: true)
        }
        
        if identifier == "cuisinesCell4"{
            
            StaticLinker.selectedCuisine = nil
            StaticLinker.selectedCuisine = self.staticCuisines[indexPath.row]
            StaticLinker.mainVC?.selectedIndex = 1;
            
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
    
            cellPriceLabel?.text = "\(recommendedMeals[indexPath.row].item_details?.list_price ?? 0) AED"
            cellNameLabel?.text = String(recommendedMeals[indexPath.row].item_details?.name ?? "")

//            cellView?.layer.masksToBounds = true
            cellView?.roundCorners([.bottomRight,.bottomLeft], radius: 15)
            cellImage?.kf.setImage(with: recommendedImagesURLS[indexPath.row])
            
            return recommendedCell
        }
        
            else if identifier == "mealDayCell1"{

            let mealCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            let mealImage = mealCell.viewWithTag(600) as? UIImageView
            mealImage?.kf.setImage(with: mealImagesURLS[indexPath.row])

            let mealName = mealCell.viewWithTag(610) as? UILabel
            mealName?.roundCorners([.bottomLeft,.bottomRight], radius: 15)
            mealName?.text = String(todays_meals[indexPath.row].item_details?.name ?? "")
            print(mealName?.frame.size.width)
            mealName?.frame.size.width = 224
            
            return mealCell
        }
        
        else if identifier == "cuisinesCell4"{

            let cuisineCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            print(indexPath.row)
            print("Section --- \(indexPath.section)")
            
            let cuisineImg = cuisineCell.viewWithTag(500) as? UIImageView
            let cuisineLabel = cuisineCell.viewWithTag(501) as? UILabel

            cuisineLabel?.text = self.staticCuisines[indexPath.row].name
            cuisineImg?.image = UIImage(named: self.staticCuisines[indexPath.row].imageName ?? "1.jpg")
            
            return cuisineCell
        }
        else{
            return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            
        }
            
    }
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        staticCuisines = [Cuisine(id: 1, name: "Indian", img: ""), Cuisine(id: 2, name: "Arabic", img: ""),
                  Cuisine(id: 4, name: "Emirati", img: ""),
                  Cuisine(id: 5, name: "English", img: ""),
                  Cuisine(id: 9, name: "Sudanese", img: ""),
        //                          Cuisine(id: 10, name: "Shami", img: ""),
        //                          Cuisine(id: 11, name: "Gulf", img: ""),
                  Cuisine(id: 12, name: "Palestinian", img: ""),
                  Cuisine(id: 13, name: "Iraqi", img: ""),
                  Cuisine(id: 14, name: "Jordanian", img: ""),
                  Cuisine(id: 15, name: "Lebanese", img: ""),
                  Cuisine(id: 16, name: "Egyptian", img: ""),
                  Cuisine(id: 17, name: "The Maghreb", img: ""),
        //                          Cuisine(id: 18, name: "Italian", img: ""),
                  Cuisine(id: 19, name: "Other", img: ""),
                  Cuisine(id: 20, name: "Asian", img: ""),
                  Cuisine(id: 21, name: "Mexican", img: ""),
                  Cuisine(id: 22, name: "Chinese", img: ""),
        //                          Cuisine(id: 23, name: "Thai", img: ""),
        //                          Cuisine(id: 24, name: "Turkish", img: "")
        ]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
