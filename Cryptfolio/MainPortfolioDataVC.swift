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
    @IBOutlet weak var holderView: UIView!
    
    // memeber variables
    private var pricesSet:Array<Double> = Array<Double>();
    private var dateSet:Array<String> = Array<String>();
    private var currentPortfolio:String = "";
    private var currentChange:String = "";
    
    private var prevIndex:Int = -1;
    private var circleView = UIView();

    
    public init?(coder: NSCoder, pricesSet:Array<Double>, dateSet:Array<String>, currentPortfolio:String, currentChange:String) {
        super.init(coder: coder)
        self.pricesSet = pricesSet;
        self.dateSet = dateSet;
        self.currentPortfolio = currentPortfolio;
        self.currentChange = currentChange;
    }
    
    public init?(coder:NSCoder, dataSet:Array<PortfolioData>, currentPortfolio:String, currentChange:String) {
        super.init(coder: coder);
        for portData in dataSet {
            self.pricesSet.append(portData.currentPrice);
            self.dateSet.append(portData.currentDate);
        }
        self.currentPortfolio = currentPortfolio;
        self.currentChange = currentChange;
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
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

        self.chart_view.topInset = 20.0;
        self.chart_view.bottomInset = 0.0;
        
        self.holderView.layer.borderColor = UIColor.orange.cgColor;
        self.holderView.layer.cornerRadius = 15.0;
        self.holderView.clipsToBounds = true;
        self.holderView.layer.borderWidth = 1.0;

        
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
                if (dataIndex! != self.prevIndex) {
                    if (self.pricesSet.count >= 50) {
                        if (dataIndex!.isMultiple(of: 2)) {
                            self.vibrate(style: .light);
                        }
                        self.circleView.isHidden = false;
                        self.circleView.removeFromSuperview();
                        
                        // calc y pos
                        let heightPercent:CGFloat = (CGFloat(value!) - CGFloat(self.pricesSet.min()!)) / CGFloat(self.pricesSet.max()! - self.pricesSet.min()!);
                        let currentHeight = ((heightPercent) * (self.chart_view.frame.height - self.chart_view.topInset));
                        
                        // calc x pos
                        let widthPercentage:CGFloat = (CGFloat(dataIndex! + 1) / CGFloat(self.pricesSet.count));
                        let currentWidth = widthPercentage * self.chart_view.frame.width;
                        
                        self.circleView = UIView(frame: CGRect(x: (currentWidth) - self.circleView.frame.width / 2, y: ((self.chart_view.frame.height - currentHeight) - self.circleView.frame.height / 2), width: 13, height: 13));
                        self.circleView.layer.cornerRadius = self.circleView.frame.width / 2;
                        self.circleView.clipsToBounds = true;
                        self.circleView.backgroundColor = .darkGray;
                        self.circleView.layer.borderColor = UIColor.orange.cgColor;
                        self.circleView.layer.borderWidth = 1.0;
                        self.chart_view.addSubview(self.circleView);
                    }
                }
                self.prevIndex = dataIndex!;
                let deviceBool = UIDevice.current.userInterfaceIdiom == .pad;
                let rightValue:CGFloat = deviceBool ? 750.0 : 295.0;
                let offset:CGFloat = 90.0
                
                if (left <= 80.0) {
                    self.graphPrice_lbl.transform = CGAffineTransform(translationX: -self.graphPrice_lbl.bounds.width / 2 + 85.0, y: 0.0);
                } else if (left >= rightValue) {
                    self.graphPrice_lbl.transform = CGAffineTransform(translationX: left - (self.graphPrice_lbl.bounds.width / 2 - (self.view.frame.width - left) + offset), y: 0.0);
                } else {
                    self.graphPrice_lbl.transform = CGAffineTransform(translationX: left - (self.graphPrice_lbl.bounds.width / 2), y: 0.0);
                }
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        UIView.animate(withDuration: 0.1) {
            self.graphPrice_lbl.transform = .identity;
        }
        self.graphPrice_lbl.text = "Touch and Hold Chart to Begin";
        self.circleView.isHidden = true;
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        UIView.animate(withDuration: 0.1) {
            self.graphPrice_lbl.transform = .identity;
        }
        self.graphPrice_lbl.text = "Touch and Hold Chart to Begin";
        self.circleView.isHidden = true;
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
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light);
        impactFeedbackGenerator.impactOccurred()
    }

    
}
