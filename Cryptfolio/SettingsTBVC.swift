//
//  SettingsTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-27.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

private class Section {
    public var title:String;
    public var image:UIImage;
    init(title: String, image: UIImage) {
        self.title = title;
        self.image = image;
    }
}

class SettingsTBVC: UITableViewController {
    
    private var generalItems = Array<Section>();
    private var referenceItems = Array<Section>();
    private var feedbackItems = Array<Section>();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.title = "Settings"
        self.navigationController?.navigationBar.tintColor = .orange
        self.getData();
        
    }
    
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
            cell.textLabel!.text = self.generalItems[indexPath.row].title;
            //cell.imageView!.image = self.generalItems[indexPath.row].image;
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
            // watch ad for investing tip pressed
            break;
        case (0, 2):
            // view investing tips unlocked pressed
            break;
        case (1, 0):
            // rate app
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
        
    }
    
    private func viewInvestingTips() -> Void {
        
    }
    
    private func rateOnAppStore() -> Void {
        //self.openLink(linkToSite: "link to app on App Store (Itunes Link)");
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
    
    private func openLink(linkToSite:String) {
        let link = linkToSite;
        if let url = URL(string: link) {
            UIApplication.shared.open(url);
        }
    }
    

}
