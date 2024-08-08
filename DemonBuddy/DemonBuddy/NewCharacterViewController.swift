//
//  NewCharacterViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 7/23/24.
//

import UIKit
import CoreData
import FirebaseAuth

protocol CharacterCreationDelegate: UIViewController {
    func fetchCharacter()
}

class NewCharacterViewController: UIViewController {

    @IBOutlet weak var charName: UITextField!
    @IBOutlet weak var charGameName: UITextField!
    @IBOutlet weak var race: UITextField!
    @IBOutlet weak var subRace: UITextField!
    @IBOutlet weak var charClass: UITextField!
    @IBOutlet weak var charSubclass: UITextField!
    
    @IBOutlet weak var xP: UITextField!
    @IBOutlet weak var level: UITextField!
    @IBOutlet weak var profBonus: UITextField!
    @IBOutlet weak var alignment: UITextField!
    @IBOutlet weak var armorClass: UITextField!
    @IBOutlet weak var speed: UITextField!
    
    @IBOutlet weak var strScore: UITextField!
    @IBOutlet weak var conScore: UITextField!
    @IBOutlet weak var wisScore: UITextField!
    
    @IBOutlet weak var strMod: UITextField!
    @IBOutlet weak var conMod: UITextField!
    @IBOutlet weak var wisMod: UITextField!
    
    @IBOutlet weak var dexScore: UITextField!
    @IBOutlet weak var intScore: UITextField!
    @IBOutlet weak var chaScore: UITextField!
    
    @IBOutlet weak var dexMod: UITextField!
    @IBOutlet weak var intMod: UITextField!
    @IBOutlet weak var chaMod: UITextField!
    
    @IBOutlet weak var hp: UITextField!
    @IBOutlet weak var currHP: UITextField!
    
    @IBOutlet weak var hitDice: UITextField!
    @IBOutlet weak var currHitDice: UITextField!
    
    @IBOutlet weak var tempHp: UITextField!
    @IBOutlet weak var inspiration: UITextField!
    
    
    // how to save death saves to core data?
    @IBOutlet weak var deathSaveSucc1: UIButton!
    @IBOutlet weak var deathSaveSucc2: UIButton!
    @IBOutlet weak var deathSaveSucc3: UIButton!
    
    @IBOutlet weak var deathSaveFail1: UIButton!
    @IBOutlet weak var deathSaveFail2: UIButton!
    @IBOutlet weak var deathSaveFail3: UIButton!
    
    // how to save whether they have proficiency or not in core data?
    @IBOutlet weak var strSaveProf: UIButton!
    @IBOutlet weak var conSaveProf: UIButton!
    @IBOutlet weak var wisSaveProf: UIButton!
    
    @IBOutlet weak var dexSaveProf: UIButton!
    @IBOutlet weak var intSaveProf: UIButton!
    @IBOutlet weak var chaSaveProf: UIButton!
    
    
    @IBOutlet weak var strSaveProfBonus: UITextField!
    @IBOutlet weak var conSaveProfBonus: UITextField!
    @IBOutlet weak var wisSaveProfBonus: UITextField!
    
    @IBOutlet weak var dexSaveProfBonus: UITextField!
    @IBOutlet weak var intSaveProfBonus: UITextField!
    @IBOutlet weak var chaSaveProfBonus: UITextField!

    @IBOutlet weak var skills: UITextField!
    
    // for now so I can create an entity I have just the attacks textbox
    @IBOutlet weak var attacks: UITextField!
    
    @IBOutlet weak var copper: UITextField!
    @IBOutlet weak var silver: UITextField!
    @IBOutlet weak var gold: UITextField!
    @IBOutlet weak var electrum: UITextField!
    @IBOutlet weak var platinum: UITextField!
    
    @IBOutlet weak var featuresAndTraits: UITextField!
    
    @IBOutlet weak var items: UITextField!
    
    
    // Array for UITextFields
    var textFieldOutlets: [UITextField] {
        return [
            alignment,
            armorClass,
            attacks,
            chaMod,
            chaScore,
            chaSaveProfBonus,
            charClass,
            charSubclass,
            charGameName,
            charName,
            conMod,
            conScore,
            conSaveProfBonus,
            copper,
            currHP,
            currHitDice,
            dexMod,
            dexScore,
            dexSaveProfBonus,
            electrum,
            featuresAndTraits,
            gold,
            hitDice,
            hp,
            inspiration,
            intMod,
            intScore,
            intSaveProfBonus,
            items,
            level,
            platinum,
            profBonus,
            race,
            subRace,
            silver,
            skills,
            speed,
            strMod,
            strScore,
            strSaveProfBonus,
            tempHp,
            wisMod,
            wisScore,
            wisSaveProfBonus,
            xP
        ]
    }


    
    let attributes: [String] = [
        "alignment",
        "armorClass",
        "attacks",
        "charismaMod",
        "charisma",
        "charismaSaveProfBonus",
        "charClass",
        "charSubClass",
        "gameName",
        "name",
        "constitutionMod",
        "constitution",
        "conSaveProfBonus",
        "copper",
        "currentHealthPoints",
        "currentHitDice",
        "dexterityMod",
        "dexterity",
        "dexSaveProfBonus",
        "electrum",
        "featuresAndTraits",
        "gold",
        "hitDice",
        "healthPoints",
        "inspiration",
        "intelligenceMod",
        "intelligence",
        "intelligenceSaveProfBonus",
        "items",
        "level",
        "platinum",
        "proficiencyBonus",
        "race",
        "subRace",
        "silver",
        "skills",
        "speed",
        "strengthMod",
        "strength",
        "strSaveProfBonus",
        "tempHp",
        "wisdomMod",
        "wisdom",
        "wisSaveProfBonus",
        "experiencePoints"
    ]

    
    var delegate: UIViewController!

    var character: NSManagedObject?
    var characterToEdit: NSManagedObject?
    var gameNameOptions: [UIAction]!
    
    @IBOutlet weak var spellButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spellButton.isHidden = true
        spellButton.isEnabled = false
        
        // updateGameNameMenu()
        
        if characterToEdit != nil {
            // retrieve all information from core data
            // gamename would be edited per Joseph's implementation
            for (index, key) in attributes.enumerated() {
                if let textToInput = characterToEdit?.value(forKey: key) as? String {
                    textFieldOutlets[index].text = textToInput
                }
            }
            spellButton.isHidden = false
            spellButton.isEnabled = true
        }
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
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
            "Alignment",
            "Armor Class",
            "Attacks",
            "Charisma Mod",
            "Charisma",
            "Charisma Save Prof Bonus",
            "Character Class",
            "Character Subclass",
            
            "Game Name",
            "ConstitutionMod",
            "Constitution",
            "Constitution Save Prof Bonus",
            "Copper",
            "Current Health Points",
            "Current Hit Dice",
            "Dexterity Mod",
            "Dexterity",
            "Dexterity Save Prof Bonus",
            "Electrum",
            "Features and Traits",
            "Gold",
            "Hit Dice",
            "Health Points",
            "Inspiration",
            "Intelligence Mod",
            "Intelligence",
            "Intelligence Save Prof Bonus",
            "Items",
            "Level",
            "Name",
            "Platinum",
            "Proficiency Bonus",
            "Race",
            "Subrace",
            "Silver",
            "Skills",
            "Speed",
            "Strength Mod",
            "Strength",
            "Strength Save Prof Bonus",
            "Temporary HP",
            "Wisdom Mod",
            "Wisdom",
            "Wisdom Save Prof Bonus",
            "Experience Points"
        ]
        
        for (index, field) in textFieldOutlets.enumerated() {
            if let text = field.text, text.isEmpty {
                showAlert(forMissingField: fieldNames[index])
                return
            }
        }
        
        
        // All required fields are present, proceed with entity creation
        let userID = Auth.auth().currentUser?.uid
        
        
        if let characterToEdit = characterToEdit {
            // Update existing character instance
            for (index, key) in attributes.enumerated() {
                characterToEdit.setValue(textFieldOutlets[index].text, forKey: key)
            }
            
        } else {
            // Create a new Character instance
            let character = NSEntityDescription.insertNewObject(forEntityName: "Character", into: context)
            character.setValue(userID, forKey: "userID")
            for (index, key) in attributes.enumerated() {
                    character.setValue(textFieldOutlets[index].text, forKey: key)
                }
            spellButton.isHidden = false
            spellButton.isEnabled = true
        }
        
        saveContext()
        
        if let characterVC = delegate as? RefreshCharacterTable {
            characterVC.refreshCharacters()
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
    
    /*
    // Toy Code for implementing calculating the User's Modifiers
    func calculateModifier(for stat: Int) -> Int {
        return Int(floor(Double(stat - 10) / 2.0))
    }
     
     // Loop from 1 to 20 and print the stat and its modifier
     for stat in 1...20 {
         let modifier = calculateModifier(for: stat)
         // if >= 0 then add a plus sign to the print statement
         print("Stat: \(stat), Modifier: \(modifier)")
     }

     // Define skills and their corresponding abilities
     let skills: [String: String] = [
         "Athletics": "Strength",
         "Acrobatics": "Dexterity",
         "Sleight of Hand": "Dexterity",
         "Stealth": "Dexterity",
         "Arcana": "Intelligence",
         "History": "Intelligence",
         "Investigation": "Intelligence",
         "Nature": "Intelligence",
         "Religion": "Intelligence",
         "Animal Handling": "Wisdom",
         "Insight": "Wisdom",
         "Medicine": "Wisdom",
         "Perception": "Wisdom",
         "Survival": "Wisdom",
         "Deception": "Charisma",
         "Intimidation": "Charisma",
         "Performance": "Charisma",
         "Persuasion": "Charisma"
     ]

     // Example proficiency bonus
     let proficiencyBonus = 2

     // Example proficiency status for skills (True = proficient, False = not proficient)
     let proficiencyStatus: [String: Bool] = [
         "Athletics": true,
         "Acrobatics": false,
         "Sleight of Hand": true,
         "Stealth": false,
         "Arcana": true,
         "History": false,
         "Investigation": true,
         "Nature": false,
         "Religion": false,
         "Animal Handling": true,
         "Insight": false,
         "Medicine": true,
         "Perception": false,
         "Survival": true,
         "Deception": false,
         "Intimidation": true,
         "Performance": false,
         "Persuasion": true
     ]

     // Example stats
     let stats: [String: Int] = [
         "Strength": 15,
         "Dexterity": 14,
         "Intelligence": 12,
         "Wisdom": 13,
         "Charisma": 10
     ]

     // Function to calculate skill modifier
     func calculateSkillModifier(for skill: String) -> Int {
         guard let ability = skills[skill], let stat = stats[ability] else {
             return 0
         }
         let baseModifier = calculateModifier(for: stat)
         if proficiencyStatus[skill] == true {
             return baseModifier + proficiencyBonus
         } else {
             return baseModifier
         }
     }

     // Loop through skills and print their modifiers
     for skill in skills.keys {
         let skillModifier = calculateSkillModifier(for: skill)
         print("Skill: \(skill), Modifier: \(skillModifier)")
     }

    */
    
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
