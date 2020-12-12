//
//  SettingsTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-27.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//
import UIKit;
import SVProgressHUD;
import FirebaseAuth;
import SafariServices;

private class Section {
    public var title:String;
    public var image:UIImage;
    init(title: String, image: UIImage) {
        self.title = title;
        self.image = image;
    }
}

class SettingsTBVC: UITableViewController, ISRewardedVideoDelegate {
    
    private var generalItems = Array<Section>();
    private var referenceItems = Array<Section>();
    private var feedbackItems = Array<Section>();
    private var accountItems = Array<Section>();
    private var watchedAd:Bool = false;
    
    override func viewWillAppear(_ animated: Bool) {
        if (FirebaseAuth.Auth.auth().currentUser != nil) {
            self.accountItems.removeAll();
            self.accountItems.append(Section(title: "Change Username", image: UIImage(named: "Images/btc.png")!));
            self.accountItems.append(Section(title: "Sign Out", image: UIImage(named: "Images/btc.png")!));
            self.tableView.reloadData();
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IronSource.setRewardedVideoDelegate(self);
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.title = "Settings"
        self.navigationController?.navigationBar.tintColor = .orange
        self.getData();
        
    }
    
    // MARK: - IRON SOURCE MEHTODS
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        self.watchedAd = true;
        UserDefaults.standard.set(UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey) + 20.00, forKey: UserDefaultKeys.availableFundsKey);
        UserDefaults.standard.setValue(UserDefaults.standard.double(forKey: UserDefaultKeys.cumulativeAdMoney) + 20.00, forKey: UserDefaultKeys.cumulativeAdMoney);
    }
    
    func rewardedVideoDidClose() {
        self.tableView.reloadData();
        if (self.watchedAd) {
            self.watchedAd = false;
            displayAlertNormal(title: "Whoo!", message: "You just earned $20.00!", style: .default);
        }
    }
    
    func rewardedVideoHasChangedAvailability(_ available: Bool) {}
    func rewardedVideoDidFailToShowWithError(_ error: Error!) { self.displayAlertNormal(title: "Error", message: error.localizedDescription, style: .default); }
    func rewardedVideoDidOpen() {}
    func rewardedVideoDidStart() {}
    func rewardedVideoDidEnd() {}
    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {}

    // MARK: - Get Data
    
    private func getData() -> Void {
        
        // section 1 - General
        self.generalItems.append(Section(title: "Watch a video for bonus cash", image: UIImage(named: "Images/neo.png")!));
        self.generalItems.append(Section(title: "View investing tips", image: UIImage(named: "Images/dash.png")!));
        
        // section 2 - Feedback and Support
        self.feedbackItems.append(Section(title: "More Info", image: UIImage(named: "Images/btc.png")!));
        self.feedbackItems.append(Section(title: "Share Cryptfolio", image: UIImage(named: "Images/ltc.png")!));
        self.feedbackItems.append(Section(title: "Send bug report", image: UIImage(named: "Images/xmr.png")!));
        self.feedbackItems.append(Section(title: "About Cryptfolio", image: UIImage(named: "Images/eos.png")!));
        
        // section 3 - References
        self.referenceItems.append(Section(title: "News sources", image: UIImage(named: "Images/etc.png")!));
        self.referenceItems.append(Section(title: "References", image: UIImage(named: "Images/usdt.png")!));
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear

        let sectionLabel = UILabel(frame: CGRect(x: 8, y: 20, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height));
        sectionLabel.font = UIFont(name: "Helvetica", size: 15);
        sectionLabel.textColor = .orange;
        
        switch section {
        case 0:
            self.setTextOfHeader(label: sectionLabel, text: "GENERAL")
            headerView.addSubview(sectionLabel);
            break;
        case 1:
            self.setTextOfHeader(label: sectionLabel, text: "FEEDBACK AND SUPPORT");
            headerView.addSubview(sectionLabel)
            break;
        case 2:
            self.setTextOfHeader(label: sectionLabel, text: "REFERENCES");
            headerView.addSubview(sectionLabel)
            break;
        case 3:
            if (FirebaseAuth.Auth.auth().currentUser != nil) {
                self.setTextOfHeader(label: sectionLabel, text: "ACCOUNT");
                headerView.addSubview(sectionLabel);
            }
            break;
        default:
            break;
        }
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (FirebaseAuth.Auth.auth().currentUser != nil) {
            return 4;
        } else {
            return 3;
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.generalItems.count;
        case 1:
            return self.feedbackItems.count;
        case 2:
            return self.referenceItems.count;
        case 3:
            return self.accountItems.count;
        default:
            return 0;
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        switch indexPath.section {
        case 0:
            cell.isUserInteractionEnabled = true;
            cell.textLabel!.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1);
            cell.textLabel!.text = self.generalItems[indexPath.row].title;
            if (indexPath.row == 0) {
                cell.textLabel?.textColor = .systemOrange;
                self.glowAffect(view: cell.textLabel!, color: .orange);
            }
            break;
        case 1:
            cell.textLabel!.text = self.feedbackItems[indexPath.row].title;
            break;
        case 2:
            cell.textLabel!.text = self.referenceItems[indexPath.row].title;
        case 3:
            if (FirebaseAuth.Auth.auth().currentUser != nil) {
                cell.isHidden = false;
                cell.textLabel?.textColor = .white;
                self.glowAffect(view: cell.textLabel!, color: .clear);
                cell.textLabel?.text = self.accountItems[indexPath.row].title
                if (indexPath.row == 1 && indexPath.section == 3) {
                    cell.textLabel?.textColor = .red;
                }
            } else {
                cell.isHidden = true;
            }
            break;
        default:
            break;
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            self.watchAdForMoney();
            break;
        case (0, 1):
            self.viewInvestingTips();
            break;
        case (1, 0):
            self.showDisclaimer();
            break;
        case (1, 1):
            self.shareCryptfolio();
            break;
        case (1, 2):
            self.sendBugReport();
            break;
        case (1, 3):
            self.aboutCryptfolio();
            break;
        case (2, 0):
            self.newsReferences();
            break;
        case (2, 1):
            self.references();
            break;
        case (3, 0):
            self.changeUsername();
        case (3, 1):
            self.signOutPressed();
            break;
        default:
            break;
        }
    }
    
    private func glowAffect(view:UIView, color:UIColor) {
        view.layer.shadowColor = color.cgColor;
        view.layer.shadowRadius = 1.0;
        view.layer.shadowOpacity = 1;
        view.layer.shadowOffset = .zero;
        view.layer.masksToBounds = false;
    }
    
    private func setTextOfHeader(label:UILabel!, text: String) {
        label.text = text;
        label.sizeToFit();
    }
    
    private func changeUsername() -> Void {
        let alertController = UIAlertController(title: "Change Username", message: "Please enter a new username", preferredStyle: .alert);
        alertController.addTextField();
        alertController.textFields![0].placeholder = "New Username";
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        alertController.addAction(UIAlertAction(title: "Change", style: .default, handler: { (action) in
            DatabaseManager.findUser(username: alertController.textFields![0].text!) { (foundUser) in
                if (!foundUser) {
                    if (alertController.textFields![0].text == nil || alertController.textFields![0].text!.isEmpty || alertController.textFields![0].text!.trimmingCharacters(in: .whitespaces).isEmpty || alertController.textFields![0].text!.count > 15) { self.displayAlertNormal(title: "Error", message: "Username field must have the correct formatting.", style: .default); return; }
                    DatabaseManager.findUserByEmailWithAllData(email: FirebaseAuth.Auth.auth().currentUser!.email!) { (data, error) in
                        if let error = error { self.displayAlertNormal(title: "Error", message: error.localizedDescription, style: .default); } else {
                            let prevData = data!;
                            let oldUsername = data!["username"] as! String;
                            DatabaseManager.deleteUser(username: oldUsername) { (error) in
                                if let error = error { self.displayAlertNormal(title: "Error", message: error.localizedDescription, style: .default); } else {
                                    let newData = ["email":prevData["email"], "username":alertController.textFields![0].text!, "highscore":prevData["highscore"], "change":prevData["change"], "numberOfOwnedCoin":prevData["numberOfOwnedCoin"], "highestHolding":prevData["highestHolding"]];
                                    DatabaseManager.writeUserData(username: alertController.textFields![0].text!, merge: false, data: newData as [String : Any]) { (error) in
                                        if let error = error { self.displayAlertNormal(title: "Error", message: error.localizedDescription, style: .default); } else {
                                            self.displayAlertNormal(title: "Success", message: "Successfully changed username!", style: .default);
                                            return;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.displayAlertNormal(title: "Error", message: "Username already exists!", style: .default);
                    return;
                }
            }
        }));
        self.present(alertController, animated: true, completion: nil);
    }
    
    private func signOutPressed() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3));
        cell?.isUserInteractionEnabled = false;
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to sign out?", preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in cell?.isUserInteractionEnabled = true; }));
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] (action) in
            SVProgressHUD.show(withStatus: "Loading...")
            var highscore:Double = 0.0;
            if (UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange) != 0 && !UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortfolioKey).isLessThanOrEqualTo(0.0)) {
                highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.mainPortChange);
            } else {
                highscore = UserDefaults.standard.double(forKey: UserDefaultKeys.availableFundsKey);
            }
            let firebaseAuth = FirebaseAuth.Auth.auth();
            DatabaseManager.findUserByEmailWithAllData(email: firebaseAuth.currentUser!.email!) { [weak self] (data, error) in
                if let _ = error { self?.displayAlertNormal(title: "Error signing out", message: "There was an error signing out. Please try again", style: .default); SVProgressHUD.dismiss(); cell?.isUserInteractionEnabled = true; }
                else {
                    let currentUsername = data!["username"] as! String;
                    DatabaseManager.writeUserData(username: currentUsername, merge: true, data: ["highscore":highscore]) { (error) in
                        if let error = error { print(error.localizedDescription); SVProgressHUD.dismiss(); cell?.isUserInteractionEnabled = true; } else {
                            do {
                                try firebaseAuth.signOut();
                                self?.displayAlertNormal(title: "Signed Out!", message: "You successfully signed out", style: .default);
                                self?.tableView.reloadData();
                                SVProgressHUD.dismiss();
                                cell?.isUserInteractionEnabled = true;
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                                cell?.isUserInteractionEnabled = true;
                                SVProgressHUD.dismiss();
                            }
                        }
                    }
                }
            }
        }))
        self.present(alertController, animated: true, completion: nil);
    }
    
    private func resetPortfolio() -> Void {
        self.displayAlert(title: "Warning", message: "This will reset your holdings, portfolio and will set available funds back to $10,000", style: .destructive) { (action) in
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.availableFundsKey);
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.mainPortfolioKey);
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.holdingsKey);
            UserDefaults.standard.set(10000, forKey: UserDefaultKeys.availableFundsKey);
        }
    }
    
    private func showDisclaimer() -> Void {
        self.displayAlertNormal(title: "Note", message: "Buying and selling cryptocurrency in this app is practice.\n\n Cryptfolio is intentionally designed this way to allow you to learn how to trade crypto without the risks of real trading.\n\n The funds in your account are practice funds but the rest of the app is real-time updated information.", submitTitle: "Continue", style: .default);
    }
        
    private func watchAdForMoney() -> Void {
        SVProgressHUD.show(withStatus: "Loading...");
        if (IronSource.hasRewardedVideo()) {
            IronSource.showRewardedVideo(with: self);
            SVProgressHUD.dismiss();
        } else {
            SVProgressHUD.dismiss();
            self.displayAlertNormal(title: "Error", message: "Ad was not loaded yet. Please try again.", style: .default)
        }
    }
    
    private func viewInvestingTips() -> Void {
        let investingTipVC = self.storyboard?.instantiateViewController(withIdentifier: "investingTipVC") as! InvestingTipsVC;
        self.navigationController?.pushViewController(investingTipVC, animated: true);
    }
    
    private func shareCryptfolio() -> Void {
        let activityVC = UIActivityViewController(activityItems: ["https://apps.apple.com/us/app/id1534361409"], applicationActivities: nil);
        activityVC.popoverPresentationController?.sourceView = self.view;
        self.present(activityVC, animated: true, completion: nil);
    }
    
    private func sendBugReport() -> Void {
        let safariVC = SFSafariViewController(url: URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSd8o0t1g8t8WBsCBYc4yKRtI35hx8aqn9OHBu2gm2YCtxrgLQ/viewform?usp=sf_link")!)
        self.present(safariVC, animated: true, completion: nil);
    }
    
    private func aboutCryptfolio() -> Void {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "aboutVC") as! AboutVC;
        //self.navigationController?.pushViewController(aboutVC, animated: true);
        self.present(aboutVC, animated: true, completion: nil);
    }
    
    private func newsReferences() -> Void {
        let newsRefTBVC = self.storyboard?.instantiateViewController(withIdentifier: "newsRefTBVC") as! NewsRefTBVC;
        self.navigationController?.pushViewController(newsRefTBVC, animated: true);
    }
    
    private func references() -> Void {
        let referenceTBVC = self.storyboard?.instantiateViewController(withIdentifier: "referenceTBVC") as! ReferenceTBVC;
        self.navigationController?.pushViewController(referenceTBVC, animated: true);
    }
    
    private func displayAlert(title: String, message: String, style: UIAlertAction.Style, handler:@escaping (UIAlertAction) -> Void) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "Reset", style: style, handler: handler));
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        self.present(alert, animated: true, completion: nil);
    }
    
    private func displayAlertNormal(title: String, message: String, style: UIAlertAction.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: style, handler: nil));
        self.present(alert, animated: true, completion: nil);
    }
    
    private func displayAlertNormal(title: String, message: String, submitTitle:String, style: UIAlertAction.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: submitTitle, style: style, handler: nil));
        self.present(alert, animated: true, completion: nil);
    }
    
    private func openLink(linkToSite:String) {
        let link = linkToSite;
        if let url = URL(string: link) {
            UIApplication.shared.open(url);
        }
    }
    

}
