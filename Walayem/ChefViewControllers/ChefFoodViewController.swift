//
//  ChefFoodViewController.swift
//  Walayem
//
//  Created by MAC on 5/21/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Kingfisher
import CropViewController

class FoodImageCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    let foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "addImage")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func setViews(){
        self.layer.cornerRadius = 30
        self.layer.masksToBounds = true
        
        addSubview(foodImageView)
        foodImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        foodImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        foodImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        foodImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
}

class ChefFoodViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate{

    // MARK: Properties
    let imageCellId = "imageCellId"
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var serveTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var foodTypeSegment: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    
    @IBOutlet weak var priceIcon: UIImageView!
    @IBOutlet weak var timeIcon: UIImageView!
    @IBOutlet weak var serveIcon: UIImageView!
    @IBOutlet weak var nameView: UIStackView!
    @IBOutlet weak var priceView: UIStackView!
    @IBOutlet weak var timeView: UIStackView!
    @IBOutlet weak var servesView: UIStackView!
    @IBOutlet weak var descriptionView: UIStackView!
    @IBOutlet weak var cuisineView: UIStackView!
    @IBOutlet weak var filtersView: UIStackView!
    var activityIndicator: UIActivityIndicatorView!
    
    var user: User?
    var food: Food?
    var foodImages = [String]()
    var selectedTags: [Tag]?
    var selectedCuisine: Cuisine?
    var selectedFoodType = FoodCategEnum.appetizer
    
    @IBAction func priceFocus(_ sender: Any) {
        self.priceTextField.becomeFirstResponder()
    }
    
    @IBAction func timeFocus(_ sender: Any) {
        self.timeTextField.becomeFirstResponder()
    }
    @IBAction func peopleFocus(_ sender: Any) {
        self.serveTextField.becomeFirstResponder()
    }
    
    //MARK: Actions
    
    @IBAction func unwindToTags(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? ChooseFilterViewController{
            selectedTags = sourceVC.selectedTags
            updateTags()
        }
    }
    
    @IBAction func unwindToCuisine(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? ChooseCuisineViewController{
            selectedCuisine = sourceVC.selectedCuisine
            self.cuisineLabel.text = selectedCuisine?.name
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveMenu(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let price = priceTextField.text ?? ""
        let time = timeTextField.text ?? ""
        let serve = serveTextField.text ?? ""
        let description = descriptionTextField.text ?? ""
        
        if name.isEmpty{
            showAlert(title: "Error", msg: "Name can not be empty")
            nameTextField.becomeFirstResponder()
            return
        }else if price.isEmpty{
            showAlert(title: "Error", msg: "Price can not be empty")
            priceTextField.becomeFirstResponder()
            return
        }else if time.isEmpty{
            showAlert(title: "Error", msg: "Time can not be empty")
            timeTextField.becomeFirstResponder()
            return
        }else if serve.isEmpty{
            showAlert(title: "Error", msg: "Please enter serve quantity")
            serveTextField.becomeFirstResponder()
            return
        }else if description.isEmpty{
            showAlert(title: "Error", msg: "Please add a description of your food")
            return
        }else if selectedTags == nil{
            showAlert(title: "Error", msg: "Please select at least one filter for your food")
            return
        }else if selectedCuisine == nil{
            showAlert(title: "Error", msg: "Please select your cuisine")
            return
        }
        else if foodImages.count == 0{
            showAlert(title: "Error", msg: "Please add at least one image for your food")
            return
        }
        
        var params = ["chef_id": user?.partner_id as Any,
                      "name": name,
                      "list_price": price,
                      "preparation_time": "\(Int(time)! * 60)",
                      "serves": serve,
                      "description_sale": description,
                      "food_type": selectedFoodType.rawValue,
                      "images": foodImages,
                      "food_tags": selectedTags!.map({ (tag) -> Int in
                        return tag.id
                      }),
                      "cuisine_id": selectedCuisine!.id ] as [String : Any]
        
        if let food = food{
            params["product_id"] = food.id
        }
        
        self.showHideProgress(isLoading: true)
        RestClient().request(WalayemApi.createFood, params) { (result, error) in
            self.showHideProgress(isLoading: false)
            
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                self.showAlert(title: "Error", msg: errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            let msg = value["message"] as! String
            if let status = value["status"] as? Int, status == 0{
                self.showAlert(title: "Error", msg: msg)
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddedDish"), object: nil, userInfo: ["category" :self.selectedFoodType.rawValue])
            
            let isPresentInCreateMode = self.presentingViewController is UITabBarController
            if isPresentInCreateMode{
                self.dismiss(animated: true, completion: nil)
            }else if let navigationController = self.navigationController{
                navigationController.popViewController(animated: true)
            }else{
                fatalError("The MealViewController is not inside a navigation controller.")
            }
        }

    }
    
    @IBAction func selectFoodType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedFoodType = FoodCategEnum.appetizer
        case 1:
            selectedFoodType = FoodCategEnum.maincourse
        case 2:
            selectedFoodType = FoodCategEnum.dessert
        default:
            fatalError("Invalid segment")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        setViews()
        Utils.setupNavigationBar(nav: self.navigationController!)
        if #available(iOS 11.0, *) {
            navigationController?.navigationItem.largeTitleDisplayMode = .never
        } 
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        if traitCollection.forceTouchCapability == .available{
            registerForPreviewing(with: self, sourceView: imageCollectionView)
        }
        
        if let food = food{
            navigationItem.title = food.name
            navigationItem.leftBarButtonItem = nil
            
            nameTextField.text = food.name
            priceTextField.text = String(food.price)
            let hour = Int(max(1, round( Double(food.preparationTime) / 60.0)))
            timeTextField.text = String(hour)
            serveTextField.text = String(food.servingQunatity)
            descriptionTextField.text = food.description
            
            selectedTags = food.tags
            selectedCuisine = food.cuisine
            selectedFoodType = FoodCategEnum(rawValue: food.foodType!)!
            
            foodTypeSegment.selectedSegmentIndex = selectedFoodType.hashValue
            updateTags()
            cuisineLabel.text = selectedCuisine?.name
            downloadImages(food.imageIds!)
        }
    }
    
    override func viewWillLayoutSubviews() {
        nameView.addBottomBorderWithColor(color: .silver, width: 1)
        priceView.addBottomBorderWithColor(color: .silver, width: 1)
        timeView.addBottomBorderWithColor(color: .silver, width: 1)
        servesView.addBottomBorderWithColor(color: .silver, width: 1)
        descriptionView.addBottomBorderWithColor(color: .silver, width: 1)
        filtersView.addBottomBorderWithColor(color: .silver, width: 1)
        cuisineView.addBottomBorderWithColor(color: .silver, width: 1)
    }

    // MARK: Private methods
    
    private func setViews(){
        priceIcon.tintColor = .colorPrimary
        timeIcon.tintColor = .colorPrimary
        serveIcon.tintColor = .colorPrimary
        
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(FoodImageCell.self, forCellWithReuseIdentifier: imageCellId)
        imageCollectionView.allowsSelection = true
        
        saveButton.layer.cornerRadius = 15
        saveButton.layer.masksToBounds = true
    }
    
    private func downloadImages(_ imageIds: [Int]){
        for id in imageIds{
            if let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/food.image/\(id)/image"){
                ImageDownloader.default.downloadImage(with: imageUrl, options: [], progressBlock: nil) {
                    (image, error, url, data) in
                    //print("Downloaded Image: \(image)")
                    if let image = image, let image64 = Utils.encodeImage(image){
                        self.foodImages.append(image64)
                        let indexPath = IndexPath(row: self.foodImages.count, section: 0)
                        self.imageCollectionView.insertItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    private func updateTags(){
        var tagString = ""
        for tag in selectedTags!{
            tagString += tag.name
            if selectedTags?.last !== tag{
                tagString += ", "
            }
        }
        tagsLabel.text = tagString
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func showHideProgress(isLoading: Bool) {
        if isLoading{
            if activityIndicator == nil{
                activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityIndicator?.hidesWhenStopped = true
                let rightBarButton = UIBarButtonItem(customView: activityIndicator!)
                navigationItem.rightBarButtonItem = rightBarButton
            }
            activityIndicator?.startAnimating()
            saveButton.isEnabled = false
        }else{
            activityIndicator?.stopAnimating()
            saveButton.isEnabled = true
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        dismiss(animated: true, completion: nil)
        
        let cropViewController = CropViewController(image: selectedImage)
        cropViewController.customAspectRatio = CGSize.init(width: 1, height: 1)
        cropViewController.aspectRatioPreset = TOCropViewControllerAspectRatioPreset.presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioLockDimensionSwapEnabled = false
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
        
//        // So the user can pick only Square Image not others
//        if selectedImage.size.height == selectedImage.size.width
//        {
//            // Dismiss the picker.
//            if let image64 = Utils.encodeImage(selectedImage){
//                foodImages.append(image64)
//                let indexPath = IndexPath(row: foodImages.count, section: 0)
//                imageCollectionView.insertItems(at: [indexPath])
//            }
//        }else{
//            dismiss(animated: true, completion: nil)
//            self.showAlert(title: "Invalid Image", msg: "Please crop the image in square shape while selecting it.")
//        }
//
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: CROP VIEW CONTROLLER
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        if let image64 = Utils.encodeImage(image){
            foodImages.append(image64)
            let indexPath = IndexPath(row: foodImages.count, section: 0)
            imageCollectionView.insertItems(at: [indexPath])
        }
        
        cropViewController.dismiss(animated: false, completion: nil)

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ChooseFilterVCSegue":
            guard let destinationVC = segue.destination as? ChooseFilterViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            if let tags = selectedTags{
                destinationVC.selectedTags = tags
            }
        case "ChooseCuisineVCSegue":
            guard let destinationVC = segue.destination as? ChooseCuisineViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            destinationVC.selectedCuisine = selectedCuisine
        default:
            fatalError("Invalid segue")
        }
    }

}

extension ChefFoodViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellId, for: indexPath) as? FoodImageCell else {
            fatalError("Unexpected cell")
        }
        if indexPath.row == 0{
            
        }else{
            let image64 = foodImages[indexPath.row - 1]
            cell.foodImageView.image = Utils.decodeImage(image64)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 95)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? FoodImageCell else {
            fatalError("Unexpected cell")
        }
        if indexPath.row == 0{
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            
            let alert = UIAlertController(title: "Photo source", message: "Choose a photo source", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                }else{
                    print ("Camera not available.")
                }
            }))
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popOverController = alert.popoverPresentationController{
                popOverController.sourceView = selectedCell
                popOverController.sourceRect = CGRect(x: selectedCell.bounds.midX, y: selectedCell.bounds.maxY, width: 0, height: 0)
                popOverController.permittedArrowDirections = [.up]
            }
            present(alert, animated: true, completion: nil)
        }else{
            let actionSheet = UIAlertController(title: "Remove Image", message: "The image will be removed from collection", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
                self.foodImages.remove(at: indexPath.row - 1)
                collectionView.deleteItems(at: [indexPath])
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popOverController = actionSheet.popoverPresentationController{
                popOverController.sourceView = selectedCell
                popOverController.sourceRect = CGRect(x: selectedCell.bounds.midX, y: selectedCell.bounds.maxY, width: 0, height: 0)
                popOverController.permittedArrowDirections = [.up]
            }
            present(actionSheet, animated: true, completion: nil)
        }
    }
}

extension ChefFoodViewController: UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = imageCollectionView.indexPathForItem(at: location) else {
            return nil
        }
        guard let cell = imageCollectionView.cellForItem(at: indexPath) as? FoodImageCell else {
            fatalError("Unexpected cell")
        }
        guard let imageVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController else {
            fatalError("Unexpected view controller")
        }
        
        let selectedImage = cell.foodImageView.image
        imageVC.image = selectedImage
        imageVC.preferredContentSize = CGSize(width: 0.0, height: 300)
        previewingContext.sourceRect = cell.frame
        
        return imageVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //navigationController?.pushViewController(viewControllerToCommit, animated: true)
        show(viewControllerToCommit, sender: self)
    }
    
}
