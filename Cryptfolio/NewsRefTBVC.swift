//
//  NewsRefTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-29.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class NewsRefTBVC: UITableViewController {

    private var newsSources = Array<String>();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.newsSources = CryptoData.readTextToArray(path: "Data.bundle/newsSources")!;
        self.title = "News Sources";
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsSources.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        cell.isUserInteractionEnabled = false;
        cell.textLabel!.text = self.newsSources[indexPath.row];
        return cell;
    }



}
