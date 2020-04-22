//
//  InfoVCCustomCell.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-04-21.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class InfoVCCustomCell: UITableViewCell {
    

    @IBOutlet weak var websiteImage: UIImageView!
    @IBOutlet weak var titlePageLbl: UILabel!
    @IBOutlet weak var linkLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
