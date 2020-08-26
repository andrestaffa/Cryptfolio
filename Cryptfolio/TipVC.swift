//
//  TipVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-08-20.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class TipVC: UIViewController {

    @IBOutlet weak var paragraphView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    public var tip:Tip? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateWithSpacing(lineSpacing: 10.0);
        self.paragraphView.font = UIFont(name: "Arial", size: 15);
        self.paragraphView.font = UIFont.systemFont(ofSize: 15, weight: .thin);
        self.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold);
        self.titleLabel.text = self.tip!.title;
        self.paragraphView.text = self.tip!.paragraph;
        
    }
    
    @IBAction func tappedXButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    private func updateWithSpacing(lineSpacing: Float) {
        let attributedString = NSMutableAttributedString(string: self.paragraphView.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        if let stringLength = self.paragraphView.text?.count {
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        self.paragraphView.attributedText = attributedString;
    }

}
