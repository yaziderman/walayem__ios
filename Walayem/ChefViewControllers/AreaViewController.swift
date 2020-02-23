//
//  AreaViewController.swift
//  Walayem
//
//  Created by Ramzi Shadid on 2/16/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class AreaViewController: UIViewController {
    var params: [String : Any] = [:]
    
    @IBOutlet weak var tableView: UITableView!

    var progressAlert: UIAlertController?

    var areas = [Area]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getAreas()
    }
    
    private func getAreas(){
        
        
    let params: [String : Any] = ["login": ""]
        progressAlert = showProgressAlert()
        
        RestClient().request(WalayemApi.getAreas, params) { (result, error) in
            if error != nil{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt("Unknown Error")
                })
                return
            }
            let record = result!["result"] as! [String: Any]
            if let errmsg = record["error"] as? String{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt(errmsg)
                })
                return
            }
            let value = result!["result"] as! [String: Any]
            let status = value["status"] as! Int
             if (status != 0) {
                self.areas.removeAll()
                 let records = value["data"] as! [Any]
                 if records.count == 0{
                     return
                 }
                 for record in records{
                     let area = Area(record: record as! [String : Any])
                     self.areas.append(area)
                 }
                self.tableView.reloadData()
             }
        }
    }
    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }

   
    @IBAction func next(_ sender: UIButton){
        var selectedAreas = [Int]()
        for area in areas {
            if area.isSelected {
                selectedAreas.append(area.id ?? 0)
            }
        }
        if selectedAreas.isEmpty {
            showMessagePrompt("Please select at least one area")
        }else {
            params["areas"]=selectedAreas
            self.performSegue(withIdentifier: "SelectAreaLocationSeque", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectAreaLocationSeque" {
            if let destinationVC = segue.destination as? ChefLocationViewController {
                destinationVC.params = params
            }
        }
    }

    

    private func showProgressAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Signing up", message: "Please wait...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        
        let views = ["pending" : alert.view, "indicator" : indicator]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views as [String : Any])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views as [String : Any])
        alert.view.addConstraints(constraints)
        
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        present(alert, animated: false, completion: nil)
        
        return alert
    }
    
    private func showMessagePrompt(_ message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }


    
}

extension AreaViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AreaViewCell", for: indexPath) as? AreaViewCell else {
            fatalError("Unexpected cell")
        }
        let area = areas[indexPath.row]
        cell.area = area
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let area = areas[indexPath.row]
        area.toogle()
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}
