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
    
    let textFieldKeysFields: [String] = [
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
        "charisma"
    ]
    
    let textFieldKeysViews: [String] = [
        "skills",
        "senses",
        "languages",
        "creatureFeatures",
        "actions",
        "items"
    ]
    
    @IBOutlet weak var gameNameDropdown: UIButton!
    
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
    
    @IBOutlet weak var skills: UITextView!
    @IBOutlet weak var senses: UITextView!
    @IBOutlet weak var languages: UITextView!
    @IBOutlet weak var creatureFeatures: UITextView!
    @IBOutlet weak var actions: UITextView!
    @IBOutlet weak var items: UITextView!
    
    var delegate: UIViewController!
    
    var npcOrMonster: NSManagedObject?
    var monsterOrNpcToEdit: NSManagedObject?
    var gameNameOptions: [UIAction]!
    
    // Array of UITextFields
    var textFieldOutlets: [UITextField] {
        return [
            creatureNameText, hitPoints,
            armorClass, speed,
            challengeRating, xpToEarn,
            strength, constitution, dexterity,
            intelligence, wisdom, charisma
        ]
    }
        
    // Array of textViews!
    var textFieldViews: [UITextView] {
        return [
            skills, senses, languages,
            creatureFeatures, actions, items
        ]
    }
    
    @IBOutlet weak var adminFillInTextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // admin mode enabler
        guard let user = Auth.auth().currentUser else {
                print("No user is currently logged in.")
                return
        }
        
        if user.email == "admin@gmail.com" {
            adminFillInTextButton.isEnabled = true
            
        } else {
            if let customColor = UIColor(named: "Background Color") {
                adminFillInTextButton.backgroundColor = customColor
                adminFillInTextButton.setTitle("", for: .normal)
               }
            adminFillInTextButton.isEnabled = false
        }
        
        
        updateGameNameMenu()
        
        if monsterOrNpcToEdit != nil {
            
            // gamename would be edited per Joseph's implementation
            for (index, key) in textFieldKeysFields.enumerated() {
                if let textToInput = monsterOrNpcToEdit?.value(forKey: key) as? String {
                    textFieldOutlets[index].text = textToInput
                }
            }
            
            for (index, key) in textFieldKeysViews.enumerated() {
                if let textToInput = monsterOrNpcToEdit?.value(forKey: key) as? String {
                    textFieldViews[index].text = textToInput
                }
            }

        }
        // Listen for background color changes
       NotificationCenter.default.addObserver(self, selector: #selector(handleBackgroundColorChange(notification:)), name: .backgroundColorDidChange, object: nil)
       
       // Apply the saved background color on load
       applySavedBackgroundColor()
    }
    
    // Handle the notification and update the background color
    @objc func handleBackgroundColorChange(notification: Notification) {
        if let color = notification.object as? UIColor {
            self.view.backgroundColor = color
        }
    }
    
    // Apply the saved background color from UserDefaults
    func applySavedBackgroundColor() {
        let currColor = UserDefaults.standard.string(forKey: "backgroundColor") ?? "gray"
        var color: UIColor
        
        switch currColor {
        case "gray":
            color = UIColor.background
        case "mint":
            color = UIColor.systemMint
        case "orange":
            color = UIColor.systemOrange
        case "red":
            color = UIColor.systemRed
        case "green":
            color = UIColor.systemGreen
        default:
            color = UIColor.background
        }
        
        self.view.backgroundColor = color
    }
    
    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: .backgroundColorDidChange, object: nil)
    }

    
    func updateGameNameMenu() {
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
    }
    
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
            
        let fieldNamesFields: [String] = [
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
            "Charisma"
        ]
        
        let fielddNamesViews: [String] = [
            "Skills",
            "Senses",
            "Languages",
            "Creature Features",
            "Actions",
            "Items"
        ]

        for (index, field) in textFieldOutlets.enumerated() {
            if let text = field.text, text.isEmpty {
                showAlert(forMissingField: fieldNamesFields[index])
                return
            }
        }
        
        for (index, field) in textFieldViews.enumerated() {
            if let text = field.text, text.isEmpty {
                showAlert(forMissingField: fielddNamesViews[index])
                return
            }
        }
            
            // All required fields are present, proceed with entity creation
        let userID = Auth.auth().currentUser?.uid
            
        if let monsterOrNpcToEdit = monsterOrNpcToEdit {
                // Update existing monsters/npc instance

            for (index, key) in textFieldKeysFields.enumerated() {
                monsterOrNpcToEdit.setValue(textFieldOutlets[index].text, forKey: key)
            }
            
            for (index, key) in textFieldKeysViews.enumerated() {
                monsterOrNpcToEdit.setValue(textFieldViews[index].text, forKey: key)
            }
            
            monsterOrNpcToEdit.setValue(gameNameDropdown.titleLabel!.text, forKey: "gameName")

        } else {
            // Create new NPC/Monster instance
            let monsterOrNpc = NSEntityDescription.insertNewObject(forEntityName: "NPCorMonster", into: context)
                monsterOrNpc.setValue(userID, forKey: "userID")
            
            for (index, key) in textFieldKeysFields.enumerated() {
                    monsterOrNpc.setValue(textFieldOutlets[index].text, forKey: key)
            }
            
            for (index, key) in textFieldKeysViews.enumerated() {
                    monsterOrNpc.setValue(textFieldViews[index].text, forKey: key)
            }
            
            if (gameNameDropdown.titleLabel!.text == "Game Name") {
                monsterOrNpc.setValue("None", forKey: "gameName")
            } else {
                monsterOrNpc.setValue(gameNameDropdown.titleLabel!.text, forKey: "gameName")
            }
            
            monsterOrNpcToEdit = monsterOrNpc
        }
            
            saveContext()
            
            if let monstersAndNpcVC = delegate as? RefreshMonsterTable {
                monstersAndNpcVC.refreshMonsters()
            }
            
        }


    @IBAction func fillInMonsterValues(_ sender: Any) {
        creatureNameText.text = "Lightning Slayer"
        hitPoints.text = "100"
        
        armorClass.text = "16"
        speed.text = "60"
        
        challengeRating.text = "6"
        xpToEarn.text = "5000"
        
        strength.text = "18"
        constitution.text = "16"
        dexterity.text = "12"
        intelligence.text = "7"
        wisdom.text = "10"
        charisma.text = "8"
        
        skills.text = "athletics +7"
        senses.text = "blindsense 10 ft"
        languages.text = "common, giant"
        creatureFeatures.text = "Charge \nCreature moves 30ft in a straight line and can strike a foe within 5 ft with it's hooves, \n1D10 + 4 bludgeoning damage"
        actions.text = "MultiAttack \nLighting Slayer can make 2 spear attacks \nSpear 1d6 + 4 piercing + 2d6 lightning Damage"
        items.text = "Lightning Helm \nLightning Lance \nLightning Lance does 1d6 piercing and 2d6 lightning plus your strength modifier"
        
        let alert = UIAlertController(title: "Reminder", message: "Scroll to the bottom and hit save, please.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        
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
