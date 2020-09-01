//
//  TradeVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-06.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class TradeVC: UIViewController {

    @IBOutlet weak var marketPrice_lbl: UILabel!
    @IBOutlet weak var availableFunds_lbl: UILabel!
    @IBOutlet weak var amount_txt: UITextField!
    @IBOutlet weak var ownedCoinStatic_lbl: UILabel!
    @IBOutlet weak var ownedCoin_lbl: UILabel!
    @IBOutlet weak var cost_lbl: UILabel!
    @IBOutlet weak var overview_txtView: UITextView!
    @IBOutlet weak var buy_btn: UIButton!
    @IBOutlet weak var sell_btn: UIButton!
    @IBOutlet weak var fiveBtn: UIButton!
    @IBOutlet weak var thousBtn: UIButton!
    @IBOutlet weak var fiveThousBtn: UIButton!
    @IBOutlet weak var allBtn: UIButton!
    
    // Public member variables
    public var ticker:Ticker?;
    public var portfolioVC:PortfolioVC?;
    
    // Private member variables
    private var holdings = Array<Holding>();
    private var availPressed:Bool = false;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // load in available funds
        var availableFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (availableFunds != nil) {
            if (availableFunds!.isLessThanOrEqualTo(0.0)) {
                self.availableFunds_lbl.text = "$0.00";
            } else {
                var tempString = String(availableFunds!);
                if (tempString.first == "-" ) {
                    tempString.removeFirst();
                    availableFunds = Double(tempString);
                }
                self.availableFunds_lbl.text = "$\(String(format: "%.2f", availableFunds!))";
                self.availableFunds_lbl.textColor = .systemOrange;
            }
        } else {
            self.availableFunds_lbl.text = "$0.00";
        }
        
        // load in holdings array if it exists
        if let loadedholdings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedholdings {
                if (holding.ticker.name == self.ticker!.name) {
                    if (holding.amountOfCoin.isLessThanOrEqualTo(0.0)) {
                        self.ownedCoin_lbl.text = "0.00";
                        break;
                    }
                    print("You have: \(holding.amountOfCoin)")
                    self.ownedCoin_lbl.text = "\(String(format: "%.3f", holding.amountOfCoin))";
                    self.ownedCoin_lbl.textColor = .systemOrange;
                    break;
                }
            }
        } else {
            self.ownedCoin_lbl.text = "0.00";
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpVC();
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard));
        self.view.addGestureRecognizer(tap);
        
        self.availableFunds_lbl.isUserInteractionEnabled = true;
        let amountTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped));
        self.availableFunds_lbl.addGestureRecognizer(amountTap);
        
        self.ownedCoin_lbl.isUserInteractionEnabled = true;
        let ownedTap = UITapGestureRecognizer(target: self, action: #selector(ownedTapped));
        self.ownedCoin_lbl.addGestureRecognizer(ownedTap);
        
        self.ownedCoin_lbl.text = "0.00"
        self.ownedCoinStatic_lbl.text = "Owned \(ticker!.symbol.uppercased())"
        
        // TODO: - Add a View Controller where the user can view their order history and see their holdings
        
    }
    
    @IBAction func fiveTapped(_ sender: Any) {
        self.vibrate(style: .medium);
        if (self.cost_lbl.text == "$ - ") {
            let newAmountOfCoin = 500.00 / self.ticker!.price;
            self.amount_txt.text = String(newAmountOfCoin);
            self.updateInfo();
        } else {
            var temp:String = self.cost_lbl.text!;
            temp.removeFirst();
            let combinedDouble = (Double(temp)! + 500.0) / ticker!.price;
            self.amount_txt.text = String(combinedDouble)
            self.updateInfo();
        }
    }
    @IBAction func thousTapped(_ sender: Any) {
        self.vibrate(style: .medium);
        if (self.cost_lbl.text == "$ - ") {
            let newAmountOfCoin = 1000.00 / self.ticker!.price;
            self.amount_txt.text = String(newAmountOfCoin);
            self.updateInfo();
        } else {
            var temp:String = self.cost_lbl.text!;
            temp.removeFirst();
            let combinedDouble = (Double(temp)! + 1000.00) / ticker!.price;
            self.amount_txt.text = String(combinedDouble)
            self.updateInfo();
        }
    }
    @IBAction func fiveThousTapped(_ sender: Any) {
        self.vibrate(style: .medium);
        if (self.cost_lbl.text == "$ - ") {
            let newAmountOfCoin = 5000.00 / self.ticker!.price;
            self.amount_txt.text = String(newAmountOfCoin);
            self.updateInfo();
        } else {
            var temp:String = self.cost_lbl.text!;
            temp.removeFirst();
            let combinedDouble = (Double(temp)! + 5000.00) / ticker!.price;
            self.amount_txt.text = String(combinedDouble)
            self.updateInfo();
        }
    }
    @IBAction func allTapped(_ sender: Any) {
        self.vibrate(style: .medium);
//        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
//        if (currentFunds != nil || currentFunds! != 0.0) {
//            let result = currentFunds! / self.ticker!.price;
//            if (result.isLessThanOrEqualTo(0.0)) { displayAlert(title: "Sorry", message: "Insuffient funds"); return; }
//            self.amount_txt.text = "\(result)"
//            self.updateInfo();
//        } else {
//            displayAlert(title: "Sorry", message: "Insuffient funds");
//        }
        if (self.cost_lbl.text == "$ - ") {
            let newAmountOfCoin = 10000.00 / self.ticker!.price;
            self.amount_txt.text = String(newAmountOfCoin);
            self.updateInfo();
        } else {
           var temp:String = self.cost_lbl.text!;
            temp.removeFirst();
            let combinedDouble = (Double(temp)! + 10000.00) / ticker!.price;
            self.amount_txt.text = String(combinedDouble)
            self.updateInfo();
        }
    }
    
    @objc private func amountTapped() -> Void {
        self.vibrate(style: .medium);
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            if (currentFunds!.isLessThanOrEqualTo(0.0)) { displayAlert(title: "Sorry", message: "Insuffient funds"); return;}
            let result = currentFunds! / self.ticker!.price;
            self.amount_txt.text = "\(result)"
            self.availPressed = true;
            self.updateInfo();
        }
    }
    
    @objc private func ownedTapped() -> Void {
        self.vibrate(style: .medium);
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedHoldings {
                if (holding.ticker.name == self.ticker!.name) {
                    if (holding.amountOfCoin.isLessThanOrEqualTo(0.0)) { displayAlert(title: "Sorry", message: "You do not own any \(holding.ticker.symbol.uppercased()) to sell"); return; }
                    self.amount_txt.text = "\(holding.amountOfCoin)";
                    updateInfo();
                    return;
                }
            }
            displayAlert(title: "Sorry", message: "You do not own any \(self.ticker!.symbol.uppercased()) to sell");
            return;
        }
    }
    
    @objc private func dismissKeyboard() -> Void {
        let amountDouble = Double(self.amount_txt.text!);
        if (self.amount_txt.text!.isEmpty) {
            self.view.endEditing(true);
            self.cost_lbl.text = "$ - ";
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            return;
        }
        if (amountDouble == nil) {
            self.view.endEditing(true);
            incorrectInputLayout()
            return;
        }
        if (amountDouble!.isLess(than: 0.0)) {
            incorrectInputLayout()
            return;
        }
        if (amountDouble!.isZero) {
            incorrectInputLayout()
            return;
        }
        if (amountDouble!.isZero) {
            incorrectInputLayout()
            return;
        }
        updateInfo();
        self.view.endEditing(true);
    }
    
    private func setUpVC() {
        self.marketPrice_lbl.text = "$\(String(format: "%.2f", self.ticker!.price))";
        self.amount_txt.placeholder = "Enter amount of \(self.ticker!.symbol.uppercased()) to buy/sell";
        self.cost_lbl.text = "$ - "
        self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
        self.styleButton(button: &self.fiveBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.thousBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.fiveThousBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.allBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.buy_btn, borderColor: UIColor.green.cgColor);
        self.styleButton(button: &self.sell_btn, borderColor: UIColor.red.cgColor);
        
        self.buy_btn.backgroundColor = .init(red: 0, green: 120/255, blue: 0, alpha: 1);
        self.sell_btn.backgroundColor = .init(red: 120/255, green: 0, blue: 0, alpha: 1);
        
//        let currentFunds = UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey);
//        if (currentFunds.isLessThanOrEqualTo(0.00009)) {
//            self.enableAddMoneyButtons(fiveBtn: false, thousBtn: false, fiveThousBtn: false, allBtn: false);
//        } else if (currentFunds < 500.0) {
//            self.enableAddMoneyButtons(fiveBtn: false, thousBtn: false, fiveThousBtn: false, allBtn: true);
//        } else if (currentFunds >= 500.0 && currentFunds < 1000.0) {
//            self.enableAddMoneyButtons(fiveBtn: true, thousBtn: false, fiveThousBtn: false, allBtn: true);
//        } else if (currentFunds >= 1000.0 && currentFunds < 5000.0) {
//            self.enableAddMoneyButtons(fiveBtn: true, thousBtn: true, fiveThousBtn: false, allBtn: true);
//        } else if (currentFunds >= 5000.0) {
//            self.enableAddMoneyButtons(fiveBtn: true, thousBtn: true, fiveThousBtn: true, allBtn: true);
//        }
//
    }
    
    private func enableAddMoneyButtons(fiveBtn:Bool, thousBtn:Bool, fiveThousBtn:Bool, allBtn:Bool) {
        if (!fiveBtn) {
            self.fiveBtn.setTitleColor(.systemGray, for: .normal)
        }
        if (!thousBtn) {
            self.thousBtn.setTitleColor(.systemGray, for: .normal)
        }
        if (!fiveThousBtn) {
            self.fiveThousBtn.setTitleColor(.systemGray, for: .normal)
        }
        if (!allBtn) {
            //UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            self.allBtn.setTitleColor(.systemGray, for: .normal);
        }
        self.fiveBtn.isUserInteractionEnabled = fiveBtn;
        self.thousBtn.isUserInteractionEnabled = thousBtn;
        self.fiveThousBtn.isUserInteractionEnabled = fiveThousBtn;
        self.allBtn.isUserInteractionEnabled = allBtn;
    }
    
    private func updateInfo() {
        if (self.amount_txt.text!.first == "-") {
            self.amount_txt.text!.removeFirst();
        }
        let amountDouble = Double(self.amount_txt.text!);
        if (amountDouble == nil) {
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        let result:Double = amountDouble! * self.ticker!.price;
        self.cost_lbl.text = "$\(String(format: "%.2f", result))"
        self.overview_txtView.text = "You are about to sumbit an order for \(self.amount_txt.text!) coin(s) of \(self.ticker!.name) for $\(String(round(10000.0 * self.ticker!.price) / 10000.0)) each. This order will execute at the best available price."
        
//        let currentFunds = UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey);
//        if (currentFunds.isLessThanOrEqualTo(0.0)) {
//            self.enableAddMoneyButtons(fiveBtn: false, thousBtn: false, fiveThousBtn: false, allBtn: false);
//        } else if (currentFunds >= 500.0 && currentFunds < 1000.0) {
//            self.enableAddMoneyButtons(fiveBtn: true, thousBtn: false, fiveThousBtn: false, allBtn: true);
//        } else if (currentFunds >= 1000.0 && currentFunds < 5000.0) {
//            self.enableAddMoneyButtons(fiveBtn: true, thousBtn: true, fiveThousBtn: false, allBtn: true);
//        } else if (currentFunds >= 5000.0) {
//            self.enableAddMoneyButtons(fiveBtn: true, thousBtn: true, fiveThousBtn: true, allBtn: true);
//        }
//
    }
    
    private func incorrectInputLayout() -> Void {
        self.cost_lbl.text = "$ - "
        self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
        displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        self.vibrate(style: .light);
        
        // get the amount of coin being bought
        let doubleAmount = Double(self.amount_txt.text!);
        if (doubleAmount == nil || self.amount_txt.text!.isEmpty || doubleAmount!.isZero || doubleAmount!.isLess(than: 0.0)) {
            incorrectInputLayout()
            return;
        }
        // buy the specified coin
        if (doubleAmount != nil && self.ticker != nil) {
            let resultingCost = doubleAmount! * self.ticker!.price;
            CryptoData.getCoinData(id: self.ticker!.id) { (ticker, error) in
                if let error = error {
                    print(error.localizedDescription);
                } else {
                    let affectedAmountOfCoin:Double = resultingCost / ticker!.price;
                    if (OrderHandler.buy(amountCost: resultingCost, amountOfCoin: affectedAmountOfCoin, ticker: ticker!)) {
                        self.dismiss(animated: true) {
                            if let portVC = self.portfolioVC {
                                portVC.loadData();
                                portVC.tableVIew.reloadData();
                                portVC.updateCells();
                            }
                        };
                    }
                }
            }
        }
        
    }
    
    @IBAction func sellPressed(_ sender: Any) {
        self.vibrate(style: .light);
        // get the amount of coin being bought
        let doubleAmount = Double(self.amount_txt.text!);
        if (doubleAmount == nil || self.amount_txt.text!.isEmpty || doubleAmount!.isZero || doubleAmount!.isLess(than: 0.0)) {
            incorrectInputLayout()
            return;
        }
        
        // sell the specified coin
        if (doubleAmount != nil && self.ticker != nil) {
            CryptoData.getCoinData(id: self.ticker!.id) { (ticker, error) in
                if let error = error {
                    print(error.localizedDescription);
                } else {
                    let amountCost = doubleAmount! * ticker!.price;
                    if (OrderHandler.sell(amountCost: amountCost, amountOfCoin: doubleAmount!, ticker: ticker!)) {
                        self.dismiss(animated: true) {
                            if let portVC = self.portfolioVC {
                                portVC.loadData();
                                portVC.tableVIew.reloadData();
                            }
                        };
                    }
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
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackGenerator.prepare();
        impactFeedbackGenerator.impactOccurred();
    }
    
    private func styleButton(button:inout UIButton, borderColor:CGColor) -> Void {
        button.layer.cornerRadius = 12.0
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.borderWidth = 1;
        button.layer.borderColor = borderColor;
    }
    
}
