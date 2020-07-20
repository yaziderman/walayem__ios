//
//  LocationSelectionViewController.swift
//  Walayem
//
//  Created by ITRS-348 on 03/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

@objc protocol AreaSelectionProtocol: class {
    @objc func areaSelected(selectedAreaArray: [Int], areaName: String)
}

class AreaSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var expandableTableView: UITableView!
    
    var isPush = false
    weak var delegate: ChefCoverageAreaDelegate?
    weak var areaSelectionProtocol: AreaSelectionProtocol?
    
    enum ExpandType :String
    {
        case expandTypeSingle
        case expandTypeMultiple
    }
    
    /* expandType is used to determine whether to expand a single section or multiple at same time */
    var expandType: ExpandType = .expandTypeSingle
    let kHeaderSectionTag: Int = 6900;
    var currentExpandedSectionHeader: UITableViewHeaderFooterView!
    var currentExpandedSectionHeaderNumbers: Array<Int> = [-1, -1, -1,-1,-1, -1,-1]
    
    var sectionItems: [[[String: Any]]] = []
    var filteredSectionItems: [[[String: Any]]] = []
    var sections: [[String: Any]] = []
    var filteredSections: [[String: Any]] = []
    
    var selectedAreaArray: [Int] = []
    private var selectedEmirateArray: [Int] = []
    var selectedAreaTitleArray: [String] = []
    
    //MARK: - Implementation
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.setupUI()
        
        self.filteredSectionItems = self.sectionItems
        self.filteredSections = self.sections
        self.expandableTableView!.tableFooterView = UIView()
    }
    
    private func setupUI() {
        self.expandableTableView.allowsMultipleSelection = true
        self.getAreas()
    }
    
    func getAreas() {
        RestClient().request(WalayemApi.getAreas, [:], self) { (result, error) in
            if error != nil {
                let controller = UIAlertController(title: "Oops", message: "Failed to get data", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                }))
                self.present(controller, animated: true, completion: nil)
            }
            
            if let mResult = result!["result"] as? [String: Any],
                let data = mResult["data"] as? [String: Any],
                let emirates = data["emirates"] as? [[String: Any]] {
                self.sections = []
                self.sectionItems = []
                self.currentExpandedSectionHeaderNumbers.removeAll()
                for item in emirates {
                    guard let emirateId = item["id"] as? Int else { continue }
                    
                    //emirate
                    var section: [String : Any] = ["id": emirateId,
                                                   "emirates_name": (item["emirates_name"] as? String) ?? "",
                                                   "isSelected": false]
                    
                    //areas
                    
                    if let areas = item["areas"] as? [[String: Any]] {
                        let areasId = areas.map { ($0["id"] as? Int ?? 0) }
                        
                        var count = 0
                        
                        for id in areasId {
                            if ChefAreaCoverage.loadFromUserDefaults()?.areaIds.contains(id) ?? false {
                                count += 1
                            }
                        }
                        
                        if count == areasId.count {
                            self.selectedEmirateArray.append(emirateId)
                            section["isSelected"] = true
                        }
                        
                        var areaArr: [[String: Any]] = []
                        for area in areas {
                            let dict: [String: Any] = ["title":area["name"] as! String,
                                                       "isSelected": ChefAreaCoverage.loadFromUserDefaults()?.areaIds.contains(area["id"] as! Int) ?? false,
                                                       "id":area["id"] as! Int,
                                                       "emirateId": emirateId]
                            areaArr.append(dict)
                        }
                        self.sectionItems.append(areaArr)
                    }
                    
                    if !(ChefAreaCoverage.loadFromUserDefaults()?.areaIds.isEmpty ?? true) {
                        self.selectedAreaArray = ChefAreaCoverage.loadFromUserDefaults()?.areaIds ?? []
                    }
                    
                    if !(ChefAreaCoverage.loadFromUserDefaults()?.areaTitles.isEmpty ?? true) {
                        self.selectedAreaTitleArray = (ChefAreaCoverage.loadFromUserDefaults()?.areaTitles)!
                    }
                    
                    self.sections.append(section)
                    self.currentExpandedSectionHeaderNumbers.append(-1)
                }
                self.filteredSectionItems = self.sectionItems
                self.filteredSections = self.sections
                self.expandableTableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.filterList(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterList(searchText)
    }
    
    func filterList(_ val: String) {
        if val == "" {
            self.filteredSectionItems = self.sectionItems
            self.filteredSections = self.sections
            
        } else {
            self.filteredSectionItems = []
            self.filteredSections = []
            for i in 0 ... self.sections.count - 1 {
                let section = self.sections[i]
                var innerArray: [[String: Any]] = []
                var isAdded = false
                for mItem in self.sectionItems[i] {
                    if (mItem["title"] as! String).lowercased().contains(val.lowercased()) {
                        isAdded = true
                        innerArray.append(mItem)
                    }
                }
                if isAdded {
                    self.filteredSections.append(section)
                    self.filteredSectionItems.append(innerArray)
                }
            }
        }
        
        self.currentExpandedSectionHeaderNumbers = []
        for _ in self.filteredSections {
            self.currentExpandedSectionHeaderNumbers.append(-1)
        }
        
        self.expandableTableView.reloadData()
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        //        if self.selectedAreaArray.count == 0,
        //            self.selectedEmirateArray.count == 0 {
        //            showAlertBeforeLogin(message: "Please select atleast one area.")
        ////            self.closeBtnClicked(UIButton())
        //            return
        //        }
        //        let title = self.selectedAreaTitleArray.joined(separator: ", ")
        //        if self.selectedEmirateArray.count > 0 {
        //            self.selectedAreaArray = []
        //            self.selectedEmirateArray.forEach { (emirateId) in
        //                self.sectionItems.forEach { (areas) in
        //                    areas.forEach { (area) in
        //                        if (area["emirateId"] as! Int) == emirateId {
        //                            self.selectedAreaArray.append(area["id"] as! Int)
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //        self.delegate?.didSelectMultipleAreas(selectedAreas: self.selectedAreaArray,
        //                                              selectedEmirates: self.selectedEmirateArray,
        //                                              title: title)
        if selectedAreaArray.count == 0 {
            let section = self.filteredSectionItems.first
            let item = section?.first
            if let id = item?["id"] as? Int {
                self.selectedAreaArray.append(id)
            }
            selectedAreaTitleArray.removeAll()
            if let title = item?["title"] as? String {
                selectedAreaTitleArray.append(title)
            }
            
        }
        areaSelectionProtocol?.areaSelected(selectedAreaArray: selectedAreaArray, areaName: selectedAreaTitleArray.first ?? "")
        self.closeBtnClicked(UIButton())
    }
    @IBAction func closeBtnClicked(_ sender: Any) {
        if self.isPush {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Tableview DATA SOURCE Methods
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if filteredSections.count > 0
        {
            tableView.backgroundView = nil
            return filteredSections.count
        }
        else
        {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.expandableTableView.backgroundView = messageLabel;
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.currentExpandedSectionHeaderNumbers.count > section && self.currentExpandedSectionHeaderNumbers[section] != -1
        {
            let arrayOfItems = self.filteredSectionItems[section]
            return arrayOfItems.count;
        }
        else
        {
            return 0;
        }
    }
    
    
    @objc private func headerBtnClicked(_ sender: UIButton) {
        var section = self.filteredSections[sender.tag]
        let isSelected = !(section["isSelected"] as! Bool)
        section["isSelected"] = !(section["isSelected"] as! Bool)
        filteredSections[sender.tag] = section
        let id = section["id"] as! Int
        let item = section["emirates_name"] as! String
        
        if isSelected && !self.selectedEmirateArray.contains(id) {
            self.selectedEmirateArray.append(id)
            self.selectedAreaTitleArray.append(item)
            self.filteredSections[sender.tag]["isSelected"] = true
            var section = self.filteredSectionItems[sender.tag]
            for i in 0..<section.count {
                var item = section[i]
                item["isSelected"] = true
                if !selectedAreaArray.contains(item["id"] as! Int) {
                    self.selectedAreaArray.append(item["id"] as! Int)
                }
                
                if !selectedAreaTitleArray.contains(item["title"] as! String) {
                    selectedAreaTitleArray.append(item["title"] as! String)
                }
                
                section[i] = item
            }
            self.filteredSectionItems[sender.tag] = section
        } else if !isSelected && self.selectedEmirateArray.contains(id) {
            self.selectedEmirateArray.remove(element: id)
            self.selectedAreaTitleArray.remove(element: item)
            self.filteredSections[sender.tag]["isSelected"] = false
            var section = self.filteredSectionItems[sender.tag]
            for i in 0..<section.count {
                var item = section[i]
                item["isSelected"] = false
                selectedAreaTitleArray.remove(element: item["title"] as! String)
                self.selectedAreaArray.remove(element: item["id"] as! Int)
                section[i] = item
            }
            self.filteredSectionItems[sender.tag] = section
        }
        expandableTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionDict = self.filteredSections[section]
        //        let isSelected = sectionDict["isSelected"] as! Bool == true
        
        let view = UIView()
        //        view.backgroundColor = .white
        //        let imgName = isSelected ? "areaChecked" : "areaUnchecked"
        //        let image = UIImage(named: imgName)
        let button = UIButton(type: .custom)
        button.tag = section
        button.addTarget(self, action: #selector(headerBtnClicked(_:)), for: .touchUpInside)
        button.setTitleColor(.darkGray, for: .normal)
        //        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 8, y: 3, width: 35, height: 35)
        view.addSubview(button)
        
        let label = UILabel(frame: CGRect(x: button.frame.maxX, y: 0, width: 250, height: 40))
        label.text = sectionDict["emirates_name"] as? String
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.filteredSectionItems[indexPath.section]
        
        for i in 0..<self.filteredSectionItems.count {
            var section = self.filteredSectionItems[i]
            for j in 0..<section.count {
                var item = section[j]
                item["isSelected"] = false
                section[j] = item
            }
            self.filteredSectionItems[i] = section
        }
        
        self.selectedAreaArray.removeAll()
        self.selectedAreaTitleArray.removeAll()
        
        self.itemSelected(item: section[indexPath.row]["title"] as! String,
                          id: section[indexPath.row]["id"] as! Int,
                          isSelected: !(section[indexPath.row]["isSelected"] as! Bool),
                          section: indexPath.section,
                          row: indexPath.row)
        
        //        var count = 0
        //
        //        for item in self.filteredSectionItems[indexPath.section] {
        //            if (item["isSelected"] as! Bool) {
        //                count += 1
        //            }
        //        }
        
        //        var currentSection = self.filteredSections[indexPath.section]
        
        //        if count == self.filteredSectionItems[indexPath.section].count {
        //            currentSection["isSelected"] = true
        //            if !self.selectedEmirateArray.contains(currentSection["id"] as! Int) {
        //                self.selectedEmirateArray.append(currentSection["id"] as! Int)
        //            }
        //        } else {
        //            currentSection["isSelected"] = false
        //            self.selectedEmirateArray.remove(element: currentSection["id"] as! Int)
        //        }
        
        //        self.filteredSections[indexPath.section] = currentSection
        
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as? ChefAreaTabelViewCell {
            
            let section = self.filteredSectionItems[indexPath.section]
            cell.setData(itemName: section[indexPath.row]["title"] as! String,
                         isSelected: section[indexPath.row]["isSelected"] as! Bool,
                         section: indexPath.section,
                         row: indexPath.row)
            
            return cell
        }
        return UITableViewCell()
        
    }
    
    private func deselectAllItems() {
        self.selectedAreaArray = []
        self.selectedAreaTitleArray = []
        self.selectedEmirateArray = []
        
        self.filteredSectionItems = self.filteredSectionItems.map { (areas) -> [[String: Any]] in
            return areas.map { (areaDict) -> [String: Any] in
                var newDict = areaDict
                newDict["isSelected"] = false
                return newDict
            }
        }
        self.filteredSections = self.filteredSections.map { (section) -> [String: Any] in
            var newSection = section
            newSection["isSelected"] = false
            return newSection
        }
    }
    
    func itemSelected(item: String, id: Int, isSelected: Bool, section: Int, row: Int) {
        //        if isSelected && !self.selectedAreaArray.contains(id) {
        self.selectedAreaArray.append(id)
        self.selectedAreaTitleArray.append(item)
        self.filteredSectionItems[section][row]["isSelected"] = true
        //        } else if !isSelected && self.selectedAreaArray.contains(id) {
        //            guard self.selectedAreaArray.count > 0 else {
        //                return
        //            }
        //            self.selectedAreaArray.remove(element: id)
        ////            self.selectedAreaTitleArray.remove(element: item)
        //            self.filteredSectionItems[section][row]["isSelected"] = isSelected
        //        }
        expandableTableView.reloadData()
    }
    
    // MARK: - Tableview DELEGATE Methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40.0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(ChefCoverageArea.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section){
            viewWithTag.removeFromSuperview()
        }
        
        let headerFrame = self.view.frame.size
        let chevronImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 11, width: 18, height: 18))
        chevronImageView.image = UIImage(named: "down")?.withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            chevronImageView.tintColor = .label
        } else {
            chevronImageView.tintColor = .black
        }
        chevronImageView.tag = kHeaderSectionTag + section
        if self.filteredSections[section]["emirates_name"] as! String != "Near By" {
            header.addSubview(chevronImageView)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer)
    {
        let headerView = sender.view!
        let section    = headerView.tag
        let currentlyTouchedHeaderImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView // The Dropdown Image for the currently touched header
        if self.filteredSections[section]["emirates_name"] as! String == "Near By" {
            return
        }
        if !self.isAnySectionExpanded()
        {
            //  none of the sections/headers are currently expanded
            if self.currentExpandedSectionHeaderNumbers.count > section {
                self.currentExpandedSectionHeaderNumbers[section] = section
                expandTableViewSection(section, imageView: currentlyTouchedHeaderImageView!)
            }
        }
        else
        {
            if self.currentExpandedSectionHeaderNumbers.count > section && self.currentExpandedSectionHeaderNumbers[section] != -1
            {
                //  already expanded section/header is touched, so collapse that
                
                collapseTableViewSection(section, imageView: currentlyTouchedHeaderImageView!)
            }
            else
            {
                // a secction/header is already expanded, and another header/section is touched to expand
                
                if self.expandType == .expandTypeSingle
                {
                    collpaseAlreadyExpandedSection()
                }
                
                expandTableViewSection(section, imageView: currentlyTouchedHeaderImageView!)
            }
        }
    }
    
    func collapseTableViewSection(_ section: Int, imageView: UIImageView)
    {
        let sectionData = self.filteredSectionItems[section]
        
        self.currentExpandedSectionHeaderNumbers[section] = -1
        
        if (sectionData.count == 0)
        {
            return;
        }
        else
        {
            // un-rotate chevron ImageView
            
            UIView.animate(withDuration: 0.4, animations:
                {
                    imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            
            // delete rows of collapsed section
            
            var indexPaths = [IndexPath]()
            
            for i in 0 ..< sectionData.count
            {
                let index = IndexPath(row: i, section: section)
                indexPaths.append(index)
            }
            
            self.expandableTableView!.beginUpdates()
            self.expandableTableView!.deleteRows(at: indexPaths, with: UITableView.RowAnimation.fade)
            self.expandableTableView!.endUpdates()
        }
    }
    
    func expandTableViewSection(_ section: Int, imageView: UIImageView)
    {
        let sectionData = self.filteredSectionItems[section]
        
        if (sectionData.count == 0)
        {
            self.currentExpandedSectionHeaderNumbers[section] = -1
            return;
        }
        else
        {
            // rotate chevron ImageView
            
            UIView.animate(withDuration: 0.4, animations:
                {
                    imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            
            // add rows for expanded section
            
            var indexesPath = [IndexPath]()
            
            for i in 0 ..< sectionData.count
            {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            
            self.currentExpandedSectionHeaderNumbers[section] = section
            
            self.expandableTableView!.beginUpdates()
            self.expandableTableView!.insertRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.expandableTableView!.endUpdates()
        }
    }
    
    // MARK:- Private
    
    func isAnySectionExpanded() -> Bool
    {
        for i in 0 ..< self.currentExpandedSectionHeaderNumbers.count
        {
            if self.currentExpandedSectionHeaderNumbers[i] != -1
            {
                return true
            }
        }
        return false
    }
    
    func collpaseAlreadyExpandedSection()
    {
        for section in 0 ..< self.currentExpandedSectionHeaderNumbers.count
        {
            if self.currentExpandedSectionHeaderNumbers[section] != -1
            {
                let alreadyExpandedHeaderImageView = self.view.viewWithTag(kHeaderSectionTag + section) as? UIImageView ?? UIImageView()
                
                collapseTableViewSection(section, imageView: alreadyExpandedHeaderImageView)
            }
        }
    }
}
