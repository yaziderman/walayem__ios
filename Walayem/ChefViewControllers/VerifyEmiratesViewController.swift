//
//  VerifyEmiratesViewController.swift
//  Walayem
//
//  Created by MAC on 5/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class VerifyEmiratesViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var activeImageView: UIImageView!
    var user: User?
    
    // MARK: Actions
    
    @IBAction func verify(_ sender: UIButton) {
        if let firstImage = firstImageView.image, let secondImage = secondImageView.image{
            guard let firstImage64 = Utils.encodeImage(firstImage) else {
                return
            }
            guard let secondImage64 = Utils.encodeImage(secondImage) else {
                return
            }
            let values = ["emirates_front_image": firstImage64, "emirates_back_image": secondImage64]
            
            activityIndicator.startAnimating()
            OdooClient.sharedInstance().write(model: "res.partner", ids: [user!.partner_id!], values: values) { (result, error) in
                self.activityIndicator.stopAnimating()
                if let error = error{
                    let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                    self.showMessagePrompt(msg: errmsg)
//                    self.onSessionExpired()
                    return
                }
                print (result!)
                self.performSegue(withIdentifier: "ChefMainSegue", sender: self)
            }
        }
    }
    
    @IBAction func pickFirstImage(_ sender: UITapGestureRecognizer) {
        activeImageView = firstImageView
        chooseImagePicker()
    }
    
    @IBAction func pickSecondImage(_ sender: UITapGestureRecognizer) {
        activeImageView = secondImageView
        chooseImagePicker()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        
        firstImageView.layer.cornerRadius = 25
        firstImageView.layer.masksToBounds = true
        secondImageView.layer.cornerRadius = 25
        secondImageView.layer.masksToBounds = true
    }
    
    
    // MARK: Private methods
    
    private func chooseImagePicker(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        let alert = UIAlertController(title: "Photo source", message: "Choose an image source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print ("Camera not available.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (action) in
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popOverController = alert.popoverPresentationController{
            popOverController.sourceView = activeImageView
            popOverController.sourceRect = CGRect(x: activeImageView.bounds.midX, y: activeImageView.bounds.maxY, width: 0, height: 0)
            popOverController.permittedArrowDirections = [.up]
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func showMessagePrompt(msg: String){
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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

extension VerifyEmiratesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
    
        activeImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
