//
//  Coin.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-03.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation
import UIKit;

public struct Image: Codable {
    let imageData: Data?
    
    init(withImage image: UIImage) {
        self.imageData = image.pngData()
    }

    func getImage() -> UIImage? {
        guard let imageData = self.imageData else {
            return nil
        }
        let image = UIImage(data: imageData)
        
        return image
    }
}

public class Coin : NSObject, Codable {
    public var ticker:Ticker;
    public var image:Image;
    
    init(ticker:Ticker, image:Image) {
        self.ticker = ticker;
        self.image = image;
    }
    
}
