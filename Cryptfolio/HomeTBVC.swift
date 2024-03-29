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

class HomeTBVC: UITableViewController, HomeCellDelgate {
    
    // Private member variables
    private var coins = Array<Coin>();
    private var filterCoins = Array<Coin>();
    private var maxCoins = 20;
    private var counter = 0;
    private var prevLength = 0;
    private var tappedContainer:Bool = false;
    
    // Public member variables
    public var isAdding = false;
	public var isARSelection:Bool = false;
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
		} else if (self.isARSelection) {
			//self.navigationController?.navigationBar.prefersLargeTitles = false;
			self.navigationItem.rightBarButtonItem = nil;
			self.navigationController?.navigationBar.backItem?.title = "Back"
			self.title = "Select Coin";
		} else {
            self.navigationController?.navigationBar.prefersLargeTitles = true;
            self.navigationController?.navigationBar.isHidden = false;
            //let refreshButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.refresh, target: self, action:#selector(refresh));
            //refreshButton.tintColor = UIColor.orange
            //self.navigationItem.rightBarButtonItem = refreshButton;
            self.navigationController?.navigationBar.tintColor = UIColor.orange;
            self.tableView.refreshControl = UIRefreshControl();
            self.tableView.refreshControl!.attributedTitle = NSAttributedString(string: "");
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
        
        self.getData(loadingIndicator: true);

    }

    // MARK: - Refresh data
    
    @objc private func refresh() {
        self.getData(loadingIndicator: false);
    }
    
    // MARK: - Data gathering
    
	private func getData(loadingIndicator:Bool) {
        self.counter += 1;
		if (loadingIndicator) { SVProgressHUD.show(withStatus: "Loading..."); self.tableView.separatorStyle = .none; }
        CryptoData.getCryptoData { [weak self] (tickerList, error) in
			if let _ = error { CryptoData.DisplayNetworkErrorAlert(vc: self); SVProgressHUD.dismiss(); return; }
			if let tickerList = tickerList {
				for ticker in tickerList {
					if let imageUI = UIImage(named: "Images/" + "\(ticker.symbol.lowercased())" + ".png") {
						let image = Image(withImage: imageUI);
						self?.coins.append(Coin(ticker: ticker, image: image));
						if (self!.counter < 2) {
							self?.prevLength = (self!.coins.count);
						}
						if ((self!.coins.count) > self!.prevLength) {
							self?.coins.removeSubrange((0...self!.prevLength - 1));
						}
					}
				}
			}
            if let refresh = self?.tableView.refreshControl { refresh.endRefreshing(); }
			SVProgressHUD.dismiss();
			self?.tableView.separatorStyle = .singleLine;
			if (loadingIndicator) {
				self?.tableView.beginUpdates();
				self?.tableView.reloadSections(IndexSet(integer: 0), with: .middle);
				self?.tableView.endUpdates();
			} else {
				self?.tableView.reloadData();
			}
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (self.coins.isEmpty) {
            if let navBarItem = self.navigationItem.rightBarButtonItem {
                navBarItem.isEnabled = false;
            }
            return 0;
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
    
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return (self.isAdding || self.isARSelection) ? 50.0 : 80.0;
	}
	
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return (self.isAdding || self.isARSelection) ? 50.0 : 80.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell;
        cell.delegate = self;
		if (self.isFiltering) {
			if (self.filterCoins.isEmpty) {
				let cell = UITableViewCell();
				cell.backgroundColor = .clear;
				cell.contentView.backgroundColor = .clear;
				return cell;
			}
			cell.addSymbolImg.isHidden = true;
			if (self.isAdding) {
				self.displayAddingVC(cell: cell, coinSet: self.filterCoins, indexPathRow: indexPath.row);
			} else if (self.isARSelection) {
				self.displayARSelectionCoins(cell: cell, coinSet: self.filterCoins, indexPathRow: indexPath.row);
			}
			cell.symbolLbl.text = self.filterCoins[indexPath.row].ticker.symbol.uppercased();
			cell.name_lbl.text = self.filterCoins[indexPath.row].ticker.name;
			cell.crypto_img.image = self.filterCoins[indexPath.row].image.getImage();
			cell.priceTxt.text = CryptoData.convertToDollar(price: self.filterCoins[indexPath.row].ticker.price, hasSymbol: false);
			cell.percentChangeTxt.text = self.setChange(change: String(format: "%.2f", self.filterCoins[indexPath.row].ticker.changePrecent24H), cell: cell);
			let series = ChartSeries(self.filterCoins[indexPath.row].ticker.history24h);
			if (!((self.filterCoins[indexPath.row].ticker.history24h.first?.isLess(than: self.filterCoins[indexPath.row].ticker.history24h.last!))!)) {
				series.color = ChartColors.redColor();
			} else {
				series.color = ChartColors.greenColor();
			}
			cell.chartView.add(series);
		} else {
			if (self.coins.isEmpty) {
				let cell = UITableViewCell();
				cell.backgroundColor = .clear;
				cell.contentView.backgroundColor = .clear;
				return cell;
			}
			cell.addSymbolImg.isHidden = true;
			if (self.isAdding) {
				self.displayAddingVC(cell: cell, coinSet: self.coins, indexPathRow: indexPath.row);
			} else if (self.isARSelection) {
				self.displayARSelectionCoins(cell: cell, coinSet: self.coins, indexPathRow: indexPath.row);
			}
			cell.symbolLbl.text = self.coins[indexPath.row].ticker.symbol.uppercased();
			cell.name_lbl.text = self.coins[indexPath.row].ticker.name;
			cell.crypto_img.image = self.coins[indexPath.row].image.getImage();
			cell.priceTxt.text = CryptoData.convertToDollar(price: self.coins[indexPath.row].ticker.price, hasSymbol: false);
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
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        if (self.isFiltering) {
            if (self.isAdding) {
                if (self.userHasCoin(coinSet: self.filterCoins, indexPathRow: indexPath.row)) { self.alert(title: "Coin Already Added!", message: "You already have \(self.filterCoins[indexPath.row].ticker.name) in your dashboard"); return;  }
                if let portfolioVC = self.portfolioVC {
                    portfolioVC.viewDidLoad();
                }
                DataStorageHandler.saveObject(type: self.filterCoins[indexPath.row], forKey: UserDefaultKeys.coinKey);
                self.navigationController?.popViewController(animated: true);
                return;
			} else if (self.isARSelection) {
				self.searchController.searchBar.endEditing(true);
				if let tabbar = self.tabBarController {
					let timestampView = ATimestampSelectionView(viewController: self, containingView: tabbar.view, coin: self.filterCoins[indexPath.row]);
					timestampView.show();
				}
				return;
			}
            infoVC.coin = self.filterCoins[indexPath.row];
            self.navigationController?.pushViewController(infoVC, animated: true);
        } else {
            if (self.isAdding) {
                if (self.userHasCoin(coinSet: self.coins, indexPathRow: indexPath.row)) { self.alert(title: "Coin Already Added!", message: "You already have \(self.coins[indexPath.row].ticker.name) in your dashboard"); return; }
                if let portfolioVC = self.portfolioVC {
                    portfolioVC.viewDidLoad();
                }
                DataStorageHandler.saveObject(type: self.coins[indexPath.row], forKey: UserDefaultKeys.coinKey);
                self.navigationController?.popViewController(animated: true);
                return;
			} else if (self.isARSelection) {
				self.searchController.searchBar.endEditing(true);
				if let tabbar = self.tabBarController {
					let timestampView = ATimestampSelectionView(viewController: self, containingView: tabbar.view, coin: self.coins[indexPath.row]);
					timestampView.show();
				}
				return;
			}
            infoVC.coin = self.coins[indexPath.row];
            self.navigationController?.pushViewController(infoVC, animated: true);
        }
    }
    
    func didTap(_ cell: CustomCell) {
        self.tappedContainer = !self.tappedContainer;
        let indexPath = self.tableView.indexPath(for: cell);
        if (self.isFiltering) {
            cell.percentChangeTxt.text = self.tappedContainer ? self.formatPrice(price: self.filterCoins[indexPath!.row].ticker.price, coinSet: self.filterCoins, indexPathRow: indexPath!.row) : self.setChange(change: String(format: "%.2f", self.filterCoins[indexPath!.row].ticker.changePrecent24H), cell: cell);
        } else {
            cell.percentChangeTxt.text = self.tappedContainer ? self.formatPrice(price: self.coins[indexPath!.row].ticker.price, coinSet: self.coins, indexPathRow: indexPath!.row) : self.setChange(change: String(format: "%.2f", self.coins[indexPath!.row].ticker.changePrecent24H), cell: cell);
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
    
    private func formatPrice(price:Double, coinSet:Array<Coin>, indexPathRow:Int) -> String {
        var priceString = String(price);
        priceString.removeFirst();
        
        var otherPrice = String(price)
        otherPrice.removeFirst();
        otherPrice.removeFirst();

        let priceChange = (coinSet[indexPathRow].ticker.changePrecent24H / 100) * price
        
        if (String(price).first == "0" || priceString.first == ".") {
            return priceChange >= 0 ? "+\(String(format: "%.5f", priceChange))" : "\(String(format: "%.5f", priceChange))";
        } else if (otherPrice.first == ".") {
            return priceChange >= 0 ? "+\(String(format: "%.2f", priceChange))" : "\(String(format: "%.2f", priceChange))";
        } else {
            return priceChange >= 0 ? "+\(String(format: "%.2f", priceChange))" : "\(String(format: "%.2f", priceChange))";
        }
    }
    
    private func displayAddingVC(cell:CustomCell, coinSet:Array<Coin>, indexPathRow:Int) -> Void {
        cell.addSymbolImg.isHidden = false;
        cell.chartView.isHidden = true;
        cell.priceTxt.isHidden = true;
        cell.container.isHidden = true;
        cell.percentChangeTxt.isHidden = true;
        if let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey) {
            if (loadedCoins.contains(where: { (coin) -> Bool in
                return coin.ticker.symbol.lowercased() == coinSet[indexPathRow].ticker.symbol.lowercased();
            })) {
                cell.addSymbolImg.tintColor = .green;
                cell.addSymbolImg.image = #imageLiteral(resourceName: "checkmark");
            } else {
                // set cell add image to plus sign
                cell.addSymbolImg.tintColor = .orange;
                cell.addSymbolImg.image = #imageLiteral(resourceName: "plus");
            }
        } else {
            // set cell add image to plus sign
            cell.addSymbolImg.tintColor = .orange;
            cell.addSymbolImg.image = #imageLiteral(resourceName: "plus");
        }
    }
	
	private func displayARSelectionCoins(cell:CustomCell, coinSet:Array<Coin>, indexPathRow:Int) -> Void {
		cell.addSymbolImg.isHidden = true;
		cell.chartView.isHidden = true;
		cell.priceTxt.isHidden = true;
		cell.container.isHidden = true;
		cell.percentChangeTxt.isHidden = true;
		cell.selectionImg.isHidden = false;
	}
    
    private func userHasCoin(coinSet:Array<Coin>, indexPathRow:Int) -> Bool {
        if let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey) {
            if (loadedCoins.contains(where: { (coin) -> Bool in
                return coin.ticker.symbol.lowercased() == coinSet[indexPathRow].ticker.symbol.lowercased();
            })) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
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
