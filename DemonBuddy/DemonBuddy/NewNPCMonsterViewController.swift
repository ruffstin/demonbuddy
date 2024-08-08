//
//  NewNPCMonsterViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 8/5/24.
//

import UIKit
import CoreData
import FirebaseAuth

class NewNPCMonsterViewController: UIViewController {
    
    let textFieldKeys: [String] = [
        "gameName",
        "creatureName",
        "hitPoints",
        "armorClass",
        "speed",
        "challengeRating",
        "xp",
        "strength",
        "constitution",
        "dexterity",
        "intelligence",
        "wisdom",
        "charisma",
        "skills",
        "senses",
        "languages",
        "creatureFeatures",
        "actions",
        "items"
    ]
    
    @IBOutlet weak var gameName: UITextField! // could be adjusted to Joseph's implementation game name
    @IBOutlet weak var creatureNameText: UITextField!
    @IBOutlet weak var hitPoints: UITextField!
    
    @IBOutlet weak var armorClass: UITextField!
    @IBOutlet weak var speed: UITextField!
    
    @IBOutlet weak var challengeRating: UITextField!
    @IBOutlet weak var xpToEarn: UITextField!
    
    @IBOutlet weak var strength: UITextField!
    @IBOutlet weak var constitution: UITextField!
    @IBOutlet weak var dexterity: UITextField!
    @IBOutlet weak var intelligence: UITextField!
    @IBOutlet weak var wisdom: UITextField!
    @IBOutlet weak var charisma: UITextField!
    
    @IBOutlet weak var skills: UITextField!
    @IBOutlet weak var senses: UITextField!
    @IBOutlet weak var languages: UITextField!
    @IBOutlet weak var creatureFeatures: UITextField!
    @IBOutlet weak var actions: UITextField!
    @IBOutlet weak var items: UITextField!
    
    var delegate: UIViewController!
    
    var npcOrMonster: NSManagedObject?
    var monsterOrNpcToEdit: NSManagedObject?
    var gameNameOptions: [UIAction]!
    
    // Array of UITextFields
        var textFieldOutlets: [UITextField] {
            return [
                gameName, creatureNameText, hitPoints,
                armorClass, speed,
                challengeRating, xpToEarn,
                strength, constitution, dexterity,
                intelligence, wisdom, charisma,
                skills, senses, languages,
                creatureFeatures, actions, items
            ]
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updateGameNameMenu()
        
        if monsterOrNpcToEdit != nil {
            
            // gamename would be edited per Joseph's implementation
            for (index, key) in textFieldKeys.enumerated() {
                if let textToInput = monsterOrNpcToEdit?.value(forKey: key) as? String {
                    textFieldOutlets[index].text = textToInput
                }
            }

        }
    }
    
    /*func updateGameNameMenu() {
     gameNameOptions = [
     UIAction(title: "None") {
     _ in self.gameNameDropdown.setTitle("None", for: .normal)
     }
     ]
     for name in gameNames {
     gameNameOptions.append(UIAction(title: name) {
     _ in self.gameNameDropdown.setTitle(name, for: .normal)
     })
     }
     
     let menu = UIMenu(title: "Game Names", options: .displayInline, children: gameNameOptions)
     gameNameDropdown.menu = menu
     gameNameDropdown.showsMenuAsPrimaryAction = true
     }*/
    
    // Create NPC or Monster
    @IBAction func savePressed(_ sender: Any) {
            // Function to show alert
            func showAlert(forMissingField fieldName: String) {
                let controller = UIAlertController(
                    title: "Missing \(fieldName)",
                    message: "Please input a value for \(fieldName).",
                    preferredStyle: .alert
                )
                
                controller.addAction(UIAlertAction(title: "Ok", style: .default))
                present(controller, animated: true)
            }
            
        let fieldNames: [String] = [
            "Game Name",
            "Creature Name",
            "Hit Points",
            "Armor Class",
            "Speed",
            "Challenge Rating",
            "XP to Earn",
            "Strength",
            "Dexterity",
            "Constitution",
            "Intelligence",
            "Wisdom",
            "Charisma",
            "Skills",
            "Senses",
            "Languages",
            "Creature Features",
            "Actions",
            "Items"
        ]

        for (index, field) in textFieldOutlets.enumerated() {
            if let text = field.text, text.isEmpty {
                showAlert(forMissingField: fieldNames[index])
                return
            }
        }
            
            // All required fields are present, proceed with entity creation
            let userID = Auth.auth().currentUser?.uid
            
            if let monsterOrNpcToEdit = monsterOrNpcToEdit {
                // Update existing monsters/npc instance

                for (index, key) in textFieldKeys.enumerated() {
                    monsterOrNpcToEdit.setValue(textFieldOutlets[index].text, forKey: key)
                }

            } else {
                // Create new NPC/Monster instance
                let monsterOrNpc = NSEntityDescription.insertNewObject(forEntityName: "NPCorMonster", into: context)
                monsterOrNpc.setValue(userID, forKey: "userID")
                for (index, key) in textFieldKeys.enumerated() {
                        monsterOrNpc.setValue(textFieldOutlets[index].text, forKey: key)
                    }
            }
            
            saveContext()
            
            if let monstersAndNpcVC = delegate as? RefreshMonsterTable {
                monstersAndNpcVC.refreshMonsters()
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

}
