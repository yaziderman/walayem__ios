//
//  OnBoardingViewController.swift
//  Walayem
//
//  Created by MAC on 4/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let titles = ["Discover foods", "Order", "Enjoy"]
    let bodies = ["Discover foods being prepared\nby home chefs in your city",
                  "Order the meals you like, on the\ngo and with just a single tap",
                  "Enjoy fresh home cooked\nmeals, everyday"]
    let images = [UIImage(named: "onBoarding1"), UIImage(named: "onBoarding2"), UIImage(named: "onBoarding3")]
    
    // MARK: Actions
    
    @IBAction func skipWalkThrough(_ sender: UIButton) {
        performSegue(withIdentifier: "LocationPermissionSegue", sender: self)
    }
    
    @IBAction func showNext(_ sender: UIButton) {
        if pageControl.currentPage == titles.count - 1{
            performSegue(withIdentifier: "LocationPermissionSegue", sender: self)
            return
        }
        let indexPath = IndexPath(row: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else{
            fatalError("Could not get the flow layout")
        }
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
    }
    
    // MARK: UICollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as? OnboardingCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        cell.titleLabel.text = titles[indexPath.row]
        cell.bodyLabel.text = bodies[indexPath.row]
        cell.bannerImageView.image = images[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
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
