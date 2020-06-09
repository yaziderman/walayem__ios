//
//  ChefRatingViewController.swift
//  Walayem
//
//  Created by Inception on 5/27/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import SDWebImage

class ChefRatingViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var chefImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var kitchenLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var foodLabel: UILabel!
    
    var user: User?
    var chef: Chef?
    var orderId: Int?
    var foods : [String]?
    
    // MARK: Actions
    
    @IBAction func submit(_ sender: UIButton) {
        activityIndicator.startAnimating()
        let params: [String: Any] = ["partner_id": user?.partner_id as Any, "chef_id": chef?.id as Any, "star": ratingControl.rating]
        
        RestClient().request(WalayemApi.rateChef, params) { (result, error) in
            self.activityIndicator.stopAnimating()
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as? String
                print (errmsg)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        
        dialogView.layer.cornerRadius = 15
        dialogView.layer.masksToBounds = true
        iconView.tintColor = UIColor.rosa
        submitButton.layer.cornerRadius = 15
        submitButton.layer.masksToBounds = true
        chefImageView.layer.cornerRadius = 15
        chefImageView.layer.masksToBounds = true
        activityIndicator.hidesWhenStopped = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mainViewClicked)))
        
        if let _ = chef{
            self.updateUI()
        }else if let orderId = orderId{
            let params: [String: Int] = ["partner_id": user!.partner_id!, "order_id": orderId]
            
            RestClient().request(WalayemApi.orderDetail, params) { (result, error) in
                if error != nil{
                    let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                    let alert  = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
            
                let value = result!["result"] as! [String: Any]
                let record = value["order_detail"] as! [String: Any]
                
                self.chef = Chef(id: record["chef_id"] as! Int,
                                 name: record["chef_name"] as! String,
                                 image: record["chef_image_hash"] as! String,
                                 kitchen: record["kitchen_name"] as! String,
                                 foods: [Food]())
                self.updateUI()
            }
        }
        
        self.view.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
    }
    
    // MARK: Private methods
    
    private func updateUI(){
		let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/api/chefImage/\(chef!.id)-\(chef!.image)/image_medium")
//        chefImageView.kf.setImage(with: imageUrl)
        chefImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        chefImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
        nameLabel.text = self.chef?.name
        kitchenLabel.text = self.chef?.kitchen
        var foodString = ""
        if((foods?.count)!>0){
            for food in foods!{
                foodString += food + ", "
            }
            foodString =  String(foodString.dropLast(2))
            foodLabel.text = foodString
        }
    }
    
    @objc private func mainViewClicked(sender: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
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
