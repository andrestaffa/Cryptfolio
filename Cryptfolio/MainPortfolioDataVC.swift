//
//  MainPortfolioDataVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-13.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import SwiftChart;

class MainPortfolioDataVC: UIViewController, ChartDelegate  {

    @IBOutlet weak var mainPortfolio_lbl: UILabel!
    @IBOutlet weak var changeInterval_lbl: UILabel!
    @IBOutlet weak var change_lbl: UILabel!
    @IBOutlet weak var graphPrice_lbl: UILabel!
    @IBOutlet weak var chart_view: Chart!
    @IBOutlet weak var chartInterval_seg: UISegmentedControl!
    
    private var pricesSet:Array<Double> = Array<Double>();
    private var dateSet:Array<String> = Array<String>();
    private var prevIndex:Int = -1;
    
    private var currentPortfolio:String = "";
    private var currentChange:String = "";
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chart_view.delegate = self;
        self.changeInterval_lbl.text = "CHANGE";
        self.graphPrice_lbl.text = "Touch and Hold Chart to Begin";
        self.mainPortfolio_lbl.text = self.currentPortfolio;
        if (self.currentChange.first! == "-") {
            self.change_lbl.textColor = ChartColors.redColor();
            self.change_lbl.attributedText = self.attachImageToString(text: self.currentChange, image: #imageLiteral(resourceName: "sortDownArrow"));
        } else {
            self.change_lbl.textColor = ChartColors.greenColor();
            self.change_lbl.attributedText = self.attachImageToString(text: self.currentChange, image: #imageLiteral(resourceName: "sortUpArrow"));
        }

        
        self.setChartData();
        self.title = "Main Portfolio";
        
    }

    // MARK: Chart Methods
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        for (serieIndex, dataIndex) in indexes.enumerated() {
            if dataIndex != nil {
                // The series at serieIndex has been touched
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
                self.graphPrice_lbl.text = "$\(String(format: "%.2f", value!)), \(self.dateSet[dataIndex!])";
                self.graphPrice_lbl.isHidden = false;
                print("LEFT: \(left)")
                if (dataIndex! != self.prevIndex) {
//                    self.vibrate(style: .light);
                }
                self.prevIndex = dataIndex!;
                let deviceBool = UIDevice.current.userInterfaceIdiom == .pad;
                let rightValue:CGFloat = deviceBool ? 750.0 : 295.0;
                let errorMargin:CGFloat = deviceBool ? 78.0 : 65.0;
                let otherErrorMargin:CGFloat = deviceBool ? 85.0 : 75.0;
                
                if (left <= 75.0) {
                    UIView.animate(withDuration: 0.5) {
                        self.view.layoutIfNeeded();
                        self.graphPrice_lbl.transform = CGAffineTransform(translationX: left - (self.graphPrice_lbl.bounds.width / 2 - errorMargin), y: 0.0);
                    }
                } else if (left >= rightValue) {
                    UIView.animate(withDuration: 0.5) {
                        self.view.layoutIfNeeded();
                        self.graphPrice_lbl.transform = CGAffineTransform(translationX: left - (self.graphPrice_lbl.bounds.width / 2 + otherErrorMargin), y: 0.0);
                    }
                } else {
                    UIView.animate(withDuration: 0.1) {
                        self.view.layoutIfNeeded();
                        self.graphPrice_lbl.transform = CGAffineTransform(translationX: left - (self.graphPrice_lbl.bounds.width / 2), y: 0.0);
                    }
                }
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        self.graphPrice_lbl.transform = .identity;
        self.graphPrice_lbl.text = "Touch and Hold Chart to Begin";
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        self.graphPrice_lbl.transform = .identity;
        self.graphPrice_lbl.text = "Touch and Hold Chart to Begin";
    }
    
    private func setChartData() {
        let series = ChartSeries(self.pricesSet);
        series.area = true
        self.chart_view.hideHighlightLineOnTouchEnd = true;
        self.chart_view.showXLabelsAndGrid = false;
        self.chart_view.lineWidth = 3.0;
        self.chart_view.labelColor = UIColor.white;
        if (self.pricesSet[pricesSet.count - 1].isLess(than: self.pricesSet[0])) {
            series.color = ChartColors.redColor();
        } else {
            series.color = ChartColors.greenColor();
        }
        self.chart_view.add(series);
    }
    

    // MARK: Getters and Setters
    
    public func setDataSet(dataSet:Array<PortfolioData>) {
        for portData in dataSet {
            self.pricesSet.append(portData.currentPrice);
            self.dateSet.append(portData.currentDate);
        }
    }
    
    public func setPortfolio(portfolio:String) {
        self.currentPortfolio = portfolio;
    }
    
    public func setChange(change:String) {
        self.currentChange = change;
    }
    
    // MARK: Helper Methods
    
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
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackGenerator.prepare();
        impactFeedbackGenerator.impactOccurred();
    }

    
}
