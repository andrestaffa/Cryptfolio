//
//  PortfolioVCCustomCell.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-05.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import SwiftChart;

protocol CellDelegate: AnyObject {
    func didTap(_ cell: PortfolioVCCustomCell)
}

class PortfolioVCCustomCell: UITableViewCell {

    weak var delegate: CellDelegate?
    
    @IBOutlet weak var name_lbl: UILabel!
    @IBOutlet weak var crypto_img: UIImageView!
    @IBOutlet weak var price_lbl: UILabel!
    @IBOutlet weak var percentChange_lbl: UILabel!
    @IBOutlet weak var amountCost_lbl: UILabel!
    @IBOutlet weak var amountCoin_lbl: UILabel!
    @IBOutlet weak var add_btn: UIButton!
    
    let holdingPercentChange: UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false;
        label.textAlignment = .right;
        label.font = UIFont.systemFont(ofSize: 9);
        label.adjustsFontSizeToFitWidth = true;
        return label;
    }();
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(self.holdingPercentChange);
        
        self.price_lbl.font = UIFont(name: "PingFangHK-Medium", size: 12.0);
        self.price_lbl.textColor = .white;
        
        self.amountCost_lbl.font = UIFont(name: "PingFangHK-Medium", size: 12.0);
        self.amountCost_lbl.textColor = .white;
        
        self.holdingPercentChange.topAnchor.constraint(equalTo: self.amountCoin_lbl.bottomAnchor).isActive = true;
        self.holdingPercentChange.trailingAnchor.constraint(equalTo: self.amountCoin_lbl.trailingAnchor).isActive = true;
        self.holdingPercentChange.widthAnchor.constraint(equalTo: self.amountCost_lbl.widthAnchor).isActive = true;
        self.holdingPercentChange.heightAnchor.constraint(equalTo: self.amountCoin_lbl.heightAnchor).isActive = true;
        
    }

    
    @IBAction func addHoldingButtonPressed(_ sender: Any) { delegate?.didTap(self); }
    
}
