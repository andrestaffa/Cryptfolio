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
    @IBOutlet weak var amount_txt: UITextField!
    @IBOutlet weak var cost_lbl: UILabel!
    @IBOutlet weak var overview_txtView: UITextView!
    @IBOutlet weak var buy_btn: UIButton!
    @IBOutlet weak var sell_btn: UIButton!
    
    // Public member variables
    public var ticker:Ticker?;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // load in available funds
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpVC();
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard));
        self.view.addGestureRecognizer(tap);
        
        // TODO: - Add where the user Adds funds to their account
        // TODO: - Update main portfolio and available Funds accordingly
        // TODO: - Add a View Controller where the user can view their order history
        
    }
    
    @objc private func dismissKeyboard() -> Void {
        if (self.amount_txt.text!.isEmpty) {
            self.view.endEditing(true);
            self.cost_lbl.text = "$ - "
            self.overview_txtView.text = "Welcome to Cryptfolio's practice buy/sell dashboard. Here you can practice buying and selling cryptocurrency with the funds you have added in your account.";
            return;
        }
        updateInfo();
        self.view.endEditing(true);
    }
    
    private func setUpVC() {
        self.marketPrice_lbl.text = "$\(String(round(10000.0 * ticker!.price) / 10000.0))";
        self.amount_txt.placeholder = "Amount " + "\(self.ticker!.symbol.uppercased())";
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
        self.cost_lbl.text = "$\(String(round(10000.0 * result) / 10000.0))"
        self.overview_txtView.text = "You are about to sumbit an order for \(self.amount_txt.text!) coin(s) of \(self.ticker!.name) for $\(String(round(10000.0 * self.ticker!.price) / 10000.0)) each. This order will execute at the best available price."
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        print("buy button pressed")
        
        // deduct and save available funds
        // update and save main portfoilio
        // add buy to order history
        
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
