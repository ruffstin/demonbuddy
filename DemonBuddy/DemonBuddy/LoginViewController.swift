//
//  LoginViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/9/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var toRegisterButton: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
                if user != nil {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    self.emailInput.text = nil
                    self.passwordInput.text = nil
                }
        }
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        if !fieldsIncorrect(){
            Auth.auth().signIn(withEmail: emailInput.text!, password: passwordInput.text!) {
                authResult, error in
                if let error = error as NSError? {
                    self.errorLabel.text = "Email or password is incorrect"
                } else {
                    self.errorLabel.text = nil
                }
            }
        }
    }
    
    func fieldsIncorrect() -> Bool{
        self.errorLabel.text = nil
        
        if self.emailInput.text!.isEmpty{
            self.errorLabel.text = "Email missing"
            return true
        } else if self.passwordInput.text!.isEmpty{
            self.errorLabel.text = "Password missing"
            return true
        }
        
        self.errorLabel.text = nil
        return false
    }
    
}
