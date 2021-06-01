//
//  TradeVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-06.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class TradeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var orderSummary_lbl: UILabel!
    @IBOutlet weak var marketPrice_lbl: UILabel!
    @IBOutlet weak var availableFunds_lbl: UILabel!
    @IBOutlet weak var amount_txt: UITextField!
    @IBOutlet weak var estCost: UILabel!
    @IBOutlet weak var ownedCoinStatic_lbl: UILabel!
    @IBOutlet weak var ownedCoin_lbl: UILabel!
    @IBOutlet weak var ownedAmountCoin_txt: UILabel!
    @IBOutlet weak var cost_lbl: UILabel!
    @IBOutlet weak var overview_txtView: UITextView!
    @IBOutlet weak var buy_btn: UIButton!
    @IBOutlet weak var sell_btn: UIButton!
    @IBOutlet weak var fiveBtn: UIButton!
    @IBOutlet weak var thousBtn: UIButton!
    @IBOutlet weak var fiveThousBtn: UIButton!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var switchState_btn: UIButton!
    
    
    // Public member variables
    public var ticker:Ticker?;
    public var portfolioVC:PortfolioVC?;
    
    // Private member variables
    private var holdings = Array<Holding>();
    private var availPressed:Bool = false;
    private var ownedCoinPressed:Bool = false;
    private var isUSDAmount:Bool = true;
    private var calculatedAmountOfCoin:Double = 0.0;
    
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
                        let yPos:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 7: 6.7
                        self.ownedCoin_lbl.transform = CGAffineTransform(translationX: 0, y: yPos);
                        self.ownedAmountCoin_txt.text = "";
                        break;
                    }
                    self.ownedCoin_lbl.text = "$\(String(format: "%.2f", holding.estCost))";
                    self.ownedAmountCoin_txt.text = self.formatPrice(price: holding.amountOfCoin);
                    self.ownedCoin_lbl.transform = .identity;
                    self.ownedCoin_lbl.textColor = .systemOrange;
                    self.ownedAmountCoin_txt.textColor = UIColor(red: 1, green: 215/255, blue: 0, alpha: 1);
                    break;
                } else {
                    self.ownedCoin_lbl.text = "0.00";
                    let yPos:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 7 : 6.7
                    self.ownedCoin_lbl.transform = CGAffineTransform(translationX: 0, y: yPos);
                    self.ownedAmountCoin_txt.text = "";
                }
            }
        } else {
            self.ownedCoin_lbl.text = "0.00";
            let yPos:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 7 : 6.7
            self.ownedCoin_lbl.transform = CGAffineTransform(translationX: 0, y: yPos);
            self.ownedAmountCoin_txt.text = "";
        }
        
        CryptoData.styleTextField(textField: self.amount_txt, width: self.amount_txt.frame.width * 0.9, color: .lightGray);
        self.amount_txt.delegate = self;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpVC();
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard));
        self.view.addGestureRecognizer(tap);
        
        //self.amount_txt.backgroundColor = .black;
        self.amount_txt.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)), onCancel: (target: self, action: #selector(self.cancelButtonTappedForMyNumericTextField)), doneName: "Done");
        self.amount_txt.addTarget(self, action: #selector(self.amountTextDidChange), for: .editingChanged);
        
        self.orderSummary_lbl.text = "Order Summary (\(self.ticker!.symbol.uppercased()))";
        self.orderSummary_lbl.font = UIFont(name: "Kohinoor Bangla", size: 17);
        self.orderSummary_lbl.textColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1);
        self.orderSummary_lbl.adjustsFontSizeToFitWidth = true;
        
        self.availableFunds_lbl.isUserInteractionEnabled = true;
        let amountTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped));
        self.availableFunds_lbl.addGestureRecognizer(amountTap);
        
        self.ownedCoin_lbl.isUserInteractionEnabled = true;
        let ownedTap = UITapGestureRecognizer(target: self, action: #selector(ownedTapped));
        self.ownedCoin_lbl.addGestureRecognizer(ownedTap);
        
        // switch button settings
        self.switchState_btn.addTarget(self, action: #selector(self.switchButtonTapped), for: .touchUpInside);
        
        self.ownedCoinStatic_lbl.text = "Owned \(ticker!.symbol.uppercased())"
        
        self.ownedCoin_lbl.adjustsFontSizeToFitWidth = true;
        self.ownedAmountCoin_txt.adjustsFontSizeToFitWidth = true;
        self.availableFunds_lbl.adjustsFontSizeToFitWidth = true;
        self.marketPrice_lbl.adjustsFontSizeToFitWidth = true;
        self.cost_lbl.adjustsFontSizeToFitWidth = true;
        
        self.addLeftImage(textfield: self.amount_txt, image: UIImage(named: "dollar24")!);
        CryptoData.styleTextField(textField: self.amount_txt, width: self.view.frame.width * 0.9, color: .lightGray);
        self.amount_txt.font = UIFont.systemFont(ofSize: 16.0);
        
    }
    
    @objc func amountTextDidChange() {
        updateInfo(isTypeing: true);
    }
    
    @objc func switchButtonTapped() {
        self.vibrate(style: .light);
        let alertMessage = self.isUSDAmount ? "Switch to entering the amount of coin" : "Switch to entering the amount of USD";
        let alertController = UIAlertController(title: "Switch Purchase Type", message: alertMessage, preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        alertController.addAction(UIAlertAction(title: "Switch", style: UIAlertAction.Style.default, handler: { [weak self] (action) in
            self?.isUSDAmount = !self!.isUSDAmount;
            self?.addLeftImage(textfield: self!.amount_txt, image: (self!.isUSDAmount ? UIImage(named: "dollar24")! : UIImage(named: "Images/\(self!.ticker!.symbol.lowercased()).png"))!)
            self?.setUpVC();
            self?.amount_txt.text = "";
        }))
        self.present(alertController, animated: true, completion: nil);
    }
    
    @IBAction func fiveTapped(_ sender: Any) {
        self.vibrate(style: .medium);
        if (self.cost_lbl.text == "$ - " || self.cost_lbl.text == " - ") {
            let newAmountOfCoin = self.isUSDAmount ? 500.00 : 500.00 / self.ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", newAmountOfCoin) : String(newAmountOfCoin);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        } else {
            var temp:String = self.isUSDAmount ? self.amount_txt.text!.replacingOccurrences(of: ",", with: "") : self.cost_lbl.text!;
            if (!self.isUSDAmount) { temp.removeFirst(); }
            let combinedDouble = self.isUSDAmount ? (Double(temp)! + 500.0) : (Double(temp)! + 500.0) / ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", combinedDouble) : String(combinedDouble);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        }
    }
    @IBAction func thousTapped(_ sender: Any) {
        self.vibrate(style: .medium);
        if (self.cost_lbl.text == "$ - " || self.cost_lbl.text == " - ") {
            let newAmountOfCoin = self.isUSDAmount ? 1000.0 : 1000.00 / self.ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", newAmountOfCoin) : String(newAmountOfCoin);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        } else {
            var temp:String = self.isUSDAmount ? self.amount_txt.text!.replacingOccurrences(of: ",", with: "") : self.cost_lbl.text!;
            if (!self.isUSDAmount) { temp.removeFirst(); }
            let combinedDouble = self.isUSDAmount ? (Double(temp)! + 1000.0) : (Double(temp)! + 1000.00) / ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", combinedDouble) : String(combinedDouble);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        }
    }
    @IBAction func fiveThousTapped(_ sender: Any) {
        self.vibrate(style: .medium);
        if (self.cost_lbl.text == "$ - " || self.cost_lbl.text == " - ") {
            let newAmountOfCoin = self.isUSDAmount ? 5000.0 : 5000.00 / self.ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", newAmountOfCoin) : String(newAmountOfCoin);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        } else {
            var temp:String = self.isUSDAmount ? self.amount_txt.text!.replacingOccurrences(of: ",", with: "") : self.cost_lbl.text!;
            if (!self.isUSDAmount) { temp.removeFirst(); }
            let combinedDouble = self.isUSDAmount ? (Double(temp)! + 5000.0) : (Double(temp)! + 5000.00) / ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", combinedDouble) : String(combinedDouble);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        }
    }
    @IBAction func allTapped(_ sender: Any) {
        self.vibrate(style: .medium);
        if (self.cost_lbl.text == "$ - " || self.cost_lbl.text == " - ") {
            let newAmountOfCoin = self.isUSDAmount ? 10000.0 : 10000.00 / self.ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", newAmountOfCoin) : String(newAmountOfCoin);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        } else {
            var temp:String = self.isUSDAmount ? self.amount_txt.text!.replacingOccurrences(of: ",", with: "") : self.cost_lbl.text!;
            if (!self.isUSDAmount) { temp.removeFirst(); }
            let combinedDouble = self.isUSDAmount ? (Double(temp)! + 10000.0) : (Double(temp)! + 10000.00) / ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? String(format: "%.2f", combinedDouble) : String(combinedDouble);
            self.setAmountFormattedText(textField: self.amount_txt);
            updateInfo(isTypeing: false);
        }
    }
    
    @objc private func amountTapped() -> Void {
        self.vibrate(style: .medium);
        self.ownedCoinPressed = false;
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            if (currentFunds!.isLessThanOrEqualTo(0.0)) { displayAlert(title: "Sorry", message: "Insuffient funds"); return;}
            let result = self.isUSDAmount ? currentFunds! : currentFunds! / self.ticker!.price;
            self.amount_txt.text = self.isUSDAmount ? "\(String(format: "%.2f", result))" : "\(result)";
            self.setAmountFormattedText(textField: self.amount_txt);
            self.availPressed = true;
            updateInfo(isTypeing: false);
        }
    }
    
    @objc private func ownedTapped() -> Void {
        self.vibrate(style: .medium);
        self.availPressed = false;
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedHoldings {
                if (holding.ticker.name == self.ticker!.name) {
                    if (holding.amountOfCoin.isLessThanOrEqualTo(0.0)) { displayAlert(title: "Sorry", message: "You do not own any \(holding.ticker.symbol.uppercased()) to sell"); return; }
                    self.amount_txt.text = self.isUSDAmount ? "\(String(format: "%.2f", holding.amountOfCoin * self.ticker!.price))" : "\(holding.amountOfCoin)";
                    self.setAmountFormattedText(textField: self.amount_txt);
                    self.ownedCoinPressed = true;
                    updateInfo(isTypeing: false);
                    return;
                }
            }
            displayAlert(title: "Sorry", message: "You do not own any \(self.ticker!.symbol.uppercased()) to sell");
            return;
        }
    }
    
    @objc private func dismissKeyboard() -> Void {
        self.dismissKeyboardReset();
    }
    
    private func setUpVC() {
        self.marketPrice_lbl.text = "$\(String(format: "%.2f", self.ticker!.price))";
        self.amount_txt.placeholder = self.isUSDAmount ? "USD" : "\(self.ticker!.symbol.uppercased())";
        self.estCost.text = self.isUSDAmount ? "AMT OF COIN" : "EST COST";
        self.cost_lbl.text = self.isUSDAmount ? " - " : "$ - "
        let combinedString = NSMutableAttributedString();
        combinedString.append(NSMutableAttributedString(string: "Welcome to Cryptfolio's practice trade console. Here you can practice buying and selling cryptocurrency with the funds you have in your account.", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
        combinedString.append(NSMutableAttributedString(string: "\n\nTip: tap on highlighted text to input all holdings or available funds", attributes: [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12.0), NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
        self.overview_txtView.attributedText = combinedString;
        self.styleButton(button: &self.fiveBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.thousBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.fiveThousBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.allBtn, borderColor: UIColor.orange.cgColor);
        self.styleButton(button: &self.buy_btn, borderColor: UIColor.green.cgColor);
        self.styleButton(button: &self.sell_btn, borderColor: UIColor.red.cgColor);
        
        self.buy_btn.backgroundColor = .init(red: 0, green: 120/255, blue: 0, alpha: 1);
        self.sell_btn.backgroundColor = .init(red: 120/255, green: 0, blue: 0, alpha: 1);
        
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
    
    private func updateInfo(isTypeing:Bool) {
        if (self.amount_txt.text!.first == "-") {
            self.amount_txt.text!.removeFirst();
        }
        let amountDouble = Double(self.amount_txt.text!.replacingOccurrences(of: ",", with: ""));
        if (amountDouble == nil) {
            self.cost_lbl.text = self.isUSDAmount ? " - " : "$ - ";
            if (!isTypeing) {
                displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
            } else {
                let combinedString = NSMutableAttributedString();
                combinedString.append(NSMutableAttributedString(string: "Welcome to Cryptfolio's practice trade console. Here you can practice buying and selling cryptocurrency with the funds you have in your account.", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
                combinedString.append(NSMutableAttributedString(string: "\n\nTip: tap on highlighted text to input all holdings or available funds", attributes: [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12.0), NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
                self.overview_txtView.attributedText = combinedString;
            }
            return;
        }
        let result:Double = self.isUSDAmount ? amountDouble! / self.ticker!.price : amountDouble! * self.ticker!.price;
        self.calculatedAmountOfCoin = result;
        self.cost_lbl.text =  self.isUSDAmount ? "\(String(format: "%.8f", result))" : "$\(String(format: "%.2f", result))";
        let displayText = self.isUSDAmount ? "You are about to sumbit an order for \(self.cost_lbl.text!) coin(s) of \(self.ticker!.name) for $\(String(format: "%.2f", self.ticker!.price)) each. This order will execute at the best available price." : "You are about to sumbit an order for \(self.amount_txt.text!) coin(s) of \(self.ticker!.name) for $\(String(format: "%.2f", self.ticker!.price)) each. This order will execute at the best available price."
        let attributedString = NSMutableAttributedString(string: displayText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12.0), NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]);
        self.overview_txtView.attributedText = attributedString;
    }
    
    private func incorrectInputLayout() -> Void {
        self.cost_lbl.text = self.isUSDAmount ? " - " : "$ - ";
        let combinedString = NSMutableAttributedString();
        combinedString.append(NSMutableAttributedString(string: "Welcome to Cryptfolio's practice trade console. Here you can practice buying and selling cryptocurrency with the funds you have in your account.", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
        combinedString.append(NSMutableAttributedString(string: "\n\nTip: tap on highlighted text to input all holdings or available funds", attributes: [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12.0), NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
        self.overview_txtView.attributedText = combinedString;
        displayAlert(title: "Oops...", message: "Must be a valid number i.e. 1.23, 2.0");
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        self.vibrate(style: .light);
        
        // get the amount of coin being bought
        let doubleAmount = self.isUSDAmount ? Double(self.cost_lbl.text!) : Double(self.amount_txt.text!.replacingOccurrences(of: ",", with: ""));
        if (doubleAmount == nil || self.amount_txt.text!.isEmpty || doubleAmount!.isZero || doubleAmount!.isLess(than: 0.0) || self.cost_lbl.text! == "$ - " || self.cost_lbl.text! == " - ") {
            incorrectInputLayout()
            return;
        }
        
        var tempCalc = self.calculatedAmountOfCoin;
        
        if (self.isUSDAmount) {
            var temp:String = self.availableFunds_lbl.text!;
            temp.removeFirst();
            if (Double(temp)!.isEqual(to: Double(self.amount_txt.text!.replacingOccurrences(of: ",", with: ""))!) || self.availPressed) {
                let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
                if (currentFunds != nil) {
                    if (currentFunds!.isLessThanOrEqualTo(0.0)) { displayAlert(title: "Sorry", message: "Insuffient funds"); return;}
                    tempCalc = currentFunds! / self.ticker!.price;
                    print("BUYING WITH ALL FUNDS");
                } else { displayAlert(title: "Sorry", message: "Insuffient funds"); return; }
            }
        }
        
        // buy the specified coin
        if (doubleAmount != nil && self.ticker != nil) {
            let resultingCost = self.isUSDAmount ? tempCalc * self.ticker!.price : doubleAmount! * self.ticker!.price;
            CryptoData.getCryptoID(coinSymbol: self.ticker!.symbol.lowercased()) { (uuid, error)  in
                if let error = error { print(error.localizedDescription); return; }
                CryptoData.getCoinData(id: uuid!) { [weak self] (ticker, error) in
                    if let error = error {
                        print(error.localizedDescription);
                    } else {
                        let affectedAmountOfCoin:Double = resultingCost / ticker!.price;
                        if (OrderHandler.buy(amountCost: resultingCost, amountOfCoin: affectedAmountOfCoin, ticker: ticker!)) {
                            self?.dismiss(animated: true) {
                                if let portVC = self?.portfolioVC {
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
        
    }
    
    @IBAction func sellPressed(_ sender: Any) {
        self.vibrate(style: .light);
        // get the amount of coin being bought
        let doubleAmount = Double(self.amount_txt.text!.replacingOccurrences(of: ",", with: ""));

        if (doubleAmount == nil || self.amount_txt.text!.isEmpty || doubleAmount!.isZero || doubleAmount!.isLess(than: 0.0) || self.cost_lbl.text! == "$ - " || self.cost_lbl.text == " - ") {
            incorrectInputLayout()
            return;
        }
        var tempCalc:Double = self.calculatedAmountOfCoin;
        if (self.isUSDAmount) {
            var temp:String = self.ownedCoin_lbl.text!;
            temp.removeFirst();
            if (Double(temp)!.isEqual(to: Double(self.amount_txt.text!.replacingOccurrences(of: ",", with: ""))!) || self.ownedCoinPressed) {
                print("yes")
                if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                    for holding in loadedHoldings {
                        if (holding.ticker.name == self.ticker!.name) {
                            tempCalc = (holding.amountOfCoin);
                            print("SELLING ALL COINS IN USD AMOUNT");
                            print("CALC: \(tempCalc)");
                        }
                    }
                }
            }
        } else {
            let temp:String = self.ownedAmountCoin_txt.text!;
            if (Double(temp)!.isEqual(to: Double(self.amount_txt.text!.replacingOccurrences(of: ",", with: ""))!) || self.ownedCoinPressed) {
                if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                    for holding in loadedHoldings {
                        if (holding.ticker.name == self.ticker!.name) {
                            print("here");
                            tempCalc = (holding.amountOfCoin);
                            print("CALC: \(tempCalc)");
                            print("SELLING ALL COINS IN COIN AMOUNT");
                        }
                    }
                }
            } else {
                print("here 2");
                tempCalc = 0.0;
                tempCalc = self.calculatedAmountOfCoin / self.ticker!.price
            }
        }
        print("CALC OUT: \(tempCalc)")
        // sell the specified coin
        if (doubleAmount != nil && self.ticker != nil) {
            CryptoData.getCryptoID(coinSymbol: self.ticker!.symbol.lowercased()) { (uuid, error) in
                if let error = error { print(error.localizedDescription); return; }
                CryptoData.getCoinData(id: uuid!) { [weak self] (ticker, error) in
                    if let error = error {
                        print(error.localizedDescription);
                    } else {
                        let amountCost = tempCalc * ticker!.price;
                        if (OrderHandler.sell(amountCost: amountCost, amountOfCoin: tempCalc, ticker: ticker!)) {
                            self?.dismiss(animated: true) {
                                if let portVC = self?.portfolioVC {
                                    portVC.loadData();
                                    portVC.tableVIew.reloadData();
                                }
                            };
                        }
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
    
    private func dismissKeyboardReset() {
        let amountDouble = Double(self.amount_txt.text!.replacingOccurrences(of: ",", with: ""));
        if (self.amount_txt.text!.isEmpty) {
            self.view.endEditing(true);
            self.cost_lbl.text = self.isUSDAmount ? " - " : "$ - ";
            self.overview_txtView.text = "";
            let combinedString = NSMutableAttributedString();
            combinedString.append(NSMutableAttributedString(string: "Welcome to Cryptfolio's practice trade console. Here you can practice buying and selling cryptocurrency with the funds you have in your account.", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
            combinedString.append(NSMutableAttributedString(string: "\n\nTip: tap on highlighted text to input all holdings or available funds", attributes: [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12.0), NSAttributedString.Key.foregroundColor : UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)]));
            self.overview_txtView.attributedText = combinedString;
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
        updateInfo(isTypeing: false);
        self.view.endEditing(true);
    }
    
    private func formatPrice(price:Double) -> String {
        var priceString = String(price);
        priceString.removeFirst();
        var otherPrice = String(price)
        otherPrice.removeFirst();
        otherPrice.removeFirst();
        if (String(price).first == "0" || priceString.first == ".") {
            return "\(String(format: "%.7f", price))"
        } else if (otherPrice.first == ".") {
            return "\(String(format: "%.2f", price))"
        } else {
            return "\(String(format: "%.2f", price))"
        }
    }
    
    @objc func doneButtonTappedForMyNumericTextField() {
        self.dismissKeyboardReset();
        self.amount_txt.resignFirstResponder()
    }
    
    @objc func cancelButtonTappedForMyNumericTextField() {
        self.setUpVC();
        self.amount_txt.text = "";
        self.amount_txt.resignFirstResponder()
    }
    
    private func addLeftImage(textfield:UITextField, image:UIImage) -> Void {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 35.0, height: 25.0));
        let leftImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.isUSDAmount ? image.size.width : 25.0, height: self.isUSDAmount ? image.size.width : 25.0));
        view.addSubview(leftImageView);
        leftImageView.image = image;
        leftImageView.tintColor = .white;
        textfield.leftView = view;
        textfield.leftViewMode = .always;
    }
    
    @objc private func hideKeyboard() -> Void { self.view.endEditing(true); }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { textField.resignFirstResponder(); return true; }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch (textField) {
        case self.amount_txt:
            CryptoData.styleTextFieldsOnEditing(textField: self.amount_txt, width: self.view.frame.width * 0.9, weight: .medium, color: .orange, labelColor: .orange);
            break;
        default:
            break;
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField) {
        case self.amount_txt:
            CryptoData.styleTextFieldsOnEditing(textField: self.amount_txt, width: self.view.frame.width * 0.9, weight: .light, color: .lightGray, labelColor: .black);
            break;
        default:
            break;
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.setAmountFormattedText(textField: textField);
    }
    
    private func setAmountFormattedText(textField:UITextField) -> Void {
        if (!self.isUSDAmount) { return; }
        if var amountString = textField.text?.currencyInputFormatting() {
            if (!amountString.isEmpty) {
                amountString.remove(at: amountString.startIndex);
                textField.text = amountString;
            } else {
                textField.text = "";
            }
        }
    }
    
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil, doneName:String) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped));
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped));
        
        let toolbar: UIToolbar = UIToolbar();
        toolbar.barStyle = .default;
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: doneName, style: .done, target: onDone.target, action: onDone.action)
        ];
        toolbar.sizeToFit();
        
        self.inputAccessoryView = toolbar;
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder(); }
    @objc func cancelButtonTapped() { self.resignFirstResponder(); }
}

extension String {

    // formatting text for currency textField
    func currencyInputFormatting() -> String {

        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        var amountWithPrefix = self

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")

        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }

        return formatter.string(from: number)!
 
    }
}
