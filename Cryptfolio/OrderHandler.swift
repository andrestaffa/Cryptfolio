//
//  OrderHandler.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-15.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

public class OrderHandler {
    
    public static func buy(amountCost:Double, amountOfCoin:Double, ticker:Ticker) -> Bool {
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            if (currentFunds!.isZero) {
                betterAlert(title: "Sorry", message: "Insufficient funds");
                return false;
            }
            print("Current Funds: \(currentFunds!)");
            print("Amount Cost: \(amountCost)");
            if (currentFunds!.isLess(than: amountCost)) {
                betterAlert(title: "Sorry", message: "Insufficient funds");
                return false;
            } else {
                let updatedFunds:Double = currentFunds! - amountCost;
                UserDefaults.standard.set(updatedFunds, forKey: UserDefaultKeys.availableFundsKey);
                // update main portfolio
                let mainPortfolio = UserDefaults.standard.value(forKey: UserDefaultKeys.mainPortfolioKey) as? Double;
                if (mainPortfolio != nil) {
                    if (mainPortfolio!.isZero) {
                        print("cool 1")
                        UserDefaults.standard.set(amountCost, forKey: UserDefaultKeys.mainPortfolioKey);
                    } else {
                        let updatedMainPortfolio:Double = mainPortfolio! + amountCost;
                        UserDefaults.standard.set(updatedMainPortfolio, forKey: UserDefaultKeys.mainPortfolioKey);
                    }
                } else {
                    print("cool 2")
                    UserDefaults.standard.set(amountCost, forKey: UserDefaultKeys.mainPortfolioKey);
                }
                
                var holdings = Array<Holding>();
                
                // load holdings if it exists
                if let loadedholdings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                    holdings = loadedholdings;
                }
                
                let hold = Holding(ticker: ticker, amountOfCoin: amountOfCoin, estCost: amountCost);
                if (!holdings.contains(where: { (holding) -> Bool in
                    return holding.ticker.name == hold.ticker.name;
                })) {
                    holdings.append(hold);
                } else {
                    for i in 0...holdings.count - 1 {
                        if (holdings[i].ticker.name == hold.ticker.name) {
                            let prevHolding = holdings[i];
                            prevHolding.amountOfCoin += hold.amountOfCoin;
                            prevHolding.estCost += hold.estCost; // might be an issue
                            prevHolding.ticker = hold.ticker;
                            prevHolding.amountOfCoins.insert(amountOfCoin, at: 0);
                            prevHolding.prices.insert(ticker.price, at: 0);
                            prevHolding.dateAddedList.insert(prevHolding.getNewCurrentDate(), at: 0);
                            prevHolding.isBuyList.insert(true, at: 0);
                        }
                    }
                }
                // save the holdings array
                DataStorageHandler.saveObject(type: holdings, forKey: UserDefaultKeys.holdingsKey);
                DatabaseManager.writeHighscoreAndHoldings { (error) in
                    if let error = error { print(error.localizedDescription); } else { print("Success in sell method!"); }
                }
                return true;
            }
        } else {
            betterAlert(title: "Sorry", message: "Insufficient funds");
            print("Current Funds: nil or 0.00");
            print("Amount Cost: \(amountCost)");
            return false;
        }
    }
    
    public static func sell(amountCost:Double, amountOfCoin:Double, ticker:Ticker)  -> Bool {
        
        var holdings = Array<Holding>();
        
        //load in how much the coin the user own's
        var currentAmountOfCoin:Double = 0.0;
        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
            holdings = loadedHoldings;
            for holding in loadedHoldings {
                if (holding.ticker.name == ticker.name) {
                    currentAmountOfCoin = holding.amountOfCoin;
                }
            }
        } else {
            betterAlert(title: "Sorry", message: "You do not own \(String(format: "%.2f", amountOfCoin)) amount of \(ticker.symbol.uppercased()) to sell.");
            return false;
        }
        
        // load in avialbale funds
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds != nil) {
            print("AMOUNT OF COIN: \(amountOfCoin)");
            print("CURRENT AMOUNT OF COIN: \(currentAmountOfCoin)");
            if (!amountOfCoin.isLessThanOrEqualTo(currentAmountOfCoin)) { // MIGHT NEED TO REMOVE "round()"
                betterAlert(title: "Sorry", message: "You do not own \(String(format: "%.2f", amountOfCoin)) \(ticker.symbol.uppercased()) to sell.");
                return false;
            } else {
                // update the current holdings of the coin being sold
                for i in 0...holdings.count - 1 {
                    if (holdings[i].ticker.name == ticker.name) {
                        let prevHolding = holdings[i];
                        prevHolding.amountOfCoin -= amountOfCoin;
                        if (prevHolding.amountOfCoin.isLess(than: 0.0) || OrderHandler.almostEqual(prevHolding.amountOfCoin, 0.0)) { prevHolding.amountOfCoin = 0.00 }
                        prevHolding.estCost -= amountCost;
                        if (prevHolding.ticker.name == ticker.name && prevHolding.estCost.isLess(than: 0.0) || OrderHandler.almostEqual(prevHolding.estCost, 0.0)) { prevHolding.estCost = 0.00; }
                        prevHolding.ticker = ticker;
                        prevHolding.amountOfCoins.insert(amountOfCoin, at: 0);
                        prevHolding.prices.insert(ticker.price, at: 0);
                        prevHolding.dateAddedList.insert(prevHolding.getNewCurrentDate(), at: 0);
                        prevHolding.isBuyList.insert(false, at: 0);
                        
                    }
                }
                DataStorageHandler.saveObject(type: holdings, forKey: UserDefaultKeys.holdingsKey);
                
                // update available funds
                let updatedFunds = currentFunds! + amountCost;
                UserDefaults.standard.set(updatedFunds, forKey: UserDefaultKeys.availableFundsKey);
                
                // update main portfilio
                let mainPortfolio = UserDefaults.standard.value(forKey: UserDefaultKeys.mainPortfolioKey) as? Double;
                if (mainPortfolio != nil) {
                    let updatedMainPort = mainPortfolio! - amountCost;
                    var sum:Double = 0.0;
                    for holding in holdings {
                        sum += holding.amountOfCoin;
                    }
                    
                    // calcualte the correct portfolio based upon certain cases
                    sum.isZero || updatedMainPort.isLessThanOrEqualTo(0.0) ? UserDefaults.standard.set(0.00, forKey: UserDefaultKeys.mainPortfolioKey) : UserDefaults.standard.set(updatedMainPort, forKey: UserDefaultKeys.mainPortfolioKey);
                    
                } else {
                    // this should NOT happen, when ever you sell something, the main portfolio should always have value;
                    UserDefaults.standard.set(0.00, forKey: UserDefaultKeys.mainPortfolioKey);
                }
                DatabaseManager.writeHighscoreAndHoldings { (error) in
                    if let error = error { print(error.localizedDescription); } else { print("Success in sell method!"); }
                }
                return true;
            }
        } else {
            // user does have any money, but they own some of the coin, so updated their funds when the sell it
            UserDefaults.standard.set(amountCost, forKey: UserDefaultKeys.availableFundsKey);
            DatabaseManager.writeHighscoreAndHoldings { (error) in
                if let error = error { print(error.localizedDescription); } else { print("Success in sell method!"); }
            }
            return true;
        }
    }
    
    
    
    private static func betterAlert(title:String, message:String) -> Void {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK");
        alert.show();
    }
    
    static func almostEqual(_ a: Double, _ b: Double) -> Bool {
        return a >= b.nextDown && a <= b.nextUp
    }
    

}
