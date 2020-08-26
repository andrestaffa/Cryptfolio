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
    
    public var amountOfCoins:Array<Double> = Array<Double>();
    public var prices:Array<Double> = Array<Double>();
    public var dateAddedList:Array<String> = Array<String>();
    public var isBuyList:Array<Bool> = Array<Bool>();
    
    
    
    init(ticker:Ticker, amountOfCoin:Double, estCost:Double) {
        self.ticker = ticker;
        self.amountOfCoin = amountOfCoin;
        self.estCost = estCost;
        
        let date = Date(timeIntervalSince1970: Double(Date().timeIntervalSince1970));
        let dateFormatter = DateFormatter();
        dateFormatter.timeStyle = DateFormatter.Style.medium;
        dateFormatter.dateStyle = DateFormatter.Style.medium;
        dateFormatter.timeZone = .current;
        dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss";

        self.amountOfCoins.insert(amountOfCoin, at: 0)
        self.prices.insert(ticker.price, at: 0);
        self.dateAddedList.insert(dateFormatter.string(from: date), at: 0);
        self.isBuyList.insert(true, at: 0);
    }
    
    public func hasCoin() -> Bool {
        if (!self.amountOfCoin.isLessThanOrEqualTo(0.0)) {
            return true;
        } else {
            return false;
        }
    }
    
    public func getNewCurrentDate() -> String {
        let date = Date(timeIntervalSince1970: Double(Date().timeIntervalSince1970))
        let dateFormatter = DateFormatter();
        dateFormatter.timeStyle = DateFormatter.Style.medium;
        dateFormatter.dateStyle = DateFormatter.Style.medium;
        dateFormatter.timeZone = .current;
        dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss";
        return dateFormatter.string(from: date);
    }
    
    
}
