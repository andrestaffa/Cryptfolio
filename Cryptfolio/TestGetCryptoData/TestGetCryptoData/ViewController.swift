//
//  ViewController."swift
//  TestGetCryptoData
//
//  Created by Andre Staffa on 2020-04-15.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

var symbols = Array<String>();
var names = Array<String>();
var loading = false;

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getData();

        
    }

    private func getData() -> Void {
        CryptoData.getCryptoData { (ticker, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Name: " + ticker!.name);
                print("Symbol: " + ticker!.symbol)
                print("Rank: " + "\(ticker!.rank)")
                print("Price: " + "\(ticker!.price)")
                print("Change: " + "\(ticker!.changePrecent24H)")
                print("volume24H: " + "\(ticker!.volume24H)");
                print("Market Cap: " + "\(ticker!.marketCap)")
                print("Circulation: " + "\(ticker!.circulation)")
                print(" - - - - - - - - - - - - - - - - - - - -")
            }
        }
    }
    

}

