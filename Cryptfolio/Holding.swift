//
//  Holding.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-07.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

public class Holding: NSObject, Codable {
    public var ticker:Ticker;
    public var amountOfCoin:Double;
    public var estCost:Double;
    // possible date
    
    init(ticker:Ticker, amountOfCoin:Double, estCost:Double) {
        self.ticker = ticker;
        self.amountOfCoin = amountOfCoin;
        self.estCost = estCost;
        // possible date
    }
    
    public func hasCoin() -> Bool {
        if (!self.amountOfCoin.isLessThanOrEqualTo(0.0)) {
            return true;
        } else {
            return false;
        }
    }
    
}
