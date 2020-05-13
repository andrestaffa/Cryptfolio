//
//  AddFundsVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-07.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class AddFundsVC: UIViewController {

    
    @IBOutlet weak var availableFunds_lbl: UILabel!
    @IBOutlet weak var amount_lbl: UILabel!
    @IBOutlet weak var oneH_btn: UIButton!
    @IBOutlet weak var twoH_btn: UIButton!
    @IBOutlet weak var threeH_btn: UIButton!
    @IBOutlet weak var fiveH_btn: UIButton!
    @IBOutlet weak var sevenH_btn: UIButton!
    @IBOutlet weak var oneTh_btn: UIButton!
    @IBOutlet weak var twoTh_btn: UIButton!
    @IBOutlet weak var other_btn: UIButton!
    @IBOutlet weak var addFunds_btn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // load in available funds
        let availableFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (availableFunds != nil) {
            self.availableFunds_lbl.text = "$\(String(format: "%.2f", availableFunds!))";
        } else {
            self.availableFunds_lbl.text = "$0.00";
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true;
        
    }

    @IBAction func exitPressed(_ sender: Any) { self.navigationController?.popViewController(animated: true); }
    @IBAction func oneHPressed(_ sender: Any) { self.amount_lbl.text = "$100.00"; }
    @IBAction func twoHPressed(_ sender: Any) { self.amount_lbl.text = "$200.00"; }
    @IBAction func threeHPressed(_ sender: Any) { self.amount_lbl.text = "$300.00"; }
    @IBAction func fiveHPressed(_ sender: Any) { self.amount_lbl.text = "$500.00"; }
    @IBAction func sevenHPressed(_ sender: Any) { self.amount_lbl.text = "$750.00" }
    @IBAction func oneThPressed(_ sender: Any) { self.amount_lbl.text = "$1000.00" }
    @IBAction func twoThPressed(_ sender: Any) { self.amount_lbl.text = "$2000.00" }
    
    
    @IBAction func otherPressed(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.availableFundsKey);
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.mainPortfolioKey);
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.holdingsKey);
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func addFundsPressed(_ sender: Any) {
        if (self.amount_lbl.text == "$ _____") {
            displayAlert(title: "Error", message: "Invalid amount, use one of the given options")
            return;
        }
        var temp = self.amount_lbl.text!;
        temp.removeFirst();
        let amountToAdd = Double(temp);
        print(amountToAdd!)
        
        // load current value of available Funds
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            let updatedFunds = currentFunds! + amountToAdd!;
            UserDefaults.standard.set(updatedFunds, forKey: UserDefaultKeys.availableFundsKey);
        } else {
            UserDefaults.standard.set(amountToAdd, forKey: UserDefaultKeys.availableFundsKey);
        }
        self.navigationController?.popViewController(animated: true);
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton)
        present(alert, animated: true, completion: nil);
    }
    
    
}
