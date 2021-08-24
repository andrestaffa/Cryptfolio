//
//  ScreenshotView.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2021-08-24.
//  Copyright © 2021 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

class ScreenshotView : UIView {
	
	let backgroundView : UIView = {
		let view = UIView();
		view.backgroundColor = .black.withAlphaComponent(0.3);
		view.translatesAutoresizingMaskIntoConstraints = false;
		return view;
	}();
	
	let imageView : UIImageView = {
		let imageView = UIImageView();
		imageView.contentMode = .scaleAspectFit;
		imageView.layer.cornerRadius = 5;
		imageView.layer.masksToBounds = true;
		imageView.clipsToBounds = true;
		imageView.translatesAutoresizingMaskIntoConstraints = false;
		return imageView;
	}();
	
	let exitButton : UIButton = {
		let button = UIButton();
		button.frame = CGRect(x: 0, y: 0, width: 55, height: 55);
		button.setImage(UIImage(named: "exit")?.withRenderingMode(.alwaysTemplate), for: .normal);
		button.tintColor = .white
		button.backgroundColor = .mainBackgroundColor;
		button.layer.borderWidth = 1.0;
		button.layer.borderColor = UIColor.orange.cgColor;
		button.layer.cornerRadius = button.bounds.size.width / 2;
		button.layer.masksToBounds = true;
		button.clipsToBounds = true;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	let shareButton : UIButton = {
		let button = UIButton();
		button.frame = CGRect(x: 0, y: 0, width: 55, height: 55);
		button.setImage(UIImage(named: "share")?.withRenderingMode(.alwaysTemplate), for: .normal);
		button.tintColor = .white
		button.backgroundColor = .mainBackgroundColor;
		button.layer.borderWidth = 1.0;
		button.layer.borderColor = UIColor.orange.cgColor;
		button.layer.cornerRadius = button.bounds.size.width / 2;
		button.layer.masksToBounds = true;
		button.clipsToBounds = true;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button;
	}();
	
	private var viewController:ARChartViewController!;
	
	
	public init(viewController:ARChartViewController, image:UIImage) {
		super.init(frame: .zero);
		self.viewController = viewController;
		self.imageView.image = image;
		self.backgroundColor = .mainBackgroundColor;
		self.layer.borderWidth = 3;
		self.layer.borderColor = UIColor.orange.cgColor;
		self.layer.cornerRadius = 15;
		self.translatesAutoresizingMaskIntoConstraints = false;
		self.transform = CGAffineTransform(translationX: 0, y: -self.viewController.view.frame.size.height);
		self.exitButton.transform = CGAffineTransform(translationX: 0, y: -self.viewController.view.frame.size.height);
		self.shareButton.transform = CGAffineTransform(translationX: 0, y: -self.viewController.view.frame.size.height);
		
		self.exitButton.addTarget(self, action: #selector(self.exitButtonTapped(_:)), for: .touchUpInside);
		self.shareButton.addTarget(self, action: #selector(self.shareButtonTapped(_:)), for: .touchUpInside);
		
		self.setupConstraints();
	}
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
	
	public func show() -> Void {
		self.viewController.chartButton.isHidden = true;
		self.viewController.screenshotButton.isHidden = true;
		self.viewController.navigationController?.navigationBar.isHidden = true;
		UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.transform = .identity;
			self.exitButton.transform = .identity;
			self.shareButton.transform = .identity;
		}, completion: nil);
	}
	
	@objc private func exitButtonTapped(_ sender:UIButton) -> Void {
		self.closeInfoView();
	}
	
	@objc private func shareButtonTapped(_ sender:UIButton) -> Void {
		let impact = UIImpactFeedbackGenerator(style: .light);
		impact.prepare();
		impact.impactOccurred();
		let vc = UIActivityViewController(activityItems: [self.imageView.image!], applicationActivities: []);
		self.viewController.present(vc, animated: true);
	}
	
	private func setupConstraints() -> Void {
		self.viewController.view.addSubview(self.backgroundView);
		self.viewController.view.addSubview(self);
		self.addSubview(self.imageView);
		self.backgroundView.addSubview(self.exitButton);
		self.backgroundView.addSubview(self.shareButton);
		
		// constraints for backgroundView
		self.backgroundView.topAnchor.constraint(equalTo: self.viewController.view.topAnchor).isActive = true;
		self.backgroundView.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor).isActive = true;
		self.backgroundView.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor).isActive = true;
		self.backgroundView.bottomAnchor.constraint(equalTo: self.viewController.view.bottomAnchor).isActive = true;
		
		// constraints for imageView
		self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
		self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
		self.imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7).isActive = true;
		self.imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.7).isActive = true;
		
		// constraints for exitButton
		self.exitButton.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 20).isActive = true;
		self.exitButton.centerXAnchor.constraint(equalTo: self.viewController.view.centerXAnchor, constant: -45.0).isActive = true;
		self.exitButton.widthAnchor.constraint(equalToConstant: 55).isActive = true;
		self.exitButton.heightAnchor.constraint(equalToConstant: 55).isActive = true;
		
		// constraints for shareButton
		self.shareButton.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 20).isActive = true;
		self.shareButton.centerXAnchor.constraint(equalTo: self.viewController.view.centerXAnchor, constant: 45.0).isActive = true;
		self.shareButton.widthAnchor.constraint(equalToConstant: 55).isActive = true;
		self.shareButton.heightAnchor.constraint(equalToConstant: 55).isActive = true;
		
		// constraints for self (view)
		self.centerYAnchor.constraint(equalTo: self.viewController.view.centerYAnchor, constant: -50.0).isActive = true;
		self.centerXAnchor.constraint(equalTo: self.viewController.view.centerXAnchor).isActive = true;
		self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.75).isActive = true;
		self.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.73).isActive = true;
		
	}
	
	private func closeInfoView() -> Void {
		self.viewController.chartButton.isHidden = false;
		self.viewController.screenshotButton.isHidden = false;
		self.viewController.navigationController?.navigationBar.isHidden = false;
		self.backgroundView.removeFromSuperview();
		UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.transform = CGAffineTransform(translationX: 0, y: -self.viewController.view.frame.size.height);
			self.exitButton.transform = CGAffineTransform(translationX: 0, y: -self.viewController.view.frame.size.height);
			self.shareButton.transform = CGAffineTransform(translationX: 0, y: -self.viewController.view.frame.size.height);
		}) { (done) in
			self.removeFromSuperview();
		};
	}
	
	
}
