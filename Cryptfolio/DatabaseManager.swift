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
    let numberOfTransactions:Int;
}


public class DatabaseManager {
    
    private static let db = Firestore.firestore();
    
    public static func writeUserData(username:String, password:String, highscore:Double, change:String, merge:Bool, completion:@escaping(Error?) -> Void) -> Void {
        db.collection("users").document(username).setData(["username":username, "hashedPassword":password, "highscore":highscore, "change":change], merge: merge, completion: completion);
    }

    public static func writeUserData(username:String, merge:Bool, data:[String : Any], completion:@escaping(Error?) -> Void) -> Void {
        db.collection("users").document(username).setData(data, merge: merge, completion: completion);
    }
    
    public static func writeUserData(email:String, username:String, highscore:Double, change:String, numberOfOwnedCoin:Int, numberOfTransactions:Int, merge:Bool, viewController:UIViewController) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection("users").document(username).setData(["email":email, "username":username, "highscore":highscore, "change":change, "numberOfOwnedCoin":numberOfOwnedCoin, "numberOfTransactions":numberOfTransactions], merge: merge) { (error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                SVProgressHUD.dismiss();
                let leaderboardInfoVC = viewController.storyboard?.instantiateViewController(withIdentifier: "leaderboardVC") as! LeaderboardVC;
                leaderboardInfoVC.currentUsername = username;
                leaderboardInfoVC.currentHighscore = highscore;
                leaderboardInfoVC.currentChange = change;
                leaderboardInfoVC.currentOwnedCoin = numberOfOwnedCoin;
                leaderboardInfoVC.currentTransactions = numberOfTransactions;
                viewController.navigationController?.pushViewController(leaderboardInfoVC, animated: true);
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
    
    public static func findUser(email:String, highscore:Double, change:String, numberOfCoin:Int, numberOfTransactions:Int, viewController:UIViewController) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
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
                            DatabaseManager.writeUserData(username: foundUser!, merge: true, data: ["highscore":highscore, "change":change, "numberOfOwnedCoin":numberOfCoin, "numberOfTransactions":numberOfTransactions]) { (error) in
                                if let error = error {
                                    SVProgressHUD.dismiss();
                                    print(error.localizedDescription);
                                } else {
                                    SVProgressHUD.dismiss();
                                    let leaderboardInfoVC = viewController.storyboard?.instantiateViewController(withIdentifier: "leaderboardVC") as! LeaderboardVC;
                                    leaderboardInfoVC.currentUsername = foundUser!;
                                    leaderboardInfoVC.currentHighscore = highscore;
                                    leaderboardInfoVC.currentChange = change;
                                    leaderboardInfoVC.currentOwnedCoin = numberOfCoin;
                                    leaderboardInfoVC.currentTransactions = numberOfTransactions;
                                    viewController.navigationController?.pushViewController(leaderboardInfoVC, animated: true);
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
                        let numberOfTransactions = docData["numberOfTransactions"] as? Int;
                        let user = User(rank: rank, email: email, username: username, highscore: highscore, change: change, numberOfOwnedCoin: numberOfOwnedCoin ?? 0, numberOfTransactions: numberOfTransactions ?? 0);
                        completion(user, nil);
                    }
                } else {
                    completion(nil, error);
                }
            }
        }
    }

}
