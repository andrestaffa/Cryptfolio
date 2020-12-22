//
//  CustomCell.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-02-19.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import SwiftChart;

protocol HomeCellDelgate: class {
    func didTap(_ cell: CustomCell);
}

class CustomCell: UITableViewCell, ChartDelegate {
   
    weak var delegate: HomeCellDelgate?;

    let chartView: Chart = {
        let chart = Chart();
        chart.topInset = 20.0;
        chart.bottomInset = 0.0;
        chart.showXLabelsAndGrid = false;
        chart.showYLabelsAndGrid = false;
        chart.layer.borderColor = UIColor.clear.cgColor;
        chart.isUserInteractionEnabled = false;
        chart.translatesAutoresizingMaskIntoConstraints = false;
        return chart;
    }();
    
    let crypto_img: UIImageView = {
        let image = UIImageView();
        image.translatesAutoresizingMaskIntoConstraints = false;
        return image;
    }();
    
    let symbolLbl: UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let name_lbl: UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    
    let priceTxt: UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let container: UIView = {
        let container = UIView();
        container.translatesAutoresizingMaskIntoConstraints = false;
        return container;
    }();
    
    let percentChangeTxt: UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let addSymbolImg: UIImageView = {
        let image = UIImageView();
        image.translatesAutoresizingMaskIntoConstraints = false;
        return image;
    }();
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(self.chartView);
        self.addSubview(self.crypto_img);
        self.addSubview(self.symbolLbl);
        self.addSubview(self.name_lbl);
        self.addSubview(self.priceTxt);
        self.addSubview(self.container);
        self.addSubview(self.addSymbolImg);
        self.container.addSubview(self.percentChangeTxt);
        
        let con:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? -10.0 : -5.0;
        let mul:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 0.4 : 0.3;
        self.chartView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.chartView.trailingAnchor.constraint(equalTo: self.priceTxt.leadingAnchor, constant: con).isActive = true;
        self.chartView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: mul).isActive = true;
        self.chartView.heightAnchor.constraint(equalToConstant: 60).isActive = true;
        
        self.crypto_img.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.crypto_img.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true;
        self.crypto_img.widthAnchor.constraint(equalToConstant: 35).isActive = true;
        self.crypto_img.heightAnchor.constraint(equalToConstant: 35).isActive = true;
        
        self.symbolLbl.font = UIFont.systemFont(ofSize: 16);
        self.symbolLbl.bottomAnchor.constraint(equalTo: self.name_lbl.topAnchor, constant: 5).isActive = true;
        self.symbolLbl.leadingAnchor.constraint(equalTo: self.crypto_img.trailingAnchor, constant: 10).isActive = true;
        self.symbolLbl.widthAnchor.constraint(equalTo: self.name_lbl.widthAnchor).isActive = true;
        self.symbolLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true;
        
        self.name_lbl.font = UIFont.systemFont(ofSize: 12.5);
        self.name_lbl.textColor = .systemGray;
        self.name_lbl.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 7).isActive = true;
        self.name_lbl.leadingAnchor.constraint(equalTo: self.crypto_img.trailingAnchor, constant: 10).isActive = true;
        self.name_lbl.widthAnchor.constraint(equalToConstant: 80).isActive = true;
        self.name_lbl.heightAnchor.constraint(equalToConstant: 30).isActive = true;
        
        self.priceTxt.textAlignment = .right;
        self.priceTxt.adjustsFontSizeToFitWidth = true;
        self.priceTxt.bottomAnchor.constraint(equalTo: self.container.topAnchor).isActive = true;
        self.priceTxt.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true;
        self.priceTxt.widthAnchor.constraint(equalToConstant: 100).isActive = true;
        self.priceTxt.heightAnchor.constraint(equalToConstant: 30).isActive = true;
        
        self.container.layer.masksToBounds = true;
        self.container.layer.cornerRadius = 4.0;
        self.container.isUserInteractionEnabled = true;
        self.container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.containerTapped)));
        self.container.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 10).isActive = true;
        self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true;
        self.container.widthAnchor.constraint(equalToConstant: 70).isActive = true;
        self.container.heightAnchor.constraint(equalToConstant: 27).isActive = true;
        
        self.percentChangeTxt.textColor = .white;
        self.percentChangeTxt.adjustsFontSizeToFitWidth = true;
        self.percentChangeTxt.textAlignment = .right;
        self.percentChangeTxt.font = UIFont.systemFont(ofSize: 15);
        self.percentChangeTxt.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true;
        self.percentChangeTxt.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -5).isActive = true;
        self.percentChangeTxt.widthAnchor.constraint(equalTo: self.container.widthAnchor, multiplier: 0.9).isActive = true;
        self.percentChangeTxt.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true;
        
        self.addSymbolImg.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.addSymbolImg.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true;
        self.addSymbolImg.widthAnchor.constraint(equalToConstant: 17.5).isActive = true;
        self.addSymbolImg.heightAnchor.constraint(equalToConstant: 17.5).isActive = true;
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        self.addSymbolImg.isHidden = true;
        self.chartView.removeAllSeries();
    }
    
    // MARK: - Chart Delegate Methods
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {}
    func didFinishTouchingChart(_ chart: Chart) {}
    func didEndTouchingChart(_ chart: Chart) {}
    
    @objc func containerTapped() {
        delegate?.didTap(self);
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light);
        impactFeedbackgenerator.impactOccurred()
    }

}
