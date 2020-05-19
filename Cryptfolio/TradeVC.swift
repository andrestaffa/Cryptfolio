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
    
    // Public member variables
    public var ticker:Ticker?;
    
    // Private member variables
    private var holdings = Array<Holding>();
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // load in available funds
        var availableFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (availableFunds != nil) {
            var tempString = String(availableFunds!);
            if (tempString.first == "-" ) {
                tempString.removeFirst();
                availableFunds = Double(tempString);
            }
            self.availableFunds_lbl.text = "$\(String(format: "%.2f", availableFunds!))";
        } else {
            self.availableFunds_lbl.text = "$0.00";
        }
        
        // load in holdings array if it exists
        if let loadedholdings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedholdings {
                if (holding.ticker.name == self.ticker!.name) {
                    self.ownedCoin_lbl.text = "\(String(format: "%.3f", holding.amountOfCoin))";
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
    
    @objc private func amountTapped() -> Void {
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            let result = currentFunds! / self.ticker!.price;
            self.amount_txt.text = "\(result)"
            self.updateInfo();
        }
    }
    
    @objc private func ownedTapped() -> Void {
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedHoldings {
                if (holding.ticker.name == self.ticker!.name) {
                    self.amount_txt.text = "\(holding.amountOfCoin)";
                    updateInfo();
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() -> Void {
        let amountDouble = Double(self.amount_txt.text!);
        if (self.amount_txt.text!.isEmpty) {
            self.view.endEditing(true);
            self.cost_lbl.text = "$ - "
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
        
        // get the amount of coin being bought
        
        let doubleAmount = Double(self.amount_txt.text!);
        if (doubleAmount == nil || self.amount_txt.text!.isEmpty || doubleAmount!.isZero || doubleAmount!.isLess(than: 0.0)) {
            incorrectInputLayout()
            return;
        }
        
//        var tempCost = self.cost_lbl.text!;
//        tempCost.removeFirst();
//        let tempCostDouble = Double(tempCost);
        
        // buy the specified coin
        if (doubleAmount != nil && self.ticker != nil) {
            CryptoData.getCoinData(id: self.ticker!.id) { (ticker, error) in
                if let error = error {
                    print(error.localizedDescription);
                } else {
                    let result = doubleAmount! * ticker!.price;
                    if (OrderHandler.buy(amountCost: result, amountOfCoin: doubleAmount!, ticker: ticker!)) {
                        self.dismiss(animated: true, completion: nil);
                    }
                }
            }
        }
        
    }
    
    @IBAction func sellPressed(_ sender: Any) {
        
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
                        self.dismiss(animated: true, completion: nil);
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
    
}
