//
//  HomeTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-02-19.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import CryptoCurrencyKit
import SVProgressHUD

// Coin class
public class Coin {
    public let ticker:Ticker?;
    public let image:UIImage?;
    
    init(ticker:Ticker, image:UIImage) {
        self.ticker = ticker;
        self.image = image;
    }
    
    public func isEqual(coin:Coin) -> Bool {
        if (self.ticker == coin.ticker && self.image == coin.image) {
            return true;
        } else {
            return false;
        }
    }
    
}

class HomeTBVC: UITableViewController {

    // Member vairables
    private var coins = Array<Coin>();
    private var filterCoins = Array<Coin>();
    private var loading = true;
    private var maxCoins = 20;
    private var counter = 0;
    private var prevLength = 0;
    
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

        // Configure navigation controller
        self.clearsSelectionOnViewWillAppear = false;
        self.navigationController?.navigationBar.isTranslucent = true;
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.refresh, target: self, action:#selector(refresh))
        
        // Configure searchView
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = false;
        searchController.searchBar.placeholder = "Search";
        navigationItem.searchController = searchController;
        definesPresentationContext = true;
        
        self.title = "Explore";
        self.getData();

    }

    // MARK: - Refresh data
    
    @objc private func refresh() {
        self.tableView.reloadData();
        self.getData();
    }
    
    // MARK: - Data gathering
    
    private func getData() {
        self.counter += 1;
        if (!self.loading) {
            self.loading = true;
        }
        CryptoCurrencyKit.fetchTickers { [weak self] response in
            switch response {
            case .success(let data):
                for i in 0...data.count - 1 {
                    let url = NSURL(string: "https://raw.githubusercontent.com/atomiclabs/cryptocurrency-icons/master/128/icon/" + "\(data[i].symbol.lowercased())" + ".png");
                    if (url != nil) {
                        let webData = NSData(contentsOf: url! as URL);
                        if (webData != nil) {
                            let image = UIImage(data: webData! as Data);
                            if (image != nil) {
                                self?.coins.append(Coin(ticker: data[i], image: image!));
                                if (self!.counter < 2) {
                                    self?.prevLength = (self?.coins.count)!;
                                }
                               if ((self?.coins.count)! > self!.prevLength) {
                                    self?.coins.removeSubrange((0...self!.prevLength - 1));
                                }
                            }
                        } else {
                            //self?.coins.append(Coin(ticker: data[i], image: UIImage(named: "circle")!));
                        }
                    }
                }
            case .failure(let error):
                print(error);
            }
            self?.loading = false;
            self?.tableView.reloadData();
            self?.tableView.reloadData();
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
        } else {
            SVProgressHUD.dismiss();
            if (self.isFiltering) {
                cell.name_lbl.text = self.filterCoins[indexPath.row].ticker?.name;
                cell.crypto_img.image = self.filterCoins[indexPath.row].image;
            } else {
                cell.name_lbl.isHidden = false;
                cell.crypto_img.isHidden = false;
                cell.name_lbl.text = self.coins[indexPath.row].ticker?.name;
                cell.crypto_img.image = self.coins[indexPath.row].image;
            }
            
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoVC = storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        if (self.isFiltering) {
            let ticker = self.filterCoins[indexPath.row].ticker;
            let tickerImage = self.filterCoins[indexPath.row].image;
            infoVC.title = self.filterCoins[indexPath.row].ticker?.name;
            infoVC.navigationItem.titleView = navTitleWithImageAndText(titleText: self.filterCoins[indexPath.row].ticker!.name, imageIcon: self.filterCoins[indexPath.row].image!)
            updateInfoVC(infoVC: infoVC, ticker: ticker!, tickerImage: tickerImage!);
            self.navigationController?.pushViewController(infoVC, animated: true);
        } else {
            let ticker = self.coins[indexPath.row].ticker;
            let tickerImage = self.coins[indexPath.row].image;
            infoVC.title = self.coins[indexPath.row].ticker?.name;
            infoVC.navigationItem.titleView = navTitleWithImageAndText(titleText: self.coins[indexPath.row].ticker!.name, imageIcon: self.coins[indexPath.row].image!);
            updateInfoVC(infoVC: infoVC, ticker: ticker!, tickerImage: tickerImage!);
            self.navigationController?.pushViewController(infoVC, animated: true);
        }
    }
    // MARK: - Alert view controller
    
    private func setChange(change:String) -> String {
        if (change.first != "-") {
            let newChange = "+\(change)%";
            return newChange;
        }
        else {
            let newChange = "\(change)%";
            return newChange;
        }
    }
    
    private func updateInfoVC(infoVC:InfoVC, ticker:Ticker, tickerImage:UIImage) {
        infoVC.name = ticker.name;
        infoVC.symbol = ticker.symbol;
        infoVC.image = tickerImage;
        infoVC.price = "$\(String(round(10000.0 * ticker.priceUSD!) / 10000.0))";
        infoVC.change = setChange(change: String(ticker.percentChange24h!));
        infoVC.rank =  "#\(String(ticker.rank))";
        infoVC.volume24H = "$\(String(ticker.volumeUSD24h!))";
        infoVC.marketCap = "$\(String(ticker.marketCapUSD!))";
        infoVC.maxSupply = "$\(String(ticker.totalSupply!))";
        infoVC.circulation = "$\(String(ticker.availableSupply!))";
    }
    
    private func alert(title:String, message:String) -> Void {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK");
        alert.show();
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
        
        // Adds both the label and image view to the titleView
        titleView.addSubview(label);
        titleView.addSubview(image);
        
        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit();
        
        return titleView;
        
    }
    
    func filterContentForSearchText(_ searchText: String) {
        self.filterCoins = self.coins.filter({ (coin) -> Bool in
            let filterContext = (coin.ticker?.name.lowercased().contains(searchText.lowercased()))! || ((coin.ticker?.symbol.lowercased().contains(searchText.lowercased()))!);
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
