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
    let username:String;
    let highscore:Double;
    let change:String;
}


public class DatabaseManager {
    
    private static let db = Firestore.firestore();
    
    public static func writeUserData(username:String, highscore:Double, change:String, merge:Bool, completion:@escaping(Error?) -> Void) -> Void {
        db.collection("users").document(username).setData(["username":username, "highscore":highscore, "change":change], merge: merge, completion: completion);
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
    
    public static func findUser(username:String, highscore:Double, change:String, viewController:UIViewController) -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if let snapshot = snapshot {
                    var foundUser:Bool = false;
                    for document in snapshot.documents {
                        let docData = document.data();
                        let foundUsername = docData["username"] as! String;
                        if (foundUsername.lowercased() == username.lowercased()) {
                            foundUser = true;
                            break;
                        }
                    }
                    if (!foundUser) {
                        UserDefaults.standard.set(username, forKey: UserDefaultKeys.username);
                        DatabaseManager.writeUserData(username: username, highscore: highscore, change: change, merge: false, viewController: viewController);
                    } else {
                        SVProgressHUD.dismiss();
                        let alert = UIAlertController(title: "Sorry", message: "Username already exists!", preferredStyle: .alert);
                        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
                        alert.addAction(defaultButton);
                        viewController.present(alert, animated: true, completion: nil);
                    }
                    return;
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
    

}
