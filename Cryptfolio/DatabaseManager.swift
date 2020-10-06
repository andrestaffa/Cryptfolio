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
    
    public static func writeUserData(username:String, password:String, highscore:Double, change:String, merge:Bool, completion:@escaping(Error?) -> Void) -> Void {
        db.collection("users").document(username).setData(["username":username, "hashedPassword":password, "highscore":highscore, "change":change], merge: merge, completion: completion);
    }

    public static func writeUserData(username:String, merge:Bool, data:[String : Any], completion:@escaping(Error?) -> Void) -> Void {
        db.collection("users").document(username).setData(data, merge: merge, completion: completion);
    }
    
    public static func writeUserData(email:String, username:String, highscore:Double, change:String, numberOfOwnedCoin:Int, highestHolding:String, merge:Bool, viewController:UIViewController, isPortVC:Bool) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection("users").document(username).setData(["email":email, "username":username, "highscore":highscore, "change":change, "numberOfOwnedCoin":numberOfOwnedCoin, "highestHolding":highestHolding], merge: merge) { (error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                SVProgressHUD.dismiss();
                if let leaderboardVC = viewController.storyboard?.instantiateViewController(identifier: "leaderboardVC", creator: { (coder) -> LeaderboardVC? in
                    return LeaderboardVC(coder: coder, currentUsername: username, currentHighscore: highscore, currentChange: change, isPortVC: isPortVC);
                }) {
                    leaderboardVC.hidesBottomBarWhenPushed = true;
                    viewController.navigationController?.pushViewController(leaderboardVC, animated: true);
                } else { print("LeaderboardVC has not been instantiated"); }
            }
        }
    }
        
    public static func findUser(username:String, completion:@escaping(Bool) -> Void) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
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
    
    public static func findUserByEmail(email:String, completion:@escaping (Double?, Error?) -> Void) -> Void {
        db.collection("users").getDocuments { (snapshot, error) in
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
        db.collection("users").getDocuments { (snapshot, error) in
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
        db.collection("users").getDocuments { (snapshot, error) in
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
                            return;
                        }
                    }
                    SVProgressHUD.dismiss();
                }
            }
        }
    }
    
    public static func deleteUser(username:String, completion:@escaping(Error?) -> Void) -> Void {
        db.collection("users").document(username).delete(completion: completion);
    }
    
    public static func getAllUserData(completion:@escaping(User?, Error?) -> Void) -> Void {
        db.collection("users").order(by: "highscore", descending: true).getDocuments { (snapshot, error) in
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
