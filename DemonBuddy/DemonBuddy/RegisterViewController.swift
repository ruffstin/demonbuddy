//
//  RegisterViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/9/24.
//

import UIKit
import FirebaseAuth
import CoreData

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var confirmPasswordInput: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var toLoginButton: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        passwordInput.isSecureTextEntry = true
        confirmPasswordInput.isSecureTextEntry = true
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        if !fieldsIncorrect(){
            Auth.auth().createUser(withEmail: emailInput.text!, password: passwordInput.text!) {
                authResult, error in
                if let error = error as NSError? {
                    switch AuthErrorCode.Code(rawValue: error.code){
                        case .emailAlreadyInUse:
                            self.errorLabel.text = "\u{2757} Email is already in use"
                            break
                        case .missingEmail:
                            self.errorLabel.text = "\u{2757} Email missing"
                            break
                        case .weakPassword:
                            self.errorLabel.text = "\u{2757} Password must be at least 7 characters long"
                            break
                        default:
                            break
                    }
                } else {
                    self.errorLabel.text = nil
                }
            }
        }
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fieldsIncorrect() -> Bool{
        self.errorLabel.text = nil
        
        if self.usernameInput.text!.isEmpty{
            self.errorLabel.text = "Missing username"
            return true
        } else if self.emailInput.text!.isEmpty{
            self.errorLabel.text = "Missing email"
            return true
        } else if self.passwordInput.text!.isEmpty{
            self.errorLabel.text = "Missing password"
            return true
        } else if self.confirmPasswordInput.text!.isEmpty{
            self.errorLabel.text = "Missing confirm password"
            return true
        } else if self.passwordInput.text! != self.confirmPasswordInput.text!{
            self.errorLabel.text = "Passwords must match"
            return true
        }
        
        return false
    }
}
