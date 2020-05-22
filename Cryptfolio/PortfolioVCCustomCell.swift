//
//  PortfolioVCCustomCell.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-05.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import SwiftChart;

protocol CellDelegate: class {
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addHoldingButtonPressed(_ sender: Any) { delegate?.didTap(self); }
    
}
