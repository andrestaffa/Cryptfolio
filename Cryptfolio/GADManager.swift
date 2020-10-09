//
//  GADManager.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-27.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import GoogleMobileAds;


public class GADManager {
    
    public static var rewardedAd:GADRewardedAd?;
    public static var isLoadingAd:Bool = false;
    private static let adUnit = "ca-app-pub-1350200849096335/9735345093";
    private static let adUnitTest = "ca-app-pub-3940256099942544/1712485313";
    
    public static func createAndLoadRewardedAd(completion:@escaping (Error?) -> Void) -> GADRewardedAd? {
        GADManager.isLoadingAd = true;
        rewardedAd = GADRewardedAd(adUnitID: adUnit);
        rewardedAd?.load(GADRequest(), completionHandler: { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil);
            }
        })
        return rewardedAd;
    }

}
