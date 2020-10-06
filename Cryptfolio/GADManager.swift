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
    
    public static func createAndLoadRewardedAd(completion:@escaping () -> Void) -> GADRewardedAd? {
        GADManager.isLoadingAd = true;
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-1350200849096335/1509192136");
        rewardedAd?.load(GADRequest(), completionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                completion();
            }
        })
        return rewardedAd;
    }
    
}
