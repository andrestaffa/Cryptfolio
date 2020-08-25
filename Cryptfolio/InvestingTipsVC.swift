//
//  InvestingTipsVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-08-18.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class InvestingTipsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var investingTips = Array<Tip>();
    private var isGoingBack:Bool = false;
    
    override func viewWillAppear(_ animated: Bool) {
        if let loadedTips = TipManager.loadTipList() {
            self.investingTips = loadedTips;
        } else {
            self.investingTips = TipManager.createTipList();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.title = "Investing Tips";
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        // FIX THESE USING ASPECT RATIOS
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 15);
        layout.minimumInteritemSpacing = 5;
        layout.itemSize = CGSize(width: (self.collectionView.bounds.width - 30) / 2, height: self.collectionView.bounds.height / 3);
        self.collectionView!.collectionViewLayout = layout;
        //print(self.collectionView.contentOffset.y);
       self.autoScroll();
    }
     
    
    
    func autoScroll () {
        if (self.isGoingBack) {
            return;
        }
        var co = collectionView.contentOffset.y;
        var no = co + 3
        if (no >= 1700) {
//            self.isGoingBack = true;
//            autoScrollInner(endPoint: 10.0, speed: 0.001)
            collectionView.contentOffset.y = 0.0;
            co = collectionView.contentOffset.y;
            no = co + 5;
        }

        UIView.animate(withDuration: 0.001, delay: 0, options: .curveEaseInOut, animations: { [weak self]() -> Void in
            self?.collectionView.contentOffset = CGPoint(x: 0, y: no)
            }) { [weak self](finished) -> Void in
                self?.autoScroll();
        }
        
    }
    
    func autoScrollInner (endPoint: CGFloat, speed: TimeInterval) {
        let co = self.collectionView.contentOffset.y;
        let no = co - 5
        
        if (no <= endPoint) {
            self.isGoingBack = false;
            return;
        }
        
        UIView.animate(withDuration: speed, delay: 0, options: .curveEaseInOut, animations: { [weak self]() -> Void in
            self?.collectionView.contentOffset = CGPoint(x: 0, y: no)
            }) { [weak self](finished) -> Void in
                self?.autoScrollInner(endPoint: endPoint, speed: speed);
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.investingTips.count;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InvestingTipCell;
        cell.tipTitle.text = self.investingTips[indexPath.item].title;
        
        cell.layer.borderColor = UIColor.orange.cgColor;
        cell.layer.borderWidth = 0.5;
        
        cell.layer.cornerRadius = 7.0;
        cell.layer.masksToBounds = true;
        cell.tipTitle.font = cell.tipTitle.font.withSize(20.0);
        
        if (cell.tipTitle.text == "?") {
            cell.orangeDotImg.isHidden = true;
        } else {
            if (!self.investingTips[indexPath.item].isDiscovered) {
                cell.orangeDotImg.isHidden = false;
            } else {
                cell.orangeDotImg.isHidden = true;
            }
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true);
        if (self.investingTips[indexPath.item].title == "?") {
            alert(title: "Locked!", message: "Watch a reward Ad video to unlock investing tips");
        } else {
            self.investingTips[indexPath.item].isDiscovered = true;
            TipManager.saveTipList();
            self.collectionView.reloadData();
            let tipVC = self.storyboard?.instantiateViewController(withIdentifier: "tipVC") as! TipVC;
            tipVC.tip = self.investingTips[indexPath.item];
            self.present(tipVC, animated: true, completion: nil);
        }
    }
    

    private func alert(title:String, message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton);
        present(alert, animated: true, completion: nil);
    }
    
    
}
