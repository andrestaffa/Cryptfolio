//
//  NewsTBVCCustomCell.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-22.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class NewsTBVCCustomCell: UITableViewCell {

    @IBOutlet weak var title_lbl: UITextView!
    @IBOutlet weak var source_lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
