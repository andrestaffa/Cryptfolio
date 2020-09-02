//
//  DatabaseManager.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-02.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;
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
    
    public static func readAllUsers(completion:@escaping(QuerySnapshot?, Error?) -> Void) -> Void {
        db.collection("users").getDocuments(completion: completion)
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

// FirebaseStore test data
        
        // get reference to database
        //let db = Firestore.firestore();
        
        // CREATE/WRITE/UPDATE: adding/updating documents with completion.
//        var temp = self.mainPortfolio_lbl.text!;
//        temp.removeFirst();
//        db.collection("users").document("andre_is_life").setData(["highscore":Double(temp)!], merge: false) { (error) in
//            if let error = error {
//                print(error.localizedDescription);
//            } else {
//
//            }
//        }
        
        // READ: read specific document / read read all documents from a specific collection
//        db.collection("users").document("andre_is_life").getDocument { (document, error) in
//            if let error = error {
//                print(error.localizedDescription);
//            } else {
//                if (document != nil && document!.exists) {
//                    let data = document!.data();
//                }
//            }
//        }
//        db.collection("users").getDocuments { (snapshot, error) in
//            if let error = error {
//                print(error.localizedDescription);
//            } else {
//                if (snapshot != nil) {
//                    for document in snapshot!.documents {
//                        let docData = document.data();
//                    }
//                }
//            }
//        }
//        db.collection("users").whereField("highscore", isGreaterThan: 15000.0).getDocuments { (snapshot, error) in
//            if let error = error {
//                print(error.localizedDescription);
//            } else {
//                if (snapshot != nil) {
//                    for document in snapshot!.documents {
//                        let docData = document.data();
//                    }
//                }
//            }
//        }
        
        // DELETE: delete a document with completion / delete field if nessessary
//        db.collection("users").document("andre_is_life").delete { (error) in
//            if let error = error {
//                print(error.localizedDescription);
//            } else {
//                // delete has completed
//            }
//        }
//        db.collection("users").document("andre_is_life").updateData(["highscore":FieldValue.delete()]) { (error) in
//            if let error = error {
//                print(error.localizedDescription);
//            } else {
//                // deletion of field successful
//            }
//        }
