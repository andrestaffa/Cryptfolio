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

class HomeTBVC: UITableViewController {
    
    var tickers = Array<Ticker>();
    var tickerImages = Array<UIImage>();
    var loading = true;
    var maxCoins = 13;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false;

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
        self.title = "Explore";
        self.getData();
        
        
    }

    // MARK - Data Gathering
    
    private func getData() {
        CryptoCurrencyKit.fetchTickers { [weak self] response in
            switch response {
            case .success(let data):
                for i in 0...self!.maxCoins - 1 {
                    self?.tickers.append(data[i]);
                    let url = NSURL(string: "https://raw.githubusercontent.com/atomiclabs/cryptocurrency-icons/master/128/icon/" + "\(data[i].symbol.lowercased())" + ".png");
                    if (url != nil) {
                        let data = NSData(contentsOf: url! as URL);
                        if (data != nil) {
                            let image = UIImage(data: data! as Data);
                            if (image != nil) {
                                self?.tickerImages.append(image!);
                            } else {
                                self?.tickerImages.append(UIImage(named: "circle")!);
                            }
                        } else {
                            self?.tickerImages.append(UIImage(named: "circle")!);
                        }
                    } else {
                        self?.tickerImages.append(UIImage(named: "circle")!);
                    }
                }
            case .failure(let error):
                print(error);
            }
            self?.loading = false;
            self?.tableView.reloadData();
        }
        
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (loading) {
            return 1;
        } else {
            return self.tickers.count;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell;
        if (loading) {
            SVProgressHUD.show(withStatus: "Loading...")
            cell.name_lbl.isHidden = true;
            cell.crypto_img.isHidden = true;
        } else {
            SVProgressHUD.dismiss();
            cell.name_lbl.isHidden = false;
            cell.crypto_img.isHidden = false;
            cell.name_lbl.text = self.tickers[indexPath.row].name;
            cell.crypto_img.image = self.tickerImages[indexPath.row];
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alert(title: self.tickers[indexPath.row].symbol, message: String(self.tickers[indexPath.row].priceUSD!));
    }
    
    private func alert(title:String, message:String) -> Void {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK");
        alert.show();
    }

   

}
