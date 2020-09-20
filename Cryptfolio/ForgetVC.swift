//
//  ForgetVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-07.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit

class Forgot: UIViewController {

    
    @IBOutlet weak var lockIcon_img: UIImageView!
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var resetPassword_btn: UIButton!
    @IBOutlet weak var signIn_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleButton(button: &self.resetPassword_btn, borderColor: UIColor.orange.cgColor);
        self.resetPassword_btn.backgroundColor = UIColor(red: 150/255, green: 80/255, blue: 0, alpha: 1);
        self.signIn_btn.setTitleColor(.orange, for: .normal);
        self.signIn_btn.setTitleColor(.orange, for: .highlighted);
        self.styleTextField(textField: &self.email_txt, image: UIImage(named: "Images/btc.png")!);
                
        self.resetPassword_btn.addTarget(self, action: #selector(resetBtnTapped), for: .touchUpInside);
        self.signIn_btn.addTarget(self, action: #selector(signInTapped), for: .touchUpInside);
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen));
        self.view.addGestureRecognizer(tap);

    }
    
    @objc func tappedScreen() {
        self.view.endEditing(true);
    }
    
    @objc func resetBtnTapped() {
        self.vibrate(style: .medium);
        self.view.endEditing(true);
        print("Reset Password Tapped!");
    }
    
    @objc func signInTapped() {
        self.vibrate(style: .light);
        self.view.endEditing(true);
        self.dismiss(animated: true, completion: nil);
    }
    
    private func styleButton(button:inout UIButton, borderColor:CGColor) -> Void {
        button.layer.cornerRadius = 20.0;
        button.layer.masksToBounds = true;
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
        button.layer.shadowOpacity = 1.0;
        button.layer.borderWidth = 1;
        button.layer.borderColor = borderColor;
    }
    
    private func styleTextField(textField:inout UITextField, image:UIImage) {
        textField.leftViewMode = .always;
        textField.backgroundColor = .clear;
        let distanceFromImage:CGFloat = 30.0;
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: distanceFromImage, height: 0));
        let bottomLine = CALayer();
        bottomLine.frame = CGRect(x: distanceFromImage, y: 20.0, width: textField.frame.width - distanceFromImage, height: 1.0);
        bottomLine.backgroundColor = UIColor.white.cgColor;
        textField.borderStyle = .none;
        textField.layer.addSublayer(bottomLine);
        let imageView = UIImageView();
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20);
        imageView.image = image;
        textField.addSubview(imageView)
    }
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackGenerator.prepare();
        impactFeedbackGenerator.impactOccurred();
    }
    
}
