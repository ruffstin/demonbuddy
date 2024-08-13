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
    
    // these 6 buttons are here in the case we wish to expand our app in the future adding
    // QoL calculation bonus' to the user.
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

    var characterToEdit: NSManagedObject?
    
    var gameNameOptions: [UIAction]!
    @IBOutlet weak var gameNameDropdown: UIButton!
    
    @IBOutlet weak var spellButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // arrays for deathSaveBooleans, first 3 are fails, last 3 are successes,
    var deathSaveBooleans = [false, false, false, false, false, false]

    lazy var deathSaveButtons: [UIButton] = [deathSaveFail1, deathSaveFail2, deathSaveFail3, deathSaveSucc1, deathSaveSucc2, deathSaveSucc3]
    
    let deathSaveAttrib : [String] = [
        "deathSaveFail1",
        "deathSaveFail2",
        "deathSaveFail3",
        "deathSaveSucc1",
        "deathSaveSucc2",
        "deathSaveSucc3"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spellButton.isHidden = true
        spellButton.isEnabled = false
        
        updateGameNameMenu()
        
        if characterToEdit != nil {
            // retrieve all information from core data
            for (index, key) in attributes.enumerated() {
                if let textToInput = characterToEdit?.value(forKey: key) as? String {
                    textFieldOutlets[index].text = textToInput
                }
            }
            if let game = characterToEdit?.value(forKey: "gameName") as? String {
                gameNameDropdown.setTitle(game, for: .normal)
            }
            spellButton.isHidden = false
            spellButton.isEnabled = true
            
            setUpDeathSaves()
        }
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

    
    // function to change the buttons view upon entering a created character
    func setUpDeathSaves() {
        for (index, key) in deathSaveAttrib.enumerated() {
            if let boolVal = characterToEdit?.value(forKey: key) as? Bool {
                deathSaveBooleans[index] = boolVal
                
                var imageName: String
                
                if (boolVal) {
                    imageName = "radioOn"
                } else {
                    imageName = "radioOff"
                }
                
                deathSaveButtons[index].setImage(UIImage(named: imageName), for: .normal)
            }
        }
    }
    
    
    // code to change the button
    @IBAction func deathSavePressed(_ sender:  UIButton) {
        if let index = deathSaveButtons.firstIndex(of: sender) {
            // Toggle the corresponding boolean value
            deathSaveBooleans[index].toggle()
                
            // Update the button image based on the new boolean value
            let newImageName = deathSaveBooleans[index] ? "radioOn" : "radioOff"
            sender.setImage(UIImage(named: newImageName), for: .normal)
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
            characterToEdit.setValue(gameNameDropdown.titleLabel!.text, forKey: "gameName")
            
            
            for (index, key) in deathSaveAttrib.enumerated() {
                characterToEdit.setValue(deathSaveBooleans[index], forKey: key)
            }

            
        } else {
            // Create a new Character instance
            let character = NSEntityDescription.insertNewObject(forEntityName: "Character", into: context)
            character.setValue(userID, forKey: "userID")
            for (index, key) in attributes.enumerated() {
                character.setValue(textFieldOutlets[index].text, forKey: key)
            }
            character.setValue(gameNameDropdown.titleLabel!.text, forKey: "gameName")
            spellButton.isHidden = false
            spellButton.isEnabled = true
            
            for (index, key) in deathSaveAttrib.enumerated() {
                character.setValue(deathSaveBooleans[index], forKey: key)
            }
            
            characterToEdit = character
        }
        
        saveContext()
        
        if let characterVC = delegate as? RefreshCharacterTable {
            characterVC.refreshCharacters()
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "castSpells" {
            if let spellSheetVC = segue.destination as? SpellSheetViewController {
                if let characterToPass = characterToEdit as? Character {
                    spellSheetVC.character = characterToPass
                } else {
                    // Handle the case where characterToEdit couldn't be cast to Character
                    print("Error: characterToEdit is not of type Character")
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
}
