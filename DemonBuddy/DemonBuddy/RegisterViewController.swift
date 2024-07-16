//
//  RegisterViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/9/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var confirmPasswordInput: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var toLoginButton: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerButton.layer.cornerRadius = 5
        registerButton.clipsToBounds = true
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
                if user != nil {
                    self.performSegue(withIdentifier: "registerLoginSegue", sender: nil)
                    self.usernameInput.text = nil
                    self.emailInput.text = nil
                    self.passwordInput.text = nil
                    self.confirmPasswordInput.text = nil
                }
        }
    }
    
    
    @IBAction func registerPressed(_ sender: Any) {
        if !fieldsIncorrect(){
            Auth.auth().createUser(withEmail: emailInput.text!, password: passwordInput.text!) {
                authResult, error in
                if let error = error as NSError? {
                    switch AuthErrorCode.Code(rawValue: error.code){
                        case .emailAlreadyInUse:
                            self.emailErrorLabel.text = "\u{2757} Email is already in use"
                            break
                        case .missingEmail:
                            self.emailErrorLabel.text = "\u{2757} Email missing"
                            break
                        case .weakPassword:
                            self.passwordErrorLabel.text = "\u{2757} Password must be at least 7 characters long"
                            break
                        default:
                            break
                    }
                } else {
                    self.emailErrorLabel.text = nil
                    self.passwordErrorLabel.text = nil
                }
            }
        }
    }
    
    func fieldsIncorrect() -> Bool{
        self.usernameErrorLabel.text = nil
        self.emailErrorLabel.text = nil
        self.passwordErrorLabel.text = nil
        self.confirmPasswordErrorLabel.text = nil
        
        if self.usernameInput.text!.isEmpty{
            self.usernameErrorLabel.text = "Missing username"
            return true
        } else if self.emailInput.text!.isEmpty{
            self.emailErrorLabel.text = "Missing email"
            return true
        } else if self.passwordInput.text!.isEmpty{
            self.passwordErrorLabel.text = "Missing password"
            return true
        } else if self.confirmPasswordInput.text!.isEmpty{
            self.confirmPasswordErrorLabel.text = "Missing confirm password"
            return true
        } else if self.passwordInput.text! != self.confirmPasswordInput.text!{
            self.confirmPasswordErrorLabel.text = "Passwords must match"
            return true
        }
        
        return false
    }
    
}
