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

public class CryptoData {
    
//    public static func getCryptoData(completion:@escaping (Ticker?, Error?) -> Void) {
//        let symbols = readTextToArray(path: "Data.bundle/cryptoTickers");
//        let names = readTextToArray(path: "Data.bundle/cryptoNames");
//        let descriptions = readTextToArray(path: "Data.bundle/cryptoDescriptionsNew");
//        let websites = readTextToArray(path: "Data.bundle/cryptoWebsites");
//        let reddit = readTextToArray(path: "Data.bundle/cryptoReddit");
//        var longString:String = "";
//        for symbol in symbols! {
//            longString += symbol + ",";
//        }
//        longString.removeLast();
//        let url:URL = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=" + longString + "&tsyms=USD")!
//         AF.request(url).responseJSON { response in
//             if let json = response.value {
//                for index in 0...symbols!.count - 1 {
//                    let jsonObject:Dictionary = json as! Dictionary<String, Any>;
//                    let dataObject:Dictionary = jsonObject["RAW"] as! Dictionary<String, Any>;
//                    let coin:Dictionary = dataObject[symbols![index]] as! Dictionary<String, Any>;
//                    let USD_lbl:Dictionary = coin["USD"] as! Dictionary<String, Any>;
//                    let price:Double = (USD_lbl["PRICE"] as? Double)!;
//                    let changePercent24H:Double = (USD_lbl["CHANGEPCT24HOUR"] as? Double)!;
//                    let volume24H:Double = (USD_lbl["VOLUME24HOUR"] as? Double)!;
//                    let marketCap:Double = (USD_lbl["MKTCAP"] as? Double)!;
//                    let circulation:Double = (USD_lbl["SUPPLY"] as? Double)!;
//                    let ticker = Ticker(name: names![index], symbol: symbols![index], rank: index+1, price: price, changePrecent24H: changePercent24H, volume24H: volume24H, marketCap: marketCap, circulation: circulation, description: descriptions![index], website: websites![index], redditLink: reddit![index]);
//                    completion(ticker, nil);
//                }
//
//             } else if let error = response.error {
//                 completion(nil, error);
//             }
//         }
//     }
    
    
    public static func getCryptoData(index:Int, completion:@escaping (Ticker?, Error?) -> Void) -> Void {
        if (index < 0) {
            print("Index must be greater or eqaul to 0");
            return;
        }
        let url = URL(string: "https://api.coinranking.com/v1/public/coins?limit=100");
        if (url == nil) {
            return;
        }
        AF.request(url!).responseJSON { response in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let coins = data["coins"] as! [[String: Any]];
                let name = coins[index]["name"] as? String;
                let symbol = coins[index]["symbol"] as? String;
                let rank = coins[index]["rank"] as? Int;
                let priceString = coins[index]["price"] as? String;
                let price  = Double(priceString ?? "0.0");
                let change =  coins[index]["change"] as? Double;
                let volume = coins[index]["volume"] as? Double;
                let marketCap = coins[index]["marketCap"] as? Double;
                let circulation = coins[index]["circulatingSupply"] as? Double;
                let description = coins[index]["description"] as? String;
                let website = coins[index]["websiteUrl"] as? String;
                let allTimeHigh = coins[index]["allTimeHigh"] as! Dictionary<String, Any>;
                let allTimeHighPriceString = allTimeHigh["price"] as? String
                let allTimeHighPriceDouble = Double(allTimeHighPriceString ?? "0.0");
                let history24hString = coins[index]["history"] as? [String];
                var historyDouble = [Double]();
                if (history24hString != nil) {
                    historyDouble = history24hString!.map { Double($0) } as! [Double]
                } else {
                    historyDouble = [Double]();
                }
                let ticker = Ticker(name: name ?? "No Name", symbol: symbol ?? "No symbol", rank: rank ?? 0, price: price!, changePrecent24H: change ?? 0.0, volume24H: volume ?? 0.0, marketCap: marketCap ?? 0.0, circulation: circulation ?? 0.0, description: description ?? "No Description Available", website: website ?? "No Website Available", allTimeHigh: allTimeHighPriceDouble!, history24h: historyDouble)
                completion(ticker, nil);
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    public static func getCryptoData(completion:@escaping (Ticker?, Error?) -> Void) -> Void {
        let url = URL(string: "https://api.coinranking.com/v1/public/coins?limit=100");
        if (url == nil) {
            return;
        }
        AF.request(url!).responseJSON { response in
            if let json = response.value {
                let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                let data:Dictionary = jsonObject["data"] as! Dictionary<String, Any>;
                let coins = data["coins"] as! [[String: Any]];
                for i in 0...coins.count - 1 {
                    let name = coins[i]["name"] as? String;
                    let symbol = coins[i]["symbol"] as? String;
                    let rank = coins[i]["rank"] as? Int;
                    let priceString = coins[i]["price"] as? String;
                    let price  = Double(priceString ?? "0.0");
                    let change =  coins[i]["change"] as? Double;
                    let volume = coins[i]["volume"] as? Double;
                    let marketCap = coins[i]["marketCap"] as? Double;
                    let circulation = coins[i]["circulatingSupply"] as? Double;
                    let description = coins[i]["description"] as? String;
                    let website = coins[i]["websiteUrl"] as? String;
                    let allTimeHigh = coins[i]["allTimeHigh"] as! Dictionary<String, Any>;
                    let allTimeHighPriceString = allTimeHigh["price"] as? String
                    let allTimeHighPriceDouble = Double(allTimeHighPriceString ?? "0.0");
                    let history24hString = coins[i]["history"] as? [String];
                    var historyDouble = [Double]();
                    if (history24hString != nil) {
                        historyDouble = history24hString!.map { Double($0) } as! [Double]
                    } else {
                        historyDouble = [Double]();
                    }
                    let ticker = Ticker(name: name ?? "No Name", symbol: symbol ?? "No symbol", rank: rank ?? 0, price: price!, changePrecent24H: change ?? 0.0, volume24H: volume ?? 0.0, marketCap: marketCap ?? 0.0, circulation: circulation ?? 0.0, description: description ?? "No Description Available", website: website ?? "No Website Available", allTimeHigh: allTimeHighPriceDouble!, history24h: historyDouble)
                    completion(ticker, nil);
                }
            } else if let error = response.error {
                completion(nil, error);
            }
        }
    }
    
    private static func readTextToArray(path:String) -> Array<String>? {
        var arrayOfStrings: Array<String>?
        do {
            // This solution assumes  you've got the file in your bundle
            if let path = Bundle.main.path(forResource: path, ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8);
                arrayOfStrings = data.components(separatedBy: "\n");
                arrayOfStrings!.remove(at: arrayOfStrings!.count - 1);
                for index in 0...arrayOfStrings!.count - 1 {
                    arrayOfStrings![index].removeLast();
                }
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
    
}
