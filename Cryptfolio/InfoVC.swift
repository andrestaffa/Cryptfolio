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
    @IBOutlet weak var daysRange_lbl: UILabel!
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
    
    // Public member variables
    public var coin:Coin?;
    public var isTradingMode:Bool = false;
    
    // Private member variables
    private var coinData = Array<CoinData>();
    private var views = Array<UIView>();
    
    private var dataPoints = Array<Double>();
    private var timestamps = Array<Double>();
    private var lastContentOffset: CGFloat = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        CryptoData.getCoinData(id: coin!.ticker.id) { (ticker, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                self.coin!.ticker = ticker!;
                self.setDesciption(ticker: &self.coin!.ticker);
                self.updateInfoVC(ticker: self.coin!.ticker, tickerImage: self.coin!.image.getImage()!);
                self.dayChart();
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
        
        if (self.isTradingMode) {
            let imageLiteral = #imageLiteral(resourceName: "tradeIcon");
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imageLiteral, style: .plain, target: self, action: #selector(trade))
        } else {
            self.navigationItem.setRightBarButton(nil, animated: true);
        }
        self.navigationController?.navigationBar.isTranslucent = true;
        
        updateInfoVC(ticker: self.coin!.ticker, tickerImage: self.coin!.image.getImage()!);
        self.navigationItem.titleView = navTitleWithImageAndText(titleText: self.coin!.ticker.name, imageIcon: self.coin!.image.getImage()!);
        
        self.chartPrice_lbl.isHidden = true;
        self.dayChart();
        
    }
    
    @objc func trade() {
        let tradeVC = storyboard?.instantiateViewController(withIdentifier: "tradeVC") as! TradeVC;
        tradeVC.ticker = self.coin!.ticker;
        self.present(tradeVC, animated: true, completion: nil);
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
            openLink(linkToSite: self.coin!.ticker.website);
            break;
        case 1:
            openLink(linkToSite: "https://www.cryptocompare.com/coins/" + "\(self.coin!.ticker.symbol.lowercased())" + "/forum");
            break;
        case 2:
            openLink(linkToSite: "https://twitter.com/hashtag/" + "\(self.coin!.ticker.name.lowercased().replacingOccurrences(of: " ", with: ""))" + "?lang=en");
            break;
        case 3:
            openLink(linkToSite: "https://cryptowat.ch/assets/" + "\(self.coin!.ticker.symbol.lowercased())");
            break;
        default:
            break;
        }
    }
    
    private func openLink(linkToSite:String) {
        let link = linkToSite;
        if let url = URL(string: link) {
            UIApplication.shared.open(url);
        } else {
            displayAlert(title: "Oops...", message: "Link does not exist")
        }
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton)
        present(alert, animated: true, completion: nil);
    }
    
    // MARK: - Methods for setting up all fields on the screen
    
    private func updateInfoVC(ticker:Ticker, tickerImage:UIImage) {
        self.title = ticker.name
        self.name_lbl.text = ticker.name;
        self.symbol_lbl.text = ticker.symbol;
        self.crypto_img.image = tickerImage;
        self.price_lbl.text = "$\(String(format: "%.4f", ticker.price))";
        self.change_lbl.text = setChange(change: String(format: "%.2f", ticker.changePrecent24H));
        setChange(change: self.change_lbl);
        self.rank_lbl.text =  "#" + "\(String(ticker.rank))";
        self.volume24H_lbl.text = formatMoney(money: ticker.volume24H, isMoney: true);
        self.marketCap_lbl.text = formatMoney(money: ticker.marketCap, isMoney: true);
        self.allTimeHigh_lbl.text = "$\(String(format: "%.2f", ticker.allTimeHigh))";
        self.daysRange_lbl.text = self.formatDaysRange(ticker: ticker);
        self.maxSupply_lbl.text = formatMoney(money: ticker.circulation, isMoney: false);
        self.description_view.text = ticker.description;
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/" + "\(ticker.symbol.lowercased())" + ".png")!, title: "Website", linkName: ticker.website.replacingOccurrences(of: "https://", with: "")));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/internet.png")!, title: "CryptoCompare", linkName: "cryptocompare.com/coins/" + "\(ticker.symbol.lowercased())" + "/forum"));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/twitter.png")!, title: "Twitter", linkName: "twitter.com/hashtag/" + "\(ticker.name.lowercased())"));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/chart.png")!, title: "Technical Charts", linkName: "cryptowat.ch/assets/" + "\(ticker.symbol.lowercased())"));
        if #available(iOS 13.0, *) {
            self.timeStamp_seg.selectedSegmentTintColor = UIColor.orange
        }
        self.views.append(self.view1);
        self.views.append(self.view2);
        self.views.append(self.view3);
        self.views.append(self.view4);
        self.views.append(self.view5);
        self.views.append(self.view6);
        if (traitCollection.userInterfaceStyle == .light) {
            for view in self.views {
                view.backgroundColor = UIColor.init(red: 192/255, green: 192/255, blue: 192/255, alpha: 1);
            }
        } else {
            for view in self.views {
                view.backgroundColor = UIColor.init(red: 105/255, green: 105/255, blue: 105/255, alpha: 1);
            }
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
    
    private func formatDaysRange(ticker:Ticker) -> String {
        var priceString = String(ticker.price);
        priceString.removeFirst();
        
        var otherPrice = String(ticker.price);
        otherPrice.removeFirst();
        otherPrice.removeFirst();
        
        if (String(ticker.price).first == "0" || priceString.first == ".") {
            return "\(String(format: "%.5f", ticker.history24h.min()!))" + " - " + "\(String(format: "%.5f", ticker.history24h.max()!))"
        } else if (otherPrice.first == ".") {
            return "\(String(format: "%.2f", ticker.history24h.min()!))" + " - " + "\(String(format: "%.2f", ticker.history24h.max()!))"
        } else {
            return "\(String(format: "%.0f", ticker.history24h.min()!))" + " - " + "\(String(format: "%.0f", ticker.history24h.max()!))"
        }
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
            result.insert("$", at: result.startIndex);
        }
        return result;
    }
    
    // MARK: - Methods describing how all charts are being displayed dependent on the timestap
    // TODO: - Add loading symbol (chart data and current price dont quite add up)
    
    private func dayChart() {
        self.updateGraph(timePeriod: "minute", limit: "1440", divisor: 8, isDay: true); // 180 units
    }
    
    private func weekChart() {
        self.updateGraph(timePeriod: "hour", limit: "168", divisor: 1, isDay: false); // 168 units
    }
    
    private func oneMonthChart() {
        self.updateGraph(timePeriod: "hour", limit: "744", divisor: 4, isDay: false); // 186 units
    }
    
    private func threeMonthChart() {
        self.updateGraph(timePeriod: "day", limit: "93", divisor: 1, isDay: false); // 93 units
    }
    
    private func sixMonthChart() {
        self.updateGraph(timePeriod: "day", limit: "182", divisor: 1, isDay: false); // 182 units
    }
    
    private func yearChart() {
        self.updateGraph(timePeriod: "day", limit: "365", divisor: 1, isDay: false) // 365 units
    }
    
    private func updateGraph(timePeriod:String, limit:String, divisor:Int, isDay:Bool) {
        self.deleteDataForReuse(dataPoints: &self.dataPoints, timestaps: &self.timestamps);
        self.chart_view.isHidden = true;
        self.activityIndicator.startAnimating();
        execute(URL(string: "https://min-api.cryptocompare.com/data/v2/histo" + "\(timePeriod)" + "?fsym=" + "\(self.symbol_lbl.text!.uppercased())" + "&tsym=USD&limit=" + "\(limit)")!) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.chart_view.isHidden = false;
                self.activityIndicator.stopAnimating();
                for i in 0...data!.count - 1 {
                    if (i < divisor) {
                        self.dataPoints.append(data![i]["open"] as! Double);
                        self.timestamps.append(data![i]["time"] as! Double);
                    } else if (i % divisor == 0) {
                        self.dataPoints.append(data![i]["open"] as! Double);
                        self.timestamps.append(data![i]["time"] as! Double);
                    }
                }
                if (isDay) {
                    self.chartSetup(data: self.coin!.ticker.history24h, isDay: isDay)
                } else {
                    self.chartSetup(data: self.dataPoints, isDay: isDay);
                }
            }
        }
    }
    
    private func chartSetup(data: Array<Double>, isDay:Bool) {
        self.chart_view.removeAllSeries();
        let series = ChartSeries(data);
        series.area = true;
        if (isDay) {
            if (change_lbl.text?.first != "-") {
                series.color = ChartColors.greenColor();
            } else {
                series.color = ChartColors.darkRedColor();
            }
        } else {
            if (!((data.first?.isLess(than: data.last!))!)) {
                series.color = ChartColors.darkRedColor();
            } else {
                series.color = ChartColors.greenColor();
            }
        }
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
            self.dayChart();
            self.vibrate(style: .light);
        case 1:
            self.weekChart();
            self.vibrate(style: .light);
        case 2:
            self.oneMonthChart();
            self.vibrate(style: .light);
        case 3:
            self.threeMonthChart();
            self.vibrate(style: .light);
        case 4:
            self.sixMonthChart();
            self.vibrate(style: .light);
        case 5:
            self.yearChart();
            self.vibrate(style: .light);
        default:
            print("Not a date");
        }
    }
    
    
    // MARK: - Date formatting
    
    func getFormattedDate(data:Array<Double>?, index: Int) -> String {
        let timeResult = data![index];
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        let r = localDate.index(localDate.startIndex, offsetBy: 0)..<localDate.index(localDate.endIndex, offsetBy: -14)
        return String(localDate[r]);
    }
    

    // MARK: - Networking (getting data for charts)
    
    func execute(_ url: URL, completion:@escaping ([[String: Any]]?, Error?) -> Void) {
        AF.request(url).responseJSON { response in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let dataObject:Dictionary = jsonObject["Data"] as! Dictionary<String, Any>;
                let dataTWO = dataObject["Data"] as! [[String: Any]]
                completion(dataTWO, nil);
            } else if let error = response.error {
                completion(nil, error);
            }
        }
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
        for (serieIndex, dataIndex) in indexes.enumerated() {
            if (dataIndex != nil) {
                // The series at serieIndex has been touched
                if (self.chartPrice_lbl.isHidden) {
                    self.chartPrice_lbl.isHidden = false;
                }
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex);
                self.chartPrice_lbl.text = getFormattedDate(data: self.timestamps, index: dataIndex!) + " $\(String(round(10000.0 * value!) / 10000.0))";
                if (left < self.view.frame.width / 6) {
                    self.chartPrice_lbl.frame.origin.x = (self.view.frame.width / 6) - 175.0;
                }
                if (left > self.view.frame.width / 1.3) {
                    self.chartPrice_lbl.frame.origin.x = (self.view.frame.width / 1.3) - 175.0
                }
                if (left >= 66.5 && left <= 296.0) {
                    self.chartPrice_lbl.frame.origin.x = left - 175.0;
                }
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        self.chartPrice_lbl.isHidden = true;
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        self.chartPrice_lbl.isHidden = true;
    }
    
    private func vibrate(style:UIImpactFeedbackGenerator.FeedbackStyle) -> Void {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
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
