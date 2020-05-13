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
        let availableFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (availableFunds != nil) {
            self.availableFunds_lbl.text = "$\(String(format: "%.2f", availableFunds!))";
        } else {
            self.availableFunds_lbl.text = "$0.00";
        }
        
        // load in holdings array if it exists
        let defaults = UserDefaults.standard;
        if let savedHoldings = defaults.object(forKey: UserDefaultKeys.holdingsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedHoldings = try? decoder.decode([Holding].self, from: savedHoldings) {
                for holding in loadedHoldings {
                    if (holding.ticker.name == self.ticker!.name) {
                        self.ownedCoin_lbl.text = "\(String(format: "%.2f", holding.amountOfCoin))"
                        break;
                    }
                }
            }
        } else {
            self.ownedCoin_lbl.text = "0.00"
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
        
        self.ownedCoin_lbl.text = "0.00"
        self.ownedCoinStatic_lbl.text = "Owned \(ticker!.symbol.uppercased())"
        
        // TODO: - Add a View Controller where the user can view their order history and see their holdings
        
    }
    
    @objc private func amountTapped() -> Void {
        var temp = self.availableFunds_lbl.text!;
        temp.removeFirst();
        let tempDouble = Double(temp);
        let result = tempDouble! / ticker!.price;
        self.amount_txt.text = "\(result)";
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
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        if (amountDouble!.isLess(than: 0.0)) {
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        if (amountDouble!.isZero) {
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        if (amountDouble!.isZero) {
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
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
        let amountDouble = Double(self.amount_txt.text!);
        if (amountDouble == nil) {
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        let result:Double = amountDouble! * self.ticker!.price;
        self.cost_lbl.text = "$\(String(format: "%.2f", result))"
        self.overview_txtView.text = "You are about to sumbit an order for \(self.amount_txt.text!) coin(s) of \(self.ticker!.name) for $\(String(round(10000.0 * self.ticker!.price) / 10000.0)) each. This order will execute at the best available price."
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        let doubleAmount = Double(self.amount_txt.text!);
        if (self.amount_txt.text!.isEmpty) {
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        if (doubleAmount == nil) {
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        if (doubleAmount!.isZero) {
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        // check if user has enough funds
          // get available funds
          // check if the user has enough
        let amountDouble = Double(self.amount_txt.text!);
        if (amountDouble == nil || amountDouble!.isLess(than: 0.0)) {
            displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            return;
        }
        
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            var tempCost = self.cost_lbl.text!;
            tempCost.removeFirst();
            let tempCostDouble = Double(tempCost)
            if (currentFunds!.isLess(than: tempCostDouble!)) {
                displayAlert(title: "Sorry", message: "Insufficient funds");
                return;
            } else {
                let updatedFunds:Double = currentFunds! - tempCostDouble!;
                UserDefaults.standard.set(updatedFunds, forKey: UserDefaultKeys.availableFundsKey);
                // update main portfolio
                let mainPortfolio = UserDefaults.standard.value(forKey: UserDefaultKeys.mainPortfolioKey) as? Double;
                if (mainPortfolio != nil) {
                    let updatedMainPortfolio:Double = mainPortfolio! + tempCostDouble!;
                    UserDefaults.standard.set(updatedMainPortfolio, forKey: UserDefaultKeys.mainPortfolioKey);
                } else {
                    UserDefaults.standard.set(tempCostDouble, forKey: UserDefaultKeys.mainPortfolioKey);
                }
                
                // load in holdings array if it exists
                let defaults = UserDefaults.standard;
                if let savedHoldings = defaults.object(forKey: UserDefaultKeys.holdingsKey) as? Data {
                    let decoder = JSONDecoder()
                    if let loadedHoldings = try? decoder.decode([Holding].self, from: savedHoldings) {
                        self.holdings = loadedHoldings;
                    }
                }
                
                let hold = Holding(ticker: self.ticker!, amountOfCoin: amountDouble!, estCost: tempCostDouble!);
                if (!self.holdings.contains(where: { (holding) -> Bool in
                    return holding.ticker.name == hold.ticker.name;
                })) {
                    self.holdings.append(hold);
                } else {
                    for i in 0...self.holdings.count - 1 {
                        if (self.holdings[i].ticker.name == hold.ticker.name) {
                            let prevHolding = self.holdings[i];
                            prevHolding.amountOfCoin += hold.amountOfCoin;
                            prevHolding.estCost += hold.estCost;
                            prevHolding.ticker = hold.ticker;
                        }
                    }
                }
                
                // save holdings
                let encoder = JSONEncoder();
                if let encoded = try? encoder.encode(self.holdings) {
                    let defaults = UserDefaults.standard;
                    defaults.set(encoded, forKey: UserDefaultKeys.holdingsKey);
                }
                
                // TODO: - update order history items
                // TODO: - update holdings items
                
            }
        } else {
            displayAlert(title: "Sorry", message: "Insufficient funds");
            return;
        }
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func sellPressed(_ sender: Any) {
        print("sell button pressed");
        // update and save available funds
        // update and save main portfolio
        // add sell to order history
    }
    
    public func styleTextField(textField:inout UITextField!, placeHolder:String, secure:Bool)
    {
        textField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textField.textColor = UIColor.white
        textField.layer.cornerRadius = 8.0
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1.0
        textField.isSecureTextEntry = secure
    }
    
    public func styleButton(button:inout UIButton!)
    {
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton)
        present(alert, animated: true, completion: nil);
    }
    
}
