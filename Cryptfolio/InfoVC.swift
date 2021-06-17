	//
//  InfoVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-02-19.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import SwiftChart;
import Alamofire;
import SafariServices;

public class CoinData {
    
    public let webImage:UIImage?
    public let title:String
    public let linkName:String
    
    init(webImage:UIImage, title:String, linkName:String) {
        self.webImage = webImage;
        self.title = title;
        self.linkName = linkName;
    }
    
}

    
class InfoVC: UIViewController, UIScrollViewDelegate, ChartDelegate , UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var crypto_img: UIImageView!
    @IBOutlet weak var name_lbl: UILabel!
    @IBOutlet weak var symbol_lbl: UILabel! 
    @IBOutlet weak var price_lbl: UILabel!
    @IBOutlet weak var change_lbl: UILabel!
    @IBOutlet weak var rank_lbl: UILabel!
    @IBOutlet weak var volume24H_lbl: UILabel!
    @IBOutlet weak var marketCap_lbl: UILabel!
    @IBOutlet weak var maxSupply_lbl: UILabel!
    @IBOutlet weak var allTimeHigh_lbl: UILabel!
    @IBOutlet weak var allTimeHighStatic_lbl: UILabel!
    @IBOutlet weak var daysRange_lbl: UILabel!
    @IBOutlet weak var daysRangeStatic_lbl: UILabel!
    @IBOutlet weak var description_view: UITextView!
    @IBOutlet weak var chartPrice_lbl: UILabel!
    @IBOutlet weak var chart_view: Chart!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var timeStamp_seg: UISegmentedControl!
    @IBOutlet weak var tableViewNews: UITableView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view6: UIView!
    @IBOutlet weak var infoTableViewYConstraint: NSLayoutConstraint!
    
    private var circleView:UIView = UIView();
    private var prevIndex:Int = 0;
    
    // Public member variables
    public var coin:Coin?;
    private var isTradingMode:Bool = false;
    
    // Private member variables
    private var coinData = Array<CoinData>();
    private var views = Array<UIView>();
    
    private var dataPoints = Array<Double>();
    private var timestamps = Array<Double>();
    private var lastContentOffset: CGFloat = 0;
    
    private var isDayOrWeekChart:Bool = true;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.barTintColor = nil;
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationController?.navigationBar.shadowImage = nil;
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default);
        CryptoData.getCryptoID(coinSymbol: coin!.ticker.symbol.lowercased()) { (uuid, error) in
            if let error = error { print(error.localizedDescription); return; }
            CryptoData.getCoinData(id: uuid!) { [weak self] (ticker, error) in
                if let error = error {
                    print(error.localizedDescription);
                } else {
                    self?.coin!.ticker = ticker!;
                    self?.updateInfoVC(ticker: (self?.coin!.ticker)!, tickerImage: (self?.coin!.image.getImage()!)!);
                    if (self!.description_view.text == "No Description Available.") {
                        self?.infoTableViewYConstraint.constant = 180.0;
                        self?.description_view.isHidden = true;
                    } else {
                        self?.infoTableViewYConstraint.constant = 225.0;
                        self?.description_view.isHidden = false;
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self;
        self.chart_view.delegate = self;
        self.tableViewNews.delegate = self;
        self.tableViewNews.dataSource = self;
        
        self.activityIndicator.hidesWhenStopped = true;
        
        self.updateRightBarItem();
        
        self.navigationController?.navigationBar.isTranslucent = true;
        updateInfoVC(ticker: self.coin!.ticker, tickerImage: self.coin!.image.getImage()!);
        self.price_lbl.font = UIFont(name: "PingFangHK-Medium", size: 20.0);
        self.price_lbl.textColor = .white;
        self.navigationItem.titleView = navTitleWithImageAndText(titleText: self.coin!.ticker.name, imageIcon: self.coin!.image.getImage()!);
        
        self.chartPrice_lbl.isHidden = true;
        self.dayChart();
        
        self.description_view.translatesAutoresizingMaskIntoConstraints = false;
        self.description_view.sizeToFit();
        self.description_view.isScrollEnabled = false;
        
        self.name_lbl.adjustsFontSizeToFitWidth = true;
        self.symbol_lbl.adjustsFontSizeToFitWidth = true;
        self.price_lbl.adjustsFontSizeToFitWidth = true;
        self.change_lbl.adjustsFontSizeToFitWidth = true;
        self.rank_lbl.adjustsFontSizeToFitWidth = true;
        self.volume24H_lbl.adjustsFontSizeToFitWidth = true;
        self.marketCap_lbl.adjustsFontSizeToFitWidth = true;
        self.maxSupply_lbl.adjustsFontSizeToFitWidth = true;
        self.allTimeHigh_lbl.adjustsFontSizeToFitWidth = true;
        self.daysRange_lbl.adjustsFontSizeToFitWidth = true;
        
    }
    
    @objc func trade() {
        self.vibrate(style: .light);
        let tradeVC = storyboard?.instantiateViewController(withIdentifier: "tradeVC") as! TradeVC;
        tradeVC.ticker = self.coin!.ticker;
        self.present(tradeVC, animated: true, completion: nil);
    }
    
    @objc func addCoin() {
        self.vibrate(style: .light);
        DataStorageHandler.saveObject(type: self.coin!, forKey: UserDefaultKeys.coinKey);
        var loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey)!;
        loadedCoins.append(self.coin!);
        DataStorageHandler.saveObject(type: loadedCoins, forKey: UserDefaultKeys.coinArrayKey);
        self.displayAlertWithCompletion(title: "Coin Added!", message: "\(self.coin!.ticker.name) added to dashboard", style: .default) { (action) in
            self.updateRightBarItem();
        }
    }
    
    private func updateRightBarItem() -> Void {
        let loadedCoins = DataStorageHandler.loadObject(type: [Coin].self, forKey: UserDefaultKeys.coinArrayKey)!;
         for coin in loadedCoins {
             if (coin.ticker.name.lowercased() == self.coin!.ticker.name.lowercased()) {
                 self.isTradingMode = true;
                 break;
             }
         }
         if (self.isTradingMode) {
            let tradeButton = UIButton();
            tradeButton.frame = CGRect(x:0, y:0, width:80, height:20);
            tradeButton.setTitle("Trade", for: .normal);
            tradeButton.setTitle("Trade", for: .highlighted);
            tradeButton.backgroundColor = UIColor.orange;
            tradeButton.layer.cornerRadius = 8.0;
            tradeButton.addTarget(self, action: #selector(trade), for: .touchUpInside);
            let rightBarButton = UIBarButtonItem(customView: tradeButton);
            self.navigationItem.rightBarButtonItem = rightBarButton;
//            let button = UIButton()
//            button.setImage(#imageLiteral(resourceName: "trade"), for: .normal);
//            button.addTarget(self, action: #selector(self.trade), for: .touchUpInside);
//            let barButton = UIBarButtonItem(customView: button)
//            self.navigationItem.rightBarButtonItem = barButton;
        } else {
            let addButton = UIButton();
            addButton.frame = CGRect(x:0, y:0, width:80, height:20);
            addButton.setTitle("Add", for: .normal);
            addButton.setTitle("Add", for: .highlighted);
            addButton.backgroundColor = UIColor.orange;
            addButton.layer.cornerRadius = 8.0;
            addButton.addTarget(self, action: #selector(addCoin), for: .touchUpInside);
            let rightBarButton = UIBarButtonItem(customView: addButton);
            self.navigationItem.rightBarButtonItem = rightBarButton;
        }
    }
    
    // MARK: - Table view data source methodd
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.separatorStyle = .none;
        return self.coinData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoVCCell", for: indexPath) as! InfoVCCustomCell;
        cell.websiteImage.image = self.coinData[indexPath.row].webImage;
        cell.titlePageLbl.text = self.coinData[indexPath.row].title;
        cell.linkLbl.text = self.coinData[indexPath.row].linkName;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        switch indexPath.row {
        case 0:
            if let url = URL(string: self.coin!.ticker.website) {
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true, completion: nil);
            } else {
                self.displayAlert(title: "Sorry", message: "Website unavailable.");
            }
            break;
        case 1:
            if let url = URL(string: "https://www.cryptocompare.com/coins/" + "\(self.coin!.ticker.symbol.lowercased())" + "/forum") {
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true, completion: nil);
            } else {
                self.displayAlert(title: "Sorry", message: "Website unavailable.");
            }
            break;
        case 2:
            if let url = URL(string: "https://twitter.com/hashtag/" + "\(self.coin!.ticker.name.lowercased().replacingOccurrences(of: " ", with: ""))" + "?lang=en") {
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true, completion: nil);
            } else {
                self.displayAlert(title: "Sorry", message: "Website unavailable.");
            }
            break;
        case 3:
            if let url = URL(string: "https://cryptowat.ch/assets/" + "\(self.coin!.ticker.symbol.lowercased())") {
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true, completion: nil);
            } else {
                self.displayAlert(title: "Sorry", message: "Website unavailable.");
            }
            break;
        default:
            break;
        }
    }
    
    private func displayAlert(title:String, message:String) -> Void {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton)
        present(alert, animated: true, completion: nil);
    }
    
     private func displayAlertWithCompletion(title: String, message: String, style: UIAlertAction.Style, handler:@escaping (UIAlertAction) -> Void) -> Void {
       let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
       alert.addAction(UIAlertAction(title: "OK", style: style, handler: handler));
       self.present(alert, animated: true, completion: nil);
    }
       
    
    // MARK: - Methods for setting up all fields on the screen
    
    private func updateInfoVC(ticker:Ticker, tickerImage:UIImage) {
        self.title = ticker.name
        self.name_lbl.text = ticker.name;
        self.symbol_lbl.text = ticker.symbol;
        self.crypto_img.image = tickerImage;
        self.price_lbl.text = CryptoData.convertToDollar(price: self.coin!.ticker.price, hasSymbol: true);
        self.change_lbl.text = setChange(change: String(format: "%.2f", ticker.changePrecent24H));
        setChange(change: self.change_lbl);
        self.rank_lbl.text =  "#" + "\(String(ticker.rank))";
        self.volume24H_lbl.text = formatMoney(money: ticker.volume24H, isMoney: true);
        self.marketCap_lbl.text = formatMoney(money: ticker.marketCap, isMoney: true);
        self.allTimeHigh_lbl.text = "\(String(format: "%.2f", ticker.allTimeHigh))";
        self.maxSupply_lbl.text = formatMoney(money: ticker.circulation, isMoney: false);
        self.description_view.text = self.setGoodDescription(ticker: ticker);
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/" + "\(ticker.symbol.lowercased())" + ".png")!, title: "Website", linkName: ticker.name));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/internet.png")!, title: "CryptoCompare", linkName: "cryptocompare.com/coins/" + "\(ticker.symbol.lowercased())" + "/forum"));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/twitter.png")!, title: "Twitter", linkName: "twitter.com/hashtag/" + "\(ticker.name.lowercased())"));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/chart.png")!, title: "Technical Charts", linkName: "cryptowat.ch/assets/" + "\(ticker.symbol.lowercased())"));
        if #available(iOS 13.0, *) {
            self.timeStamp_seg.selectedSegmentTintColor = UIColor.orange
        }
        self.price_lbl.adjustsFontSizeToFitWidth = true;
        self.change_lbl.adjustsFontSizeToFitWidth = true;
        self.allTimeHigh_lbl.adjustsFontSizeToFitWidth = true;
        self.daysRange_lbl.adjustsFontSizeToFitWidth = true;
        self.rank_lbl.adjustsFontSizeToFitWidth = true;
    }
    
    private func setGoodDescription(ticker:Ticker) -> String {
        if (ticker.name.lowercased() == "Bitcoin".lowercased() || ticker.name.lowercased() == "Tether USD".lowercased() || ticker.name.lowercased() == "Bitcoin SV".lowercased() || ticker.name.lowercased() == "Ontology".lowercased() || ticker.name.lowercased() == "NEO".lowercased() || ticker.name.lowercased() == "Litecoin".lowercased() || ticker.symbol.lowercased() == "matic") {
            let charset = CharacterSet(charactersIn: ".")
            let arr = ticker.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).components(separatedBy: charset)
            var resultString = Array<String>();
            for i in 0...1 {
                if (i < arr.count) {
                    resultString.append(arr[i]);
                }
            }
            var desc = resultString.joined(separator: ".");
            if (desc.last != ".") {
                desc.append(".");
            }
            return desc;
        } else if (ticker.name.lowercased() == "TrueUSD".lowercased()) {
            return "TrueUSD is a USD-pegged stablecoin, that provides its users with regular attestations of escrowed balances, full collateral and legal protection against the misappropriation of the underlying USD. TrueUSD is issued by the TrustToken platform, the platform that has partnered with registered fiduciaries and banks that hold the funds backing the TrueUSD tokens.";
        } else if (ticker.name.lowercased() == "Paxos Standard".lowercased()) {
            return "Paxos Standard (PAX) is a stablecoin that allows users to exchange US dollars for Paxos Standard Tokens to 'transact at the speed of the internet'. It aims to meld the stability of the dollar with blockchain technology. Paxos, the company behind PAX, has a charter from the New York State Department of Financial Services, which allows it to offer regulated services in the cryptoasset space.";
        } else {
            let charset = CharacterSet(charactersIn: ".")
            let arr = ticker.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).components(separatedBy: charset)
            var resultString = Array<String>();
            for i in 0...2 {
                if (i < arr.count) {
                    resultString.append(arr[i]);
                }
            }
            var desc = resultString.joined(separator: ".");
            if (desc.last != ".") {
                desc.append(".");
            }
            return desc;
        }
    }
    
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
    
    private func setChange(change:UILabel) -> Void {
        if (change_lbl.text?.first != "-") {
            change_lbl.textColor = ChartColors.greenColor();
        } else {
            change_lbl.textColor = ChartColors.redColor();
        }
    }
    
    private func formatDaysRange(ticker:Ticker, data:inout Array<Double>) -> String {
        return "\(CryptoData.convertToDollar(price: data.min()!, hasSymbol: false)) - \(CryptoData.convertToDollar(price: data.max()!, hasSymbol: false))"
    }
    
    private func formatAllTimeHighRange(ticker:Ticker, data:inout Array<Double>) -> String {
        var priceString = String(ticker.price);
        priceString.removeFirst();
        
        var otherPrice = String(ticker.price);
        otherPrice.removeFirst();
        otherPrice.removeFirst();
        
        if (String(ticker.price).first == "0" || priceString.first == ".") {
            return "\(String(format: "%.5f", data.max()!))";
        } else if (otherPrice.first == ".") {
            return "\(String(format: "%.2f", data.max()!))";
        } else {
            return "\(String(format: "%.2f", data.max()!))";
        }
        
    }
    
    private func updatePercentChangeWithGraph(data:inout Array<Double>) -> String {
        if let first = data.first, let last = data.last {
            if (first.isZero) {
                var nonZeroFirst:Double = 1.0;
                for datapoint in data {
                    if (!datapoint.isLessThanOrEqualTo(0)) {
                        nonZeroFirst = datapoint;
                        break;
                    }
                }
                let percentChange = (last / nonZeroFirst - 1) * 100;
                let cool = String(format: "%.2f", percentChange);
                if (cool.first! == "-") {
                    var finalString = CryptoData.convertToMoney(price: String(format: "%.2f", percentChange));
                    finalString.remove(at: finalString.startIndex);
                    finalString = "-\(finalString)%";
                    return finalString;
                } else {
                    var finalString = CryptoData.convertToMoney(price: String(format: "%.2f", percentChange));
                    finalString.remove(at: finalString.startIndex);
                    finalString = "+\(finalString)%";
                    return finalString;
                }
            } else {
                let percentChange = (last / first - 1) * 100;
                let cool = String(format: "%.2f", percentChange);
                if (cool.first! == "-") {
                    var finalString = CryptoData.convertToMoney(price: String(format: "%.2f", percentChange));
                    finalString.remove(at: finalString.startIndex);
                    finalString = "-\(finalString)%";
                    return finalString;
                } else {
                    var finalString = CryptoData.convertToMoney(price: String(format: "%.2f", percentChange));
                    finalString.remove(at: finalString.startIndex);
                    finalString = "+\(finalString)%";
                    return finalString;
                }
            }
        }
        return self.setChange(change: String(format: "%.2f", self.coin!.ticker.changePrecent24H));
    }
    
    private func formatMoney(money:Double, isMoney:Bool) -> String {
        var result:String = String(Int(money));
        switch result.count {
        case 15:
            for _ in 1...15 - 5 {
                result.removeLast();
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "T";
        case 14:
            for _ in 1...14 - 4 {
                result.removeLast();
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "T";
            break;
        case 13:
            for _ in 1...13 - 3 {
                result.removeLast();
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "T";
            break;
        case 12:
            for _ in 1...12 - 5 {
                result.removeLast();
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "B";
            break;
        case 11:
            for _ in 1...11 - 4 {
                result.removeLast()
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "B";
            break;
        case 10:
            for _ in 1...10 - 3 {
                result.removeLast();
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "B";
            break;
        case 9:
            for _ in 1...9 - 5 {
                result.removeLast();
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "M";
            break;
        case 8:
            for _ in 1...8 - 4 {
                result.removeLast()
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "M";
            break;
        case 7:
            for _ in 1...7 - 3 {
                result.removeLast();
            }
            result.insert(".", at: result.index(result.startIndex, offsetBy: result.count - 2));
            result = result + "M";
            break;
        default:
            break;
        }
        if (isMoney) {
            //result.insert("$", at: result.startIndex);
        }
        return result;
    }
    
    // MARK: - Methods describing how all charts are being displayed dependent on the timestap
    // TODO: - Add loading symbol (chart data and current price dont quite add up)
    
    private func dayChart() {
        self.updateGraph(timeFrame: "24h")
    }
    
    private func weekChart() {
        self.updateGraph(timeFrame: "7d");
    }
    
    private func oneMonthChart() {
        self.updateGraph(timeFrame: "30d");
    }
    
    private func yearChart() {
        self.updateGraph(timeFrame: "1y");
    }
    
    private func fiveYearChart() {
        self.updateGraph(timeFrame: "5y");
    }
    
    private func updateGraph(timeFrame: String) {
        self.deleteDataForReuse(dataPoints: &self.dataPoints, timestaps: &self.timestamps);
        self.chart_view.isHidden = true;
        self.activityIndicator.startAnimating();
        CryptoData.getCryptoID(coinSymbol: self.coin!.ticker.symbol.lowercased()) { (uuid, error) in
            if let error = error { print(error.localizedDescription); return; }
            CryptoData.getCoinHistory(id: uuid!, timeFrame: timeFrame) { [weak self] (history, error) in
                if let error = error {
                    print(error.localizedDescription);
                } else {
                    self?.chart_view.isHidden = false;
                    self?.activityIndicator.stopAnimating();
                    self?.dataPoints = history!.prices;
                    self?.timestamps = history!.timestamps;
                    self?.chartSetup(data: self!.dataPoints, isDay: false);
                    if (timeFrame != "24h") {
                        self?.change_lbl.text = self!.updatePercentChangeWithGraph(data: &self!.dataPoints);
                        self?.setChange(change: self!.change_lbl);
                    } else {
                        self?.change_lbl.text = self?.setChange(change: String(format: "%.2f", self!.coin!.ticker.changePrecent24H));
                        self?.setChange(change: self!.change_lbl);
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let max = self!.dataPoints.max() {
                            self!.allTimeHigh_lbl.text = CryptoData.convertToDollar(price: max, hasSymbol: false);
                            self!.allTimeHigh_lbl.text = self?.formatAllTimeHighRange(ticker: self!.coin!.ticker, data: &self!.dataPoints);
                            self!.allTimeHigh_lbl.text = CryptoData.convertToDollar(price:  self!.dataPoints.max()!, hasSymbol: false);
                            self!.daysRange_lbl.text = self?.formatDaysRange(ticker: self!.coin!.ticker, data: &self!.dataPoints);
                        }
                        self!.allTimeHighStatic_lbl.text = "All Time High (\(timeFrame.uppercased()))";
                        self!.daysRangeStatic_lbl.text = "(\(timeFrame.uppercased())) Range";
                    }
                }
            }
        }
    }
    
    private func chartSetup(data: Array<Double>, isDay:Bool) {
        self.chart_view.removeAllSeries();
        self.chart_view.hideHighlightLineOnTouchEnd = true;
        self.chart_view.topInset = 20.0;
        self.chart_view.bottomInset = 0.0;
        self.chart_view.showXLabelsAndGrid = false;
        self.chart_view.lineWidth = 3.0;
        self.chart_view.labelColor = UIColor.white;
        let series = ChartSeries(data);
        series.area = true;
        if (isDay) {
            if (!((data.first?.isLess(than: data.last!))!) || self.change_lbl.text!.first == "-") {
                series.color = ChartColors.redColor();
            } else {
                series.color = ChartColors.greenColor();
            }
        } else {
            if (!((data.first?.isLess(than: data.last!))!)) {
                series.color = ChartColors.redColor();
            } else {
                series.color = ChartColors.greenColor();
            }
        }
        if (self.price_lbl.text!.first == "-") { series.color = ChartColors.greenColor(); }
        self.chart_view.showXLabelsAndGrid = false;
        if traitCollection.userInterfaceStyle == .light {
            self.chart_view.labelColor = UIColor.black;
        } else {
            self.chart_view.labelColor = UIColor.white;
        }
        self.chart_view.add(series);
    }
    
    private func deleteDataForReuse( dataPoints: inout Array<Double>, timestaps: inout Array<Double>) {
        if (!dataPoints.isEmpty) {
            dataPoints.removeAll();
        }
        if (!timestaps.isEmpty) {
            timestaps.removeAll();
        }
    }
    
    @IBAction func timestapLogHandler(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            self.isDayOrWeekChart = true;
            self.dayChart();
            self.vibrate(style: .light);
            break;
        case 1:
            self.isDayOrWeekChart = true;
            self.weekChart();
            self.vibrate(style: .light);
            break;
        case 2:
            self.isDayOrWeekChart = false;
            self.oneMonthChart();
            self.vibrate(style: .light);
            break;
        case 3:
            self.isDayOrWeekChart = false;
            self.yearChart();
            self.vibrate(style: .light);
            break;
        case 4:
            self.isDayOrWeekChart = false;
            self.fiveYearChart();
            self.vibrate(style: .light);
            break;
        default:
            print("Not a date");
            break;
        }
    }
    
    
    // MARK: - Date formatting
    
    func getFormattedDate(data:Array<Double>?, index: Int) -> String {
        if (!(index >= 0 && index < data!.count)) { return ""; }
        let timeResult = data![index];
        let date = Date(timeIntervalSince1970: timeResult);
        let dateFormatter = DateFormatter();
        dateFormatter.timeStyle = DateFormatter.Style.medium;
        dateFormatter.dateStyle = DateFormatter.Style.medium;
        dateFormatter.timeZone = .current;
        if (isDayOrWeekChart) {
            dateFormatter.dateFormat = "MMM d, h:mm a";
        } else {
            dateFormatter.dateFormat = "MMM d, yyyy";
        }
        let localDate = dateFormatter.string(from: date);
        //let r = localDate.index(localDate.startIndex, offsetBy: 0)..<localDate.index(localDate.endIndex, offsetBy: -14)
        return localDate;
    }
    
    // MARK: - Scroll view methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y;
        if (lastContentOffset >= -1.0) {
            self.navigationItem.titleView?.isHidden = false;
        } else {
            self.navigationItem.titleView?.isHidden = true;
        }
    }
    
    // MARK: - Chart methods
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        if (self.dataPoints.isEmpty) { return; }
        for (serieIndex, dataIndex) in indexes.enumerated() {
            if (dataIndex != nil) {
                // The series at serieIndex has been touched
                if (self.chartPrice_lbl.isHidden) {
                    self.chartPrice_lbl.isHidden = false;
                }
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex);
                //self.chartPrice_lbl.text = getFormattedDate(data: self.timestamps, index: dataIndex!) + " $\(String(round(10000.0 * value!) / 10000.0))";
                self.chartPrice_lbl.text = getFormattedDate(data: self.timestamps, index: dataIndex!) + " \(CryptoData.convertToDollar(price: value!, hasSymbol: false))";
                
                // calcualte height
                if (dataIndex! != self.prevIndex) {
                    if (dataIndex!.isMultiple(of: 2)) { self.vibrate(style: .light); }
                    self.circleView.isHidden = false;
                    self.circleView.removeFromSuperview();
                    let heightPercent:CGFloat = (CGFloat(value!) - CGFloat(self.dataPoints.min()!)) / CGFloat(self.dataPoints.max()! - self.dataPoints.min()!);
                    let currentHeight = ((heightPercent) * (self.chart_view.frame.height - self.chart_view.topInset));
                    self.circleView = UIView(frame: CGRect(x: left - self.circleView.frame.width / 2, y: ((self.chart_view.frame.height - currentHeight) - self.circleView.frame.height / 2), width: 10, height: 10));
                    self.circleView.layer.cornerRadius = self.circleView.frame.width / 2;
                    self.circleView.clipsToBounds = true;
                    self.circleView.backgroundColor = .darkGray;
                    self.circleView.layer.borderColor = UIColor.orange.cgColor;
                    self.circleView.layer.borderWidth = 1.0;
                    self.chart_view.addSubview(self.circleView);
                }
                self.prevIndex = dataIndex!;
                
                let deviceBool = UIDevice.current.userInterfaceIdiom == .pad;
                let rightValue:CGFloat = deviceBool ? 750.0 : 295.0;
                let offset:CGFloat = 90.0
                if (left <= 80.0) {
                    self.chartPrice_lbl.transform = CGAffineTransform(translationX: -self.chartPrice_lbl.bounds.width / 2 + 85.0, y: 0.0);
                } else if (left >= rightValue) {
                    self.chartPrice_lbl.transform = CGAffineTransform(translationX: left - (self.chartPrice_lbl.bounds.width / 2 - (self.view.frame.width - left) + offset), y: 0.0);
                } else {
                    self.chartPrice_lbl.transform = CGAffineTransform(translationX: left - (self.chartPrice_lbl.bounds.width / 2), y: 0.0);
                }

                
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        self.chartPrice_lbl.isHidden = true;
        self.circleView.isHidden = true;
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        self.chartPrice_lbl.isHidden = true;
        self.circleView.isHidden = true;
    }
    
    private func vibrate(style:UIImpactFeedbackGenerator.FeedbackStyle) -> Void {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackgenerator.impactOccurred()
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
    

}
