//
//  PortfolioVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-03.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class PortfolioVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addCoin_btn: UIButton!
    @IBOutlet weak var welcome_lbl: UILabel!
    @IBOutlet weak var appName_lbl: UILabel!
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var multipleViews: UIView!
    
    
    private var coins = Array<Coin>();
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableVIew.reloadData();
        writeCoinArray();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.tableVIew.delegate = self;
        self.tableVIew.dataSource = self;
    
        self.title = "Dashboard";
        
    }
    
    @objc func addTapped() {
        let homeTBVC = self.storyboard?.instantiateViewController(withIdentifier: "homeTBVC") as! HomeTBVC;
        homeTBVC.isAdding = true;
        self.navigationController?.pushViewController(homeTBVC, animated: true);
    }
    
    private func writeCoinArray() {
        let encoder = JSONEncoder();
        if let encoded = try? encoder.encode(self.coins) {
            let defaults = UserDefaults.standard;
            defaults.set(encoded, forKey: "coinArrayKey");
        }
    }
    
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton)
        present(alert, animated: true, completion: nil);
    }
    
    
    // MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let defaults = UserDefaults.standard;
        if let savedCoin = defaults.object(forKey: "coinArrayKey") as? Data {
            let decoder = JSONDecoder()
            if let loadedCoin = try? decoder.decode([Coin].self, from: savedCoin) {
                self.coins = loadedCoin;
            }
        }
        if let savedCoin = defaults.object(forKey: "coinKey") as? Data {
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
            tableView.separatorStyle = .none;
            return self.coins.count;
        } else {
            self.styleButton(button: &self.addCoin_btn);
            self.hideViews(hidden: false);
            tableView.backgroundView = self.multipleViews;
            tableView.separatorStyle = .none;
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.coins.remove(at: indexPath.row);
            UserDefaults.standard.removeObject(forKey: "coinKey");
            UserDefaults.standard.removeObject(forKey: "coinArrayKey");
            writeCoinArray();
            tableView.beginUpdates();
            tableView.deleteRows(at: [indexPath], with: .fade);
            tableView.endUpdates();
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        cell.textLabel?.text = self.coins[indexPath.row].ticker.name;
        cell.imageView?.image = self.coins[indexPath.row].image.getImage();
        cell.layer.cornerRadius = 10.0;
        cell.backgroundColor = UIColor.init(red: 2/255, green: 7/255, blue: 93/255, alpha: 0.5)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        CryptoData.getCryptoData(index: indexPath.row) { (ticker, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                self.coins[indexPath.row].ticker.price = ticker!.price;
                self.displayAlert(title: "Price", message: "\(self.coins[indexPath.row].ticker.price)")
            }
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
        button.backgroundColor = UIColor.init(red: 2/255, green: 7/255, blue: 93/255, alpha: 1);
    }
    
    // MARK: - Hide all views
    
    private func hideViews(hidden:Bool) -> Void {
        self.addCoin_btn.isHidden = hidden;
        self.welcome_lbl.isHidden = hidden;
        self.appName_lbl.isHidden = hidden;
    }
    

}
