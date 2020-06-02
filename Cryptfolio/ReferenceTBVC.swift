//
//  ReferenceTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-30.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class ReferenceTBVC: UITableViewController {

    var items = [["Data provided by Coinranking"], ["Images provided by Atomiclabs"], ["Data provided by Cryptocompare"], ["Images provided Icons8"]];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "References";
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
               self.setTextOfHeader(label: sectionLabel, text: "ALL TICKER INFORMATION")
               headerView.addSubview(sectionLabel);
               break;
           case 1:
               self.setTextOfHeader(label: sectionLabel, text: "CRYPTOCURRENCY IMAGES");
               headerView.addSubview(sectionLabel)
               break;
           case 2:
               self.setTextOfHeader(label: sectionLabel, text: "CHART DATA, NEWS AND DISCUSSION BOARDS");
               headerView.addSubview(sectionLabel)
           case 3:
               self.setTextOfHeader(label: sectionLabel, text: "TAB BAR IMAGES");
               headerView.addSubview(sectionLabel);
           default:
               break;
           }
           return headerView
       }

       override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 50;
       }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        cell.isUserInteractionEnabled = false;
        cell.textLabel!.text = self.items[indexPath.section][indexPath.row];
        return cell;
    }
    
    private func setTextOfHeader(label:UILabel!, text: String) {
        label.text = text;
        label.sizeToFit();
    }


}
