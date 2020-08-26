//
//  HistoryVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-08-23.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clearBtn: UIButton!
    
    public var holdingCoin:Holding? = nil;
    public var holdingVC:HoldingVC?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        self.styleButton(button: &self.clearBtn, borderColor: UIColor.orange.cgColor);
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0);
        layout.minimumInteritemSpacing = 5;
        self.collectionView!.collectionViewLayout = layout;
        self.collectionView!.showsVerticalScrollIndicator = false;
        
    }
    
    @IBAction func tappedExitBtn(_ sender: Any) {
        self.dismiss(animated: true) {
            if let holdingVC = self.holdingVC {
                holdingVC.tableView.reloadData();
            }
        }
    }
    
    @IBAction func tappedClearBtn(_ sender: Any) {
        self.vibrate(style: .medium);
        self.holdingCoin!.amountOfCoins.removeAll();
        self.holdingCoin!.prices.removeAll();
        self.holdingCoin!.dateAddedList.removeAll();
        self.holdingCoin!.isBuyList.removeAll();
        guard let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) else { return; }
        for hold in loadedHoldings {
            if (hold.ticker.name.lowercased() == self.holdingCoin!.ticker.name.lowercased()) {
                hold.amountOfCoins.removeAll();
                hold.prices.removeAll();
                hold.dateAddedList.removeAll();
                hold.isBuyList.removeAll();
            }
        }
        DataStorageHandler.saveObject(type: loadedHoldings, forKey: UserDefaultKeys.holdingsKey);
        self.collectionView.reloadData();
        if let holdingVC = self.holdingVC {
            holdingVC.tableView.reloadData();
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.holdingCoin!.amountOfCoins.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HistoryCell;
        
        cell.amountOfCoinLbl.text = String(format: "%.2f", self.holdingCoin!.amountOfCoins[indexPath.item]);
        cell.pricesLbl.text = String(format: "%.2f", self.holdingCoin!.prices[indexPath.item]);
        cell.dateAddedLbl.text = self.holdingCoin!.dateAddedList[indexPath.row];
        
        if (self.holdingCoin!.isBuyList[indexPath.item]) {
            cell.layer.borderColor = UIColor.green.cgColor;
            cell.backgroundColor = .init(red: 0, green: 35/255, blue: 0, alpha: 1);
        } else {
            cell.layer.borderColor = UIColor.red.cgColor;
            cell.backgroundColor = .init(red: 35/255, green: 0, blue: 0, alpha: 1);
        }
        
        cell.layer.borderWidth = 0.5;
        cell.layer.cornerRadius = 7.0;
        
        return cell;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width - 10, height: 50.0);
    }
    
    private func styleButton(button:inout UIButton, borderColor:CGColor) -> Void {
        button.layer.cornerRadius = 12.0
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.borderWidth = 1;
        button.layer.borderColor = borderColor;
        //button.backgroundColor = .orange;
    }
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackGenerator.prepare();
        impactFeedbackGenerator.impactOccurred();
    }
    
}

class HistoryCell: UICollectionViewCell {
    @IBOutlet weak var amountOfCoinLbl: UILabel!
    @IBOutlet weak var pricesLbl: UILabel!
    @IBOutlet weak var dateAddedLbl: UILabel!
}
