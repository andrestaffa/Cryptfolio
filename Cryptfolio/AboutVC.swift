//
//  AboutVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-06-02.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var aboutView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateWithSpacing(lineSpacing: 10.0);
        self.aboutView.text = "Cryptfolio is an application where you can view, analyze, and practice trade 50+ different cryptocurrencies with a press of a button. You initially start with an up-front investment of $10,000 and can buy any cryptocurrency of your choice and play the markets, you can see your portfolio grow or decay depending on what cryptocurrencies are in your holdings.\n\nThe Dashboard is where the you can view your available funds (how much USD you have) and your main portfolio (profit/loss). You can add, remove, and rearrange cryptocurrencies for your liking.\n\nThe Explore tab is where you can view all available cryptocurrencies Cryptfolio supports, you can view price, charts, descriptions and much more to have a better understanding of a specific cryptocurrency and help you in the process if its the right choice to buy, sell or hodl (hold).\n\nThe News tab is where you can view the latest news articles about the realm of cryptocurrencies, you may use this information provided in the news articles to help you choose a cryptocurrency to buy.\n\n The Settings tab is where you can watch short video ads in exchange for useful investing tips and strategies to help grow your portfolio. You can watch another short ad and be rewarded with some bonus cash to help your portfolio grow. Other activities such as social media, and references can be viewed if interested.\n\nLastly I want to give a special thanks to you for choosing Cryptfolio."
        self.aboutView.font = UIFont(name: "Arial", size: 15);
        self.aboutView.font = UIFont.systemFont(ofSize: 15, weight: .thin);
        self.titleLbl.font = UIFont.systemFont(ofSize: 30, weight: .semibold);
        
        
    }
    
    
    @IBAction func tappedXButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    private func updateWithSpacing(lineSpacing: Float) {
        let attributedString = NSMutableAttributedString(string: self.aboutView.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        if let stringLength = self.aboutView.text?.count {
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        self.aboutView.attributedText = attributedString;
    }

}
