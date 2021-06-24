//
//  PortfolioVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-03.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import SwiftChart;
import SVProgressHUD;
import FirebaseAuth;

class PortfolioVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, CellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subtitleLbl: UILabel!;
    @IBOutlet weak var mainTitleLbl: UILabel!;
    @IBOutlet weak var leaderboard_btn: UIButton!
    
    private var isSubmitLogin:Bool = true;
    private var alert:UIAlertController = UIAlertController();
    private var alertButton:UIButton = UIButton();
    
    @IBOutlet weak var addCoin_btn: UIButton!
    @IBOutlet weak var welcome_lbl: UILabel!
    @IBOutlet weak var appName_lbl: UILabel!
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var multipleViews: UIView!
    @IBOutlet weak var availableFundsStatic_lbl: UILabel!
    @IBOutlet weak var availableFunds_lbl: UILabel!
    @IBOutlet weak var mainPortfolioStatic_lbl: UILabel!
    @IBOutlet weak var mainPortfolio_lbl: UILabel!
    @IBOutlet weak var mainPortTimeStamp_lbl: UILabel!
    @IBOutlet weak var mainPortPercentChange_lbl: UILabel!
    @IBOutlet weak var nameCol_btn: UIButton!
    @IBOutlet weak var priceCol_btn: UIButton!
    @IBOutlet weak var holdingCol_btn: UIButton!
    @IBOutlet weak var nameCol_img: UIImageView!
    @IBOutlet weak var priceCol_img: UIImageView!
    @IBOutlet weak var holdingCol_img: UIImageView!
    
    
    private var coins = Array<Coin>();
    
    private var tickers = Array<Coin>();
    private var viewDisappeared:Bool = false;
    
    private var isLoading:Bool = true;
    private var usingPullRefresh:Bool = false;
    private var pressedAddCoin:Bool = false;
    private var priceDifference:Double = 0.0;
    private var portPercentChange:Double = 0.0;
    private var portfolio:Double = 0.00;
    private static var counter = 0;
    private static var indexOptionName = 0;
    private static var indexOptionsPrice = 0;
    private static var indexOptionsHolding = 0;
    
    private static var runOnce:Bool = false;
    private var refreshPortfolioTimer:Timer? = nil;
    private var refreshCount:Int = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false;
        self.navigationController?.navigationBar.barTintColor = .clear;
        self.navigationController?.navigationBar.shadowImage = UIImage();
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
        
        self.tabBarController?.tabBar.isHidden = false;
        
        self.leaderboard_btn.isUserInteractionEnabled = true;
        self.addCoin_btn.isUserInteractionEnabled = true;
        
        self.viewDisappeared = false;
        if (!self.viewDisappeared && self.collectionView != nil && !self.tickers.isEmpty) { self.autoScroll(); }
        
        PortfolioVC.indexOptionName = 0;
        PortfolioVC.indexOptionsPrice = 0;
        PortfolioVC.indexOptionsHolding = 0;
        
        self.nameCol_img.image = #imageLiteral(resourceName: "normal")
        self.priceCol_img.image = #imageLiteral(resourceName: "normal");
        self.holdingCol_img.image = #imageLiteral(resourceName: "normal");
        
        self.updateCells();
        self.loadData();
        self.tableVIew.reloadData();
        if (self.refreshCount < 20) {
            self.refreshPortfolioTimer = Timer.scheduledTimer(withTimeInterval: 90, repeats: true) {
                (_) in
                self.refreshCount += 1;
                print("REFRESH COIN: \(self.refreshCount)");
                self.updateCells();
                self.loadData();
                self.tableVIew.reloadData();
            }
        }
        
        if (UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotFirstTime)) {
            NotificationManager.askPermission();
        }
        
        let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey);
        if (loadedCoins != nil) {
            if (!UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotFirstTime) && loadedCoins!.count == 1) {
                self.displayAlert(title: "Welcome!", message: "Buying and selling cryptocurrency in this app is practice.\n\n Cryptfolio is intentionally designed this way to allow you to learn how to trade cryptocurrencies without the risks of real trading.\n\n The funds in your account are practice funds but the rest of the app is real-time updated information.", submitTitle: "Continue");
                UserDefaults.standard.set(true, forKey: UserDefaultKeys.isNotFirstTime);
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false;
        self.tabBarController?.tabBar.isHidden = false;
        
        //self.glowAffect(view: self.leaderboard_btn, color: .orange);
        
        self.availableFunds_lbl.font = UIFont(name: "PingFangHK-Medium", size: 25.0);
        self.availableFunds_lbl.textColor = .white;
        
        self.mainPortfolio_lbl.font = UIFont(name: "PingFangHK-Medium", size: 25.0);
        self.mainPortfolio_lbl.textColor = .white;
        
        // setup collectionView
        self.getTickerData();
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsHorizontalScrollIndicator = false;
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.minimumLineSpacing = 8;
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout;
        
        
        // setup tableView
        self.tableVIew.delegate = self;
        self.tableVIew.dataSource = self;
        self.tableVIew.estimatedRowHeight = 46;
        self.tableVIew.refreshControl = UIRefreshControl();
        self.tableVIew.refreshControl!.attributedTitle = NSAttributedString(string: "");
        self.tableVIew.refreshControl!.addTarget(self, action: #selector(self.reloadData), for: .valueChanged);
        
        self.navigationItem.titleView = self.navTitleWithImageAndText(titleText: "ryptfolio", imageIcon: #imageLiteral(resourceName: "appLogo"));
        
        // assign some properties
        self.appName_lbl.textColor = .systemOrange;
        self.appName_lbl.attributedText = self.attachImageToStringTitle(text: "ryptfolio", image: #imageLiteral(resourceName: "appLogo"), color: .systemOrange, bounds: CGRect(x: 8.0, y: -10.0, width: 50, height: 50));
        self.availableFunds_lbl.adjustsFontSizeToFitWidth = true;
        self.mainPortfolio_lbl.adjustsFontSizeToFitWidth = true;
        self.mainPortPercentChange_lbl.adjustsFontSizeToFitWidth = true;
        
        PortfolioVC.indexOptionName = 0;
        PortfolioVC.indexOptionsPrice = 0;
        PortfolioVC.indexOptionsHolding = 0;
        
        self.nameCol_img.image = #imageLiteral(resourceName: "normal");
        self.priceCol_img.image = #imageLiteral(resourceName: "normal");
        self.holdingCol_img.image = #imageLiteral(resourceName: "normal");
        
        // style buttons
        let rightBarItems:[UIBarButtonItem] = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)), self.editButtonItem];
        for rightBarItem in rightBarItems {
            rightBarItem.tintColor = UIColor.orange;
        }
        let leftBarItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(goToHoldingsVC));
        leftBarItem.tintColor = .orange;
        self.navigationController?.navigationBar.tintColor = UIColor.orange;
        self.navigationItem.rightBarButtonItems = rightBarItems;
        self.navigationItem.leftBarButtonItem = leftBarItem;
        
        self.availableFunds_lbl.isUserInteractionEnabled = true;
        let availFundsTap = UITapGestureRecognizer(target: self, action: #selector(availFundsTapped));
        self.availableFunds_lbl.addGestureRecognizer(availFundsTap);
        
        self.mainPortPercentChange_lbl.isUserInteractionEnabled = true;
        let mainPortPercentTap = UITapGestureRecognizer(target: self, action: #selector(mainPortPercentTapped));
        self.mainPortPercentChange_lbl.addGestureRecognizer(mainPortPercentTap);

        self.subtitleLbl.text = self.getNewCurrentDate();
        
        // Animations
        self.autoScroll();
        self.animateCollectionViewAndTitles();
        self.animateStartScreen();
        
        
    }
    
    @objc private func reloadData() -> Void {
        self.usingPullRefresh = true;
        self.updateCells();
        self.loadData();
        self.tableVIew.reloadData();
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableVIew.refreshControl!.endRefreshing();
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46;
    }
    
    func navTitleWithImageAndText(titleText: String, imageIcon: UIImage) -> UIView {
        
        // Creates a new UIView
        let titleView = UIView();
        
        // Creates a new text label
        let label = UILabel();
        label.text = titleText;
        label.sizeToFit();
        label.center = titleView.center;
        label.textColor = .systemOrange;
        label.textAlignment = NSTextAlignment.center;
        
        // Creates the image view
        let image = UIImageView();
        image.image = imageIcon;
        
        // Maintains the image's aspect ratio:
        let imageAspect = image.image!.size.width / image.image!.size.height;
        // Sets the image frame so that it's immediately before the text:
        let imageX = (label.frame.origin.x - label.frame.size.height * imageAspect - 10) + 5.0;
        let imageY = label.frame.origin.y - 7.0;
        
        let imageWidth = (label.frame.size.height * imageAspect) * 1.5;
        let imageHeight = (label.frame.size.height * 1.5);
        
        image.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight);
        
        image.contentMode = UIView.ContentMode.scaleAspectFit;
        
        // Adds both the label and image view to the titleView
        titleView.addSubview(label);
        titleView.addSubview(image);
        
        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit();
        
        return titleView;
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewDisappeared = true;
        self.refreshPortfolioTimer!.invalidate();
        self.refreshPortfolioTimer = nil;
    }
    
    // MARK: - CollecitonView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tickers.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TickerScreenCell;
        cell.symbolLbl.adjustsFontSizeToFitWidth = true;
        cell.percentChangeLbl.adjustsFontSizeToFitWidth = true;
        cell.symbolLbl.text = self.tickers[indexPath.item].ticker.symbol.uppercased();
        
        if (String(self.tickers[indexPath.item].ticker.changePrecent24H).first! == "-") {
            cell.percentChangeLbl.attributedText = self.attachImageToString(text: "\(String(format: "%.2f", self.tickers[indexPath.item].ticker.changePrecent24H))%", image: #imageLiteral(resourceName: "sortDownArrow"));
            cell.percentChangeLbl.textColor = ChartColors.redColor();
        } else {
            cell.percentChangeLbl.attributedText = self.attachImageToString(text: "+\(String(format: "%.2f", self.tickers[indexPath.item].ticker.changePrecent24H))%", image: #imageLiteral(resourceName: "sortUpArrow"));
            cell.percentChangeLbl.textColor = ChartColors.greenColor();
        }
        
        return cell;
    }
            
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        infoVC.coin = self.tickers[indexPath.item];
        self.navigationController?.pushViewController(infoVC, animated: true);
    }
    
    
    private func autoScroll () {
        if (self.viewDisappeared) {
            return;
        }
        var co = self.collectionView.contentOffset.x;
        var no = co + 0.5;
        if (no >= 3000) {
            self.collectionView.contentOffset.x = -350.0;
            co = self.collectionView.contentOffset.x;
            no = co + 0.5;
        }
        UIView.animate(withDuration: 0.001, delay: 0, options: .allowUserInteraction, animations: { [weak self]() -> Void in
            self?.collectionView.contentOffset = CGPoint(x: no, y: 0);
        }) { [weak self] (finished) -> Void in
            self?.autoScroll();
        }
    }
    
    private func animateCollectionViewAndTitles() {
        self.collectionView.alpha = 0.0;
        //self.mainTitleLbl.alpha = 0.0;
        self.subtitleLbl.alpha = 0.0;
        self.navigationItem.titleView?.alpha = 0.0;
        UIView.animate(withDuration: 6, delay: 0, options: .allowUserInteraction, animations: { self.collectionView.alpha = 1;  }, completion: nil)
        UIView.animate(withDuration: 3, delay: 0, options: .allowUserInteraction, animations: { self.subtitleLbl.alpha = 1; /*self.mainTitleLbl.alpha = 1;*/ }, completion: nil)
        UIView.animate(withDuration: 7, delay: 0, options: .curveEaseIn, animations: { self.navigationItem.titleView?.alpha = 1 }, completion: nil)
    }
    
    private func animateStartScreen() {
        self.welcome_lbl.alpha = 0.0;
        self.appName_lbl.alpha = 0.0;
        self.addCoin_btn.alpha = 0.0;
        UIView.animate(withDuration: 8, delay: 0, options: .allowUserInteraction, animations: { self.addCoin_btn.alpha = 1; }, completion: nil)
        UIView.animate(withDuration: 3, delay: 0, options: .allowUserInteraction, animations: { self.welcome_lbl.alpha = 1; }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction, animations: { self.appName_lbl.alpha = 1; }, completion: nil)
    }
    
    private func attachImageToString(text:String, image:UIImage) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0.5, y: -0.3, width: 8, height: 8)
        let masterStirng = NSMutableAttributedString(string: "")
        let percentString = NSMutableAttributedString(string: text);
        let imageAttachment = NSAttributedString(attachment: attachment)
        masterStirng.append(percentString)
        masterStirng.append(imageAttachment)
        return masterStirng;
    }
    
    private func attachImageToStringNew(text:String, image:UIImage) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 1, y: -1.5, width: 12, height: 12)
        let masterStirng = NSMutableAttributedString(string: "")
        let percentString = NSMutableAttributedString(string: text);
        let imageAttachment = NSAttributedString(attachment: attachment)
        masterStirng.append(percentString)
        masterStirng.append(imageAttachment)
        return masterStirng;
    }
    
    private func attachImageToString(text:String, image:UIImage, color:UIColor, bounds:CGRect) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let tempImage = image.withTintColor(color);
        attachment.image = tempImage;
        attachment.bounds = bounds;
        let masterStirng = NSMutableAttributedString(string: "")
        let percentString = NSMutableAttributedString(string: text);
        let imageAttachment = NSAttributedString(attachment: attachment)
        masterStirng.append(percentString)
        masterStirng.append(imageAttachment)
        return masterStirng;
    }
    
    private func attachImageToStringTitle(text:String, image:UIImage, color:UIColor, bounds:CGRect) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let tempImage = image.withTintColor(color);
        attachment.image = tempImage;
        attachment.bounds = bounds;
        let masterStirng = NSMutableAttributedString(string: "")
        let percentString = NSMutableAttributedString(string: text);
        let imageAttachment = NSAttributedString(attachment: attachment)
        masterStirng.append(imageAttachment)
        masterStirng.append(percentString)
        return masterStirng;
    }
    
    private func attachImageToStringTitle(image:UIImage, color:UIColor, bounds:CGRect) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let tempImage = image.withTintColor(color);
        attachment.image = tempImage;
        attachment.bounds = bounds;
        let masterStirng = NSMutableAttributedString(string: "")
        let imageAttachment = NSAttributedString(attachment: attachment)
        masterStirng.append(imageAttachment)
        return masterStirng;
    }
    
    private func getNewCurrentDate() -> String {
        let date = Date(timeIntervalSince1970: Double(Date().timeIntervalSince1970))
        let dateFormatter = DateFormatter();
        dateFormatter.timeStyle = DateFormatter.Style.medium;
        dateFormatter.dateStyle = DateFormatter.Style.medium;
        dateFormatter.timeZone = .current;
        dateFormatter.dateFormat = "EEEE, MMMM d";
        return dateFormatter.string(from: date);
   }
    
    private func getNewCurrentDate(format:String) -> String {
        let date = Date(timeIntervalSince1970: Double(Date().timeIntervalSince1970))
        let dateFormatter = DateFormatter();
        dateFormatter.timeStyle = DateFormatter.Style.medium;
        dateFormatter.dateStyle = DateFormatter.Style.medium;
        dateFormatter.timeZone = .current;
        dateFormatter.dateFormat = format;
        return dateFormatter.string(from: date);
    }
       
    private func getTickerData() -> Void {
        CryptoData.getCryptoData { [weak self] (tickerList, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                for ticker in tickerList! {
                    if let imageUI = UIImage(named: "Images/" + "\(ticker.symbol.lowercased())" + ".png") {
                        self?.tickers.append(Coin(ticker: ticker, image: Image(withImage: imageUI)));
                        self?.collectionView.reloadData();
                    }
                }
            }
        }
    }
    
    public func updateCells() -> Void {
//        if (!self.isLoading) {
//            self.isLoading = true;
//        }
        if (UserDefaults.standard.bool(forKey: UserDefaultKeys.loginPressed)) {
            print("PRESSED LOGIN AND NOW DATA IS BEING RETRIEVED FROM THE DATABASE");
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.loginPressed);
            DatabaseManager.getUsername(email: FirebaseAuth.Auth.auth().currentUser!.email!) { (username) in
                if (username != "NA") {
                    DatabaseManager.getObjects(username: username, type: [Holding].self, typeName: "holdings") { [weak self] (object, error) in
                        if let error = error { print(error.localizedDescription); } else {
                            guard let holdings = object as? [Holding] else {
                                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.mainPortChange);
                                self?.getCoinDataFromDisk();
                                return;
                            }
                            print("The username: \(username)");
                            if (!holdings.isEmpty) {
                                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinArrayKey);
                                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.holdingsKey);
                                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinKey);
                                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.mainPortChange);
                                DataStorageHandler.saveObject(type: holdings, forKey: UserDefaultKeys.holdingsKey);
                                var coins = Array<Coin>();
                                let coin = Coin(ticker: holdings[0].ticker, image: Image(withImage: UIImage(named: "Images/" + "\(holdings[0].ticker.symbol.lowercased())" + ".png")!));
                                DataStorageHandler.saveObject(type: coin, forKey: UserDefaultKeys.coinKey);
                                coins.append(coin);
                                DataStorageHandler.saveObject(type: coins, forKey: UserDefaultKeys.coinArrayKey);
                                var sum:Double = holdings[0].estCost;
                                if (holdings.count > 1) {
                                    for i in 1...holdings.count - 1 {
                                        let coin = Coin(ticker: holdings[i].ticker, image: Image(withImage: UIImage(named: "Images/" + "\(holdings[i].ticker.symbol.lowercased())" + ".png")!));
                                        DataStorageHandler.saveObject(type: coin, forKey: UserDefaultKeys.coinKey);
                                        var loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey)!;
                                        loadedCoins.append(coin);
                                        DataStorageHandler.saveObject(type: loadedCoins, forKey: UserDefaultKeys.coinArrayKey);
                                        sum += holdings[i].estCost;
                                    }
                                }
                                UserDefaults.standard.set(UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey) - sum, forKey: UserDefaultKeys.availableFundsKey);
                                UserDefaults.standard.set(sum, forKey: UserDefaultKeys.mainPortfolioKey);
                                //self?.availableFunds_lbl.text = "$\(String(format: "%.2f", UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey)))";
                                self?.availableFunds_lbl.text = CryptoData.convertToMoney(price: String(format: "%.2f", UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey)));
                                self!.coins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey)!;
                                self?.loadData();
                                self?.tableVIew.reloadData();
                                // update the current coinList;
                                CryptoData.getCryptoData { [weak self] (tickerList, error) in
                                    if let error = error { print(error.localizedDescription); return; }
                                    guard let tickerList = tickerList else { return; }
                                    for coin in self!.coins {
                                        if let selectedTicker:Ticker = CryptoData.findTickerWithinList(tickerList: tickerList, otherTicker: coin.ticker) {
                                            coin.image = Image(withImage: UIImage(named: "Images/" + "\(selectedTicker.symbol.lowercased())" + ".png")!);
                                            coin.ticker = selectedTicker;
                                            self?.isLoading = false;
                                            self?.tableVIew.reloadData();
                                            self?.writeCoinArray();
                                        } else {
                                            CryptoData.getCryptoID(coinSymbol: coin.ticker.symbol.lowercased()) { (uuid, error) in
                                                if let error = error { print(error.localizedDescription); return; }
                                                CryptoData.getCoinData(id: uuid!) { (ticker, error) in
                                                    if let ticker = ticker {
                                                        coin.image = Image(withImage: UIImage(named: "Images/" + "\(ticker.symbol.lowercased())" + ".png")!);
                                                        coin.ticker = ticker;
                                                    }
                                                    self?.tableVIew.reloadData();
                                                    self?.writeCoinArray();
                                                }
                                            }
                                            self?.isLoading = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            self.getCoinDataFromDisk();
        }
    }
    
    private func getCoinDataFromDisk() -> Void {
        // get current coins in watchList;
        if let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey) {
            self.coins = loadedCoins;
        } else {
            self.coins = Array<Coin>();
        }
        if let loadedCoin = DataStorageHandler.loadObject(type: Coin.self, forKey: UserDefaultKeys.coinKey) {
            if (!self.coins.contains(where: { (coin) -> Bool in
                return coin.ticker.name == loadedCoin.ticker.name;
            })) {
                self.coins.append(loadedCoin);
            }
        }
        writeCoinArray();
        self.tableVIew.reloadData();
        // update the current coinList;
        CryptoData.getCryptoData { [weak self] (tickerList, error) in
            if let error = error { print(error.localizedDescription); return; }
            guard let tickerList = tickerList else { return; }
            for coin in self!.coins {
                if let selectedTicker:Ticker = CryptoData.findTickerWithinList(tickerList: tickerList, otherTicker: coin.ticker) {
                    coin.image = Image(withImage: UIImage(named: "Images/" + "\(selectedTicker.symbol.lowercased())" + ".png")!);
                    coin.ticker = selectedTicker;
                    self?.isLoading = false;
                    self?.tableVIew.reloadData();
                    self?.writeCoinArray();
                } else {
                    CryptoData.getCryptoID(coinSymbol: coin.ticker.symbol.lowercased()) { (uuid, error) in
                        if let error = error { print(error.localizedDescription); return; }
                        CryptoData.getCoinData(id: uuid!) { (ticker, error) in
                            if let ticker = ticker {
                                coin.image = Image(withImage: UIImage(named: "Images/" + "\(ticker.symbol.lowercased())" + ".png")!);
                                coin.ticker = ticker;
                            }
                            self?.tableVIew.reloadData();
                            self?.writeCoinArray();
                        }
                    }
                    self?.isLoading = false;
                }
            }
        }
    }
    
    private func updateMainPortPrice(priceChange:Double, updatedMainPort:Double) -> Void {
        let attributedText = NSMutableAttributedString(string: CryptoData.convertToMoney(price: String(format: "%.2f", updatedMainPort)));
        UserDefaults.standard.set(updatedMainPort, forKey: UserDefaultKeys.mainPortfolioKey);
        if (priceChange > 0) {
            if (String(format: "%.2f", priceChange) != "0.00") {
                var price = CryptoData.convertToMoney(price: String(format: "%.2f", priceChange));
                price.remove(at: price.startIndex);
                attributedText.append(NSAttributedString(string: "  +\(price)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.green, NSAttributedString.Key.baselineOffset : 1]));
                attributedText.append(self.attachImageToStringTitle(image: #imageLiteral(resourceName: "sortUpArrow"), color: .green, bounds: CGRect(x: 1, y: -0.5, width: 12, height: 12)));
            }
        } else if (priceChange < 0) {
            if (String(format: "%.2f", priceChange) != "-0.00") {
                var price = CryptoData.convertToMoney(price: String(format: "%.2f", priceChange));
                price.remove(at: price.startIndex);
                attributedText.append(NSAttributedString(string: "  \(price)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.baselineOffset : 1]));
                attributedText.append(self.attachImageToStringTitle(image: #imageLiteral(resourceName: "sortDownArrow"), color: .red, bounds: CGRect(x: 1, y: -0.5, width: 12, height: 12)));
            }
        }
        self.mainPortfolio_lbl.attributedText = attributedText;
    }
    
    public func loadData() -> Void {
        let currentAvailFunds = UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey);
        //self.availableFunds_lbl.text = "$\(String(format: "%.2f", currentAvailFunds))"
        self.availableFunds_lbl.text = CryptoData.convertToMoney(price: String(format: "%.2f", currentAvailFunds));
        
        guard var loadedHolding = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) else {
            self.portfolio = 0.00;
            self.priceDifference = (currentAvailFunds) - 10000;
            self.portPercentChange = (self.priceDifference / 10000);
            self.mainPortPercentChange_lbl.textColor = String(self.portPercentChange).first == "-" && !self.portPercentChange.isZero ? ChartColors.redColor() : ChartColors.greenColor();
            self.mainPortPercentChange_lbl.attributedText = String(self.portPercentChange).first == "-" && !(self.portPercentChange.isZero) ? self.attachImageToStringNew(text: "\(String(format: "%.2f", self.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortDownArrow")) : self.attachImageToStringNew(text: "+\(String(format: "%.2f", self.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortUpArrow"));
            self.mainPortfolio_lbl.text = "$0.00";
            return;
        }
        var updatedMainPortfolio:Double = 0.0;
        var counter:Int = 0;
        var counterInner = 0;
        loadedHolding = loadedHolding.filter({ (holding) -> Bool in
            return holding.amountOfCoin > 0;
        })
        if (loadedHolding.isEmpty) {
            self.portfolio = 0.00;
            self.priceDifference = (updatedMainPortfolio + currentAvailFunds) - 10000;
            self.portPercentChange = (self.priceDifference / 10000);
            self.mainPortPercentChange_lbl.textColor = String(self.portPercentChange).first == "-" && !self.portPercentChange.isZero ? ChartColors.redColor() : ChartColors.greenColor();
            self.mainPortPercentChange_lbl.attributedText = String(self.portPercentChange).first == "-" && !(self.portPercentChange.isZero) ? self.attachImageToStringNew(text: "\(String(format: "%.2f", self.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortDownArrow")) : self.attachImageToStringNew(text: "+\(String(format: "%.2f", self.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortUpArrow"));
            self.mainPortfolio_lbl.text = "$0.00";
            return;
        }
        
        CryptoData.getCryptoData { [weak self] (tickerList, error) in
            if let error = error { print(error.localizedDescription); return; }
            guard let tickerList = tickerList else { self?.updateMainPortPrice(priceChange: 0.00, updatedMainPort: UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortfolioKey)); return; }
            for holding in loadedHolding {
                if let selectedTicker:Ticker = CryptoData.findTickerWithinList(tickerList: tickerList, otherTicker: holding.ticker) {
                    counter += 1;
                    holding.estCost = holding.amountOfCoin * selectedTicker.price;
                    updatedMainPortfolio += holding.estCost;
                    self?.priceDifference = (updatedMainPortfolio + currentAvailFunds) - 10000;
                    self?.portPercentChange = (self!.priceDifference / 10000);
                    
                    if (counter == loadedHolding.count) {
                        self?.portfolio = updatedMainPortfolio;
                        let mainPortChange = UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange);
                        if (mainPortChange != 0.0) {
                            if (!(updatedMainPortfolio + currentAvailFunds).isLessThanOrEqualTo(mainPortChange)) {
                                let priceChange = ((updatedMainPortfolio + currentAvailFunds) - mainPortChange) - UserDefaults.standard.double(forKey: UserDefaultKeys.cumulativeAdMoney);
                                self?.updateMainPortPrice(priceChange: priceChange, updatedMainPort: updatedMainPortfolio);
                                UserDefaults.standard.set((updatedMainPortfolio + currentAvailFunds), forKey: UserDefaultKeys.mainPortChange);
                                UserDefaults.standard.set(0.00, forKey: UserDefaultKeys.cumulativeAdMoney);
                                self?.retreiveUsernameAndUploadHoldings();
                            } else if ((updatedMainPortfolio + currentAvailFunds).isLess(than: mainPortChange)) {
                                let priceChange = ((updatedMainPortfolio + currentAvailFunds) - mainPortChange) - UserDefaults.standard.double(forKey: UserDefaultKeys.cumulativeAdMoney);
                                self?.updateMainPortPrice(priceChange: priceChange, updatedMainPort: updatedMainPortfolio);
                                UserDefaults.standard.set((updatedMainPortfolio + currentAvailFunds), forKey: UserDefaultKeys.mainPortChange);
                                UserDefaults.standard.set(0.00, forKey: UserDefaultKeys.cumulativeAdMoney);
                                self?.retreiveUsernameAndUploadHoldings();
                            } else {
                                self?.mainPortfolio_lbl.text = CryptoData.convertToMoney(price: String(format: "%.2f", updatedMainPortfolio));
                                self?.retreiveUsernameAndUploadHoldings();
                            }
                        } else {
                            print("WAS 0, adding to userDefaults");
                            UserDefaults.standard.set((updatedMainPortfolio + currentAvailFunds), forKey: UserDefaultKeys.mainPortChange);
                            self?.mainPortfolio_lbl.text = CryptoData.convertToMoney(price: String(format: "%.2f", updatedMainPortfolio));
                            self?.retreiveUsernameAndUploadHoldings();
                        }
                    }
                    
                    self?.mainPortPercentChange_lbl.isHidden = false;
                    self?.mainPortTimeStamp_lbl.isHidden = false;
                    
                    self?.mainPortPercentChange_lbl.textColor = String(self!.portPercentChange).first == "-" && !self!.portPercentChange.isZero ? ChartColors.redColor() : ChartColors.greenColor();
                    self?.mainPortPercentChange_lbl.attributedText = String(self!.portPercentChange).first == "-" && !(self!.portPercentChange.isZero) ? self?.attachImageToStringNew(text: "\(String(format: "%.2f", self!.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortDownArrow")) : self?.attachImageToStringNew(text: "+\(String(format: "%.2f", self!.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortUpArrow"));
                    
                } else {
                    CryptoData.getCryptoID(coinSymbol: holding.ticker.symbol.lowercased()) { (uuid, error) in
                        if let error = error { print(error.localizedDescription); return; }
                        CryptoData.getCoinData(id: uuid!) { (ticker, error) in
                            guard let ticker = ticker else { self?.updateMainPortPrice(priceChange: 0.00, updatedMainPort: UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortfolioKey)); return; }
                            counterInner += 1;
                            holding.estCost = holding.amountOfCoin * ticker.price;
                            updatedMainPortfolio += holding.estCost;

                            self?.priceDifference = (updatedMainPortfolio + currentAvailFunds) - 10000;
                            self?.portPercentChange = (self!.priceDifference / 10000);

                            if (counter == loadedHolding.count - counterInner) {
                                self?.portfolio = updatedMainPortfolio;
                                let mainPortChange = UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange);
                                if (mainPortChange != 0.0) {
                                    if (!(updatedMainPortfolio + currentAvailFunds).isLessThanOrEqualTo(mainPortChange)) {
                                        let priceChange = ((updatedMainPortfolio + currentAvailFunds) - mainPortChange) - UserDefaults.standard.double(forKey: UserDefaultKeys.cumulativeAdMoney);
                                        self?.updateMainPortPrice(priceChange: priceChange, updatedMainPort: updatedMainPortfolio);
                                        UserDefaults.standard.set((updatedMainPortfolio + currentAvailFunds), forKey: UserDefaultKeys.mainPortChange);
                                        UserDefaults.standard.set(0.00, forKey: UserDefaultKeys.cumulativeAdMoney);
                                        self?.retreiveUsernameAndUploadHoldings();
                                    } else if ((updatedMainPortfolio + currentAvailFunds).isLess(than: mainPortChange)) {
                                        let priceChange = ((updatedMainPortfolio + currentAvailFunds) - mainPortChange) - UserDefaults.standard.double(forKey: UserDefaultKeys.cumulativeAdMoney);
                                        self?.updateMainPortPrice(priceChange: priceChange, updatedMainPort: updatedMainPortfolio);
                                        UserDefaults.standard.set((updatedMainPortfolio + currentAvailFunds), forKey: UserDefaultKeys.mainPortChange);
                                        UserDefaults.standard.set(0.00, forKey: UserDefaultKeys.cumulativeAdMoney);
                                        self?.retreiveUsernameAndUploadHoldings();
                                    } else {
                                        self?.mainPortfolio_lbl.text = CryptoData.convertToMoney(price: String(format: "%.2f", updatedMainPortfolio));
                                        self?.retreiveUsernameAndUploadHoldings();
                                    }
                                } else {
                                    print("WAS 0, adding to userDefaults");
                                    UserDefaults.standard.set((updatedMainPortfolio + currentAvailFunds), forKey: UserDefaultKeys.mainPortChange);
                                    self?.mainPortfolio_lbl.text = CryptoData.convertToMoney(price: String(format: "%.2f", updatedMainPortfolio));
                                    self?.retreiveUsernameAndUploadHoldings();
                                }
                            }

                            self?.mainPortPercentChange_lbl.isHidden = false;
                            self?.mainPortTimeStamp_lbl.isHidden = false;

                            self?.mainPortPercentChange_lbl.textColor = String(self!.portPercentChange).first == "-" && !self!.portPercentChange.isZero ? ChartColors.redColor() : ChartColors.greenColor();
                            self?.mainPortPercentChange_lbl.attributedText = String(self!.portPercentChange).first == "-" && !(self!.portPercentChange.isZero) ? self?.attachImageToStringNew(text: "\(String(format: "%.2f", self!.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortDownArrow")) : self?.attachImageToStringNew(text: "+\(String(format: "%.2f", self!.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortUpArrow"));
                        }
                    }
                }
            }
        }
        
    }
    
    public func saveUserData() -> Void {
        var change:String = "";
        if (String(self.portPercentChange).first != "-") {
            change = "+\(String(format: "%.2f", self.portPercentChange * 100))%";
        } else {
            change = "\(String(format: "%.2f", self.portPercentChange * 100))%";
        }
        DatabaseManager.writeHighscoreAndHoldings(change: change) { (error) in
            if let error = error { print("CANNOT UPLOAD HIGHSCORE AND HOLDINGS: \(error.localizedDescription)"); } else {
                print("Success!");
            }
        }
    }
    
    private func retreiveUsernameAndUploadHoldings() -> Void {
        if (!UserDefaults.standard.bool(forKey: UserDefaultKeys.prevSignedInUser)) {
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.prevSignedInUser);
            if (FirebaseAuth.Auth.auth().currentUser != nil) {
                DatabaseManager.getUsername(email: FirebaseAuth.Auth.auth().currentUser!.email!) { [weak self] (username) in
                    UserDefaults.standard.set(username, forKey: UserDefaultKeys.currentUsername);
                    self?.saveUserData();
                }
            } else { DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { self.saveUserData(); } }
        } else { DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { self.saveUserData(); } }
    }
    
    
    @objc private func availFundsTapped() -> Void {
        print("Avail Tapped");
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.investingTipsKey);
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.foundAllTips);
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.randomIndex);
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.mainPortfolioGraph);
//        if let currentUsername = UserDefaults.standard.string(forKey: UserDefaultKeys.currentUsername) {
//            self.displayAlert(title: "Current Username:\n", message: "\(currentUsername)")
//        } else {
//            self.displayAlert(title: "Current Username:\n", message: "NO USER LOGGED IN");
//        }
    }
    
    @IBAction func nameColButtonPressed(_ sender: Any) {
        self.vibrate(style: .light);
        if (self.isLoading) { return; }
        self.toggleNameFilter();
        self.tableVIew.reloadData();
    }
    @IBAction func priceColButtonPressed(_ sender: Any) {
        self.vibrate(style: .light);
        if (self.isLoading) { return; }
        self.togglePriceFilter();
        self.tableVIew.reloadData();
    }
    @IBAction func holdingColPressed(_ sender: Any) {
        self.vibrate(style: .light);
        if (self.isLoading) { return; }
        self.toggleHoldingFilter();
        self.tableVIew.reloadData();
    }
    
    private func toggleNameFilter() {
        PortfolioVC.indexOptionName += 1;
        if (PortfolioVC.indexOptionName % 4 == 0) { PortfolioVC.indexOptionName = 1; }
        let options = [1, 2, 3, 4];
        
        if (options[PortfolioVC.indexOptionName] == 2) {
            self.nameCol_img.image = #imageLiteral(resourceName: "sortUpArrow");
            self.coins = self.coins.sorted(by: { (coin, nextCoin) -> Bool in
                return coin.ticker.name < nextCoin.ticker.name;
            });
        } else if (options[PortfolioVC.indexOptionName] == 3) {
            self.nameCol_img.image = #imageLiteral(resourceName: "sortDownArrow");
            self.coins = self.coins.sorted(by: { (coin, nextCoin) -> Bool in
                return coin.ticker.name > nextCoin.ticker.name;
            });
        } else if (options[PortfolioVC.indexOptionName] == 4) {
            self.nameCol_img.image = #imageLiteral(resourceName: "normal");
            if let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey) {
                self.coins = loadedCoins;
            }
        }
    
    }
    
    private func togglePriceFilter() {
        PortfolioVC.indexOptionsPrice += 1;
        if (PortfolioVC.indexOptionsPrice % 4 == 0) { PortfolioVC.indexOptionsPrice = 1; }
        let options = [1, 2, 3, 4];
        
        if (options[PortfolioVC.indexOptionsPrice] == 2) {
            self.priceCol_img.image = #imageLiteral(resourceName: "sortUpArrow");
            self.coins = self.coins.sorted(by: { (coin, nextCoin) -> Bool in
                return coin.ticker.price > nextCoin.ticker.price;
            });
        } else if (options[PortfolioVC.indexOptionsPrice] == 3) {
            self.priceCol_img.image = #imageLiteral(resourceName: "sortDownArrow");
            self.coins = self.coins.sorted(by: { (coin, nextCoin) -> Bool in
                return coin.ticker.price < nextCoin.ticker.price;
            });
        } else if (options[PortfolioVC.indexOptionsPrice] == 4) {
            self.priceCol_img.image = #imageLiteral(resourceName: "normal");
            if let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey) {
                self.coins = loadedCoins;
            }
        }
    }
    
    private func toggleHoldingFilter() {
        PortfolioVC.indexOptionsHolding += 1;
        if (PortfolioVC.indexOptionsHolding % 4 == 0) { PortfolioVC.indexOptionsHolding = 1; }
        let options = [1, 2, 3, 4];
        
        if(options[PortfolioVC.indexOptionsHolding] == 2) {
            self.holdingCol_img.image = #imageLiteral(resourceName: "sortUpArrow")
            self.sortHoldingUp();
        } else if (options[PortfolioVC.indexOptionsHolding] == 3) {
            self.holdingCol_img.image = #imageLiteral(resourceName: "sortDownArrow")
            self.sortHoldingDown();
        } else if (options[PortfolioVC.indexOptionsHolding] == 4) {
            self.holdingCol_img.image = #imageLiteral(resourceName: "normal");
            if let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey) {
                self.coins = loadedCoins;
            }
        }
    }
    
    private func sortHoldingUp() {
        var index = 0;
        var removedCoins = Array<Coin>();
        if var loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            loadedHoldings = loadedHoldings.sorted(by: { (holding, nextHolding) -> Bool in
                return holding.estCost > nextHolding.estCost;
            })
            for holding in loadedHoldings {
                self.coins.removeAll { (coin) -> Bool in
                    if (holding.ticker.name == coin.ticker.name) {
                        removedCoins.append(coin);
                    }
                    return holding.ticker.name == coin.ticker.name;
                }
            }
            for removedCoin in removedCoins {
                self.coins.insert(removedCoin, at: index);
                index += 1;
            }
        }
    }
    
    private func sortHoldingDown() {
        var removedCoins = Array<Coin>();
        if var loadedHolding = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            loadedHolding = loadedHolding.sorted(by: { (holding, nextHolding) -> Bool in
                return holding.estCost < nextHolding.estCost;
            })
            for holding in loadedHolding {
                self.coins.removeAll { (coin) -> Bool in
                    if (holding.ticker.name == coin.ticker.name) {
                        removedCoins.append(coin);
                    }
                    return holding.ticker.name == coin.ticker.name;
                }
            }
            for removedCoin in removedCoins {
                self.coins.append(removedCoin);
            }
        }
    }
    
    @IBAction func leaderboardBtnTapped(_ sender: Any) {
        self.vibrate(style: .light);
        self.leaderboard_btn.isUserInteractionEnabled = false;
        self.isSubmitLogin = true;
        var highscore:Double = 0.0;
        if (UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange) != 0 && (!UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortfolioKey).isLessThanOrEqualTo(0.0) || self.mainPortfolio_lbl.text != "$0.00")) {
            highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange);
        } else {
            highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey);
        }
        
        var change:String = "";
        if (String(self.portPercentChange).first != "-") {
            change = "+\(String(format: "%.2f", self.portPercentChange * 100))%";
        } else {
            change = "\(String(format: "%.2f", self.portPercentChange * 100))%";
        }
        
        var highestHolding:String = "NA";
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            if (!loadedHoldings.isEmpty) {
                let hold = loadedHoldings.max { (holding, nextHolding) -> Bool in
                    return holding.estCost < nextHolding.estCost;
                }
                if (hold!.amountOfCoin > 0) {
                    highestHolding = hold!.ticker.symbol.uppercased();
                }
            }
        }

        // MIGHT CHANGE TO getIDToken INSTEAD FOR BETTER SECURITY
        if (FirebaseAuth.Auth.auth().currentUser != nil) {
            DatabaseManager.findUser(email: FirebaseAuth.Auth.auth().currentUser!.email!, highscore: highscore, change: change, numberOfCoin: self.getNumberOfOwnedCoin(), highestHolding: highestHolding, viewController: self, isPortVC: true, isLogin: false);
        } else {
            if let signUpVC = self.storyboard?.instantiateViewController(identifier: "signUpVC", creator: { (coder) -> SignUpVC? in
                return SignUpVC(coder: coder, highscore: highscore, change: change, numberOfOwnedCoins: self.getNumberOfOwnedCoin(), highestHolding: highestHolding);
            }) {
                signUpVC.hidesBottomBarWhenPushed = true;
                self.navigationController?.pushViewController(signUpVC, animated: true);
            } else { print("signUpBC has not been instantiated"); }
        }
    }

    @objc private func goToHoldingsVC() -> Void {
        let holdingVC = self.storyboard?.instantiateViewController(withIdentifier: "holdingVC") as! HoldingVC;
        self.navigationController?.pushViewController(holdingVC, animated: true);
    }
    
    private func changeAllCellsProperties(configure:(TickerScreenCell, Int) -> Void) -> Void {
        for i in 0...self.tickers.count - 1 {
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? TickerScreenCell {
                configure(cell, i);
            }
        }
    }
    
    @objc private func mainPortPercentTapped() -> Void {
        self.vibrate(style: .light);
        PortfolioVC.counter += 1;
        if (PortfolioVC.counter % 2 != 0) {
            self.mainPortPercentChange_lbl.attributedText = String(self.portPercentChange).first != "-" ? self.attachImageToStringNew(text: "+\(String(format: "%.2f", self.priceDifference))", image: #imageLiteral(resourceName: "sortUpArrow") ) : self.attachImageToStringNew(text: "\(String(format: "%.2f", self.priceDifference))", image: #imageLiteral(resourceName: "sortDownArrow"));
        } else {
            self.mainPortPercentChange_lbl.attributedText = String(self.portPercentChange).first != "-" ? self.attachImageToStringNew(text: "+\(String(format: "%.2f", self.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortUpArrow") ) : self.attachImageToStringNew(text: "\(String(format: "%.2f", self.portPercentChange * 100))%", image: #imageLiteral(resourceName: "sortDownArrow"));
        }
    }
    
    @objc private func addTapped() {
        let homeTBVC = self.storyboard?.instantiateViewController(withIdentifier: "homeTBVC") as! HomeTBVC;
        homeTBVC.isAdding = true;
        self.navigationController?.pushViewController(homeTBVC, animated: true);
    }
    
    private func writeCoinArray() {
        DataStorageHandler.saveObject(type: self.coins, forKey: UserDefaultKeys.coinArrayKey);
    }
    
    private func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton);
        present(alert, animated: true, completion: nil);
    }
    
    private func displayAlert(title:String, message:String, submitTitle:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: submitTitle, style: .default, handler: nil);
        alert.addAction(defaultButton);
        present(alert, animated: true, completion: nil);
    }
    
    // MARK: - Buy/Sell methods
    
    private func quickBuy(coinSet:Array<Coin>, indexPathRow:Int) -> Void {
        self.vibrate(style: .light);
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to use all your funds to buy \(self.coins[indexPathRow].ticker.symbol.uppercased())", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        let buyAction = UIAlertAction(title: "BUY", style: .default) { (action) in
            let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
            if (currentFunds != nil) {
                CryptoData.getCryptoID(coinSymbol: coinSet[indexPathRow].ticker.symbol.lowercased()) { (uuid, error) in
                    if let error = error { print(error.localizedDescription); return; }
                    CryptoData.getCoinData(id: uuid!) { [weak self] (ticker, error) in
                        if let error = error {
                            print(error.localizedDescription);
                        } else {
                            let amountCoin = currentFunds! / ticker!.price;
                            if (OrderHandler.buy(amountCost: currentFunds!, amountOfCoin: amountCoin, ticker: ticker!)) {
                                self?.loadData();
                                self?.tableVIew.reloadData();
                            } else {
                                //self.displayAlert(title: "Error", message: "Buy order unsuccessful, try again")
                            }
                        }
                    }
                }
            } else {
                self.displayAlert(title: "Sorry", message: "Insufficient funds")
            }
        }
        buyAction.titleTextColor = .green;
        alert.addAction(buyAction);
        self.present(alert, animated: true, completion: nil);
    }
    
    private func quickSell(coinSet:Array<Coin>, indexPathRow:Int) -> Void {
        self.vibrate(style: .light);
        let alert = UIAlertController(title: "Warning", message: "Are you sure want to sell all holdings of \(self.coins[indexPathRow].ticker.symbol.uppercased())", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "SELL", style: .destructive, handler: { (action) in
            var currentHoldings:Holding?
            let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey);
            for holding in loadedHoldings! {
                if (holding.ticker.name == coinSet[indexPathRow].ticker.name) {
                    currentHoldings = holding;
                    break;
                }
            }
            CryptoData.getCryptoID(coinSymbol: currentHoldings!.ticker.symbol.lowercased()) { (uuid, error) in
                if let error = error { print(error.localizedDescription); return; }
                CryptoData.getCoinData(id: uuid!) { [weak self] (ticker, error) in
                    if let error = error {
                        print(error.localizedDescription);
                    } else {
                        let amountCost = currentHoldings!.amountOfCoin * ticker!.price;
                        if (OrderHandler.sell(amountCost: amountCost, amountOfCoin: currentHoldings!.amountOfCoin, ticker: ticker!)) {
                            self?.loadData();
                            self?.tableVIew.reloadData();
                        } else {
                            self?.displayAlert(title: "Error", message: "Sell order unsucessful, try again");
                        }
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil);
    }
    
    // MARK: - TableView methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableVIew.setEditing(editing, animated: true);
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCoin = self.coins.remove(at: sourceIndexPath.row);
        self.coins.insert(movedCoin, at: destinationIndexPath.row);
        self.writeCoinArray()
        tableView.reloadData();
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.coins.count == 0) {
            if(self.isLoading) {
                self.isLoading = false;
            }
            self.hideViews(hidden: false);
            self.hideFunds(hidden: true);
            self.hideColTitleLabels(hidden: true);
            self.hideColTitleImages(hidden: true);
            styleButton(button: &self.addCoin_btn);
            self.addCoin_btn.layer.cornerRadius = 13.0;
            self.mainPortPercentChange_lbl.isHidden = true;
            self.mainPortTimeStamp_lbl.isHidden = true;
            tableView.separatorStyle = .none;
            //tableView.backgroundView = self.multipleViews;
            return 0;
        }
        if (self.isLoading) {
            if (self.coins.count == 0) {
                self.isLoading = false;
            }
            for rightBarItems in self.navigationItem.rightBarButtonItems! {
                rightBarItems.isEnabled = false;
            }
            self.hideViews(hidden: true);
            self.hideFunds(hidden: true);
            self.mainPortPercentChange_lbl.isHidden = true;
            self.mainPortTimeStamp_lbl.isHidden = true;
            self.hideColTitleLabels(hidden: true);
            self.hideColTitleImages(hidden: true);
            tableView.separatorStyle = .none;
            return 1;
        } else if (self.coins.count > 0) {
            for rightBarItems in self.navigationItem.rightBarButtonItems! {
                rightBarItems.isEnabled = true;
            }
            self.hideViews(hidden: true);
            self.hideFunds(hidden: false);
            self.hideColTitleLabels(hidden: false);
            self.hideColTitleImages(hidden: false);
            self.mainPortTimeStamp_lbl.isHidden = false;
            self.mainPortPercentChange_lbl.isHidden = false;
            tableView.separatorStyle = .none;
            return self.coins.count;
        } else {
            for rightBarItems in self.navigationItem.rightBarButtonItems! {
                rightBarItems.isEnabled = true;
            }
            self.hideViews(hidden: true);
            self.hideFunds(hidden: false);
            self.hideColTitleLabels(hidden: true);
            self.hideColTitleImages(hidden: true);
            tableView.separatorStyle = .none;
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // load holdings and check if the coin swiped on has any holdings, if so, then display quick sell, otherwise just display delete
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            self.vibrate(style: .light);
            self.coins.remove(at: indexPath.row)
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinKey);
            //UserDefaults.standard.removeObject(forKey: UserDefaultKeys.coinArrayKey);
            self.writeCoinArray();
            tableView.beginUpdates();
            tableView.deleteRows(at: [indexPath], with: .fade);
            tableView.endUpdates();
            if (self.coins.count == 0) {
                self.styleButton(button: &self.addCoin_btn);
                self.addCoin_btn.layer.cornerRadius = 10.0;
                self.hideViews(hidden: false);
                self.hideFunds(hidden: true);
                self.hideColTitleLabels(hidden: true);
                //tableView.backgroundView = self.multipleViews;
                tableView.separatorStyle = .none;
            }
            self.writeCoinArray();
            tableView.reloadData();
        }
        let quickBuyAction = UITableViewRowAction(style: .normal, title: "Quick Buy") { (rowAction, indexPath) in
            self.quickBuy(coinSet: self.coins, indexPathRow: indexPath.row);
        }
        quickBuyAction.backgroundColor = ChartColors.greenColor();
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedHoldings {
                if (holding.ticker.name == self.coins[indexPath.row].ticker.name) {
                    if (!holding.amountOfCoin.isLessThanOrEqualTo(0.0)) {
                        let quickSellAction = UITableViewRowAction(style: .destructive, title: "Quick Sell") { (rowAction, indexPath) in
                            self.quickSell(coinSet: self.coins, indexPathRow: indexPath.row);
                        }
                        return [quickSellAction, quickBuyAction];
                    } else {
                        return [deleteAction, quickBuyAction];
                    }
                }
            }
        } else {
            return [deleteAction, quickBuyAction];
        }
        return [deleteAction, quickBuyAction];
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PortfolioVCCustomCell;
        cell.delegate = self;
        if (self.isLoading) {
            if (self.traitCollection.userInterfaceStyle == .dark) { SVProgressHUD.setDefaultStyle(.dark); }
            if (!self.usingPullRefresh) { SVProgressHUD.show(withStatus: "Loading..."); }
            cell.add_btn.isHidden = true;
            cell.crypto_img.isHidden = true;
            cell.name_lbl.text = "";
            cell.price_lbl.text = "";
            cell.percentChange_lbl.text = ""
            cell.amountCost_lbl.text = "";
            cell.amountCoin_lbl.text = "";
            cell.holdingPercentChange.text = "";
        } else {
            self.displayCellData(cell: cell, coinSet: self.coins, indexPath: indexPath);
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "infoVC") as! InfoVC;
        infoVC.coin = self.coins[indexPath.row];
        self.navigationController?.pushViewController(infoVC, animated: true);
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0;
    }
    
    // MARK: - Button Methods
    
    @IBAction func pressAddCoinBtn(_ sender: Any) {
        self.vibrate(style: .light);
        NotificationManager.askPermission();
        self.addCoin_btn.isUserInteractionEnabled = false;
        let homeTBVC = self.storyboard?.instantiateViewController(withIdentifier: "homeTBVC") as! HomeTBVC;
        homeTBVC.isAdding = true;
        homeTBVC.portfolioVC = self;
        self.navigationController?.pushViewController(homeTBVC, animated: true);
        self.navigationController?.navigationBar.isHidden = false;
    }
    
    func didTap(_ cell: PortfolioVCCustomCell) {
        self.vibrate(style: .light);
        let indexPath = self.tableVIew.indexPath(for: cell);
        if let indexPath = indexPath {
            let tradeVC = self.storyboard?.instantiateViewController(withIdentifier: "tradeVC") as! TradeVC;
            tradeVC.ticker = self.coins[indexPath.row].ticker;
            tradeVC.portfolioVC = self;
            self.present(tradeVC, animated: true, completion: nil);
        }
    }
    
    
    private func styleButton(button:inout UIButton) -> Void {
        button.layer.cornerRadius = 15.0
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.backgroundColor = UIColor.orange;
    }
    
    private func styleButton(button:inout UIButton, borderColor:CGColor) -> Void {
        button.layer.cornerRadius = 12.0
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.borderWidth = 1;
        button.layer.borderColor = borderColor;
    }
    
    // MARK: - Display Cell Data
    
    private func displayCellData(cell:PortfolioVCCustomCell, coinSet:Array<Coin>, indexPath:IndexPath) -> Void {
        cell.price_lbl.adjustsFontSizeToFitWidth = true;
        cell.percentChange_lbl.adjustsFontSizeToFitWidth = true;
        cell.name_lbl.adjustsFontSizeToFitWidth = true;
        cell.amountCoin_lbl.text = "";
        cell.amountCost_lbl.text = "";
        cell.holdingPercentChange.text = "";
        if (indexPath.row >= 9) {
            cell.amountCost_lbl.text = ""
            cell.amountCoin_lbl.text = "";
            cell.holdingPercentChange.text = "";
        }
        cell.add_btn.isHidden = false;
        self.styleButton(button: &cell.add_btn, borderColor: UIColor.orange.cgColor);
        cell.crypto_img.isHidden = false;
        if (!self.usingPullRefresh) { SVProgressHUD.dismiss(); }
        // basic stuff
        cell.name_lbl.text = coinSet[indexPath.row].ticker.name;
        cell.crypto_img.image = coinSet[indexPath.row].image.getImage()!;
        
        // format price
        //let theoPriceString = String(format: "%.2f", coinSet[indexPath.row].ticker.price);
        //self.appendZero(string: &theoPriceString);
        cell.price_lbl.text = CryptoData.convertToDollar(price: coinSet[indexPath.row].ticker.price, hasSymbol: false);
        
        // format percent change
        if (String(coinSet[indexPath.row].ticker.changePrecent24H).first != "-") {
            if (self.traitCollection.userInterfaceStyle == .dark) {
                cell.percentChange_lbl.textColor = ChartColors.greenColor();
            } else {
                cell.percentChange_lbl.textColor = ChartColors.greenColor();
            }
            let theoPercentString = String(format: "%.2f", coinSet[indexPath.row].ticker.changePrecent24H);
            //self.appendZero(string: &theoPercentString);
            cell.percentChange_lbl.text = "+\(theoPercentString)%"
        } else {
            cell.percentChange_lbl.textColor = ChartColors.redColor();
            let theoPercentString = String(format: "%.2f", coinSet[indexPath.row].ticker.changePrecent24H);
            //self.appendZero(string: &theoPercentString);
            cell.percentChange_lbl.text = "\(theoPercentString)%"
        }
        
        // format holdings
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            for holding in loadedHoldings {
                if (holding.ticker.name == coinSet[indexPath.row].ticker.name) {
                    if (!holding.amountOfCoin.isLessThanOrEqualTo(0.0)) {
                        cell.add_btn.isHidden = true;
                    }
                    if (holding.amountOfCoin.isLessThanOrEqualTo(0.00)) {
                        cell.amountCost_lbl.text = "";
                        cell.amountCoin_lbl.text = "";
                        cell.holdingPercentChange.text = "";
                    } else {
                        holding.estCost = holding.amountOfCoin * coinSet[indexPath.row].ticker.price;
                        DataStorageHandler.saveObject(type: loadedHoldings, forKey: UserDefaultKeys.holdingsKey);
                        cell.amountCost_lbl.text = CryptoData.convertToMoney(price: String(format: "%.2f", holding.estCost));
                        cell.amountCoin_lbl.text = self.formatPrice(price: holding.amountOfCoin);
                        let percentage:Double = holding.estCost - (holding.amountOfCoin * holding.ticker.price);
                        cell.holdingPercentChange.attributedText = percentage >= 0 ? self.attachImageToString(text: "+\(String(format: "%.2f", percentage))", image: #imageLiteral(resourceName: "sortUpArrow"), color: ChartColors.greenColor(), bounds: CGRect(x: 1, y: -1, width: 7, height: 7)) : self.attachImageToString(text: String(format: "%.2f", percentage), image: #imageLiteral(resourceName: "sortDownArrow"), color: ChartColors.redColor(), bounds: CGRect(x: 1, y: -1, width: 7, height: 7));
                        cell.holdingPercentChange.textColor = percentage >= 0 ? ChartColors.greenColor() : ChartColors.redColor();
                        if (cell.amountCost_lbl.text == "$0.00") {
                            self.quickSell(coinSet: coinSet, indexPathRow: indexPath.row);
                            self.displayAlert(title: "Dev Message", message: "Quick Sell worked when it showed zero.");
                        }
                    }
                }
            }
        } else {
            cell.amountCost_lbl.text = "";
            cell.amountCoin_lbl.text = "";
            cell.add_btn.isHidden = false;
            self.styleButton(button: &cell.add_btn, borderColor: UIColor.orange.cgColor);
        }
        //cell.layer.cornerRadius = 10.0;
        //cell.backgroundColor = UIColor.init(red: 2/255, green: 7/255, blue: 93/255, alpha: 0.5)
    }
    
    
    
    // MARK: - Hide all views and Helper Methods
    
    private func hideViews(hidden:Bool) -> Void {
        if (!hidden) { self.viewDisappeared = true; }
        self.addCoin_btn.isHidden = hidden;
        self.welcome_lbl.isHidden = hidden;
        self.appName_lbl.isHidden = hidden;
        self.multipleViews.isHidden = hidden;
        self.animateStartScreen();
    }
    
    private func hideFunds(hidden:Bool) -> Void {
        self.availableFundsStatic_lbl.isHidden = hidden;
        self.availableFunds_lbl.isHidden = hidden;
        self.mainPortfolioStatic_lbl.isHidden = hidden;
        self.mainPortfolio_lbl.isHidden = hidden;
        self.subtitleLbl.isHidden = hidden;
        self.mainTitleLbl.isHidden = hidden;
        self.collectionView.isHidden = hidden;
        self.leaderboard_btn.isHidden = hidden;
        self.navigationItem.titleView?.isHidden = hidden;
        self.navigationController?.navigationBar.isHidden = hidden;
        self.tabBarController?.tabBar.isHidden = hidden;
    }
    
    private func hideColTitleLabels(hidden:Bool) -> Void {
        self.nameCol_btn.isHidden = hidden;
        self.priceCol_btn.isHidden = hidden;
        self.holdingCol_btn.isHidden = hidden;
    }
    
    private func hideColTitleImages(hidden:Bool) -> Void {
        self.nameCol_img.isHidden = hidden;
        self.priceCol_img.isHidden = hidden;
        self.holdingCol_img.isHidden = hidden;
    }
    
    private func getNumberOfOwnedCoin() -> Int {
        guard var loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) else { return 0; }
        loadedHoldings = loadedHoldings.filter({ (holding) -> Bool in
            return holding.amountOfCoin > 0;
        })
        return loadedHoldings.count;
    }
    
    private func getNumberOfTranscations() -> Int {
        guard let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) else { return 0; }
        var sum:Int = 0;
        for holding in loadedHoldings {
            sum += holding.amountOfCoins.count;
        }
        return sum;
    }
    
    private func glowAffect(view:UIView, color:UIColor) {
        view.layer.shadowColor  = color.cgColor;
        view.layer.shadowRadius = 4.5;
        view.layer.shadowOpacity = 0.65;
        view.layer.shadowOffset = CGSize(width: 0, height: 0);
        view.layer.masksToBounds = false;
    }
    
    private func formatPrice(price:Double) -> String {
        var priceString = String(price);
        priceString.removeFirst();
        var otherPrice = String(price)
        otherPrice.removeFirst();
        otherPrice.removeFirst();
        if (String(price).first == "0" || priceString.first == ".") {
            return "\(String(format: "%.7f", price))"
        } else if (otherPrice.first == ".") {
            return "\(String(format: "%.2f", price))"
        } else {
            return "\(String(format: "%.2f", price))"
        }
    }
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackGenerator.prepare();
        impactFeedbackGenerator.impactOccurred();
    }

}

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}

public class TickerScreenCell: UICollectionViewCell {
    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var percentChangeLbl: UILabel!
}
