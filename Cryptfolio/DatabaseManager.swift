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
import CryptoSwift;


public struct User : Codable {
    let rank:String;
    let username:String;
    let highscore:Double;
    let change:String;
}


public class DatabaseManager {
    
    private static let db = Firestore.firestore();
    
    public static func writeUserData(username:String, password:String, highscore:Double, change:String, merge:Bool, completion:@escaping(Error?) -> Void) -> Void {
        db.collection("users").document(username).setData(["username":username, "hashedPassword":password, "highscore":highscore, "change":change], merge: merge, completion: completion);
    }

    public static func writeUserData(username:String, highscore:Double, change:String, merge:Bool, viewController:UIViewController) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection("users").document(username).setData(["username":username, "highscore":highscore, "change":change], merge: merge) { (error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                SVProgressHUD.dismiss();
                let leaderboardInfoVC = viewController.storyboard?.instantiateViewController(withIdentifier: "leaderboardVC") as! LeaderboardVC;
                leaderboardInfoVC.currentUsername = username;
                leaderboardInfoVC.currentHighscore = "Highscore: \(highscore)";
                viewController.navigationController?.pushViewController(leaderboardInfoVC, animated: true);
            }
        }
    }
    
    public static func writeUserData(username:String, password:String, highscore:Double, change:String, merge:Bool, viewController:UIViewController) -> Void {
        let hashedPassword:String = DatabaseManager.passwordHash(username: username, password: password);
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection("users").document(username).setData(["username":username, "hashedPassword":hashedPassword, "highscore":highscore, "change":change], merge: merge) { (error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                SVProgressHUD.dismiss();
                let leaderboardInfoVC = viewController.storyboard?.instantiateViewController(withIdentifier: "leaderboardVC") as! LeaderboardVC;
                leaderboardInfoVC.currentUsername = username;
                leaderboardInfoVC.currentHighscore = "Highscore: \(highscore)";
                viewController.navigationController?.pushViewController(leaderboardInfoVC, animated: true);
            }
        }
    }
    
    public static func findUser(username:String, password:String, highscore:Double, change:String, viewController:UIViewController, isLogin:Bool) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
                    var foundUser:Bool = false;
                    var foundBoth:Bool = false;
                    for document in snapshot.documents {
                        let docData = document.data();
                        let foundUsername = docData["username"] as! String;
                        let foundHashedPasswrod = docData["hashedPassword"] as! String;
                        if (foundUsername.lowercased() == username.lowercased()) {  
                            foundUser = true;
                        }
                        if (foundHashedPasswrod == DatabaseManager.passwordHash(username: username, password: password)) {
                            foundBoth = true;
                        }
                        if (foundBoth || foundUser) {
                            break;
                        }
                    }
                    if (isLogin) {
                        if (foundBoth) {
                            UserDefaults.standard.set(username, forKey: UserDefaultKeys.username);
                            DatabaseManager.writeUserData(username: username, password: password, highscore: highscore, change: change, merge: false, viewController: viewController);
                        } else {
                            SVProgressHUD.dismiss();
                            let alert = UIAlertController(title: "Sorry", message: "Incorrect username or password!", preferredStyle: UIAlertController.Style.alert);
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
                            viewController.present(alert, animated: true, completion: nil);
                        }
                    } else {
                        if (!foundUser) {
                            UserDefaults.standard.set(username, forKey: UserDefaultKeys.username);
                            DatabaseManager.writeUserData(username: username, password: password, highscore: highscore, change: change, merge: false, viewController: viewController);
                        } else {
                            SVProgressHUD.dismiss();
                            let alert = UIAlertController(title: "Sorry", message: "Username already exists!", preferredStyle: UIAlertController.Style.alert);
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
                            viewController.present(alert, animated: true, completion: nil);
                        }
                    }
                }
            }
        }
    }
        
    public static func findUser(username:String, completion:@escaping(Bool) -> Void) -> Void {
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        let docData = document.data();
                        let foundUser = docData["username"] as! String;
                        if (foundUser.lowercased() == username.lowercased()) {
                            completion(true);
                            return;
                        }
                    }
                    completion(false);
                    return;
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
                        let username = docData["username"] as! String;
                        let highscore = docData["highscore"] as! Double;
                        let change = docData["change"] as! String;
                        let user = User(rank: rank, username: username, highscore: highscore, change: change);
                        completion(user, nil);
                    }
                } else {
                    completion(nil, error);
                }
            }
        }
    }
    
    public static func passwordHash(username: String, password: String) -> String {
        let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
        return "\(password).\(username).\(salt)".sha256()
    }
    

}
