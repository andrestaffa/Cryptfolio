//
//  ATimestampSelectionView.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2021-08-25.
//  Copyright © 2021 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;
import SVProgressHUD;

public class ATimestampSelectionView : UIView {
	
	// MARK: - Member Fields
	
	let backgroundView : UIView = {
		let view = UIView();
		view.backgroundColor = UIColor.black.withAlphaComponent(0.3);
		view.translatesAutoresizingMaskIntoConstraints = false;
		return view;
	}();
	
	let titleLabel: UILabel = {
		let label = UILabel();
		label.text = "Choose Time Period";
		label.textAlignment = .center;
		label.textColor = .white;
		label.lineBreakMode = .byWordWrapping;
		label.numberOfLines = 2;
		label.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold);
		label.translatesAutoresizingMaskIntoConstraints = false;
		return label;
	}();
	
	
	let dayButton: UIButton = {
		let button = UIButton();
		button.setAttributedTitle(NSAttributedString(string: "24 Hours", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
		button.setTitleColor(.white, for: .normal);
		button.backgroundColor = UIColor(red: 61/255, green: 66/255, blue: 67/255, alpha: 1);
		button.layer.cornerRadius = 3.0;
		button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
		button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
		button.layer.shadowOpacity = 1.0;
		button.layer.shadowRadius = 3.0;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	let weekButton: UIButton = {
		let button = UIButton();
		button.setAttributedTitle(NSAttributedString(string: "One Week", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
		button.setTitleColor(.white, for: .normal);
		button.backgroundColor = UIColor(red: 61/255, green: 66/255, blue: 67/255, alpha: 1);
		button.layer.cornerRadius = 3.0;
		button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
		button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
		button.layer.shadowOpacity = 1.0;
		button.layer.shadowRadius = 3.0;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	let monthButton: UIButton = {
		let button = UIButton();
		button.setAttributedTitle(NSAttributedString(string: "One Month", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
		button.setTitleColor(.white, for: .normal);
		button.backgroundColor = UIColor(red: 61/255, green: 66/255, blue: 67/255, alpha: 1);
		button.layer.cornerRadius = 3.0;
		button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
		button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
		button.layer.shadowOpacity = 1.0;
		button.layer.shadowRadius = 3.0;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	let yearButton: UIButton = {
		let button = UIButton();
		button.setAttributedTitle(NSAttributedString(string: "One Year", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
		button.setTitleColor(.white, for: .normal);
		button.backgroundColor = UIColor(red: 61/255, green: 66/255, blue: 67/255, alpha: 1);
		button.layer.cornerRadius = 3.0;
		button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
		button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
		button.layer.shadowOpacity = 1.0;
		button.layer.shadowRadius = 3.0;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	let fiveYearButton: UIButton = {
		let button = UIButton();
		button.setAttributedTitle(NSAttributedString(string: "Five Years", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
		button.setTitleColor(.white, for: .normal);
		button.backgroundColor = UIColor(red: 61/255, green: 66/255, blue: 67/255, alpha: 1);
		button.layer.cornerRadius = 3.0;
		button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
		button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
		button.layer.shadowOpacity = 1.0;
		button.layer.shadowRadius = 3.0;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	let stackView : UIStackView = {
		let stackView = UIStackView();
		stackView.axis = .vertical;
		stackView.spacing = 20.0
		stackView.alignment = .fill;
		stackView.distribution = .fillEqually;
		stackView.translatesAutoresizingMaskIntoConstraints = false;
		return stackView;
	}();
	
	let continueButton: UIButton = {
		let button = UIButton();
		button.setAttributedTitle(NSAttributedString(string: "Continue", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
		button.setTitleColor(.white, for: .normal);
		button.backgroundColor = .orange;
		button.layer.cornerRadius = 3.0;
		button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
		button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
		button.layer.shadowOpacity = 1.0;
		button.layer.shadowRadius = 3.0;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	let cancelButton: UIButton = {
		let button = UIButton();
		button.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .semibold)]), for: .normal);
		button.setTitleColor(.white, for: .normal);
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	private var viewController:UIViewController!;
	private var containingView:UIView!;
	private var coin:Coin!;
	private var timestamp:String = "24h";
	private var buttons:Array<UIButton> = Array<UIButton>();

	
	// MARK: - Constructor
	init(viewController:UIViewController, containingView:UIView, coin:Coin) {
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
		self.viewController = viewController;
		self.containingView = containingView;
		self.coin = coin;
		self.buttons = [self.dayButton, self.weekButton, self.monthButton, self.yearButton, self.fiveYearButton];
		self.backgroundColor = .mainBackgroundColor;
		self.layer.borderWidth = 4;
		self.layer.borderColor = UIColor.orange.cgColor;
		self.layer.cornerRadius = 15.0;
		self.layer.masksToBounds = true;
		self.translatesAutoresizingMaskIntoConstraints = false;
		self.transform = CGAffineTransform(translationX: 0, y: self.containingView.frame.size.height);
		self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture)));
		self.setStackView();
		self.setupConstraints();
		self.dayButton.addTarget(self, action: #selector(self.dayButtonTapped), for: .touchUpInside);
		self.weekButton.addTarget(self, action: #selector(self.weekButtonTapped), for: .touchUpInside);
		self.monthButton.addTarget(self, action: #selector(self.monthButtonTapped), for: .touchUpInside);
		self.yearButton.addTarget(self, action: #selector(self.yearButtonTapped), for: .touchUpInside);
		self.fiveYearButton.addTarget(self, action: #selector(self.fiveYearButtonTapped), for: .touchUpInside);
		self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped), for: .touchUpInside);
		self.continueButton.addTarget(self, action: #selector(self.continueButtonTapped), for: .touchUpInside);
	}
	public required init?(coder: NSCoder) { super.init(coder: coder); }
	
	// MARK: - Button Interactions
	
	
	public func show() -> Void {
		UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.transform = .identity;
		}, completion: nil);
	}
	
	@objc private func dayButtonTapped() -> Void {
		self.vibrate();
		self.timestamp = "24h"
		self.setSelctedButton(selectedButton: self.dayButton);
	}
	
	@objc private func weekButtonTapped() -> Void {
		self.vibrate();
		self.timestamp = "7d";
		self.setSelctedButton(selectedButton: self.weekButton);
	}
	
	@objc private func monthButtonTapped() -> Void {
		self.vibrate();
		self.timestamp = "30d";
		self.setSelctedButton(selectedButton: self.monthButton);
	}
	
	@objc private func yearButtonTapped() -> Void {
		self.vibrate();
		self.timestamp = "1y";
		self.setSelctedButton(selectedButton: self.yearButton);
	}
	
	@objc private func fiveYearButtonTapped() -> Void {
		self.vibrate();
		self.timestamp = "5y";
		self.setSelctedButton(selectedButton: self.fiveYearButton);
	}
	
	@objc private func cancelButtonTapped() -> Void {
		self.vibrate();
		self.cancelButton.alpha = 0.5;
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
			self.cancelButton.alpha = 1.0;
		}
		self.closeInfoView();
	}
	
	@objc private func continueButtonTapped() -> Void {
		self.vibrate();
		self.continueButton.isUserInteractionEnabled = false;
		self.cancelButton.isUserInteractionEnabled = false;
		self.continueButton.alpha = 0.5;
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
			self.continueButton.alpha = 1.0;
		}
		SVProgressHUD.show(withStatus: "Loading...");
		CryptoData.getCryptoID(coinSymbol: self.coin.ticker.symbol.lowercased()) { (uuid, error) in
			if let _ = error { CryptoData.DisplayNetworkErrorAlert(vc: self.viewController); self.closeInfoView(); return; }
			guard let uuid = uuid else {  self.closeInfoView(); return; }
			CryptoData.getCoinHistory(id: uuid, timeFrame: self.timestamp) { [weak self] (history, error) in
				SVProgressHUD.dismiss();
				if let strongSelf = self {
					if let _ = error { CryptoData.DisplayNetworkErrorAlert(vc: strongSelf.viewController); strongSelf.closeInfoView(); return; }
					if let history = history {
						let dataPoints = history.prices;
						if (!dataPoints.isEmpty) {
							var series:Array<Array<Double>> = Array<Array<Double>>();
							for dataPoint in dataPoints {
								series.append([dataPoint]);
							}
							let chartVC = strongSelf.viewController.storyboard?.instantiateViewController(withIdentifier: "ARChartVC") as! ARChartViewController;
							chartVC.dataPoints = series;
							chartVC.coin = strongSelf.coin;
							chartVC.hidesBottomBarWhenPushed = true;
							strongSelf.viewController .navigationController?.pushViewController(chartVC, animated: true);
							strongSelf.closeInfoView();
						} else {
							strongSelf.closeInfoView();
						}
					} else {
						strongSelf.closeInfoView();
					}
				}
			}
		}
	}
	
	private func setSelctedButton(selectedButton:UIButton) {
		for button in self.buttons {
			if (button == selectedButton) {
				self.layoutIfNeeded();
				button.layer.borderWidth = 2;
				button.layer.borderColor = UIColor.orange.cgColor;
				button.setTitleColor(.orange, for: .normal);
			} else {
				button.layer.borderWidth = 0;
				button.layer.borderColor = UIColor.clear.cgColor;
				button.setTitleColor(.white, for: .normal);
				for subView in button.subviews {
					if (subView is UIImageView) {
						subView.removeFromSuperview();
					}
				}
			}
		}
	}
	
	private func setStackView() -> Void {
		self.stackView.addArrangedSubview(self.dayButton);
		self.stackView.addArrangedSubview(self.weekButton);
		self.stackView.addArrangedSubview(self.monthButton);
		self.stackView.addArrangedSubview(self.yearButton);
		self.stackView.addArrangedSubview(self.fiveYearButton);
		self.setSelctedButton(selectedButton: self.dayButton);
	}
	
	
	// MARK: - Setting Up Constraints
	
	private func setupConstraints() -> Void {
		self.containingView.addSubview(self.backgroundView);
		self.containingView.addSubview(self);
		self.addSubview(self.titleLabel);
		self.addSubview(self.stackView);
		self.addSubview(self.continueButton);
		self.addSubview(self.cancelButton);
		
		// constraints for backgroundView
		self.backgroundView.topAnchor.constraint(equalTo: self.containingView.topAnchor).isActive = true;
		self.backgroundView.leadingAnchor.constraint(equalTo: self.containingView.leadingAnchor).isActive = true;
		self.backgroundView.trailingAnchor.constraint(equalTo: self.containingView.trailingAnchor).isActive = true;
		self.backgroundView.bottomAnchor.constraint(equalTo: self.containingView.bottomAnchor).isActive = true;
		
		// constraints for self (view)
		self.centerYAnchor.constraint(equalTo: self.containingView.centerYAnchor).isActive = true;
		self.centerXAnchor.constraint(equalTo: self.containingView.centerXAnchor).isActive = true;
		self.widthAnchor.constraint(equalTo: self.containingView.widthAnchor, multiplier: 0.9).isActive = true;
		self.bottomAnchor.constraint(equalTo: self.continueButton.bottomAnchor, constant: 20.0).isActive = true;
		
		// constraints for titleLabel
		self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0).isActive = true;
		self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15.0).isActive = true;
		self.titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true;
		self.titleLabel.heightAnchor.constraint(equalToConstant: 60.0).isActive = true;
		
		// heights for buttons
		self.dayButton.heightAnchor.constraint(equalToConstant: 45.0).isActive = true;
		self.weekButton.heightAnchor.constraint(equalToConstant: 45.0).isActive = true;
		self.monthButton.heightAnchor.constraint(equalToConstant: 45.0).isActive = true;
		self.yearButton.heightAnchor.constraint(equalToConstant: 45.0).isActive = true;
		
		// constraints for stackView
		self.stackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5.0).isActive = true;
		self.stackView.bottomAnchor.constraint(equalTo: self.continueButton.topAnchor, constant: -30.0).isActive = true;
		self.stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
		self.stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true;
		
		// constraints for continueButton
		self.continueButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
		self.continueButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true;
		self.continueButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true;
		self.continueButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true;
		
		// constraints for cancelButton
		self.cancelButton.centerYAnchor.constraint(equalTo: self.continueButton.centerYAnchor).isActive = true;
		self.cancelButton.trailingAnchor.constraint(equalTo: self.continueButton.leadingAnchor, constant: -10.0).isActive = true;
		self.cancelButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true;
		self.cancelButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true;
		
	}
	
	// MARK: Gesture Methods
	
	@objc private func handlePanGesture(gesture:UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self.containingView);
		switch (gesture.state) {
		case .began:
			break;
		case .changed:
			if (translation.y < 0) { break; }
			self.transform = CGAffineTransform(translationX: 0.0, y: translation.y);
			break;
		case .ended:
			if (translation.y >= 100) {
				UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
					self.transform = .identity;
				}, completion: nil);
			} else {
				UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
					self.transform = .identity;
				}, completion: nil);
			}
			break;
		default:
			break;
		}
	}
	
	private func vibrate() -> Void {
		let impact = UIImpactFeedbackGenerator(style: .light);
		impact.prepare();
		impact.impactOccurred();
	}
	
	private func closeInfoView() -> Void {
		self.backgroundView.removeFromSuperview();
		UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.transform = CGAffineTransform(translationX: 0, y: self.containingView.frame.size.height);
		}) { (done) in
			self.removeFromSuperview();
		};
	}
	
	// MARK: - Deconstructor
	
	deinit { print("\(self) has been deconstructed"); }
}
