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
    
    
    private var coins = Array<Coin>();
    private var indexArray = [Int]();
    
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
            self.availableFunds_lbl.text = "$\(String(round(100.0 * availableFunds!) / 100.0))"
        } else {
            self.availableFunds_lbl.text = "$0.00";
        }
        
        // load in main portfolio amount (update with the all the users holdings)
        let mainPortfolio = UserDefaults.standard.value(forKey: UserDefaultKeys.mainPortfolioKey) as? Double;
        if (mainPortfolio != nil) {
            self.mainPortfolio_lbl.text = "$\(String(round(100.0 * mainPortfolio!) / 100.0))"
            
            // load in holdings array
            let defaults = UserDefaults.standard;
            if let savedHolding = defaults.object(forKey: UserDefaultKeys.holdingsKey) as? Data {
                let decoder = JSONDecoder()
                if let loadedHolding = try? decoder.decode([Holding].self, from: savedHolding) {
                    // USE "loadedHoldings" to calculate portfolio on load up. Use percentChange * estCost.
                    // VERY CHALLENGING TO UPDATE MAIN PORTFOLIO
                    for index in 0...loadedHolding.count - 1 {
                        CryptoData.getCryptoData(index: loadedHolding[index].ticker.rank - 1) { (ticker, error) in
                            if let error = error {
                                print(error.localizedDescription);
                            } else {
                                let priceDifference:Double = -(loadedHolding[index].ticker.price - ticker!.price);
                                let portPercentChange = priceDifference / loadedHolding[index].ticker.price;
                                let updatedChange = mainPortfolio! + (mainPortfolio! * portPercentChange);
                                print("Price Difference: \(priceDifference)");
                                print("Portfolio Percent Change: \(portPercentChange)")
                                print("Bought at price: \(loadedHolding[index].ticker.price)");
                                print("Bought at percent change at: \(loadedHolding[index].ticker.changePrecent24H)")
                                self.mainPortfolio_lbl.text = "$\(String(round(100.0 * updatedChange) / 100.0))"
                            }
                        }
                    }
                }
            }
            
        } else {
            self.mainPortfolio_lbl.text = "$0.00";
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.tabBarController?.tabBar.isHidden = false;
        self.tableVIew.delegate = self;
        self.tableVIew.dataSource = self;
        
        let barItems:[UIBarButtonItem] = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)), self.editButtonItem];
        self.navigationItem.rightBarButtonItems = barItems;
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(goToHoldingsVC));
        
        self.availableFunds_lbl.isUserInteractionEnabled = true;
        let availFundsTap = UITapGestureRecognizer(target: self, action: #selector(availFundsTapped));
        self.availableFunds_lbl.addGestureRecognizer(availFundsTap);
        
        self.mainPortfolio_lbl.isUserInteractionEnabled = true;
        let mainPortTap = UITapGestureRecognizer(target: self, action: #selector(mainPortTapped));
        self.mainPortfolio_lbl.addGestureRecognizer(mainPortTap);
    
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
        cell.change_img.image = self.coins[indexPath.row].image.getImage()!;
        if (self.coins[indexPath.row].ticker.changePrecent24H < 0.0) {
            cell.change_img.image = UIImage(named: "Images/InfoImages/lightRed.png");
        } else {
            cell.change_img.image = UIImage(named: "Images/InfoImages/lightGreen.png");
        }
        //cell.layer.cornerRadius = 10.0;
        //cell.backgroundColor = UIColor.init(red: 2/255, green: 7/255, blue: 93/255, alpha: 0.5)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        CryptoData.getCryptoData(index: self.indexArray[indexPath.row] - 1) { (ticker, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                self.coins[indexPath.row].ticker = ticker!;
                self.setDesciption(ticker: &self.coins[indexPath.row].ticker)
                let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
                infoVC.title = self.coins[indexPath.row].ticker.name;
                infoVC.navigationItem.titleView = self.navTitleWithImageAndText(titleText: self.coins[indexPath.row].ticker.name, imageIcon: self.coins[indexPath.row].image.getImage()!);
                infoVC.coin = self.coins[indexPath.row];
                infoVC.isTradingMode = true;
                self.navigationController?.pushViewController(infoVC, animated: true);
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
        self.multipleViews.isHidden = hidden;
    }
    
    private func hideFunds(hidden:Bool) -> Void {
        self.availableFundsStatic_lbl.isHidden = hidden;
        self.availableFunds_lbl.isHidden = hidden;
        self.mainPortfolioStatic_lbl.isHidden = hidden;
        self.mainPortfolio_lbl.isHidden = hidden;
    }
    
    private func setDesciption(ticker:inout Ticker) -> Void {
           if (ticker.description == "No Description Available") {
               switch ticker.name {
               case "Huobi Token":
                   ticker.description = "Huobi Token (HT) is an exchange based token and native currency of the Huobi crypto exchange. The HT can be used to purchase monthly VIP status plans for transaction fee discounts, vote on exchange decisions, gain early access to special Huobi events, receive crypto rewards from seasonal buybacks and trade with other cryptocurrencies listed on the Huobi exchange.";
                   break;
               case "Paxos Standard":
                   ticker.description = "Paxos Standard (PAX) is a stablecoin that allows users to exchange US dollars for Paxos Standard Tokens to 'transact at the speed of the internet'. It aims to meld the stability of the dollar with blockchain technology. Paxos, the company behind PAX, has a charter from the New York State Department of Financial Services, which allows it to offer regulated services in the cryptoasset space.";
                   break;
               case "Multi-Collateral Dai":
                   ticker.description = "Dai is decentralized and backed by collateral. The Maker Protocol, which allows anyone anywhere in the world to generate Dai, aims to facilitate greater security, transparency, and trust.";
                   break;
               case "Kyber Network":
                   ticker.description = "Kyber Network’s on-chain liquidity protocol allows decentralized token swaps to be integrated into any application, enabling value exchange to be performed seamlessly between all parties in the ecosystem. Tapping on the protocol, developers can build payment flows and financial apps, including instant token swap services, erc20 payments, and innovative financial dapps - helping to build a world where any token is usable anywhere.";
                   break;
               case "Matic Network":
                   ticker.description = "Matic Network describes itself as is a Layer 2 scaling solution that uses sidechains for off-chain computation while ensuring asset security using the Plasma framework and a decentralized network of Proof-of-Stake (PoS) validators. Matic aims to be the de-facto platform on which developers will deploy and run decentralized applications in a secure and decentralized manner.";
                   break;
               case "TrueUSD":
                   ticker.description = "TrueUSD is a USD-pegged stablecoin, that provides its users with regular attestations of escrowed balances, full collateral and legal protection against the misappropriation of the underlying USD. TrueUSD is issued by the TrustToken platform, the platform that has partnered with registered fiduciaries and banks that hold the funds backing the TrueUSD tokens.";
               default:
                   break;
               }
           }
       }
    
    private func navTitleWithImageAndText(titleText: String, imageIcon: UIImage) -> UIView {
        
        // Creates a new UIView
        let titleView = UIView();
        
        // Creates a new text label
        let label = UILabel();
        label.text = titleText;
        label.sizeToFit();
        label.center = titleView.center;
        label.textAlignment = NSTextAlignment.center;
        
        // Creates the image view
        let image = UIImageView();
        image.image = imageIcon;
        
        // Maintains the image's aspect ratio:
        let imageAspect = image.image!.size.width / image.image!.size.height
        ;
        // Sets the image frame so that it's immediately before the text:
        let imageX = label.frame.origin.x - label.frame.size.height * imageAspect - 10;
        let imageY = label.frame.origin.y;
        
        let imageWidth = label.frame.size.height * imageAspect;
        let imageHeight = label.frame.size.height;
        
        image.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight);
        
        image.contentMode = UIView.ContentMode.scaleAspectFit;
        
        // Adds both the label and image view to the titleView0
        titleView.addSubview(label);
        titleView.addSubview(image);
        
        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit();
        
        return titleView;
        
    }
    

}
