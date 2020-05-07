//
//  HomeTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-02-19.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import SVProgressHUD

class HomeTBVC: UITableViewController {

    // Private member vairables
    private var coins = Array<Coin>();
    private var filterCoins = Array<Coin>();
    private var indexArray = [Int]();
    private var loading = true;
    private var maxCoins = 20;
    private var counter = 0;
    private var prevLength = 0;
    
    // Public member variables
    public var isAdding = false;
    
    // Define scroll view properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true;
    }
    private var isFiltering: Bool {
        return self.searchController.isActive && !isSearchBarEmpty;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isAdding) {
            //self.navigationController?.navigationBar.prefersLargeTitles = false;
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationController?.navigationBar.backItem?.title = "Back"
            self.title = "Add Coin";
        } else {
            self.navigationController?.navigationBar.prefersLargeTitles = true;
            self.navigationController?.navigationBar.isHidden = false;
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.refresh, target: self, action:#selector(refresh))
            self.title = "Explore";
        }

        // Configure navigation controller
        self.clearsSelectionOnViewWillAppear = false;
        self.navigationController?.navigationBar.isTranslucent = true;
        
        // Configure searchView
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = false;
        searchController.searchBar.placeholder = "Search";
        navigationItem.searchController = searchController;
        definesPresentationContext = true;
        
        self.getData();

    }

    // MARK: - Refresh data
    
    @objc private func refresh() {
        self.tableView.reloadData();
        self.getData();
        self.tableView.reloadData()
    }
    
    // MARK: - Data gathering
    
    private func getData() {
        self.counter += 1;
        if (!self.loading) {
            self.loading = true;
        }
        CryptoData.getCryptoData { (ticker, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let imageUI = UIImage(named: "Images/" + "\(ticker!.symbol.lowercased())" + ".png")
                if (imageUI != nil) {
                    let image = Image(withImage: imageUI!);
                    self.coins.append(Coin(ticker: ticker!, image: image));
                    if (self.counter < 2) {
                        self.prevLength = (self.coins.count);
                    }
                    if ((self.coins.count) > self.prevLength) {
                        self.coins.removeSubrange((0...self.prevLength - 1));
                    }
                }
            }
            self.loading = false;
            self.tableView.reloadData();
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading) {
            return 1;
        } else {
            if (self.isFiltering) {
                return filterCoins.count;
            } else {
            return self.coins.count;
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell;
        if (self.loading) {
            SVProgressHUD.show(withStatus: "Loading...")
            cell.name_lbl.isHidden = true;
            cell.crypto_img.isHidden = true;
            cell.add_lbl.isHidden = true;
        } else {
            SVProgressHUD.dismiss();
            if (self.isFiltering) {
                cell.name_lbl.text = self.filterCoins[indexPath.row].ticker.name;
                cell.crypto_img.image = self.filterCoins[indexPath.row].image.getImage();
            } else {
                cell.name_lbl.isHidden = false;
                cell.crypto_img.isHidden = false;
                if (!self.isAdding) {
                    cell.add_lbl.isHidden = true;
                } else {
                    cell.add_lbl.isHidden = false;
                }
                cell.name_lbl.text = self.coins[indexPath.row].ticker.name;
                cell.crypto_img.image = self.coins[indexPath.row].image.getImage();
            }
            
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        if (self.isFiltering) {
            setDesciption(ticker: &self.filterCoins[indexPath.row].ticker);
            if (self.isAdding) {
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self.filterCoins[indexPath.row]) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: UserDefaultKeys.coinKey)
                }
                loadIndexArray();
                if (!self.indexArray.contains(self.filterCoins[indexPath.row].ticker.rank)) {
                    self.indexArray.append(self.filterCoins[indexPath.row].ticker.rank);
                }
                saveIndexArray();
                self.navigationController?.popViewController(animated: true);
                return;
            }
            // TODO: - CryptoData(index:Int) update when pressed (self.filterCoins)
            infoVC.title = self.filterCoins[indexPath.row].ticker.name;
            infoVC.navigationItem.titleView = navTitleWithImageAndText(titleText: self.filterCoins[indexPath.row].ticker.name, imageIcon: self.filterCoins[indexPath.row].image.getImage()!)
            infoVC.coin = self.filterCoins[indexPath.row];
            self.navigationController?.pushViewController(infoVC, animated: true);
        } else {
            setDesciption(ticker: &self.coins[indexPath.row].ticker);
            if (self.isAdding) {
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self.coins[indexPath.row]) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: UserDefaultKeys.coinKey)
                }
                loadIndexArray();
                if (!self.indexArray.contains(self.coins[indexPath.row].ticker.rank)) {
                    self.indexArray.append(self.coins[indexPath.row].ticker.rank);
                }
                saveIndexArray();
                self.navigationController?.popViewController(animated: true);
                return;
            }
            // TODO: - CryptoData(index:Int) update when pressed (self.coins)
            infoVC.title = self.coins[indexPath.row].ticker.name;
            infoVC.navigationItem.titleView = navTitleWithImageAndText(titleText: self.coins[indexPath.row].ticker.name, imageIcon: self.coins[indexPath.row].image.getImage()!);
            infoVC.coin = self.coins[indexPath.row];
            self.navigationController?.pushViewController(infoVC, animated: true);
        }
    }
    
    private func loadIndexArray() {
        let tempIndexArray = UserDefaults.standard.array(forKey: UserDefaultKeys.indexArrayKey) as? [Int];
        if (tempIndexArray != nil) {
            self.indexArray = tempIndexArray!;
        } else {
            self.indexArray = [Int]();
        }
    }
    
    private func saveIndexArray() {
        UserDefaults.standard.set(self.indexArray, forKey: UserDefaultKeys.indexArrayKey);
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
    // MARK: - Alert view controller
    
    private func alert(title:String, message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton);
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation controller custom image
    
    func navTitleWithImageAndText(titleText: String, imageIcon: UIImage) -> UIView {
        
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
    
    func filterContentForSearchText(_ searchText: String) {
        self.filterCoins = self.coins.filter({ (coin) -> Bool in
            let filterContext = (coin.ticker.name.lowercased().contains(searchText.lowercased())) || ((coin.ticker.symbol.lowercased().contains(searchText.lowercased())));
            return filterContext;
        })
        self.tableView.reloadData();
    }
    
}

// MARK: - Extentions

extension HomeTBVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar;
        filterContentForSearchText(searchBar.text!);
    }
}
