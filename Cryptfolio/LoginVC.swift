//
//  LoginVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-07.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import FirebaseAuth;

class LoginVC: UIViewController {
    
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var password_txt: UITextField!
    @IBOutlet weak var login_btn: UIButton!
    @IBOutlet weak var forgot_btn: UIButton!
    @IBOutlet weak var createAccont_lbl: UILabel!
    @IBOutlet weak var signUp_btn: UIButton!
    

    public var highscore:Double = 0.0;
    public var change:String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // style button, images, textFields and labels
        self.styleButton(button: &self.login_btn, borderColor: UIColor.orange.cgColor);
        self.login_btn.backgroundColor = UIColor(red: 150/255, green: 80/255, blue: 0, alpha: 1);
        self.forgot_btn.setTitleColor(.orange, for: .normal);
        self.forgot_btn.setTitleColor(.orange, for: .highlighted);
        self.signUp_btn.setTitleColor(.orange, for: .normal);
        self.signUp_btn.setTitleColor(.orange, for: .highlighted);
        self.email_txt.keyboardType = .emailAddress;
        self.password_txt.isSecureTextEntry = true;
        self.styleTextField(textField: &self.email_txt, image: UIImage(named: "Images/btc.png")!);
        self.styleTextField(textField: &self.password_txt, image: UIImage(named: "Images/eth.png")!);
                
        // add methods for signUp_btn, forgot_btn and login_btn
        self.login_btn.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside);
        self.forgot_btn.addTarget(self, action: #selector(forgotBtnTapped), for: .touchUpInside);
        self.signUp_btn.addTarget(self, action: #selector(signUpBtnTapped), for: .touchUpInside);
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen));
        self.view.addGestureRecognizer(tap);
        
    }
    
    @objc func tappedScreen() {
        self.view.endEditing(true);
    }
    
    @objc func loginBtnTapped() {
        self.vibrate(style: .medium)
        self.view.endEditing(true);
        
        if (self.email_txt.text == nil || self.email_txt.text!.isEmpty || self.email_txt.text!.trimmingCharacters(in: .whitespaces).isEmpty || !self.isValidEmail(self.email_txt.text!) ||
            self.password_txt.text == nil || self.password_txt.text!.isEmpty || self.password_txt.text!.trimmingCharacters(in: .whitespaces).isEmpty || self.password_txt.text!.count < 5) {
            self.displayAlert(title: "Sorry", message: "All fields must have the correct formatting.");
            return;
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: self.email_txt.text!, password: self.password_txt.text!) { [weak self] (result, error) in
            if (error != nil) {
                self?.displayAlert(title: "Sorry", message: "Incorrect username or password.");
            } else {
                DatabaseManager.findUser(email: self!.email_txt.text!, highscore: self!.highscore, change: self!.change, viewController: self!);
            }
        }
        
    }

    @objc func forgotBtnTapped() {
        self.vibrate(style: .light);
        self.view.endEditing(true);
        let forgotVC = self.storyboard?.instantiateViewController(withIdentifier: "forgotVC") as! ForgotVC;
        forgotVC.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(forgotVC, animated: true);
    }
    
    @objc func signUpBtnTapped() {
        self.vibrate(style: .light);
        self.view.endEditing(true);
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signUpVC") as! SignUpVC;
        signUpVC.highscore = self.highscore;
        signUpVC.change = self.change;
        signUpVC.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(signUpVC, animated: true);
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
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        self.present(alert, animated: true, completion: nil);
    }
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style);
        impactFeedbackGenerator.prepare();
        impactFeedbackGenerator.impactOccurred();
    }
    
}
