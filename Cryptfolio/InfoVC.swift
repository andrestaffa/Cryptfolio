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
    @IBOutlet weak var tableViewNews: UITableView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view6: UIView!
    
    public var coin:Coin?;
    private var coinData = Array<CoinData>();
    private var views = Array<UIView>();
    
    private var dataPoints = Array<Double>();
    private var timestamps = Array<Double>();
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self;
        chart_view.delegate = self;
        tableViewNews.delegate = self;
        tableViewNews.dataSource = self;
        
        self.navigationController?.navigationBar.isTranslucent = true;
        
        updateInfoVC(ticker: self.coin!.ticker, tickerImage: self.coin!.image.getImage()!);
        
        
        self.chartPrice_lbl.isHidden = true;
        self.dayChart();
        
    }
    
    // MARK: - Table view data source methodd
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        self.name_lbl.text = ticker.name;
        self.symbol_lbl.text = ticker.symbol;
        self.crypto_img.image = tickerImage;
        self.price_lbl.text = "$\(String(round(10000.0 * ticker.price) / 10000.0))";
        self.change_lbl.text = setChange(change: String(round(100.0 * ticker.changePrecent24H) / 100.0));
        setChange(change: self.change_lbl);
        self.rank_lbl.text =  "#" + "\(String(ticker.rank))";
        self.volume24H_lbl.text = formatMoney(money: ticker.volume24H, isMoney: true);
        self.marketCap_lbl.text = formatMoney(money: ticker.marketCap, isMoney: true);
        self.allTimeHigh_lbl.text = "$\(String(round(10000.0 * ticker.allTimeHigh) / 10000.0))";
        self.daysRange_lbl.text = "\(String(round(1000.0 * ticker.history24h.min()!) / 1000.0))" + " - " + "\(String(round(1000.0 * ticker.history24h.max()!) / 1000.0))";
        self.maxSupply_lbl.text = formatMoney(money: ticker.circulation, isMoney: false);
        self.description_view.text = ticker.description;
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/" + "\(ticker.symbol.lowercased())" + ".png")!, title: "Website", linkName: ticker.website.replacingOccurrences(of: "https://", with: "")));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/internet.png")!, title: "CryptoCompare", linkName: "cryptocompare.com/coins/" + "\(ticker.symbol.lowercased())" + "/forum"));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/twitter.png")!, title: "Twitter", linkName: "twitter.com/hashtag/" + "\(ticker.name.lowercased())"));
        self.coinData.append(CoinData(webImage: UIImage(named: "Images/InfoImages/chart.png")!, title: "Technical Charts", linkName: "cryptowat.ch/assets/" + "\(ticker.symbol.lowercased())"));
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
        execute(URL(string: "https://min-api.cryptocompare.com/data/v2/histo" + "\(timePeriod)" + "?fsym=" + "\(self.symbol_lbl.text!.uppercased())" + "&tsym=USD&limit=" + "\(limit)")!) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
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

}
