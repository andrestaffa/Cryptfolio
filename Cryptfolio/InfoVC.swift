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
   
    public var name =  "";
    public var image = UIImage();
    public var symbol = "";
    public var price = "";
    public var change = "";
    public var rank = ""
    public var volume24H = "";
    public var marketCap = "";
    public var maxSupply = "";
    public var circulation = "";
    
    private var dataPoints = Array<Double>();
    private var timestaps = Array<Double>();
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self;
        chart_view.delegate = self;
        
        self.navigationController?.navigationBar.isTranslucent = true;
        
        
        self.name_lbl.text = self.name;
        self.crypto_img.image = self.image;
        self.symbol_lbl.text = self.symbol;
        self.price_lbl.text = self.price;
        self.change_lbl.text = self.change;
        self.rank_lbl.text = self.rank;
        self.volume24H_lbl.text = self.volume24H;
        self.marketCap_lbl.text = self.marketCap;
        self.maxSupply_lbl.text = self.maxSupply;
        self.circulation_lbl.text = self.circulation;
        
        if (self.change.first == "-") {
            self.change_lbl.textColor = ChartColors.darkRedColor();
        } else {
            self.change_lbl.textColor = ChartColors.greenColor();
        }
        
        self.chartPrice_lbl.isHidden = true;
        
        execute(URL(string: "https://min-api.cryptocompare.com/data/v2/histoday?fsym=" + "\(self.symbol.uppercased())" + "&tsym=USD&limit=364")!) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for i in 0...data!.count - 1 {
                    self.dataPoints.append(data![i]["open"] as! Double);
                    self.timestaps.append(data![i]["time"] as! Double);
                }
                let series = ChartSeries(self.dataPoints);
                series.area = true;
                if (!((self.dataPoints.first?.isLess(than: self.dataPoints.last!))!)) {
                    series.color = ChartColors.darkRedColor();
                } else {
                    series.color = ChartColors.greenColor();
                }
                self.chart_view.showXLabelsAndGrid = false;
                self.chart_view.add(series);
            }
        }
    }
    
    // TODO: - Write code for different timestap charts
    
    @IBAction func timestapLogHandler(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            print("1D");
        case 1:
            print("1W");
        case 2:
            print("1M");
        case 3:
            print("3M");
        case 4:
            print("6M");
        case 5:
            print("1Y");
        default:
            print("Not a date");
        }
    }
    
    
    
    // MARK: - Custom Methods
    
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
                self.chartPrice_lbl.text = getFormattedDate(data: self.timestaps, index: dataIndex!) + " $\(String(round(1000.0 * value!) / 1000.0))";
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
