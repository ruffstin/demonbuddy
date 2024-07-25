//
//  HomeViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/11/24.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    

    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch{
            print("signout error")
        }
    }
}
