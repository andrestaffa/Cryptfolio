//
//  LeaderboardVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-02.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import SVProgressHUD;
import SwiftChart;

class LeaderboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    public var currentUsername:String = "";
    
    private var users:Array<User> = Array<User>();
    private var isLoading:Bool = true;

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = nil;
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationController?.navigationBar.shadowImage = nil;
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default);
        
        // custom nav back button
        self.navigationItem.backBarButtonItem = nil;
        let backButton = UIButton();
        backButton.frame = CGRect(x:0, y:0, width:100, height:20);
        backButton.setTitle("Dashboard", for: .normal);
        backButton.setTitle("Dashboard", for: .highlighted);
        backButton.backgroundColor = UIColor.orange;
        backButton.layer.cornerRadius = 8.0;
        backButton.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside);
        let leftBarButton = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
        self.tabBarController?.tabBar.isHidden = false;
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        self.title = "Leaderboard";
        self.getUserData();
        
    }
    
    private func getUserData() -> Void {
        DatabaseManager.getAllUserData { [weak self] (user, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                self?.isLoading = false;
                self?.users.append(user!);
                self?.tableView.reloadData();
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
            SVProgressHUD.show(withStatus: "Loading...");
            self.hideCells(cell: cell, hidden: true);
        } else {
            SVProgressHUD.dismiss();
            self.hideCells(cell: cell, hidden: false);
            if (String(self.users[indexPath.row].change).first != "-") {
                if (self.traitCollection.userInterfaceStyle == .dark) {
                    cell.change_lbl.textColor = ChartColors.darkGreenColor();
                } else {
                    cell.change_lbl.textColor = ChartColors.greenColor();
                }
                cell.change_lbl.attributedText = self.attachImageToString(text: self.users[indexPath.row].change, image: #imageLiteral(resourceName: "sortUpArrow"));
            } else {
                cell.change_lbl.textColor = ChartColors.darkRedColor();
                cell.change_lbl.attributedText = self.attachImageToString(text: self.users[indexPath.row].change, image: #imageLiteral(resourceName: "sortDownArrow"));
            }
            
            cell.rank_lbl.text = "# \(self.users[indexPath.row].rank)";
            cell.username_lbl.text = self.users[indexPath.row].username;
            cell.highscore_lbl.text = "$\(String(format: "%.2f", self.users[indexPath.row].highscore))";
            
            if (self.users[indexPath.row].username.lowercased() == currentUsername.lowercased()) {
                cell.username_lbl.textColor = .orange;
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
    
    private func hideCells(cell:LeaderboardCell, hidden:Bool) {
        cell.rank_lbl.isHidden = hidden;
        cell.username_lbl.isHidden = hidden;
        cell.highscore_lbl.isHidden = hidden;
        cell.change_lbl.isHidden = hidden;
    }
    
    @objc func backBtnTapped() {
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    private func attachImageToString(text:String, image:UIImage) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0.5, y: -0.3, width: 8, height: 8)
        let masterStirng = NSMutableAttributedString(string: "")
        let percentString = NSMutableAttributedString(string: text);
        let imageAttachment = NSAttributedString(attachment: attachment)
        masterStirng.append(percentString)
        masterStirng.append(imageAttachment)
        return masterStirng;
    }
    

}

public class LeaderboardCell : UITableViewCell {
    
    @IBOutlet weak var rank_lbl: UILabel!
    @IBOutlet weak var username_lbl: UILabel!
    @IBOutlet weak var highscore_lbl: UILabel!
    @IBOutlet weak var change_lbl: UILabel!
    
}
