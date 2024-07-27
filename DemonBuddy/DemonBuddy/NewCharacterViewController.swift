//
//  NewCharacterViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 7/23/24.
//

import UIKit

import CoreData

import FirebaseAuth

protocol CharacterCreationDelegate: AnyObject {
    func fetchCharacter()
}

class NewCharacterViewController: UIViewController {
    
    @IBOutlet weak var charName: UITextField!
    
    @IBOutlet weak var charGameName: UITextField!
    
    weak var delegate: CharacterCreationDelegate?

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
        // Save to Core Data
        let character = NSEntityDescription.insertNewObject(forEntityName: "Character", into: context)
        character.setValue(charName.text, forKey: "name")
        character.setValue(charGameName.text, forKey: "gameName")
        if let userID = Auth.auth().currentUser?.uid {
                    character.setValue(userID, forKey: "userID")
                }
        
        saveContext()
        delegate?.fetchCharacter()
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
    
}
