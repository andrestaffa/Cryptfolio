//
//  InfoVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-02-19.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit
import SwiftChart;

class InfoVC: UIViewController, UIScrollViewDelegate {
    
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
    
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self;
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
            self.change_lbl.textColor = UIColor.red;
        } else {
            self.change_lbl.textColor = UIColor.green;
        }
        
    }
    
    // MARK: - Scroll view methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //let topBarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
        self.lastContentOffset = scrollView.contentOffset.y;
        if (lastContentOffset >= 0.01) {
            self.navigationItem.titleView?.isHidden = false;
        } else {
            self.navigationItem.titleView?.isHidden = true;
        }
        
    }
    
    

}
