//
//  PortfolioVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-03.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import SwiftChart;

class PortfolioVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addCoin_btn: UIButton!
    @IBOutlet weak var welcome_lbl: UILabel!
    @IBOutlet weak var appName_lbl: UILabel!
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var multipleViews: UIView!
    @IBOutlet weak var availableFundsStatic_lbl: UILabel!
    @IBOutlet weak var availableFunds_lbl: UILabel!
    @IBOutlet weak var mainPortfolioStatic_lbl: UILabel!
    @IBOutlet weak var mainPortfolio_lbl: UILabel!
    @IBOutlet weak var mainPortTimeStamp_lbl: UILabel!
    @IBOutlet weak var mainPortPercentChange_lbl: UILabel!
    @IBOutlet weak var mainPort_img: UIImageView!
    
    
    private var coins = Array<Coin>();
    private var indexArray = [Int]();
    private var priceDifference:Double = 0.0;
    private var portPercentChange:Double = 0.0;
    private static var counter = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableVIew.reloadData();
        self.tabBarController?.tabBar.isHidden = false;
        
        
        // load in indexArray
        let tempArray = UserDefaults.standard.value(forKey: UserDefaultKeys.indexArrayKey) as? [Int];
        if (tempArray != nil) {
            self.indexArray = tempArray!;
        } else {
            self.indexArray = [Int]();
        }
        print("Index Array: " + "\(self.indexArray)");
        writeCoinArray();
        
        // load in available funds
        let availableFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (availableFunds != nil) {
            self.availableFunds_lbl.text = "$\(String(format: "%.2f", availableFunds!))"
        } else {
            self.availableFunds_lbl.text = "$0.00";
        }
        
        // load in main portfolio amount (update with the all the users holdings)
        let mainPortfolio = UserDefaults.standard.value(forKey: UserDefaultKeys.mainPortfolioKey) as? Double;
        if (mainPortfolio != nil) {
            self.mainPortPercentChange_lbl.isHidden = false;
            self.mainPortTimeStamp_lbl.isHidden = false;
            self.mainPort_img.isHidden = false;
            self.mainPortfolio_lbl.text = "$\(String(format: "%.2f", mainPortfolio!))"
            
            // load in holdings array
            let defaults = UserDefaults.standard;
            if let savedHolding = defaults.object(forKey: UserDefaultKeys.holdingsKey) as? Data {
                let decoder = JSONDecoder()
                if let loadedHolding = try? decoder.decode([Holding].self, from: savedHolding) {
                    // USE "loadedHoldings" to calculate portfolio on load up. Use percentChange * estCost.
                    // VERY CHALLENGING TO UPDATE MAIN PORTFOLIO
                    var portPercentChange:Double = 0.0;
                    for index in 0...loadedHolding.count - 1 {
                        CryptoData.getCryptoData(index: loadedHolding[index].ticker.rank - 1) { (ticker, error) in
                            if let error = error {
                                print(error.localizedDescription);
                            } else {
                                let priceDifference:Double = -(loadedHolding[index].ticker.price - ticker!.price);
                                portPercentChange += priceDifference / loadedHolding[index].ticker.price
                                let updatedChange = mainPortfolio! + (mainPortfolio! * portPercentChange);
                                self.priceDifference = updatedChange - mainPortfolio! // maybe updatedChange;
                                self.portPercentChange =  portPercentChange;
                                print("Price Difference: \(priceDifference)");
                                print("Portfolio Percent Change: \(portPercentChange)")
                                print("Bought at price: \(loadedHolding[index].ticker.price)");
                                print("Bought at percent change at: \(loadedHolding[index].ticker.changePrecent24H)")
                                self.mainPortfolio_lbl.text = "$\(String(format: "%.2f", updatedChange))"
                                if (String(portPercentChange).first == "-") {
                                    self.mainPort_img.image = UIImage(named: "Images/InfoImages/lightRed.png");
                                    self.mainPortPercentChange_lbl.textColor = ChartColors.darkRedColor();
                                    self.mainPortPercentChange_lbl.text = "\(String(format: "%.2f", portPercentChange * 100))%"
                                } else {
                                    self.mainPort_img.image = UIImage(named: "Images/InfoImages/lightGreen.png");
                                    if (self.traitCollection.userInterfaceStyle == .dark) {
                                        self.mainPortPercentChange_lbl.textColor = ChartColors.darkGreenColor();
                                        self.mainPortPercentChange_lbl.text = "+\(String(format: "%.2f", portPercentChange * 100))%"
                                    } else {
                                        self.mainPortPercentChange_lbl.textColor = ChartColors.greenColor();
                                        self.mainPortPercentChange_lbl.text = "+\(String(format: "%.2f", portPercentChange * 100))%"
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            self.mainPortfolio_lbl.text = "$0.00";
            self.mainPortPercentChange_lbl.isHidden = true;
            self.mainPortTimeStamp_lbl.isHidden = true;
            self.mainPort_img.isHidden = true;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.tabBarController?.tabBar.isHidden = false;
        self.tableVIew.delegate = self;
        self.tableVIew.dataSource = self;

        // style buttons
        let rightBarItems:[UIBarButtonItem] = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)), self.editButtonItem];
        let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(goToHoldingsVC));
        for rightBarItem in rightBarItems {
            rightBarItem.tintColor = UIColor.orange;
        }
        leftBarButtonItem.tintColor = UIColor.orange;
        self.navigationController?.navigationBar.tintColor = UIColor.orange;
        self.navigationItem.rightBarButtonItems = rightBarItems;
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        
        self.availableFunds_lbl.isUserInteractionEnabled = true;
        let availFundsTap = UITapGestureRecognizer(target: self, action: #selector(availFundsTapped));
        self.availableFunds_lbl.addGestureRecognizer(availFundsTap);
        
        self.mainPortfolio_lbl.isUserInteractionEnabled = true;
        let mainPortTap = UITapGestureRecognizer(target: self, action: #selector(mainPortTapped));
        self.mainPortfolio_lbl.addGestureRecognizer(mainPortTap);
        
        self.mainPortPercentChange_lbl.isUserInteractionEnabled = true;
        let mainPortPercentTap = UITapGestureRecognizer(target: self, action: #selector(mainPortPercentTapped));
        self.mainPortPercentChange_lbl.addGestureRecognizer(mainPortPercentTap);
        
    
        self.title = "Dashboard";
        
        // TODO: - Add selection when editing
        
    }
    
    @objc private func availFundsTapped() -> Void {
        let addFundsVC = storyboard?.instantiateViewController(withIdentifier: "addFundsVC") as! AddFundsVC;
        addFundsVC.title = "Add Funds";
        self.navigationController?.pushViewController(addFundsVC, animated: true);
    }
    
    @objc private func mainPortTapped() -> Void {
        print("go to mainPortFolioVC")
    }
    
    @objc private func goToHoldingsVC() -> Void {
        print("go to holdingsVC");
    }
    
    @objc private func mainPortPercentTapped() -> Void {
        // MOST LIKELY GOING TO DELETE
        PortfolioVC.counter += 1;
        if (PortfolioVC.counter % 2 != 0) {
            if (String(self.portPercentChange).first != "-") {
                self.mainPortPercentChange_lbl.text = "+\(String(format: "%.2f", self.priceDifference))";
            } else {
                self.mainPortPercentChange_lbl.text = "\(String(format: "%.2f", self.priceDifference))";
            }
        } else {
            if (String(self.portPercentChange).first != "-") {
                self.mainPortPercentChange_lbl.text = "+\(String(format: "%.2f", self.portPercentChange * 100))%";
            } else {
                self.mainPortPercentChange_lbl.text = "\(String(format: "%.2f", self.portPercentChange * 100))%";
            }
        }
    }
    
    @objc private func addTapped() {
        let homeTBVC = self.storyboard?.instantiateViewController(withIdentifier: "homeTBVC") as! HomeTBVC;
        homeTBVC.isAdding = true;
        self.navigationController?.pushViewController(homeTBVC, animated: true);
    }
    
    private func writeCoinArray() {
        let encoder = JSONEncoder();
        if let encoded = try? encoder.encode(self.coins) {
            let defaults = UserDefaults.standard;
            defaults.set(encoded, forKey: UserDefaultKeys.coinArrayKey);
        }
    }
    
    private func writeCoin() {
        let defaults = UserDefaults.standard;
        if let savedCoin = defaults.object(forKey: UserDefaultKeys.coinKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedCoin = try? decoder.decode(Coin.self, from: savedCoin) {
                if (!self.coins.contains(where: { (coin) -> Bool in
                    return coin.ticker.name == loadedCoin.ticker.name;
                })) {
                    self.coins.append(loadedCoin);
                }
            }
        }
    }
    
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton)
        present(alert, animated: true, completion: nil);
    }
    
    
    // MARK: - TableView methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableVIew.setEditing(editing, animated: true);
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCoin = self.coins.remove(at: sourceIndexPath.row);
        self.coins.insert(movedCoin, at: destinationIndexPath.row);
        let movedIndex = self.indexArray.remove(at: sourceIndexPath.row);
        self.indexArray.insert(movedIndex, at: destinationIndexPath.row);
        UserDefaults.standard.set(self.indexArray, forKey: UserDefaultKeys.indexArrayKey);
        writeCoinArray();
        tableView.reloadData();
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let defaults = UserDefaults.standard;
        if let savedCoin = defaults.object(forKey: UserDefaultKeys.coinArrayKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedCoin = try? decoder.decode([Coin].self, from: savedCoin) {
                self.coins = loadedCoin;
            }
        }
        if let savedCoin = defaults.object(forKey: UserDefaultKeys.coinKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedCoin = try? decoder.decode(Coin.self, from: savedCoin) {
                if (!self.coins.contains(where: { (coin) -> Bool in
                    return coin.ticker.name == loadedCoin.ticker.name;
                })) {
                    self.coins.append(loadedCoin);
                }
            }
        }
        if (self.coins.count > 0) {
            self.hideViews(hidden: true);
            self.hideFunds(hidden: false);
            tableView.separatorStyle = .none;
            return self.coins.count;
        } else {
            self.styleButton(button: &self.addCoin_btn);
            self.hideViews(hidden: false);
            self.hideFunds(hidden: true);
            tableView.backgroundView = self.multipleViews;
            tableView.separatorStyle = .none;
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.coins.remove(at: indexPath.row);
            self.indexArray.remove(at: indexPath.row);
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinKey);
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinArrayKey);
            UserDefaults.standard.set(self.indexArray, forKey: UserDefaultKeys.indexArrayKey);
            writeCoinArray();
            tableView.beginUpdates();
            tableView.deleteRows(at: [indexPath], with: .fade);
            tableView.endUpdates();
            print("Index Array: " + "\(self.indexArray)");
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PortfolioVCCustomCell;
        cell.crypto_img.image = self.coins[indexPath.row].image.getImage()!;
        cell.name_lbl.text = self.coins[indexPath.row].ticker.name;
        cell.price_lbl.text = "$0.00";
        cell.priceChange_lbl.text = "+$0.00"
        cell.percentChange_lbl.text = "+0.00%"
        CryptoData.getCryptoData(index: self.coins[indexPath.row].ticker.rank - 1) { (ticker, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                // format price
                let theoPriceString = String(format: "%.2f", ticker!.price);
                //self.appendZero(string: &theoPriceString);
                cell.price_lbl.text = "$\(theoPriceString)";
                
                // format percent change
                if (String(ticker!.changePrecent24H).first != "-") {
                    if (self.traitCollection.userInterfaceStyle == .dark) {
                        cell.percentChange_lbl.textColor = ChartColors.darkGreenColor();
                    } else {
                        cell.percentChange_lbl.textColor = ChartColors.greenColor();
                    }
                    let theoPercentString = String(format: "%.2f", ticker!.changePrecent24H);
                    //self.appendZero(string: &theoPercentString);
                    cell.percentChange_lbl.text = "(+\(theoPercentString)%)"
                } else {
                    cell.percentChange_lbl.textColor = ChartColors.darkRedColor();
                    let theoPercentString = String(format: "%.2f", ticker!.changePrecent24H);
                    //self.appendZero(string: &theoPercentString);
                    cell.percentChange_lbl.text = "(\(theoPercentString)%)"
                }
                
                // format price change
                let theoricalPriceChange = ((ticker!.price - ticker!.history24h[0]) / ticker!.price) * ticker!.price;
                var thString = String(format: "%.2f", theoricalPriceChange);
                //self.appendZero(string: &thString);
                if (thString.first == "-") {
                    cell.priceChange_lbl.textColor = ChartColors.darkRedColor();
                    let minus = thString.first!;
                    thString.removeFirst();
                    cell.priceChange_lbl.text = "\(minus)\(thString)"
                } else {
                    if (self.traitCollection.userInterfaceStyle == .dark) {
                        cell.priceChange_lbl.textColor = ChartColors.darkGreenColor();
                    } else {
                        cell.priceChange_lbl.textColor = ChartColors.greenColor();
                    }
                    cell.priceChange_lbl.text = "+\(thString)"
                }
            }
        }
        //cell.layer.cornerRadius = 10.0;
        //cell.backgroundColor = UIColor.init(red: 2/255, green: 7/255, blue: 93/255, alpha: 0.5)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        infoVC.coin = self.coins[indexPath.row];
        infoVC.isTradingMode = true;
        self.navigationController?.pushViewController(infoVC, animated: true);
        
    }
    
    // MARK: - Helper method for appending zeros to numbers
    
    private func appendZero(string:inout String) {
        if (string.last == "0" || string.last == "1" || string.last == "2" || string.last == "3" || string.last == "4" || string == "5" ||
            string.last == "6" || string.last == "7" || string.last == "8" || string.last == "9") {
            string += "0";
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func pressAddCoinBtn(_ sender: Any) {
        let homeTBVC = self.storyboard?.instantiateViewController(withIdentifier: "homeTBVC") as! HomeTBVC;
        homeTBVC.isAdding = true;
        self.navigationController?.pushViewController(homeTBVC, animated: true);
    }
    
    
    private func styleButton(button:inout UIButton) -> Void {
        button.layer.cornerRadius = 15.0
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.backgroundColor = UIColor.orange;
    }
    
    // MARK: - Hide all views
    
    private func hideViews(hidden:Bool) -> Void {
        self.addCoin_btn.isHidden = hidden;
        self.welcome_lbl.isHidden = hidden;
        self.appName_lbl.isHidden = hidden;
        self.multipleViews.isHidden = hidden;
    }
    
    private func hideFunds(hidden:Bool) -> Void {
        self.availableFundsStatic_lbl.isHidden = hidden;
        self.availableFunds_lbl.isHidden = hidden;
        self.mainPortfolioStatic_lbl.isHidden = hidden;
        self.mainPortfolio_lbl.isHidden = hidden;
    }

}
