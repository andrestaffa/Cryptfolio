//
//  HoldingVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-08-23.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class HoldingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLbl: UILabel!;
    
    public var messageText:String = "";
    public var titleText:String = "";
    
    private var loadedHoldings:Array<Holding> = Array<Holding>();
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor = nil;
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationController?.navigationBar.shadowImage = nil;
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default);
        
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            self.loadedHoldings = loadedHoldings;
            self.loadedHoldings = self.loadedHoldings.sorted(by: { (holding, nextHolding) -> Bool in
                return holding.ticker.marketCap > nextHolding.ticker.marketCap;
            })
        } else {
            self.tableView.isHidden = true;
            self.loadedHoldings = Array<Holding>();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.title = self.titleText;
        self.messageLbl.numberOfLines = 5;
        self.messageLbl.text = self.messageText;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.loadedHoldings.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HoldingCell;
        cell.coinImage.image = UIImage(named: "Images/\(self.loadedHoldings[indexPath.row].ticker.symbol.lowercased())");
        cell.coinName.text = self.loadedHoldings[indexPath.row].ticker.name;
        cell.numberOfTrades.text = String(self.loadedHoldings[indexPath.row].amountOfCoins.count);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyVC") as! HistoryVC;
        historyVC.holdingCoin = self.loadedHoldings[indexPath.row];
        historyVC.holdingVC = self;
        self.present(historyVC, animated: true, completion: nil);
    }

}

public class HoldingCell : UITableViewCell {
    @IBOutlet weak var coinImage: UIImageView!;
    @IBOutlet weak var coinName: UILabel!;
    @IBOutlet weak var numberOfTrades: UILabel!
}
