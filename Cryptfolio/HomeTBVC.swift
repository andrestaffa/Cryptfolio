//
//  HomeTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-02-19.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import SVProgressHUD;
import SwiftChart;

class HomeTBVC: UITableViewController {

    // Private member vairables
    private var coins = Array<Coin>();
    private var filterCoins = Array<Coin>();
    private var loading = true;
    private var maxCoins = 20;
    private var counter = 0;
    private var prevLength = 0;
    
    // Public member variables
    public var isAdding = false;
    public var portfolioVC:PortfolioVC?;
    
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
        
        self.navigationController?.navigationBar.barTintColor = nil;
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationController?.navigationBar.shadowImage = nil;
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default);
        
        //let ids = CryptoData.readTextToArray(path: "Data.bundle/id");
        
        if (self.isAdding) {
            //self.navigationController?.navigationBar.prefersLargeTitles = false;
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationController?.navigationBar.backItem?.title = "Back"
            self.title = "Add Coin";
        } else {
            self.navigationController?.navigationBar.prefersLargeTitles = true;
            self.navigationController?.navigationBar.isHidden = false;
            //let refreshButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.refresh, target: self, action:#selector(refresh));
            //refreshButton.tintColor = UIColor.orange
            //self.navigationItem.rightBarButtonItem = refreshButton;
            self.navigationController?.navigationBar.tintColor = UIColor.orange;
            self.tableView.refreshControl = UIRefreshControl();
            self.tableView.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh");
            self.tableView.refreshControl!.addTarget(self, action: #selector(self.refresh), for: .valueChanged);
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
        self.getData();
        self.tableView.reloadData();
    }
    
    // MARK: - Data gathering
    
    private func getData() {
        self.counter += 1;
        if (!self.loading) {
            self.loading = true;
        }
        CryptoData.getCryptoData { [weak self] (ticker, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let imageUI = UIImage(named: "Images/" + "\(ticker!.symbol.lowercased())" + ".png")
                if (imageUI != nil) {
                    if (ticker!.name != "Matic Network") {
                        let image = Image(withImage: imageUI!);
                        self?.coins.append(Coin(ticker: ticker!, image: image));
                        if (self!.counter < 2) {
                            self?.prevLength = (self!.coins.count);
                        }
                        if ((self!.coins.count) > self!.prevLength) {
                            self?.coins.removeSubrange((0...self!.prevLength - 1));
                        }
                    }
                }
            }
            self?.loading = false;
            if let refresh = self?.tableView.refreshControl {
                refresh.endRefreshing();
            }
            self?.tableView.reloadData();
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading) {
            if let navBarItem = self.navigationItem.rightBarButtonItem {
                navBarItem.isEnabled = false;
            }
            return 1;
        } else {
            if let navBarItem = self.navigationItem.rightBarButtonItem {
                navBarItem.isEnabled = true;
            }
            if (self.isFiltering) {
                return filterCoins.count;
            } else {
                return self.coins.count;
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.isAdding ? 50.0 : 80.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell;
        if (self.loading) {
            SVProgressHUD.show(withStatus: "Loading...")
            cell.chartView.isHidden = false;
            cell.symbolLbl.isHidden = true;
            cell.name_lbl.isHidden = true;
            cell.crypto_img.isHidden = true;
            cell.add_lbl.isHidden = true;
            cell.priceTxt.isHidden = true;
            cell.container.isHidden = true;
            cell.percentChangeTxt.isHidden = true;
        } else {
            SVProgressHUD.dismiss();
            if (self.isFiltering) {
                cell.symbolLbl.text = self.filterCoins[indexPath.row].ticker.symbol.uppercased();
                cell.name_lbl.text = self.filterCoins[indexPath.row].ticker.name;
                cell.crypto_img.image = self.filterCoins[indexPath.row].image.getImage();
                cell.priceTxt.text = "$\(String(format: "%.2f", self.filterCoins[indexPath.row].ticker.price))";
                cell.percentChangeTxt.text = self.setChange(change: String(format: "%.2f", self.filterCoins[indexPath.row].ticker.changePrecent24H), cell: cell);
                let series = ChartSeries(self.filterCoins[indexPath.row].ticker.history24h);
                if (!((self.filterCoins[indexPath.row].ticker.history24h.first?.isLess(than: self.filterCoins[indexPath.row].ticker.history24h.last!))!)) {
                    series.color = ChartColors.redColor();
                } else {
                    series.color = ChartColors.greenColor();
                }
                cell.chartView.add(series);
            } else {
                cell.chartView.isHidden = false;
                cell.symbolLbl.isHidden = false;
                cell.name_lbl.isHidden = false;
                cell.crypto_img.isHidden = false;
                cell.priceTxt.isHidden = false;
                cell.container.isHidden = false;
                cell.percentChangeTxt.isHidden = false;
                if (self.isAdding) {
                    cell.chartView.isHidden = true;
                    cell.priceTxt.isHidden = true;
                    cell.container.isHidden = true;
                    cell.percentChangeTxt.isHidden = true;
                }
                cell.add_lbl.isHidden = !self.isAdding;
                cell.symbolLbl.text = self.coins[indexPath.row].ticker.symbol.uppercased();
                cell.name_lbl.text = self.coins[indexPath.row].ticker.name;
                cell.crypto_img.image = self.coins[indexPath.row].image.getImage();
                cell.priceTxt.text = "$\(String(format: "%.4f", self.coins[indexPath.row].ticker.price))";
                cell.percentChangeTxt.text = self.setChange(change: String(format: "%.2f", self.coins[indexPath.row].ticker.changePrecent24H), cell: cell);
                let series = ChartSeries(self.coins[indexPath.row].ticker.history24h);
                series.area = true;
                if (!((self.coins[indexPath.row].ticker.history24h.first?.isLess(than: self.coins[indexPath.row].ticker.history24h.last!))!)) {
                    series.color = ChartColors.redColor();
                } else {
                    series.color = ChartColors.greenColor();
                }
                cell.chartView.add(series);
            }
            
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        if (self.isFiltering) {
            if (self.isAdding) {
                if let portfolioVC = self.portfolioVC {
                    portfolioVC.viewDidLoad();
                }
                DataStorageHandler.saveObject(type: self.filterCoins[indexPath.row], forKey: UserDefaultKeys.coinKey);
                self.navigationController?.popViewController(animated: true);
                return;
            }
            infoVC.coin = self.filterCoins[indexPath.row];
            self.navigationController?.pushViewController(infoVC, animated: true);
        } else {
            if (self.isAdding) {
                if let portfolioVC = self.portfolioVC {
                    portfolioVC.viewDidLoad();
                }
                DataStorageHandler.saveObject(type: self.coins[indexPath.row], forKey: UserDefaultKeys.coinKey);
                self.navigationController?.popViewController(animated: true);
                return;
            }
            infoVC.coin = self.coins[indexPath.row];
            self.navigationController?.pushViewController(infoVC, animated: true);
        }
    }
    
    private func setChange(change:String, cell: CustomCell) -> String {
        if (change.first != "-") {
            let newChange = "+\(change)%";
            cell.container.backgroundColor = ChartColors.greenColor();
            return newChange;
        }
        else {
            cell.container.backgroundColor = ChartColors.redColor();
            let newChange = "\(change)%";
            return newChange;
        }
    }
    
    // MARK: - Alert view controller
    
    private func alert(title:String, message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton);
        present(alert, animated: true, completion: nil)
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
