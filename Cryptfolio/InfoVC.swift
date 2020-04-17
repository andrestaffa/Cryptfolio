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

class InfoVC: UIViewController, UIScrollViewDelegate, ChartDelegate {

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
    @IBOutlet weak var circulation_lbl: UILabel!
    @IBOutlet weak var description_view: UITextView!
    @IBOutlet weak var chartPrice_lbl: UILabel!
    @IBOutlet weak var chart_view: Chart!
    
    public var coin:Coin?;
    
    private var dataPoints = Array<Double>();
    private var timestamps = Array<Double>();
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self;
        chart_view.delegate = self;
        
        self.navigationController?.navigationBar.isTranslucent = true;
        
        updateInfoVC(ticker: self.coin!.ticker!, tickerImage: self.coin!.image!);
        
        self.chartPrice_lbl.isHidden = true;
        self.dayChart();
        
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
        self.volume24H_lbl.text = "$\(String(Int(ticker.volume24H)))";
        self.marketCap_lbl.text = "$\(String(Int(ticker.marketCap)))";
        self.maxSupply_lbl.text = "$\(String(Int(ticker.circulation)))";
        self.circulation_lbl.text = "$\(String(Int(ticker.circulation)))";
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
                self.chartSetup(data: self.dataPoints, isDay: isDay);
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
        case 1:
            self.weekChart();
        case 2:
            self.oneMonthChart();
        case 3:
            self.threeMonthChart();
        case 4:
            self.sixMonthChart();
        case 5:
            self.yearChart();
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
                self.chartPrice_lbl.text = getFormattedDate(data: self.timestamps, index: dataIndex!) + " $\(String(round(1000.0 * value!) / 1000.0))";
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        self.chartPrice_lbl.isHidden = true;
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        self.chartPrice_lbl.isHidden = true;
    }

}
