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
    
    var partnerId: Int?
    var recommendedFoods = [Food]()
    var cellPriceLabel = UILabel()
    var cellNameLabel = UILabel()
    var foods = [Food]()
    
    var food: Food!{
        didSet{
            updateUI()
        }
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
            
            print(indexPath.section)
            print(foods)
            if foods != nil {
                
            }
//            let food = foods[indexPath.section]
            
            print("Inside CV --------------  \(food)")
//            cellNameLabel?.text = food.name
            
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
        self.collectionView.reloadData()
        getRecommendations()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    private func getRecommendations(){
        
            let params : [String: Any] = ["partner_id": partnerId ?? 0]
            
            RestClient().request(WalayemApi.recommendation, params) { (result, error) in
    //            self.hideActivityIndicator()
//                self.tableView.refreshControl?.endRefreshing()
                
                if let error = error{
                    self.handleNetworkError(error)
                    return
                }
                let data = result!["result"] as! [String: Any]
                if let status = data["status"] as? Int, status == 0{
                    return
                }
                self.recommendedFoods.removeAll()
                let records = data["data"] as! [Any]
                for record in records{
                    let food = Food(record: record as! [String : Any])
//                    self.recommendedFoods.append(food)
                    self.foods.append(food)
                    print(food.chefName as Any)
//                    self.tableView.reloadData()
                }
            }
        }
        
        private func handleNetworkError(_ error: NSError){
               let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
               if error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue{
//                   let alert = UIAlertController(title: "Cannot get Foods", message: errmsg, preferredStyle: .alert)
//                   alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                   present(alert, animated: true, completion: nil)
               }else if errmsg == OdooClient.SESSION_EXPIRED{
//                   self.onSessionExpired()
               }
           }
    

}
