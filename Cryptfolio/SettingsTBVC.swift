//
//  SettingsTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-27.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import GoogleMobileAds;
import UIKit;
import SVProgressHUD;

private class Section {
    public var title:String;
    public var image:UIImage;
    init(title: String, image: UIImage) {
        self.title = title;
        self.image = image;
    }
}

class SettingsTBVC: UITableViewController, GADRewardedAdDelegate {
    
    private var generalItems = Array<Section>();
    private var referenceItems = Array<Section>();
    private var feedbackItems = Array<Section>();
    private var rewardedAd:GADRewardedAd?;
    private var isLoading:Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rewardedAd = self.createAndLoadRewardedAd();
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.title = "Settings"
        self.navigationController?.navigationBar.tintColor = .orange
        self.getData();
        
    }
    
    // MARK: - Reward Ad Methods
    
    private func createAndLoadRewardedAd() -> GADRewardedAd? {
        self.rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313");
        self.rewardedAd?.load(GADRequest()) { error in
            if let error = error {
                print("Loading failed: \(error)");
            } else {
                self.isLoading = false;
                self.tableView.reloadData();
                print("Loading Succeeded");
            }
        };
        return self.rewardedAd;
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        TipManager.addRandomTip();
        print("You just got a new tip, go check your investing tips");
    }

    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.isLoading = true;
        self.tableView.reloadData();
        self.rewardedAd = self.createAndLoadRewardedAd();
        print("Ad dismissed");
    }
    
    private func gainMoneyReward() -> Void {
        let currentFunds = UserDefaults.standard.value(forKey: UserDefaultKeys.availableFundsKey) as? Double;
        if (currentFunds == nil || currentFunds!.isLessThanOrEqualTo(0.0)) {
            UserDefaults.standard.set(100.0, forKey: UserDefaultKeys.availableFundsKey);
        } else {
            UserDefaults.standard.set(currentFunds! + 100.0, forKey: UserDefaultKeys.availableFundsKey);
        }
    }

    // MARK: - Get Data
    
    private func getData() -> Void {
        
        // section 1 - General
        self.generalItems.append(Section(title: "Reset portfolio", image: UIImage(named: "Images/btc.png")!));
        self.generalItems.append(Section(title: "Watch ad for investing tip", image: UIImage(named: "Images/bch.png")!));
        self.generalItems.append(Section(title: "View investing tips", image: UIImage(named: "Images/dash.png")!));
        
        // section 2 - Feedback and Support
        self.feedbackItems.append(Section(title: "Rate on App Store", image: UIImage(named: "Images/xrp.png")!));
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
        default:
            break;
        }
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.generalItems.count;
        case 1:
            return self.feedbackItems.count;
        case 2:
            return self.referenceItems.count;
        default:
            return 0;
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        
        switch indexPath.section {
        case 0:
            if (self.isLoading && indexPath.row == 1) {
                cell.textLabel!.textColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1);
                cell.textLabel!.text = self.generalItems[1].title;
                cell.isUserInteractionEnabled = false;
            }
            else {
                cell.isUserInteractionEnabled = true;
                cell.textLabel!.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1);
                cell.textLabel!.text = self.generalItems[indexPath.row].title;
            }
            break;
        case 1:
            cell.textLabel!.text = self.feedbackItems[indexPath.row].title;
            //cell.imageView!.image = self.feedbackItems[indexPath.row].image;
            break;
        case 2:
            cell.textLabel!.text = self.referenceItems[indexPath.row].title;
            //cell.imageView!.image = self.referenceItems[indexPath.row].image;
        default:
            break;
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            self.resetPortfolio();
            break;
        case (0, 1):
            self.watchAdForInvestingTip();
            break;
        case (0, 2):
            self.viewInvestingTips();
            break;
        case (1, 0):
            self.rateOnAppStore();
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
        default:
            break;
        }
        
    }
    
    private func setTextOfHeader(label:UILabel!, text: String) {
        label.text = text;
        label.sizeToFit();
    }
    
    private func resetPortfolio() -> Void {
        self.displayAlert(title: "Warning", message: "This will reset your holdings, portfolio and will set available funds back to $10,000", style: .destructive) { (action) in
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.availableFundsKey);
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.mainPortfolioKey);
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.holdingsKey);
            UserDefaults.standard.set(10000, forKey: UserDefaultKeys.availableFundsKey);
        }
    }
    
    private func watchAdForInvestingTip() -> Void {
        if (self.rewardedAd!.isReady) {
            self.rewardedAd!.present(fromRootViewController: self, delegate: self);
        } else {
            displayAlertNormal(title: "Error", message: "Ad was not loaded yet! Please try again", style: .default);
        }
    }
    
    private func viewInvestingTips() -> Void {
        let investingTipVC = self.storyboard?.instantiateViewController(withIdentifier: "investingTipVC") as! InvestingTipsVC;
        self.navigationController?.pushViewController(investingTipVC, animated: true);
    }
    
    private func rateOnAppStore() -> Void {
        print("rate app on app store");
    }
    
    private func shareCryptfolio() -> Void {
        let activityVC = UIActivityViewController(activityItems: ["LinkToAppInAppStore.com"], applicationActivities: nil);
        activityVC.popoverPresentationController?.sourceView = self.view;
        self.present(activityVC, animated: true, completion: nil);
    }
    
    private func sendBugReport() -> Void {
        self.openLink(linkToSite: "https://docs.google.com/forms/d/e/1FAIpQLSeJLJ9G6MthpLca6MZgCAICivIQYZOx7ly6clq6UKwx1luQeQ/viewform?vc=0&c=0&w=1");
    }
    
    private func aboutCryptfolio() -> Void {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "aboutVC") as! AboutVC;
        self.navigationController?.pushViewController(aboutVC, animated: true);
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
    
    private func openLink(linkToSite:String) {
        let link = linkToSite;
        if let url = URL(string: link) {
            UIApplication.shared.open(url);
        }
    }
    

}
