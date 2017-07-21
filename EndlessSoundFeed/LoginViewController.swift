//
//  LoginViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/1/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import FirebaseAuth
import SkyFloatingLabelTextField
import SwiftOverlays

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var usernameField: SkyFloatingLabelTextField!
    @IBOutlet var passwordField: SkyFloatingLabelTextField!
    
    @IBOutlet var errorLabel:UILabel!
    
    @IBOutlet var newAccountButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var backgroundImage: UIImageView!
    
    @IBOutlet var signupStackView: UIStackView!
    @IBOutlet var loginStackView: UIStackView!
    @IBOutlet var newEmailField: SkyFloatingLabelTextField!
    @IBOutlet var newDisplayNameField: SkyFloatingLabelTextField!
    @IBOutlet var newPasswordField: SkyFloatingLabelTextField!
    
    @IBOutlet var cancelSignupButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    var gradientLayer:CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.delegate = self
        passwordField.delegate = self
        newEmailField.delegate = self
        newDisplayNameField.delegate = self
        newPasswordField.delegate = self
        
        passwordField.returnKeyType = .done
        newPasswordField.returnKeyType = .done
        
        passwordField.isSecureTextEntry = true
        newPasswordField.isSecureTextEntry = true
        
        /*
        if (FIRAuth.auth()?.currentUser) != nil {
            let manager = AccountManager.sharedInstance
            manager.loginUser(user: FIRAuth.auth()!.currentUser!)
            self.performSegue(withIdentifier: "LoginUser", sender: self)
        }
        */
        
        newAccountButton.layer.cornerRadius = 3.0
        loginButton.layer.cornerRadius = 3.0
        cancelSignupButton.layer.cornerRadius = 3.0
        signupButton.layer.cornerRadius = 3.0
        cancelSignupButton.backgroundColor = UIColor.clear
        cancelSignupButton.layer.borderWidth = 2.0
        cancelSignupButton.layer.borderColor = UIColor.white.cgColor        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImage.addSubview(blurEffectView)
        
        prepViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //createGradientLayer()
        
        usernameField.text = ""
        passwordField.text = ""
        newEmailField.text = ""
        newDisplayNameField.text = ""
        newPasswordField.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showViews()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepViews() {
        backgroundImage.alpha = 0
        loginStackView.alpha = 0
        signupStackView.alpha = 0
    }
    
    func showViews() {
        UIView.animate(withDuration: 0.5) { 
            self.backgroundImage.alpha = 1.0
            self.loginStackView.alpha = 1.0
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func createGradientLayer(){
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let startColor = UIColor(red: 30/255, green: 60/255, blue: 109/255, alpha: 1.0).cgColor
        let endColor = UIColor(red: 11/255, green: 24/255, blue: 45/255, alpha: 1.0).cgColor
        gradientLayer.colors = [startColor, endColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordField {
            textField.resignFirstResponder()
            return true
        }
        
        if textField == usernameField {
            let _ = passwordField.becomeFirstResponder()
            return true
        }
        
        if textField == newEmailField {
            newDisplayNameField.becomeFirstResponder()
            return true
        }
        
        if textField == newDisplayNameField {
            newPasswordField.becomeFirstResponder()
            return true
        }
        
        if textField == newPasswordField {
            newPasswordField.resignFirstResponder()
            return true
        }
        
        return true
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        print("CREATE NEW ACCOUNT PRESSED")
        errorLabel.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.loginStackView.alpha = 0.0
        }) { (success) in
            if success {
                UIView.animate(withDuration: 0.3, animations: { 
                    self.signupStackView.alpha = 1.0
                })
            }
        }
        
        
        
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let email = usernameField.text
        let pass = passwordField.text
        
        self.showWaitOverlay()
        let manager = AccountManager.sharedInstance
        manager.loginUser(email: email, pass: pass) { (success, errorString) in
            if(success){
                print("Successful Login: After Login Pressed")
                self.removeAllOverlays()
                self.performSegue(withIdentifier: "LoginUser", sender: self)
            } else {
                self.removeAllOverlays()
                self.errorLabel.isHidden = false
                self.errorLabel.text = errorString
            }
        }
        
        print("LOGIN PRESSED")
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.errorLabel.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.signupStackView.alpha = 0.0
        }) { (success) in
            if success {
                UIView.animate(withDuration: 0.3, animations: {
                    self.loginStackView.alpha = 1.0
                })
            }
        }
        
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        print("SIGNUP BUTTON PRESSED")
        
        self.showWaitOverlay()
        
        let email = newEmailField.text
        let pass = newPasswordField.text
        let displayName = newDisplayNameField.text
        
        if let count = displayName?.characters.count {
            if count <= 5 {
                self.errorLabel.isHidden = false
                self.errorLabel.text = "Display Name Too Short"
                self.removeAllOverlays()
                return
            }
        }

        if (email != nil) && (pass != nil) {
            FIRAuth.auth()?.createUser(withEmail: email!, password: pass!, completion: { (user, error) in
                if let err = error as NSError? {

                    if let code = FIRAuthErrorCode(rawValue: err.code) {
                        switch code {
                        case .errorCodeInvalidEmail:    //Invalid Email
                            print("Invalid Email")
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = "Invalid Email"
                        case .errorCodeEmailAlreadyInUse:
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = "Email Already In Use"
                        case .errorCodeWeakPassword:
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = "Too Weak of Password"
                        default:
                            print("Error Code Not Recognized")
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = "Error Creating Account"
                        }
                        
                        self.removeAllOverlays()
                    }
                    
                }else{
                    print("Firebase Signup Success")

                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = displayName
                    changeRequest?.commitChanges { (error) in
                        if(error != nil){
                            print("Error Updating Display Name")
                            self.removeAllOverlays()
                        }
                        else{
                            let manager = AccountManager.sharedInstance
                            manager.setupNewUser(user: user!)
                            self.removeAllOverlays()
                            self.performSegue(withIdentifier: "SignupUser", sender: self)
                        }
                    }


                }
            })

        }
        
    }
    
    
    @IBAction func backgroundTapped(_ sender: Any) {
        endUserInput()
    }
    
    @IBAction func logoTapped(_ sender: Any) {
        endUserInput()
    }
    
    func endUserInput() {
        if usernameField.isFirstResponder {
            usernameField.resignFirstResponder()
        }else if passwordField.isFirstResponder {
            passwordField.resignFirstResponder()
        }else{
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print(segue.identifier!)
    }
    

}
