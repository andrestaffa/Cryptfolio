//
//  NewsTBVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-05-22.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import SVProgressHUD;
import SafariServices;

class NewsTBVC: UITableViewController {

    // Private member variables
    private var newsList = Array<News>();
    private var counter:Int = 0;
    private var prevLength = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false;
        self.navigationController?.navigationBar.isTranslucent = true;
        self.navigationController?.navigationBar.isHidden = false;
        self.navigationController?.navigationBar.prefersLargeTitles = true;
        self.navigationController?.navigationBar.tintColor = UIColor.orange;
        
        self.tableView.refreshControl = UIRefreshControl();
        self.tableView.refreshControl!.attributedTitle = NSAttributedString(string: "");
        self.tableView.refreshControl!.addTarget(self, action: #selector(self.refresh), for: .valueChanged);
        
        self.getData(loadingIndicator: true);
        self.title = "News";
        
    }
    
	@objc private func refresh() -> Void {
		self.getData(loadingIndicator: false);
	}
	
	private func getData(loadingIndicator:Bool) -> Void {
        self.counter += 1;
		if (loadingIndicator) { SVProgressHUD.show(withStatus: "Loading..."); self.tableView.separatorStyle = .none; }
        CryptoData.getNewsData { [weak self] (news, error) in
			if let _ = error { CryptoData.DisplayNetworkErrorAlert(vc: self); SVProgressHUD.dismiss(); return; }
			if let news = news {
				self?.newsList.append(news);
				if (self!.counter < 2) {
					self!.prevLength = (self!.newsList.count);
				}
				if ((self!.newsList.count) > self!.prevLength) {
					self?.newsList.removeSubrange((0...self!.prevLength - 1));
				}
			} else {
				self?.newsList.append(News(title: "Error Loading News", source: "There was an error loading news", publishedOn: Date().timeIntervalSince1970, url: "https://www.calculatedinc.org"));
			}
            if let refresh = self?.tableView.refreshControl { refresh.endRefreshing(); }
			SVProgressHUD.dismiss();
			self?.tableView.separatorStyle = .singleLine;
			self?.tableView.reloadData();
        }
        
    }

    // MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 89;
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 89;
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (self.newsList.isEmpty) {
            if let navBarItem = self.navigationItem.rightBarButtonItem {
                navBarItem.isEnabled = false;
            }
            return 0;
        } else {
            if let navBarItem = self.navigationItem.rightBarButtonItem {
                navBarItem.isEnabled = true;
            }
            return self.newsList.count;
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTBVCCustomCell;
		if (self.newsList.isEmpty) {
			let cell = UITableViewCell();
			cell.backgroundColor = .clear;
			cell.contentView.backgroundColor = .clear;
			return cell;
		}
		cell.title_lbl.text = self.newsList[indexPath.row].title;
		cell.source_lbl.text = self.newsList[indexPath.row].source + " - " + "\(self.dateFormatter(time: self.newsList[indexPath.row].publishedOn))";
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let safariVC = SFSafariViewController(url: URL(string: self.newsList[indexPath.row].url)!);
        self.present(safariVC, animated: true, completion: nil);
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert);
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(defaultButton)
        self.present(alert, animated: true, completion: nil);
    }
    
    private func dateFormatter(time:Double) -> String {
        let date = Date(timeIntervalSince1970: time);
        let dateFormatter = DateFormatter();
        dateFormatter.timeStyle = DateFormatter.Style.medium;
        dateFormatter.dateStyle = DateFormatter.Style.medium;
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let strDate = dateFormatter.string(from: date);
        return strDate;
    }


}
