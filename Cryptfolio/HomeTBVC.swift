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
    var maxCoins = 40;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false;

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
        self.navigationController?.navigationBar.isTranslucent = true;
        
        self.title = "Explore";
        
        self.getData();
        
        
    }

    // MARK: - Data gathering
    
    private func getData() {
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
                                self?.tickers.append(data[i])
                                self?.tickerImages.append(image!);
                            } else {
                                //self?.tickerImages.append(UIImage(named: "circle")!);
                            }
                        } else {
                            //self?.tickerImages.append(UIImage(named: "circle")!);
                        }
                    } else {
                        //self?.tickerImages.append(UIImage(named: "circle")!);
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
        let infoVC = storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        infoVC.title = self.tickers[indexPath.row].name;
        infoVC.navigationItem.titleView = navTitleWithImageAndText(titleText: self.tickers[indexPath.row].name, imageIcon: self.tickerImages[indexPath.row]);
        self.navigationController?.pushViewController(infoVC, animated: true);
        
    }
    // MARK: - Alert view controller
    
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

   

}
