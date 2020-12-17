//
//  UserDefaultKeys.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-06.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation
import  UIKit;

public class UserDefaultKeys {
    
    // Coin Managment
    public static let coinKey = "coinKey";
    public static let coinArrayKey = "coinArrayKey";
    public static let availableFundsKey = "availableFundsKey";
    public static let mainPortfolioKey = "mainPortfolioKey";
    public static let holdingsKey = "holdingsKey";
    public static let mainPortChange = "mainPortChange";
    public static let cumulativeAdMoney = "cumulativeAdMoney";
    public static let loginPressed = "loginPressed";
    
    // Investing Tips
    public static let affectUsers = "affectedUsers";
    public static let investingTipsKey = "investingTipsKey";
    public static let randomIndex = "randomIndex";
    
    // Leaderboard
    public static let username = "username";
    
    // Traking Data
    public static let mainPortfolioGraph = "mainPortfolioGraph";
    
    // first time lanching app
    public static let isNotFirstTime = "isNotFirstTime";
    public static let didAnimateWithOneCoin = "didAnimateWithOneCoin";
    
    // User Notifications keys
    public static let dailyReminder = "dailyReminder";
    
}
