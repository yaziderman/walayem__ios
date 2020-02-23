//
//  AreaViewController.swift
//  Walayem
//
//  Created by Ramzi Shadid on 2/16/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class AreaViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!

    
    var areas = [Area]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getAreas()
    }
    
    private func getAreas(){
        
        let area1=Area(record: ["name":"Area 1","id":"1","isSelected":false])
        let area2=Area(record: ["name":"Area 2","id":"2","isSelected":false])
        let area3=Area(record: ["name":"Area 3","id":"3","isSelected":false])
        let area4=Area(record: ["name":"Area 4","id":"4","isSelected":false])
        let area5=Area(record: ["name":"Area 5","id":"5","isSelected":false])

        areas.append(area1)
        areas.append(area2)
        areas.append(area3)
        areas.append(area4)
        areas.append(area5)

        self.tableView.reloadData()
    }

   
    @IBAction func next(_ sender: UIButton){
        
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
