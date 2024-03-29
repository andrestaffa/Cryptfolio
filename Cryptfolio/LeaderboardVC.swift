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

class LeaderboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ImagePickerDelegate {
	
	/*
	 TODO:
		- Adjust portfolio money format (100K, 1M etc.).
	 */
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var username_lbl: UILabel!
    @IBOutlet weak var usernameStatic_lbl: UILabel!
    
    @IBOutlet weak var rank_lbl: UILabel!
    @IBOutlet weak var rankStatic_lbl: UILabel!
    
    @IBOutlet weak var portfolio_lbl: UILabel!
    @IBOutlet weak var portfolioStatic_lbl: UILabel!
    @IBOutlet weak var change_lbl: UILabel!
    
    @IBOutlet weak var rankHeader_btn: UIButton!
    @IBOutlet weak var nameHeader_btn: UIButton!
    @IBOutlet weak var portfolioHeader_btn: UIButton!
    
    
    @IBOutlet weak var profileViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileInfoBtn: UIButton!
    @IBOutlet weak var profileExit: UIButton!
    @IBOutlet weak var profileRank_lbl: UILabel!
    @IBOutlet weak var profileUsername_lbl: UILabel!
    @IBOutlet weak var profilePortfolio_lbl: UILabel!
    @IBOutlet weak var profileChange_lbl: UILabel!
    @IBOutlet weak var profileOwnedCoin_lbl: UILabel!
    @IBOutlet weak var profileHighestHolding_lbl: UILabel!
    private var profileCurrentUserIndex:Int = 0;
	
	private let avatarImage : AvatarImage = {
		let avatarImage = AvatarImage();
		avatarImage.initialize();
		avatarImage.translatesAutoresizingMaskIntoConstraints = false;
		return avatarImage;
	}();
	
	private let profileAvatarImage : AvatarImage = {
		let avatarImage = AvatarImage();
		avatarImage.initialize();
		avatarImage.translatesAutoresizingMaskIntoConstraints = false;
		return avatarImage;
	}();
	
    // member variables
    private var currentUsername:String = "";
    private var currentHighscore:Double = 0.0;
    private var currentChange:String = "";
    private var isPortVC:Bool?;
    
    private var theRank:String = "0";
    private var users:Array<User> = Array<User>();
    private var filterUsers:Array<User> = Array<User>();
    private var isLoading:Bool = true;
    private var maxNumberOfUsers:Int = 101;
	private let portThreshold:Double = 1_000_000;
    
    // search controller setup
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true;
    }
    private var isFiltering: Bool {
        return self.searchController.isActive && !isSearchBarEmpty;
    }

    
    public init?(coder:NSCoder, currentUsername:String, currentHighscore:Double, currentChange:String, isPortVC:Bool) {
        super.init(coder: coder);
        self.currentUsername = currentUsername;
        self.currentHighscore = currentHighscore;
        self.currentChange = currentChange;
        self.isPortVC = isPortVC;
    }
    public required init?(coder: NSCoder) { fatalError("Error loading LeaderboadVC"); }

    
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews();
		
		self.avatarImage.circleize();
		self.profileAvatarImage.circleize();
		
	}
	
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false;
        self.navigationController?.navigationBar.barTintColor = .clear;
        self.navigationController?.navigationBar.shadowImage = UIImage();
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
        
         self.tabBarController?.tabBar.isHidden = true;
        
        // custom nav back button
        if (!self.isPortVC!) {
            self.navigationItem.backBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "mainPortDataImg"), style: .plain, target: self, action: #selector(backBtnTapped));
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.tableHeaderView = UIView();
        self.tableView.tableFooterView = UIView();
        
        // configure profileView
        self.profileView.isHidden = true;
        self.profileViewCenterY.constant = 800;
        self.profileView.layer.borderColor = UIColor.orange.cgColor;
        self.profileView.layer.borderWidth = 1;
        self.profileView.layer.cornerRadius = 15.0;
        self.profileView.clipsToBounds = true;
        self.profileView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture)))
        self.profileInfoBtn.addTarget(self, action: #selector(reportUserTapped), for: .touchUpInside);
        self.profileExit.addTarget(self, action: #selector(exitProfileTapped), for: .touchUpInside);
        self.profileUsername_lbl.adjustsFontSizeToFitWidth = true;
        self.profileRank_lbl.adjustsFontSizeToFitWidth = true;
        self.profilePortfolio_lbl.adjustsFontSizeToFitWidth = true;
        self.profileChange_lbl.adjustsFontSizeToFitWidth = true;
        self.profileHighestHolding_lbl.adjustsFontSizeToFitWidth = true;
        self.profileOwnedCoin_lbl.adjustsFontSizeToFitWidth = true;
        
        self.hideStats(hidden: true);
        self.username_lbl.text = self.currentUsername;
        self.username_lbl.textColor = .orange;
		self.portfolio_lbl.text =  (self.currentHighscore < self.portThreshold) ? CryptoData.convertToMoney(price: String(format: "%.2f", self.currentHighscore)) : CryptoData.formatMoney(money: self.currentHighscore);
        setChange(change: &self.change_lbl, changeString: self.currentChange);
        
        self.portfolio_lbl.adjustsFontSizeToFitWidth = true;
        self.change_lbl.adjustsFontSizeToFitWidth = true;
        self.username_lbl.adjustsFontSizeToFitWidth = true;
        self.rank_lbl.adjustsFontSizeToFitWidth = true;
        
        // configure searchView
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = false;
        searchController.searchBar.placeholder = "Search";
        searchController.searchBar.delegate = self;
        navigationItem.searchController = searchController;
        definesPresentationContext = true;
		
		self.setupConstraints();
		
		// configure avatarImage
		self.avatarImage.initializeWith(view: self.topView);
		self.profileAvatarImage.initializeWith(view: self.profileView);
		self.profileAvatarImage.avatarEditImageView.isHidden = true;
		self.profileAvatarImage.isUserInteractionEnabled = false;
		
		self.avatarImage.setImagePickerDelegate(vc: self, delegate: self);
		
        self.getUserData();
        
    }
	
	// MARK: Setting Up Constraints
	
	private func setupConstraints() -> Void {
		self.topView.addSubview(self.avatarImage);
		self.profileView.addSubview(self.profileAvatarImage);
		
		self.avatarImage.centerXAnchor.constraint(equalTo: self.username_lbl.centerXAnchor, constant: 0.0).isActive = true;
		self.avatarImage.topAnchor.constraint(equalTo: self.username_lbl.bottomAnchor, constant: 10.0).isActive = true;
		self.avatarImage.widthAnchor.constraint(equalToConstant: 75.0).isActive = true;
		self.avatarImage.heightAnchor.constraint(equalToConstant: 75.0).isActive = true;
		
		self.profileAvatarImage.centerXAnchor.constraint(equalTo: self.profileView.centerXAnchor).isActive = true;
		self.profileAvatarImage.centerYAnchor.constraint(equalTo: self.profileView.centerYAnchor, constant: 10.0).isActive = true;
		self.profileAvatarImage.widthAnchor.constraint(equalToConstant: 75.0).isActive = true;
		self.profileAvatarImage.heightAnchor.constraint(equalToConstant: 75.0).isActive = true;
		
	}
	
	// MARK: Image Picker Delegate Methods
	
	func didSelect(image: UIImage?) {
		if let image = image {
			let params:Dictionary<String, Any> = ["avatarImage":[DataStorageHandler.encodeImage(image: image)]];
			if let username = self.username_lbl.text {
				DatabaseManager.writeUserData(username: username, merge: true, data: params) { (error) in
					if let error = error { print(error.localizedDescription); return; }
					self.avatarImage.image = image;
					UserManager.shared.setCurrentProfilePicture(image: image);
				}
			}
		}
	}
    
    // MARK: Data Gathering
    
    private func getUserData() -> Void {
        DatabaseManager.getAllUserData { [weak self] (user, error) in
            if let error = error {
                print(error.localizedDescription);
            } else {
                if (user!.username == self?.currentUsername) {
                    self?.theRank = user!.rank;
                    self?.rank_lbl.text = user!.rank;
					if let decodedImage = DataStorageHandler.decodeImage(strBase64: user!.encodedAvatarImage) {
						self?.avatarImage.image = decodedImage;
						UserManager.shared.setCurrentProfilePicture(image: decodedImage);
					} else {
						UserManager.shared.removeCurrentProfilePicture();
					}
                }
                self?.isLoading = false;
                self?.hideStats(hidden: false);
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
            if (self.isFiltering) {
                return self.filterUsers.count;
            } else {
                if (self.users.count > self.maxNumberOfUsers - 1) {
                    return self.maxNumberOfUsers;
                } else {
                    return self.users.count;
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardCell;
        cell.rank_lbl.adjustsFontSizeToFitWidth = true;
        cell.username_lbl.adjustsFontSizeToFitWidth = true;
        cell.highscore_lbl.adjustsFontSizeToFitWidth = true;
        cell.change_lbl.adjustsFontSizeToFitWidth = true;
        if (self.isLoading) {
            SVProgressHUD.show(withStatus: "Loading...");
            self.hideCells(cell: cell, hidden: true);
        } else {
            SVProgressHUD.dismiss();
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0);
            self.hideCells(cell: cell, hidden: false);
            if (self.isFiltering) {
                cell.username_lbl.textColor = .label;
                self.setChange(change: &cell.change_lbl, changeString: self.filterUsers[indexPath.row].change);
                cell.rank_lbl.text = "\(self.filterUsers[indexPath.row].rank)";
                cell.username_lbl.text = self.filterUsers[indexPath.row].username;
				cell.highscore_lbl.text = (self.filterUsers[indexPath.row].highscore < self.portThreshold) ? CryptoData.convertToMoney(price: String(format: "%.2f", self.filterUsers[indexPath.row].highscore)) : CryptoData.formatMoney(money: self.filterUsers[indexPath.row].highscore)
                if (self.filterUsers[indexPath.row].username.lowercased() == currentUsername.lowercased()) {
                    cell.username_lbl.textColor = .orange;
                }
            } else {
                cell.username_lbl.textColor = .label;
                self.setChange(change: &cell.change_lbl, changeString: self.users[indexPath.row].change)
                cell.rank_lbl.text = "\(self.users[indexPath.row].rank)";
                cell.username_lbl.text = self.users[indexPath.row].username;
				cell.highscore_lbl.text = (self.users[indexPath.row].highscore < self.portThreshold) ? CryptoData.convertToMoney(price: String(format: "%.2f", self.users[indexPath.row].highscore)) : CryptoData.formatMoney(money: self.users[indexPath.row].highscore);
                if (indexPath.row == self.maxNumberOfUsers - 1) {
                    var isUserBeingDisplayed:Bool = true;
                    for i in 1...self.maxNumberOfUsers - 1 {
                        if (Int(self.users[Int(self.theRank)! - 1].rank) == i) {
                            isUserBeingDisplayed = false;
                            break;
                        }
                    }
                    if (self.users[Int(self.theRank)! - 1].username.lowercased() == currentUsername.lowercased()) {
                        if (isUserBeingDisplayed) {
                            cell.isHidden = false;
                            self.setChange(change: &cell.change_lbl, changeString: self.users[Int(self.theRank)! - 1].change)
                            cell.rank_lbl.text = "\(self.users[Int(self.theRank)! - 1].rank)";
                            cell.username_lbl.text = self.users[Int(self.theRank)! - 1].username;
                            cell.username_lbl.textColor = .orange;
							cell.highscore_lbl.text = (self.users[Int(self.theRank)! - 1].highscore < self.portThreshold) ? CryptoData.convertToMoney(price: String(format: "%.2f", self.users[Int(self.theRank)! - 1].highscore)) : CryptoData.formatMoney(money: self.users[Int(self.theRank)! - 1].highscore);
                        } else {
                            cell.isHidden = true;
                        }
                    }
                } else {
                    if (self.users[indexPath.row].username.lowercased() == currentUsername.lowercased()) {
                        cell.username_lbl.textColor = .orange;
                    }
                }
            }
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        self.searchController.searchBar.endEditing(true);
        let currentIndex:Int = indexPath.row == self.maxNumberOfUsers - 1 ? Int(self.theRank)! - 1 : indexPath.row;
        if (self.isFiltering) {
            self.configureProfileView(userList: self.filterUsers, index: currentIndex);
        } else {
            self.configureProfileView(userList: self.users, index: currentIndex);
        }
        self.profileView.isHidden = false;
        self.profileViewCenterY.constant = 0;
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded();
        }, completion: nil);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0;
    }
    
    // MARK: ProfileView Methods
    
    private func configureProfileView(userList:Array<User>, index:Int) {
        if (userList[index].username.lowercased() == self.currentUsername.lowercased()) { self.profileInfoBtn.isHidden = true; }
        self.profileCurrentUserIndex = index;
        self.adjustViewsForAnimation(alpha: 0.5);
        self.tableView.isUserInteractionEnabled = false;
        
        // configure profileView
        self.profileHighestHolding_lbl.text = userList[index].highestHolding;
        self.profileRank_lbl.text = userList[index].rank;
        self.profileUsername_lbl.text = userList[index].username;
		self.profilePortfolio_lbl.text = (userList[index].highscore < self.portThreshold) ? CryptoData.convertToMoney(price: String(format: "%.2f", userList[index].highscore)) : CryptoData.formatMoney(money: userList[index].highscore);
		
        self.setChange(change: &self.profileChange_lbl, changeString: userList[index].change);
        if (userList[index].username.lowercased() == self.currentUsername.lowercased()) {
			self.profileUsername_lbl.textColor = .orange;
			if let decodedImage = UserManager.shared.getCurrentProfilePicture() {
				self.profileAvatarImage.image = decodedImage;
			} else {
				self.profileAvatarImage.image = UIImage(named: "avatar_image");
			}
        } else {
            self.profileUsername_lbl.textColor = .label;
			if let decodedImage = DataStorageHandler.decodeImage(strBase64: userList[index].encodedAvatarImage) {
				self.profileAvatarImage.image = decodedImage;
			} else {
				self.profileAvatarImage.image = UIImage(named: "avatar_image");
			}
		}
        self.profileOwnedCoin_lbl.text = "\(userList[index].numberOfOwnedCoin)";
        
    }
        
    @objc func reportUserTapped() {
        let alert = UIAlertController(title: "Report User", message: "", preferredStyle: .alert);
        alert.addTextField();
        alert.textFields![0].placeholder = "Reason";
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] (action) in
            if (alert.textFields![0].text!.isEmpty) {
                self?.displayAlert(title: "Error", message: "Reason cannot be blank");
                return;
            }
            DatabaseManager.writeUserData(username: self!.users[self!.profileCurrentUserIndex].username, merge: true, data: ["reported":true, "reportedMessage":alert.textFields![0].text! + "\n" + "Reported By: \(self!.currentUsername)"]) { [weak self] (error) in
                if (error != nil) {
                    print("Error reporting user");
                    return;
                }
                self?.displayAlert(title: "Success!", message: "successfuly reported player");
            }
        }));
        self.present(alert, animated: true, completion: nil);
    }
    
    @objc func exitProfileTapped() {
        self.adjustViewsForAnimation(alpha: 1);
        self.profileViewCenterY.constant = 800;
        self.tableView.isUserInteractionEnabled = true;
        self.profileInfoBtn.isHidden = false;
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded();
        });
    }
            
    @objc func handlePanGesture(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view);
        switch (gesture.state) {
        case .began:
            break;
        case .changed:
            if (translation.y < 0) { break; }
            self.profileView.transform = CGAffineTransform(translationX: 0.0, y: translation.y);
            break;
        case .ended:
            if (translation.y >= 100) {
                self.adjustViewsForAnimation(alpha: 1);
                self.tableView.isUserInteractionEnabled = true;
                self.profileViewCenterY.constant = 800;
                self.profileInfoBtn.isHidden = false;
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.profileView.transform = .identity;
                    self.view.layoutIfNeeded();
                });
            } else {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
                    self.profileView.transform = .identity;
                }, completion: nil)
            }
            break;
        default:
            break;
        }
    }
    
    @objc func backBtnTapped() {
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    @objc func addBtnTapped() {
        print("Add button pressed");
    }
        
    // MARK: Helper Methods
    
    private func adjustViewsForAnimation(alpha:CGFloat) {
        self.tableView.alpha = alpha;
        self.username_lbl.alpha = alpha;
        self.rank_lbl.alpha = alpha;
        self.portfolio_lbl.alpha = alpha;
        self.change_lbl.alpha = alpha;
        self.usernameStatic_lbl.alpha = alpha;
        self.rankStatic_lbl.alpha = alpha;
        self.portfolioStatic_lbl.alpha = alpha;
        self.rankHeader_btn.alpha = alpha;
        self.nameHeader_btn.alpha = alpha;
        self.portfolioHeader_btn.alpha = alpha;
		self.avatarImage.alpha = alpha;
		self.avatarImage.isUserInteractionEnabled = (alpha >= 1);
		self.avatarImage.avatarEditImageView.alpha = alpha;
		self.avatarImage.avatarEditImageView.tintColor = (alpha < 1) ? .lightGray : .orange;
		self.avatarImage.avatarEditImageView.isUserInteractionEnabled = (alpha >= 1);
    }
    
    private func hideCells(cell:LeaderboardCell, hidden:Bool) {
        cell.rank_lbl.isHidden = hidden;
        cell.username_lbl.isHidden = hidden;
        cell.highscore_lbl.isHidden = hidden;
        cell.change_lbl.isHidden = hidden;
    }
    
    private func hideStats(hidden:Bool) -> Void {
        self.username_lbl.isHidden = hidden;
        self.rank_lbl.isHidden = hidden;
        self.portfolio_lbl.isHidden = hidden;
        self.change_lbl.isHidden = hidden;
        self.usernameStatic_lbl.isHidden = hidden;
        self.rankStatic_lbl.isHidden = hidden;
        self.portfolioStatic_lbl.isHidden = hidden;
        self.rankHeader_btn.isHidden = hidden;
        self.nameHeader_btn.isHidden = hidden;
        self.portfolioHeader_btn.isHidden = hidden;
		self.avatarImage.isHidden = hidden;
		self.avatarImage.avatarEditImageView.isHidden = hidden;
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
    
    private func setChange(change:inout UILabel, changeString:String) {
        if (changeString.first! != "-") {
            if (self.traitCollection.userInterfaceStyle == .dark) {
                change.textColor = ChartColors.greenColor();
            } else {
                change.textColor = ChartColors.greenColor();
            }
            change.attributedText = self.attachImageToString(text: changeString, image: #imageLiteral(resourceName: "sortUpArrow"));
        } else {
            change.textColor = ChartColors.redColor();
            change.attributedText = self.attachImageToString(text: changeString, image: #imageLiteral(resourceName: "sortDownArrow"));
        }
    }
    
    private func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        self.present(alert, animated: true, completion: nil);
    }

    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light);
        impactFeedbackGenerator.impactOccurred()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        self.filterUsers = self.users.filter({ (user) -> Bool in
            let filterContext = user.username.lowercased().contains(searchText.lowercased());
            return filterContext;
        })
        self.tableView.reloadData();
    }
}

extension LeaderboardVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar;
        filterContentForSearchText(searchBar.text!);
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.searchTextField.isEnabled = true;
        self.adjustViewsForAnimation(alpha: 1);
        self.profileViewCenterY.constant = 800;
        self.tableView.isUserInteractionEnabled = true;
        self.profileInfoBtn.isHidden = false;
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded();
        });
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.adjustViewsForAnimation(alpha: 1);
            self.profileViewCenterY.constant = 800;
            self.tableView.isUserInteractionEnabled = true;
            self.profileInfoBtn.isHidden = false;
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded();
            });
        }
    }
}


public class LeaderboardCell : UITableViewCell {
    
    @IBOutlet weak var rank_lbl: UILabel!
    @IBOutlet weak var username_lbl: UILabel!
    @IBOutlet weak var highscore_lbl: UILabel!
    @IBOutlet weak var change_lbl: UILabel!
    
}
