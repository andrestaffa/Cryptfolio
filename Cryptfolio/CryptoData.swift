//
//  CryptoData.swift
//  TestGetCryptoData
//
//  Created by Andre Staffa on 2020-04-16.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import Alamofire;

public struct Ticker : Codable {
    let id:Int;
    let name:String;
    let symbol:String;
    let rank:Int;
    var price:Double;
    let changePrecent24H:Double;
    let volume24H:Double;
    let marketCap:Double;
    let circulation:Double;
    var description:String
    let website:String;
    let allTimeHigh:Double
    let history24h:[Double]
}

public struct News : Codable {
    let title:String;
    let source:String;
    let publishedOn:Double;
    let url:String;
}

public struct History : Codable {
    let prices:[Double]
    let timestamps:[Double];
}

public struct PortfolioData : Codable {
    let currentPrice:Double;
    let currentDate:String;
}

public struct CoinMap : Codable {
    var coinMap:Dictionary<String, String>;
}

public class CryptoData {
    
    public static func getCoinHistory(id: String, timeFrame:String, completion:@escaping (History?, Error?) -> Void) -> Void {
        let url = URL(string: "https://api.coinranking.com/v2/coin/\(id)/history?timePeriod=\(timeFrame)");
        if (url == nil) {
            print("error loading history, url was nil");
            return;
        }
        AF.request(url!).responseJSON { (response) in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let historys = data["history"] as! [[String: Any]];
                var prices = [Double]();
                var timestamps = [Double]();
                for i in 0...historys.count - 1 {
                    let price = historys[i]["price"] as? String;
                    let timestamp = historys[i]["timestamp"] as? Double;
                    let priceDouble = Double(price ?? "0.0");
                    let timestampDouble = Double(timestamp ?? 0);
                    prices.append(priceDouble!);
                    timestamps.append(timestampDouble);
                }
                completion(History(prices: prices, timestamps: timestamps), nil);
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getNewsData(completion:@escaping (News?, Error?) -> Void) -> Void {
        let url = URL(string: "https://min-api.cryptocompare.com/data/v2/news/?lang=EN");
        if (url == nil) {
            print("url was nil");
            return;
        }
        AF.request(url!).responseJSON { (response) in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data = jsonObject["Data"] as! [Dictionary<String, Any>];
                for index in 0...data.count - 1 {
                    let title = data[index]["title"] as! String;
                    let sourceInfo:Dictionary = data[index]["source_info"] as! Dictionary<String, Any>;
                    let source = sourceInfo["name"] as! String;
                    let publishedOn = data[index]["published_on"] as! Double;
                    let urlString = data[index]["url"] as! String;
                    let news = News(title: title, source: source, publishedOn: publishedOn, url: urlString);
                    completion(news, nil);
                }
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getCoinData(id: String, completion:@escaping (Ticker?, Error?) -> Void) -> Void {
        let url = URL(string: "https://api.coinranking.com/v2/coin/\(id)");
        if (url == nil) {
            return;
        }
        AF.request(url!).responseJSON { (response) in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let coin:Dictionary = data["coin"] as! Dictionary<String, Any>;
                // get properties
                let id = 9999;
                let name = coin["name"] as? String;
                let symbol = coin["symbol"] as? String;
                let rank = coin["rank"] as? Int;
                let priceString = coin["price"] as? String;
                let changeString =  coin["change"] as? String;
                let volumeString = coin["24hVolume"] as? String;
                let marketCapString = coin["marketCap"] as? String;
                let price  = Double(priceString ?? "0.0");
                let change = Double(changeString ?? "0.0");
                let volume = Double(volumeString ?? "0.0");
                let marketCap = Double(marketCapString ?? "0.0");
                let supply = coin["supply"] as? Dictionary<String, Any>;
                var circulation:Double = 0.0;
                if let supply = supply {
                    let circulationString = supply["circulating"] as? String;
                    circulation = Double(circulationString ?? "0.0")!;
                }
                let description = coin["description"] as? String;
                let website = coin["websiteUrl"] as? String;
                let allTimeHigh = coin["allTimeHigh"] as! Dictionary<String, Any>;
                let allTimeHighPriceString = allTimeHigh["price"] as? String
                let allTimeHighPriceDouble = Double(allTimeHighPriceString ?? "0.0");
                let history24hString = coin["sparkline"] as? [String?];
                var historyDouble = [Double]();
                if (history24hString != nil) {
                    for priceString in history24hString! {
                        if (priceString != nil) {
                            historyDouble.append(Double(priceString!)!);
                        }
                    }
                } else {
                    historyDouble = [Double]();
                }
                let ticker = Ticker(id: id, name: name ?? "No Name", symbol: symbol ?? "No symbol", rank: rank ?? 0, price: price!, changePrecent24H: change ?? 0.0, volume24H: volume ?? 0.0, marketCap: marketCap ?? 0.0, circulation: circulation, description: description ?? "No Description Available", website: website ?? "No Website Available", allTimeHigh: allTimeHighPriceDouble!, history24h: historyDouble)
                completion(ticker, nil);
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getCryptoData(completion:@escaping (Array<Ticker>?, Error?) -> Void) -> Void {
        let url = URL(string: "https://api.coinranking.com/v2/coins?limit=100");
        if (url == nil) {
            return;
        }
        AF.request(url!).responseJSON { response in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let coins = data["coins"] as! [[String: Any]];
                var tickerList:Array<Ticker> = Array<Ticker>();
                for i in 0...coins.count - 1 {
                    let id = 9999;
                    let name = coins[i]["name"] as? String;
                    let symbol = coins[i]["symbol"] as? String;
                    let rank = coins[i]["rank"] as? Int;
                    let priceString = coins[i]["price"] as? String;
                    let changeString =  coins[i]["change"] as? String;
                    let volumeString = coins[i]["24hVolume"] as? String;
                    let marketCapString = coins[i]["marketCap"] as? String;
                    let price  = Double(priceString ?? "0.0");
                    let change = Double(changeString ?? "0.0");
                    let volume = Double(volumeString ?? "0.0");
                    let marketCap = Double(marketCapString ?? "0.0");
                    let history24hString = coins[i]["sparkline"] as? [String?];
                    var historyDouble = [Double]();
                    if (history24hString != nil) {
                        for priceString in history24hString! {
                            if (priceString != nil) {
                                historyDouble.append(Double(priceString!)!);
                            }
                        }
                    } else {
                        historyDouble = [Double]();
                    }
                    let ticker = Ticker(id: id, name: name ?? "No Name", symbol: symbol ?? "No symbol", rank: rank ?? 0, price: price!, changePrecent24H: change ?? 0.0, volume24H: volume ?? 0.0, marketCap: marketCap ?? 0.0, circulation: 0.0, description: "No Description Available", website: "No Website Available", allTimeHigh: 0.0, history24h: historyDouble)
                    tickerList.append(ticker);
                }
                completion(tickerList, nil);
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getCryptoID(coinSymbol:String, completion:@escaping (String?, Error?) -> Void) -> Void {
        if let coinMap = DataStorageHandler.loadObject(type: CoinMap.self, forKey: UserDefaultKeys.coinMap) {
            if let uuid = coinMap.coinMap[coinSymbol] {
                print("CACHED!!");
                completion(uuid, nil);
                return;
            }
        }
        let url = URL(string: "https://api.coinranking.com/v2/coins?limit=100");
        if (url == nil) {
            print("URL IS NIL");
            completion(nil, nil);
            return;
        }
        AF.request(url!).responseJSON { response in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let coins = data["coins"] as! [[String: Any]];
                for i in 0...coins.count - 1 {
                    let symbol = coins[i]["symbol"] as! String;
                    if (symbol.lowercased() == coinSymbol.lowercased()) {
                        let uuid = coins[i]["uuid"] as! String;
                        if var coinMap = DataStorageHandler.loadObject(type: CoinMap.self, forKey: UserDefaultKeys.coinMap) {
                            coinMap.coinMap[coinSymbol] = uuid;
                            DataStorageHandler.saveObject(type: coinMap, forKey: UserDefaultKeys.coinMap);
                        } else {
                            var coinMap:CoinMap = CoinMap(coinMap: Dictionary<String, String>());
                            coinMap.coinMap[coinSymbol] = uuid;
                            DataStorageHandler.saveObject(type: coinMap, forKey: UserDefaultKeys.coinMap);
                        }
                        completion(uuid, nil);
                        break;
                    }
                }
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func readTextToArray(path:String) -> Array<String>? {
        var arrayOfStrings: Array<String>?
        do {
            // This solution assumes  you've got the file in your bundle
            if let path = Bundle.main.path(forResource: path, ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8);
                arrayOfStrings = data.components(separatedBy: "\n");
                arrayOfStrings!.remove(at: arrayOfStrings!.count - 1);
//                for index in 0...arrayOfStrings!.count - 1 {
//                    arrayOfStrings![index].removeLast();
//                }
                return arrayOfStrings;
            }
        } catch let err as NSError {
            arrayOfStrings = [String()];
            print(err);
            return arrayOfStrings;
        }
        arrayOfStrings = [String()];
        return arrayOfStrings;
    }
    
    public static func styleTextField(textField: UITextField, width:CGFloat, color:UIColor) {
        let bottomLine = CALayer();
        bottomLine.frame = CGRect(x: 0.0, y: 30.0, width: width, height: 1.0);
        bottomLine.backgroundColor = color.cgColor;
        textField.borderStyle = .none;
        textField.layer.addSublayer(bottomLine);
    }
    
    public static func styleTextFieldsOnEditing(textField:UITextField, width:CGFloat, weight:UIFont.Weight, color:UIColor, labelColor:UIColor) -> Void {
        self.styleTextField(textField: textField, width: width, color: color);
    }
    
    private static func formatPrice(price:Double) -> (String, Double) {
        var priceString = String(price);
        priceString.removeFirst();
        var otherPrice = String(price);
        otherPrice.removeFirst();
        otherPrice.removeFirst();
        if (String(price).first == "0" || priceString.first == ".") {
            return ("\(String(format: "%.7f", price))", 10000000);
        } else if (otherPrice.first == ".") {
            return ("\(String(format: "%.2f", price))", 100);
        } else {
            return ("\(String(format: "%.2f", price))", 100)
        }
    }
    
    public static func convertToDollar(price:Double, hasSymbol:Bool) -> String {
        var number: NSNumber!;
        let formatter = NumberFormatter();
        formatter.numberStyle = .currencyAccounting;
        //formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 7;
        formatter.minimumFractionDigits = 2;
        
        let priceData = CryptoData.formatPrice(price: price);
        let price = priceData.0;
        var amountWithPrefix = price;

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive);
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, price.count), withTemplate: "");

        let double = (amountWithPrefix as NSString).doubleValue;
        number = NSNumber(value: double / priceData.1);

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return hasSymbol ? "$0.00" : "0.00";
        }
        if (hasSymbol) {
            return formatter.string(from: number)!
        } else {
            var calcString = formatter.string(from: number)!;
            calcString.remove(at: calcString.startIndex);
            return calcString;
        }
        
    }
    
    public static func convertToMoney(price:String) -> String {
        var number: NSNumber!;
        let formatter = NumberFormatter();
        formatter.numberStyle = .currencyAccounting;
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;

        var amountWithPrefix = price;

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive);
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, price.count), withTemplate: "");

        let double = (amountWithPrefix as NSString).doubleValue;
        number = NSNumber(value: double / 100);

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return "$0.00";
        }
        return formatter.string(from: number)!
        
    }
    
}

