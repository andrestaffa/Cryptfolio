//
//  ForgetVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-09-07.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import UIKit;
import FirebaseAuth;

class ForgotVC: UIViewController {

    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var resetPassword_btn: UIButton!
    @IBOutlet weak var signIn_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleButton(button: &self.resetPassword_btn, borderColor: UIColor.orange.cgColor);
        self.resetPassword_btn.backgroundColor = UIColor(red: 150/255, green: 80/255, blue: 0, alpha: 1);
        self.signIn_btn.setTitleColor(.orange, for: .normal);
        self.signIn_btn.setTitleColor(.orange, for: .highlighted);
        self.email_txt.keyboardType = .emailAddress;
        self.styleTextField(textField: &self.email_txt, image: #imageLiteral(resourceName: "email"), width: 15.0, height: 15.0);
                
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
        
        if (self.email_txt.text == nil || self.email_txt.text!.isEmpty || self.email_txt.text!.trimmingCharacters(in: .whitespaces).isEmpty || !self.isValidEmail(self.email_txt.text!)) {
            self.displayAlert(title: "Sorry", message: "Incorrect formatting of email address");
            return;
        }
        
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: self.email_txt.text!) { [weak self] (error) in
            if (error != nil) {
                self?.displayAlert(title: "Sorry", message: "There are no records that match this email address.");
                return;
            }
            self?.displayAlert(title: "Success!", message: "Password reset email has been sent!\nCheck spam box if you do not see email.");
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
        bottomLine.frame = CGRect(x: distanceFromImage, y: 20.0, width: self.view.frame.width - 130.0, height: 1.0);
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
