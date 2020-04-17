//
//  CryptoData.swift
//  TestGetCryptoData
//
//  Created by Andre Staffa on 2020-04-16.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import Alamofire;

public struct Ticker {
    let name:String;
    let symbol:String;
    let rank:Int;
    let price:Double;
    let changePrecent24H:Double;
    let volume24H:Double;
    let marketCap:Double;
    let circulation:Double;
    let description:String
}

public class CryptoData {
    
    public static func getCryptoData(completion:@escaping (Ticker?, Error?) -> Void) {
        let symbols = readTextToArray(path: "Data.bundle/cryptoTickers");
        let names = readTextToArray(path: "Data.bundle/cryptoNames");
        let descriptions = readTextToArray(path: "Data.bundle/cryptoDescriptions");
        var longString:String = "";
        for symbol in symbols! {
            longString += symbol + ",";
        }
        longString.removeLast();
        let url:URL = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=" + longString + "&tsyms=USD")!
         AF.request(url).responseJSON { response in
             if let json = response.value {
                for index in 0...symbols!.count - 1 {
                    let jsonObject:Dictionary = json as! Dictionary<String, Any>;
                    let dataObject:Dictionary = jsonObject["RAW"] as! Dictionary<String, Any>;
                    let coin:Dictionary = dataObject[symbols![index]] as! Dictionary<String, Any>;
                    let USD_lbl:Dictionary = coin["USD"] as! Dictionary<String, Any>;
                    let price:Double = (USD_lbl["PRICE"] as? Double)!;
                    let changePercent24H:Double = (USD_lbl["CHANGEPCT24HOUR"] as? Double)!;
                    let volume24H:Double = (USD_lbl["VOLUME24HOUR"] as? Double)!;
                    let marketCap:Double = (USD_lbl["MKTCAP"] as? Double)!;
                    let circulation:Double = (USD_lbl["SUPPLY"] as? Double)!;
                    let ticker = Ticker(name: names![index], symbol: symbols![index], rank: index+1, price: price, changePrecent24H: changePercent24H, volume24H: volume24H, marketCap: marketCap, circulation: circulation, description: descriptions![index])
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
