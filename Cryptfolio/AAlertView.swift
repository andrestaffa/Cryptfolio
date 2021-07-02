//
//  AAlertViewController.swift
//  AAlert
//
//  Created by Andre Staffa on 06/20/2021.
//

import Foundation;
import UIKit;


public class AAlertView : UIView {
    
    // MARK: Member Fields
    
    let backgroundView : UIView = {
        let view = UIView();
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45);
        view.translatesAutoresizingMaskIntoConstraints = false;
        return view;
    }();
    
    let exitButton: UIButton = {
        let button = UIButton(type: .close);
        button.translatesAutoresizingMaskIntoConstraints = false;
        return button;
    }();
    
    let titleLabel: UILabel = {
        let label = UILabel();
        label.textAlignment = .center;
        label.textColor = .black;
        label.lineBreakMode = .byWordWrapping;
        label.numberOfLines = 2;
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .bold);
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let messageLabel: UILabel = {
        let label = UILabel();
        label.textColor = .black;
        label.textAlignment = .center;
        label.lineBreakMode = .byWordWrapping;
        label.numberOfLines = 0;
        label.font = UIFont.systemFont(ofSize: 12.5, weight: .light);
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let rightButton: UIButton = {
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
    
    let leftButton: UIButton = {
        let button = UIButton();
        button.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .regular)]), for: .normal);
        button.setTitleColor(.black, for: .normal);
        button.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1);
        button.layer.cornerRadius = 3.0;
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
        button.layer.shadowOpacity = 1.0;
        button.layer.shadowRadius = 3.0;
        button.translatesAutoresizingMaskIntoConstraints = false;
        return button;
    }();
    
    let centerButton: UIButton = {
        let button = UIButton();
        button.setAttributedTitle(NSAttributedString(string: "OK", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
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
    
    private var containingViewController : UIViewController!;
    private var buttons:Array<(UIButton, (() -> ()))> = Array<(UIButton, (() -> ()))>();
    private var rightButtonPressed : (() -> ()) = {};
    private var leftButtonPressed : (() -> ()) = {};
    private var centerButtonPresesd : (() -> ()) = {};
    
    // MARK: Constructor
    
    public init(containingViewController:UIViewController, title:String, message:String, primaryTheme:UIColor = .orange) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        self.containingViewController = containingViewController;
        self.backgroundColor = .white;
        self.layer.borderWidth = 2;
        self.layer.borderColor = primaryTheme.cgColor;
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.transform = CGAffineTransform(translationX: 0, y: self.containingViewController.view.frame.size.height);
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture)));
        self.exitButton.addTarget(self, action: #selector(self.handleExitPressed), for: .touchUpInside);
        self.rightButton.addTarget(self, action: #selector(self.handleRightButtonPressed), for: .touchUpInside);
        self.leftButton.addTarget(self, action: #selector(self.handleLeftButtonPressed), for: .touchUpInside);
        self.centerButton.addTarget(self, action: #selector(self.handleCenterButtonPressed), for: .touchUpInside);
        self.titleLabel.text = title;
        self.messageLabel.text = message;
        self.rightButton.backgroundColor = primaryTheme;
        self.centerButton.backgroundColor = primaryTheme;
        self.leftButton.isHidden = true;
        self.rightButton.isHidden = true;
        self.centerButton.isHidden = true;
        self.setupContraints();
    }
    public required init?(coder: NSCoder) { super.init(coder: coder); }
    
    // MARK: Setting Up Contraints
    
    private func setupContraints() -> Void {
        self.containingViewController.view.addSubview(self.backgroundView);
        self.backgroundView.addSubview(self);
        self.addSubview(self.exitButton);
        self.addSubview(self.titleLabel);
        self.addSubview(self.messageLabel);
        self.addSubview(self.rightButton);
        self.addSubview(self.leftButton);
        self.addSubview(self.centerButton);
        
        // constraints for backgroundView
        self.backgroundView.topAnchor.constraint(equalTo: self.containingViewController.view.topAnchor).isActive = true;
        self.backgroundView.leadingAnchor.constraint(equalTo: self.containingViewController.view.leadingAnchor).isActive = true;
        self.backgroundView.trailingAnchor.constraint(equalTo: self.containingViewController.view.trailingAnchor).isActive = true;
        self.backgroundView.bottomAnchor.constraint(equalTo: self.containingViewController.view.bottomAnchor).isActive = true;
        
        self.backgroundView.frame = self.containingViewController.view.frame;
        
        // constraints for self (view)
        self.centerYAnchor.constraint(equalTo: self.containingViewController.view.centerYAnchor).isActive = true;
        self.centerXAnchor.constraint(equalTo: self.containingViewController.view.centerXAnchor).isActive = true;
        self.widthAnchor.constraint(equalTo: self.containingViewController.view.widthAnchor, multiplier: 0.9).isActive = true;
        self.bottomAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 80.0).isActive = true;
        
        // constraints for exitButton
        self.exitButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0).isActive = true;
        self.exitButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true;
        self.exitButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true;
        self.exitButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true;
        
        // constraints for titleLabel
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true;
        self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        self.titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true;
        self.titleLabel.heightAnchor.constraint(equalToConstant: 60.0).isActive = true;
        
        // constraints for messageLabel
        self.messageLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: -5.0).isActive = true;
        self.messageLabel.bottomAnchor.constraint(equalTo: self.centerButton.topAnchor, constant: -30.0).isActive = true;
        self.messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        self.messageLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true;
        
        // constraints for rightButton
        self.rightButton.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 30.0).isActive = true;
        self.rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0).isActive = true;
        self.rightButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.46).isActive = true;
        self.rightButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true;
        
        // constraints for leftButton
        self.leftButton.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 30.0).isActive = true;
        self.leftButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true;
        self.leftButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.46).isActive = true;
        self.leftButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true;
        
        // constraints for centerButton
        self.centerButton.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 10.0).isActive = true;
        self.centerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        self.centerButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true;
        self.centerButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true;
        
    }
    
    // MARK: Public Methods
    
    public func show() -> Void {
        if let backgroundColor = self.containingViewController.view.backgroundColor {
            self.backgroundView.backgroundColor = backgroundColor.withAlphaComponent(0.45);
        } else {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.45);
        }
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity;
        }, completion: nil);
    }
    
    public func addAction(title:String, completion:@escaping() -> Void) -> Void {
        if (self.buttons.count == 3) { print("Error: No more buttons can be added."); return; }
        if (self.buttons.isEmpty) {
            self.buttons.append((self.centerButton, completion));
            self.centerButton.setAttributedTitle(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
            self.centerButton.setTitleColor(.white, for: .normal);
            self.centerButton.isHidden = false;
            self.centerButtonPresesd = completion;
        } else if (self.buttons.count == 1) {
            self.buttons[0].0.isHidden = true;
            self.buttons.append((self.leftButton, completion));
            self.leftButton.setAttributedTitle(NSAttributedString(string: self.buttons[0].0.titleLabel!.text!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .regular)]), for: .normal);
            self.leftButton.setTitleColor(.black, for: .normal);
            self.leftButton.isHidden = false;
            self.leftButtonPressed = self.buttons[0].1;
            self.buttons.append((self.rightButton, completion));
            self.rightButton.setAttributedTitle(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13.0, weight: .bold)]), for: .normal);
            self.rightButton.setTitleColor(.white, for: .normal);
            self.rightButton.isHidden = false;
            self.rightButtonPressed = completion;
        } 
    }
    
    public func enableDarkMode() -> Void {
        self.backgroundColor = UIColor(red: 30/255, green: 31/255, blue: 31/255, alpha: 1);
        self.titleLabel.textColor = .white;
        self.messageLabel.textColor = .white;
    }
    
    // MARK: Button Interactions (Private)
    
    private func impactGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style);
        generator.impactOccurred()
    }
    
    @objc private func handleExitPressed() -> Void {
        self.exitButton.alpha = 0.5;
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
            self.exitButton.alpha = 1.0;
        }
        self.closeInfoView();
    }
    
    @objc private func handleRightButtonPressed() -> Void {
        self.impactGenerator(style: .soft);
        self.rightButton.alpha = 0.5;
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
            self.rightButton.alpha = 1.0;
        }
        self.closeInfoView();
        self.rightButtonPressed();
    }
    
    
    @objc private func handleLeftButtonPressed() -> Void {
        self.impactGenerator(style: .soft);
        self.leftButton.alpha = 0.5;
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
            self.leftButton.alpha = 1.0;
        }
        self.closeInfoView();
        self.leftButtonPressed();
    }
    
    @objc private func handleCenterButtonPressed() -> Void {
        self.impactGenerator(style: .soft);
        self.centerButton.alpha = 0.5;
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
            self.centerButton.alpha = 1.0;
        }
        self.closeInfoView();
        self.centerButtonPresesd();
    }
    
    
    // MARK: Gesture Methods
    
    @objc private func handlePanGesture(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.containingViewController.view);
        switch (gesture.state) {
        case .began:
            break;
        case .changed:
            if (translation.y < 0) { break; }
            self.transform = CGAffineTransform(translationX: 0.0, y: translation.y);
            break;
        case .ended:
            if (translation.y >= 100) {
                self.closeInfoView();
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
    
    private func closeInfoView() -> Void {
        if let backgroundColor = self.containingViewController.view.backgroundColor {
            self.backgroundView.backgroundColor = backgroundColor.withAlphaComponent(0);
        } else {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0);
        }
        self.backgroundView.backgroundColor = self.containingViewController.view.backgroundColor?.withAlphaComponent(0);
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: self.containingViewController.view.frame.size.height);
        }) { (done) in
            self.removeFromSuperview();
            self.backgroundView.removeFromSuperview();
        };
    }
    
    
    // MARK: Destructor
    
    deinit {}
    
}
