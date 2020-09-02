//
//  LeaderboardVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-02.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class LeaderboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    public var currentUsername:String = "";
    public var currentHighscore:String = "";
    
    private var users:Array<User> = Array<User>();
    private var isLoading:Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = nil;
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationController?.navigationBar.shadowImage = nil;
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default);
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        self.title = "Leaderboard";
        
        self.getUserData();
        
    }
    
    private func getUserData() -> Void {
        DatabaseManager.getAllUserData { (user, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                self.isLoading = false;
                self.users.append(user!);
                self.tableView.reloadData();
            }
        }
        self.tableView.reloadData();
    }
    
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isLoading) {
            return 1;
        } else {
            return self.users.count;
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardCell;
        
        if (self.isLoading) {
            cell.rank_lbl.isHidden = true;
            cell.username_lbl.isHidden = true;
            cell.highscore_lbl.isHidden = true;
            cell.change_lbl.isHidden = true;
        } else {
            cell.rank_lbl.isHidden = false;
            cell.username_lbl.isHidden = false;
            cell.highscore_lbl.isHidden = false;
            cell.change_lbl.isHidden = false;
            
            cell.rank_lbl.text = "# \(self.users[indexPath.row].rank)";
            cell.username_lbl.text = self.users[indexPath.row].username;
            cell.highscore_lbl.text = "$\(String(format: "%.2f", self.users[indexPath.row].highscore))";
            cell.change_lbl.text = self.users[indexPath.row].change;
            
            if (self.users[indexPath.row].username.lowercased() == currentUsername.lowercased()) {
                cell.username_lbl.textColor = .yellow;
            }
            
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0;
    }

}

public class LeaderboardCell : UITableViewCell {
    
    @IBOutlet weak var rank_lbl: UILabel!
    @IBOutlet weak var username_lbl: UILabel!
    @IBOutlet weak var highscore_lbl: UILabel!
    @IBOutlet weak var change_lbl: UILabel!
    
}
