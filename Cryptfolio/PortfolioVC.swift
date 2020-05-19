//
//  PortfolioVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-03.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import SwiftChart;
import SVProgressHUD;

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
    private var isLoading:Bool = true;
    private var priceDifference:Double = 0.0;
    private var portPercentChange:Double = 0.0;
    private static var counter = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false;
        
        self.updateCells();
        self.loadData();
        self.tableVIew.reloadData();
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.tabBarController?.tabBar.isHidden = false;
        self.tableVIew.delegate = self;
        self.tableVIew.dataSource = self;

        // style buttons
        let rightBarItems:[UIBarButtonItem] = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)), self.editButtonItem];
        for rightBarItem in rightBarItems {
            rightBarItem.tintColor = UIColor.orange;
        }
        self.navigationController?.navigationBar.tintColor = UIColor.orange;
        self.navigationItem.rightBarButtonItems = rightBarItems;
        
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
    
    private func updateCells() -> Void {
        if (!self.isLoading) {
            self.isLoading = true;
        }
        // get current coins in watchList;
        if let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey) {
            self.coins = loadedCoins;
        }
        if let loadedCoin = DataStorageHandler.loadObject(type: Coin.self, forKey: UserDefaultKeys.coinKey) {
            if (!self.coins.contains(where: { (coin) -> Bool in
                return coin.ticker.name == loadedCoin.ticker.name;
            })) {
                self.coins.append(loadedCoin);
            }
        }
        writeCoinArray();
        self.tableVIew.reloadData();
        // update the current coinList;
        for coin in self.coins {
            CryptoData.getCoinData(id: coin.ticker.id) { (ticker, error) in
                if let error = error {
                    print("no internet")
                    return;
                } else {
                    print("bad 1")
                    coin.image = Image(withImage: UIImage(named: "Images/" + "\(ticker!.symbol.lowercased())" + ".png")!);
                    coin.ticker = ticker!;
                    self.isLoading = false;
                    self.tableVIew.reloadData();
                    self.writeCoinArray();
                }
            }
        }
    }
    
    private func loadData() -> Void {
        //writeCoinArray();
        
        // load in available funds
        let availableFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (availableFunds != nil) {
            var tempAvailString = String(format: "%.2f", availableFunds!);
            if (tempAvailString.first == "-") {
                tempAvailString.removeFirst();
                self.availableFunds_lbl.text = "$\(tempAvailString)"
            } else {
                self.availableFunds_lbl.text = "$\(String(format: "%.2f", availableFunds!))"
            }
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
            if let loadedHolding = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                var portPercentChange:Double = 0.0;
                var updatedMainPortfolio:Double = 0.0;
                for index in 0...loadedHolding.count - 1 {
                    CryptoData.getCoinData(id: loadedHolding[index].ticker.id) { (ticker, error) in
                        if let error = error {
                            print("no internet");
                        } else {
                            print("bad 2");
                            // update estCost
                            loadedHolding[index].estCost = loadedHolding[index].amountOfCoin * ticker!.price;
                            updatedMainPortfolio += loadedHolding[index].estCost;
                            
                            let priceDifference:Double = -(loadedHolding[index].ticker.price - ticker!.price);
                            portPercentChange += (priceDifference / loadedHolding[index].ticker.price) / Double(loadedHolding.count);
                            let updatedChange = mainPortfolio! + (mainPortfolio! * portPercentChange);
                            self.priceDifference = updatedChange - mainPortfolio! // maybe updatedChange;
                            
                            print("Price Difference: \(priceDifference)");
                            print("Portfolio Percent Change: \(portPercentChange)")
                            print("Bought at price: \(loadedHolding[index].ticker.price)");
                            print("Bought at percent change at: \(loadedHolding[index].ticker.changePrecent24H)")
                            var tempUpChange = String(format: "%.2f", updatedMainPortfolio);
                            if (tempUpChange.first == "-") {
                                tempUpChange.removeFirst();
                                self.mainPortfolio_lbl.text = "$\(tempUpChange)";
                            } else {
                                self.mainPortfolio_lbl.text = "$\(String(format: "%.2f", updatedMainPortfolio))"
                            }
                            if (updatedMainPortfolio.isZero || self.mainPortfolio_lbl.text! == "$0.00") {
                                self.mainPortPercentChange_lbl.isHidden = true;
                                self.mainPortTimeStamp_lbl.isHidden = true;
                                self.mainPort_img.isHidden = true;
                            } else {
                                self.mainPortPercentChange_lbl.isHidden = false;
                                self.mainPortTimeStamp_lbl.isHidden = false;
                                self.mainPort_img.isHidden = false;
                            }
                            if (String(portPercentChange).first == "-" && !portPercentChange.isZero) {
                                self.mainPort_img.image = UIImage(named: "Images/InfoImages/lightRed.png");
                                self.mainPortPercentChange_lbl.textColor = ChartColors.darkRedColor();
                                self.mainPortPercentChange_lbl.text = "\(String(format: "%.2f", portPercentChange * 100))%"
                                self.portPercentChange = portPercentChange;
                            } else {
                                self.mainPort_img.image = UIImage(named: "Images/InfoImages/lightGreen.png");
                                var mainPortPercentString = String(portPercentChange);
                                if (mainPortPercentString.first == "-") { mainPortPercentString.removeFirst(); portPercentChange = Double(mainPortPercentString)! }
                                self.portPercentChange = portPercentChange;
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
            
        } else {
            self.mainPortfolio_lbl.text = "$0.00";
            self.mainPortPercentChange_lbl.isHidden = true;
            self.mainPortTimeStamp_lbl.isHidden = true;
            self.mainPort_img.isHidden = true;
        }
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
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light);
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
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
        DataStorageHandler.saveObject(type: self.coins, forKey: UserDefaultKeys.coinArrayKey);
    }
    
    private func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton);
        present(alert, animated: true, completion: nil);
    }
    
    // MARK: - Buy/Sell methods
    
    private func quickBuy(indexPathRow:Int) -> Void {
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            CryptoData.getCoinData(id: self.coins[indexPathRow].ticker.id) { (ticker, error) in
                if let error = error {
                    print(error.localizedDescription);
                } else {
                    let amountCoin = currentFunds! / ticker!.price;
                    let amountCost = amountCoin * ticker!.price;
                    if (OrderHandler.buy(amountCost: amountCost, amountOfCoin: amountCoin, ticker: ticker!)) {
                        self.loadData();
                        self.tableVIew.reloadData();
                    } else {
                        //self.displayAlert(title: "Error", message: "Buy order unsuccessful, try again")
                    }
                }
            }
        } else {
            displayAlert(title: "Sorry", message: "Insufficient funds")
        }
    }
    
    private func quickSell(indexPathRow:Int) -> Void {
        var currentHoldings:Holding?
        let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey);
        for holding in loadedHoldings! {
            if (holding.ticker.name == self.coins[indexPathRow].ticker.name) {
                currentHoldings = holding;
                break;
            }
        }
        CryptoData.getCoinData(id: currentHoldings!.ticker.id) { (ticker, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                let amountCost = currentHoldings!.amountOfCoin * ticker!.price;
                if (OrderHandler.sell(amountCost: amountCost, amountOfCoin: currentHoldings!.amountOfCoin, ticker: ticker!)) {
                    self.loadData();
                    self.tableVIew.reloadData();
                } else {
                    self.displayAlert(title: "Error", message: "Sell order unsucessful, try again");
                }
            }
        }
    }
    
    // MARK: - TableView methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableVIew.setEditing(editing, animated: true);
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCoin = self.coins.remove(at: sourceIndexPath.row);
        self.coins.insert(movedCoin, at: destinationIndexPath.row);
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
        if (self.coins.count == 0) {
            if(self.isLoading) {
                self.isLoading = false;
            }
            self.hideViews(hidden: false);
            self.hideFunds(hidden: true);
            styleButton(button: &self.addCoin_btn);
            self.mainPortPercentChange_lbl.isHidden = true;
            self.mainPortTimeStamp_lbl.isHidden = true;
            self.mainPort_img.isHidden = true;
            tableView.separatorStyle = .none;
            return 0;
        }
        if (self.isLoading) {
            if (self.coins.count == 0) {
                self.isLoading = false;
            }
            for rightBarItems in self.navigationItem.rightBarButtonItems! {
                rightBarItems.isEnabled = false;
            }
            self.hideViews(hidden: true);
            self.hideFunds(hidden: true);
            self.mainPortPercentChange_lbl.isHidden = true;
            self.mainPortTimeStamp_lbl.isHidden = true;
            self.mainPort_img.isHidden = true;
            tableView.separatorStyle = .none;
            return 1;
        } else if (self.coins.count > 0) {
            for rightBarItems in self.navigationItem.rightBarButtonItems! {
                rightBarItems.isEnabled = true;
            }
            self.hideViews(hidden: true);
            self.hideFunds(hidden: false);
            tableView.separatorStyle = .none;
            return self.coins.count;
        } else {
            for rightBarItems in self.navigationItem.rightBarButtonItems! {
                rightBarItems.isEnabled = true;
            }
            self.hideViews(hidden: true);
            self.hideFunds(hidden: false);
            tableView.separatorStyle = .none;
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // load holdings and check if the coin swiped on has any holdings, if so, then display quick sell, otherwise just display delete
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            self.coins.remove(at: indexPath.row);
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinKey);
            //UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinArrayKey);
            self.writeCoinArray();
            tableView.beginUpdates();
            tableView.deleteRows(at: [indexPath], with: .fade);
            tableView.endUpdates();
            if (self.coins.count == 0) {
                self.styleButton(button: &self.addCoin_btn);
                self.hideViews(hidden: false);
                self.hideFunds(hidden: true);
                tableView.backgroundView = self.multipleViews;
                tableView.separatorStyle = .none;
            }
            self.writeCoinArray();
            tableView.reloadData();
        }
        let quickBuyAction = UITableViewRowAction(style: .normal, title: "Quick Buy") { (rowAction, indexPath) in
            self.quickBuy(indexPathRow: indexPath.row);
        }
        quickBuyAction.backgroundColor = ChartColors.greenColor();
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedHoldings {
                if (holding.ticker.name == self.coins[indexPath.row].ticker.name) {
                    if (!holding.amountOfCoin.isLessThanOrEqualTo(0.0)) {
                        let quickSellAction = UITableViewRowAction(style: .destructive, title: "Quick Sell") { (rowAction, indexPath) in
                            self.quickSell(indexPathRow: indexPath.row);
                        }
                        return [quickSellAction, quickBuyAction];
                    } else {
                        return [deleteAction, quickBuyAction];
                    }
                }
            }
        } else {
            return [deleteAction, quickBuyAction];
        }
        return [deleteAction, quickBuyAction];
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PortfolioVCCustomCell;
        if (self.isLoading) {
            SVProgressHUD.show(withStatus: "Loading...");
            cell.crypto_img.isHidden = true;
            cell.name_lbl.text = "";
            cell.price_lbl.text = "";
            cell.percentChange_lbl.text = ""
            cell.amountCost_lbl.text = "";
            cell.amountCoin_lbl.text = "";
        } else {
            cell.crypto_img.isHidden = false;
            SVProgressHUD.dismiss();
            // basic stuff
            cell.name_lbl.text = self.coins[indexPath.row].ticker.name;
            cell.crypto_img.image = self.coins[indexPath.row].image.getImage()!;
            
            // format price
            let theoPriceString = String(format: "%.2f", self.coins[indexPath.row].ticker.price);
            //self.appendZero(string: &theoPriceString);
            cell.price_lbl.text = "$\(theoPriceString)";
            
            // format percent change
            if (String(self.coins[indexPath.row].ticker.changePrecent24H).first != "-") {
                if (self.traitCollection.userInterfaceStyle == .dark) {
                    cell.percentChange_lbl.textColor = ChartColors.darkGreenColor();
                } else {
                    cell.percentChange_lbl.textColor = ChartColors.greenColor();
                }
                let theoPercentString = String(format: "%.2f", self.coins[indexPath.row].ticker.changePrecent24H);
                //self.appendZero(string: &theoPercentString);
                cell.percentChange_lbl.text = "+\(theoPercentString)%"
            } else {
                cell.percentChange_lbl.textColor = ChartColors.darkRedColor();
                let theoPercentString = String(format: "%.2f", self.coins[indexPath.row].ticker.changePrecent24H);
                //self.appendZero(string: &theoPercentString);
                cell.percentChange_lbl.text = "\(theoPercentString)%"
            }
            
            // format holdings
            if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                for holding in loadedHoldings {
                    if (holding.ticker.name == self.coins[indexPath.row].ticker.name) {
                        holding.estCost = holding.amountOfCoin * self.coins[indexPath.row].ticker.price;
                        cell.amountCost_lbl.text = "$\(String(format: "%.2f", holding.estCost))";
                        cell.amountCoin_lbl.text = "\(String(format: "%.2f", holding.amountOfCoin))";
                    }
                }
            } else {
                cell.amountCost_lbl.text = "$0.00";
                cell.amountCoin_lbl.text = "0.00";
            }
            //cell.layer.cornerRadius = 10.0;
            //cell.backgroundColor = UIColor.init(red: 2/255, green: 7/255, blue: 93/255, alpha: 0.5)
        }
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
