//
//  SignUpVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-07.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import FirebaseAuth;

class SignUpVC: UIViewController {

    @IBOutlet weak var username_txt: UITextField!
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var password_txt: UITextField!
    @IBOutlet weak var signUp_btn: UIButton!
    @IBOutlet weak var alreadyHave_btn: UILabel!
    @IBOutlet weak var signIn_btn: UIButton!
    
    public var highscore:Double = 0.0;
    public var change:String = "";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleButton(button: &self.signUp_btn, borderColor: UIColor.orange.cgColor);
        self.signUp_btn.backgroundColor = UIColor(red: 150/255, green: 80/255, blue: 0, alpha: 1);
        self.signIn_btn.setTitleColor(.orange, for: .normal);
        self.signIn_btn.setTitleColor(.orange, for: .highlighted);
        self.email_txt.keyboardType = .emailAddress;
        self.password_txt.isSecureTextEntry = true;
        self.styleTextField(textField: &self.username_txt, image: #imageLiteral(resourceName: "username"), width: 16.0, height: 16.0);
        self.styleTextField(textField: &self.email_txt, image: #imageLiteral(resourceName: "email"), width: 15.0, height: 15.0);
        self.styleTextField(textField: &self.password_txt, image: #imageLiteral(resourceName: "password"), width: 16.0, height: 16.0);
                
        self.signUp_btn.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside);
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen));
        self.view.addGestureRecognizer(tap);
        self.signIn_btn.addTarget(self, action: #selector(signInTapped), for: .touchUpInside);

    }
    
    @objc func tappedScreen() {
        self.view.endEditing(true);
    }
    
    @objc func signUpTapped() {
        self.vibrate(style: .medium);
        self.view.endEditing(true);
        
        if (self.username_txt.text == nil || self.username_txt.text!.isEmpty || self.username_txt.text!.trimmingCharacters(in: .whitespaces).isEmpty || self.email_txt.text == nil || self.email_txt.text!.isEmpty || self.email_txt.text!.trimmingCharacters(in: .whitespaces).isEmpty || !self.isValidEmail(self.email_txt.text!) ||
            self.password_txt.text == nil || self.password_txt.text!.isEmpty || self.password_txt.text!.trimmingCharacters(in: .whitespaces).isEmpty || self.password_txt.text!.count < 5) {
            self.displayAlert(title: "Sorry", message: "All fields must have the correct formatting.");
            return;
        }
        
        DatabaseManager.findUser(username: self.username_txt.text!) { [weak self] (foundUser) in
            if (!foundUser) {
                FirebaseAuth.Auth.auth().createUser(withEmail: self!.email_txt.text!, password: self!.password_txt.text!) { [weak self] (result, error) in
                    if let error = error {
                        self?.displayAlert(title: "Sorry", message: error.localizedDescription);
                    } else {
                        DatabaseManager.writeUserData(email: self!.email_txt.text!, username: self!.username_txt.text!, highscore: self!.highscore, change: self!.change, merge: false, viewController: self!);
                    }
                }
            } else {
                self?.displayAlert(title: "Sorry", message: "Username already exists.");
            }
        }
        
    }
    
    @objc func signInTapped() {
        self.vibrate(style: .light);
        self.view.endEditing(true);
        self.navigationController?.popViewController(animated: true);
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
    
    private func styleTextField(textField:inout UITextField, image:UIImage, width:CGFloat, height:CGFloat) {
        var tempImage:UIImage = image;
        textField.leftViewMode = .always;
        textField.backgroundColor = .clear;
        let distanceFromImage:CGFloat = 25.0;
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: distanceFromImage, height: 0));
        let bottomLine = CALayer();
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            bottomLine.frame = CGRect(x: distanceFromImage, y: 20.0, width: (self.view.frame.width) - 130.0, height: 1.0);
        } else {
            bottomLine.frame = CGRect(x: distanceFromImage, y: 20.0, width: textField.frame.width - distanceFromImage, height: 1.0);
        }
        bottomLine.backgroundColor = UIColor.white.cgColor;
        textField.borderStyle = .none;
        textField.layer.addSublayer(bottomLine);
        let imageView = UIImageView();
        imageView.frame = CGRect(x: 0.0, y: 5.0, width: width, height: height);
        tempImage = image.withRenderingMode(.alwaysTemplate);
        imageView.tintColor = .lightGray;
        imageView.image = tempImage;
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
