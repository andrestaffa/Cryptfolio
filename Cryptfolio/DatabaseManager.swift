//
//  DatabaseManager.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-02.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;
import SVProgressHUD;
import FirebaseFirestore;


public struct User : Codable {
    let rank:String;
    let email:String;
    let username:String;
    let highscore:Double;
    let change:String;
    let numberOfOwnedCoin:Int;
    let highestHolding:String;
}


public class DatabaseManager {
    
    private static let db = Firestore.firestore();
    private static let userServer = "users";  // Test Server: users-dev
                                                  // Production Server: users
    
    
    // MARK: Test Methods for encoding and decoding
    
    public static func writeObjects<T : Codable>(username:String, type: T, typeName:String, completion:@escaping(Error?) -> Void) -> Void {
        if let data = DataStorageHandler.encodeTypeIntoJSON(type: type) {
            db.collection(userServer).document(username).setData([typeName: data], merge: true, completion: completion);
        } else {
            print("The type inputted is nil! Not uploading to database");
        }
    }
    
    public static func getObjects<T : Codable>(username:String, type: T.Type, typeName:String, completion:@escaping(Any?, Error?) -> Void) -> Void {
        db.collection(userServer).getDocuments { (snapshot, error) in
            if let error = error { print(error.localizedDescription) } else {
                if let snapshot = snapshot {
                    for i in 0...snapshot.documents.count - 1 {
                        let docData = snapshot.documents[i].data();
                        if (docData["username"] as! String == username) {
                            let objects = docData[typeName] as? Array<Dictionary<String, Any>>;
                            if (objects == nil) { completion(nil, nil); return; }
                            if let object = DataStorageHandler.decodeTypeFromJSON(type: T.self, jsonData: objects!) {
                                completion(object, nil);
                                break;
                            }
                        }
                    }
                } else {
                    completion(nil, error);
                }
            }
        }
    }
    
    
    // MARK: Main Methods
    
    public static func writeUserData(username:String, password:String, highscore:Double, change:String, merge:Bool, completion:@escaping(Error?) -> Void) -> Void {
        db.collection(userServer).document(username).setData(["username":username, "hashedPassword":password, "highscore":highscore, "change":change], merge: merge, completion: completion);
    }

    public static func writeUserData(username:String, merge:Bool, data:[String : Any], completion:@escaping(Error?) -> Void) -> Void {
        db.collection(userServer).document(username).setData(data, merge: merge, completion: completion);
    }
    
    public static func changeUsername(oldUsername:String, newUsername:String, completion:@escaping(Error?) -> Void) -> Void {
        db.collection(userServer).document(oldUsername).setData(["username":newUsername], merge: true, completion: completion);
    }
    
    public static func writeHighscoreAndHoldings(change:String, completion:@escaping(Error?) -> Void) -> Void {
        if let currentUsername = UserDefaults.standard.string(forKey: UserDefaultKeys.currentUsername) {
            var highscore:Double = 0.0;
            if (UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange) != 0 && !UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortfolioKey).isLessThanOrEqualTo(0.0)) {
                highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange);
            } else {
                highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey);
            }
            
            var highestHolding:String = "NA";
            var numberOfCoins:Int = 0;
            if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                if (!loadedHoldings.isEmpty) {
                    let hold = loadedHoldings.max { (holding, nextHolding) -> Bool in
                        return holding.estCost < nextHolding.estCost;
                    }
                    if (hold!.amountOfCoin > 0) {
                        highestHolding = hold!.ticker.symbol.uppercased();
                    }
                    let filteredHoldingList = loadedHoldings.filter({ (holding) -> Bool in
                        return holding.amountOfCoin > 0;
                    })
                    numberOfCoins = filteredHoldingList.count;
                }
                if let data = DataStorageHandler.encodeTypeIntoJSON(type: loadedHoldings) {
                    db.collection(userServer).document(currentUsername).setData(["highscore": highscore, "numberOfOwnedCoin":numberOfCoins, "highestHolding":highestHolding, "change":change, "holdings": data], merge: true, completion: completion);
                } else {
                    print("The type inputted is nil! Not uploading to database");
                }
            } else { print("There are no holdings to upload."); }
        } else {
            print("No user was logged in. Not saving data...");
        }
    }
    
    public static func writeHighscoreAndHoldings(completion:@escaping(Error?) -> Void) -> Void {
        if let currentUsername = UserDefaults.standard.string(forKey: UserDefaultKeys.currentUsername) {
            var highscore:Double = 0.0;
            if (UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange) != 0 && !UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortfolioKey).isLessThanOrEqualTo(0.0)) {
                highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange);
            } else {
                highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey);
            }
            
            var highestHolding:String = "NA";
            var numberOfCoins:Int = 0;
            if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                if (!loadedHoldings.isEmpty) {
                    let hold = loadedHoldings.max { (holding, nextHolding) -> Bool in
                        return holding.estCost < nextHolding.estCost;
                    }
                    if (hold!.amountOfCoin > 0) {
                        highestHolding = hold!.ticker.symbol.uppercased();
                    }
                    let filteredHoldingList = loadedHoldings.filter({ (holding) -> Bool in
                        return holding.amountOfCoin > 0;
                    })
                    numberOfCoins = filteredHoldingList.count;
                }
                if let data = DataStorageHandler.encodeTypeIntoJSON(type: loadedHoldings) {
                    db.collection(userServer).document(currentUsername).setData(["highscore": highscore, "numberOfOwnedCoin":numberOfCoins, "highestHolding":highestHolding, "holdings": data], merge: true, completion: completion);
                } else {
                    print("The type inputted is nil! Not uploading to database");
                }
            } else { print("There are no holdings to upload."); }
        } else {
            print("No user was logged in. Not saving data...");
        }
    }
    
    public static func writeUserData(email:String, username:String, highscore:Double, change:String, numberOfOwnedCoin:Int, highestHolding:String, merge:Bool, viewController:UIViewController, isPortVC:Bool) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection(userServer).document(username).setData(["email":email, "username":username, "highscore":highscore, "change":change, "numberOfOwnedCoin":numberOfOwnedCoin, "highestHolding":highestHolding], merge: merge) { (error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                    DatabaseManager.writeObjects(username: username, type: loadedHoldings, typeName: "holdings") { (error) in
                        if let error = error { print(error.localizedDescription); } else {
                            SVProgressHUD.dismiss();
                            if let leaderboardVC = viewController.storyboard?.instantiateViewController(identifier: "leaderboardVC", creator: { (coder) -> LeaderboardVC? in
                                return LeaderboardVC(coder: coder, currentUsername: username, currentHighscore: highscore, currentChange: change, isPortVC: isPortVC);
                            }) {
                                UserDefaults.standard.set(username, forKey: UserDefaultKeys.currentUsername);
                                leaderboardVC.hidesBottomBarWhenPushed = true;
                                viewController.navigationController?.pushViewController(leaderboardVC, animated: true);
                            } else { print("LeaderboardVC has not been instantiated"); }
                        }
                    }
                } else {
                    SVProgressHUD.dismiss();
                    if let leaderboardVC = viewController.storyboard?.instantiateViewController(identifier: "leaderboardVC", creator: { (coder) -> LeaderboardVC? in
                        return LeaderboardVC(coder: coder, currentUsername: username, currentHighscore: highscore, currentChange: change, isPortVC: isPortVC);
                    }) {
                        UserDefaults.standard.set(username, forKey: UserDefaultKeys.currentUsername);
                        leaderboardVC.hidesBottomBarWhenPushed = true;
                        viewController.navigationController?.pushViewController(leaderboardVC, animated: true);
                    } else { print("LeaderboardVC has not been instantiated"); }
                }
            }
        }
    }
        
    public static func findUser(username:String, completion:@escaping(Bool) -> Void) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection(userServer).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
                    if ( snapshot.isEmpty || snapshot.documents.isEmpty) {
                        SVProgressHUD.dismiss();
                        completion(false);
                        return;
                    }
                    for i in 0...snapshot.documents.count - 1 {
                        let docData = snapshot.documents[i].data();
                        let foundUser = docData["username"] as! String;
                        if (foundUser.lowercased() == username.lowercased()) {
                            SVProgressHUD.dismiss();
                            completion(true);
                            return;
                        }
                    }
                    SVProgressHUD.dismiss();
                    completion(false);
                }
            }
        }
    }
    
    public static func getUsername(email:String, completion:@escaping(String) -> Void) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection(userServer).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
                    if ( snapshot.isEmpty || snapshot.documents.isEmpty) {
                        SVProgressHUD.dismiss();
                        completion("NA");
                        return;
                    }
                    for i in 0...snapshot.documents.count - 1 {
                        let docData = snapshot.documents[i].data();
                        let foundUser = docData["username"] as! String;
                        let foundEmail = docData["email"] as! String;
                        if (foundEmail.lowercased() == email.lowercased()) {
                            SVProgressHUD.dismiss();
                            completion(foundUser);
                            return;
                        }
                    }
                    SVProgressHUD.dismiss();
                    completion("NA");
                }
            }
        }
    }
    
    public static func findUserByEmail(email:String, completion:@escaping (Double?, Error?) -> Void) -> Void {
        db.collection(userServer).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
                completion(nil, error)
            } else {
                if let snapshot = snapshot {
                    for i in 0...snapshot.documents.count - 1 {
                        let docData = snapshot.documents[i].data();
                        let foundEmail = docData["email"] as! String;
                        if (foundEmail.lowercased() == email.lowercased()) {
                            let highscore = docData["highscore"] as! Double;
                            completion(highscore, nil);
                            return;
                        }
                    }
                    completion(nil, error);
                }
            }
        }
    }
    public static func findUserByEmailWithAllData(email:String, completion:@escaping (Dictionary<String, Any>?, Error?) -> Void) -> Void {
        db.collection(userServer).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
                completion(nil, error)
            } else {
                if let snapshot = snapshot {
                    for i in 0...snapshot.documents.count - 1 {
                        let docData = snapshot.documents[i].data();
                        let foundEmail = docData["email"] as! String;
                        if (foundEmail.lowercased() == email.lowercased()) {
                            let data = docData;
                            completion(data, nil);
                            return;
                        }
                    }
                    completion(nil, error);
                }
            }
        }
    }
    
    public static func findUser(email:String, highscore:Double, change:String, numberOfCoin:Int, highestHolding:String, viewController:UIViewController, isPortVC:Bool, isLogin:Bool) -> Void {
        let data = isLogin ? ["change":change, "numberOfOwnedCoin":0, "highestHolding":"NA"] : ["highscore":highscore, "change":change, "numberOfOwnedCoin":numberOfCoin, "highestHolding":highestHolding];
        SVProgressHUD.show(withStatus: "Loading...");
        DatabaseManager.hideTabBar(view: viewController);
        db.collection(userServer).getDocuments { (snapshot, error) in
            if let error = error {
                SVProgressHUD.dismiss();
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
                    for i in 0...snapshot.documents.count - 1 {
                        let docData = snapshot.documents[i].data();
                        let foundEmail = docData["email"] as! String;
                        let foundUser = docData["username"] as? String;
                        if (foundEmail.lowercased() == email.lowercased() && foundUser != nil) {
                            if (isLogin) {
                                let usernameLogin = docData["username"] as! String;
                                let highscoreLogin = docData["highscore"] as! Double;
                                let changeLogin = docData["change"] as! String;
                                UserDefaults.standard.set(0.0, forKey: UserDefaultKeys.mainPortfolioKey);
                                UserDefaults.standard.set(highscoreLogin, forKey: UserDefaultKeys.availableFundsKey);
                                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.holdingsKey);
                                DatabaseManager.writeUserData(username: usernameLogin, merge: true, data: ["change":changeLogin, "numberOfOwnedCoin":0, "highestHolding":"NA"]) { (error) in
                                    if let error = error { print(error.localizedDescription) } else {
                                        SVProgressHUD.dismiss();
                                        if let leaderboardVC = viewController.storyboard?.instantiateViewController(identifier: "leaderboardVC", creator: { (coder) -> LeaderboardVC? in
                                            return LeaderboardVC(coder: coder, currentUsername: usernameLogin, currentHighscore: highscoreLogin, currentChange: changeLogin, isPortVC: isPortVC);
                                        }) {
                                            UserDefaults.standard.set(true, forKey: UserDefaultKeys.loginPressed);
                                            UserDefaults.standard.set(usernameLogin, forKey: UserDefaultKeys.currentUsername);
                                            leaderboardVC.hidesBottomBarWhenPushed = true;
                                            viewController.navigationController?.pushViewController(leaderboardVC, animated: true);
                                        } else { print("LeaderboardVC has not been instantiated"); }
                                    }
                                }
                            } else {
                                DatabaseManager.writeUserData(username: foundUser!, merge: true, data: data) { (error) in
                                    if let error = error {
                                        SVProgressHUD.dismiss();
                                        print(error.localizedDescription);
                                    } else {
                                        if let loadedHoldings = DataStorageHandler.loadObject(type: [Holding].self, forKey: UserDefaultKeys.holdingsKey) {
                                            DatabaseManager.writeObjects(username: foundUser!, type: loadedHoldings, typeName: "holdings") { (error) in
                                                if let error = error { print(error.localizedDescription); } else {
                                                    SVProgressHUD.dismiss();
                                                    if let leaderboardVC = viewController.storyboard?.instantiateViewController(identifier: "leaderboardVC", creator: { (coder) -> LeaderboardVC? in
                                                        return LeaderboardVC(coder: coder, currentUsername: foundUser!, currentHighscore: highscore, currentChange: change, isPortVC: isPortVC);
                                                    }) {
                                                        leaderboardVC.hidesBottomBarWhenPushed = true;
                                                        viewController.navigationController?.pushViewController(leaderboardVC, animated: true);
                                                    } else { print("LeaderboardVC has not been instantiated"); }
                                                }
                                            }
                                        } else {
                                            SVProgressHUD.dismiss();
                                            if let leaderboardVC = viewController.storyboard?.instantiateViewController(identifier: "leaderboardVC", creator: { (coder) -> LeaderboardVC? in
                                                return LeaderboardVC(coder: coder, currentUsername: foundUser!, currentHighscore: highscore, currentChange: change, isPortVC: isPortVC);
                                            }) {
                                                leaderboardVC.hidesBottomBarWhenPushed = true;
                                                viewController.navigationController?.pushViewController(leaderboardVC, animated: true);
                                            } else { print("LeaderboardVC has not been instantiated"); }
                                        }
                                    }
                                }
                            }
                            return;
                        }
                    }
                    SVProgressHUD.dismiss();
                }
            }
        }
    }
    
    public static func deleteUser(username:String, completion:@escaping(Error?) -> Void) -> Void {
        db.collection(userServer).document(username).delete(completion: completion);
    }
    
    public static func getAllUserData(completion:@escaping(User?, Error?) -> Void) -> Void {
        db.collection(userServer).order(by: "highscore", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
                    for i in 0...snapshot.documents.count - 1 {
                        let docData = snapshot.documents[i].data();
                        let rank = String((i + 1));
                        let email = docData["email"] as! String;
                        let username = docData["username"] as! String;
                        let highscore = docData["highscore"] as! Double;
                        let change = docData["change"] as! String;
                        let numberOfOwnedCoin = docData["numberOfOwnedCoin"] as? Int;
                        let highestHolding = docData["highestHolding"] as? String;
                        let user = User(rank: rank, email: email, username: username, highscore: highscore, change: change, numberOfOwnedCoin: numberOfOwnedCoin ?? 0, highestHolding: highestHolding ?? "No Holding" );
                        completion(user, nil);
                    }
                } else {
                    completion(nil, error);
                }
            }
        }
    }
    
    private static func hideTabBar(view:UIViewController) {
        var frame = view.tabBarController?.tabBar.frame
        frame!.origin.y = view.view.frame.size.height + (frame?.size.height)!
        UIView.animate(withDuration: 0.5, animations: {
            view.tabBarController?.tabBar.frame = frame!
        }) { (done) in
            if (done) {
                view.tabBarController?.tabBar.isHidden = true;
            }
        }
    }
    
//    private static func showTabBar(view:UIViewController) {
//        var frame = view.tabBarController?.tabBar.frame
//        frame!.origin.y = view.view.frame.size.height - (frame?.size.height)!
//        UIView.animate(withDuration: 0.5, animations: {
//            view.tabBarController?.tabBar.frame = frame!
//        }) { (done) in
//            if (done) {
//                view.tabBarController?.tabBar.isHidden = false;
//            }
//        }
//    }

}
