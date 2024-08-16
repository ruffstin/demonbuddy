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
    
    @IBOutlet weak var strSaveProfBonus: UITextField!
    @IBOutlet weak var conSaveProfBonus: UITextField!
    @IBOutlet weak var wisSaveProfBonus: UITextField!
    
    @IBOutlet weak var dexSaveProfBonus: UITextField!
    @IBOutlet weak var intSaveProfBonus: UITextField!
    @IBOutlet weak var chaSaveProfBonus: UITextField!

    @IBOutlet weak var skills: UITextView!
    
    @IBOutlet weak var attacks: UITextView!
    
    @IBOutlet weak var copper: UITextField!
    @IBOutlet weak var silver: UITextField!
    @IBOutlet weak var gold: UITextField!
    @IBOutlet weak var electrum: UITextField!
    @IBOutlet weak var platinum: UITextField!
    
    @IBOutlet weak var featuresAndTraits: UITextView!
    
    @IBOutlet weak var items: UITextView!
    
    
    // Array for UITextFields
    var textFieldOutlets: [UITextField] {
        return [
            alignment,
            armorClass,
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
            gold,
            hitDice,
            hp,
            inspiration,
            intMod,
            intScore,
            intSaveProfBonus,
            level,
            platinum,
            profBonus,
            race,
            subRace,
            silver,
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
    
    var textViewOutlets: [UITextView] {
        return [
            attacks,
            featuresAndTraits,
            items,
            skills
        ]
    }
    
    let attributes: [String] = [
        "alignment",
        "armorClass",
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
        "gold",
        "hitDice",
        "healthPoints",
        "inspiration",
        "intelligenceMod",
        "intelligence",
        "intelligenceSaveProfBonus",
        "level",
        "platinum",
        "proficiencyBonus",
        "race",
        "subRace",
        "silver",
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
    
    let viewAttributes: [String] = [
        "attacks",
        "featuresAndTraits",
        "items",
        "skills"
    ]

    @IBOutlet weak var adminFillInTextButton: UIButton!
    
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
        
        if characterToEdit != nil {
            // retrieve all information from core data
            for (index, key) in attributes.enumerated() {
                if let textToInput = characterToEdit?.value(forKey: key) as? String {
                    textFieldOutlets[index].text = textToInput
                }
            }
            
            for (index, key) in viewAttributes.enumerated() {
                if let textToInput = characterToEdit?.value(forKey: key) as? String {
                    textViewOutlets[index].text = textToInput
                }
            }
            
            
            if let game = characterToEdit?.value(forKey: "gameName") as? String {
                gameNameDropdown.setTitle(game, for: .normal)
            }
            spellButton.isHidden = false
            spellButton.isEnabled = true
            
            setUpDeathSaves()
        } else {
            // ensuring that the death save buttons are viewed
            for (index, _) in deathSaveAttrib.enumerated() {
                deathSaveButtons[index].setImage(UIImage(named: "radioOff"), for: .normal)
            }
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
            "Gold",
            "Hit Dice",
            "Health Points",
            "Inspiration",
            "Intelligence Mod",
            "Intelligence",
            "Intelligence Save Prof Bonus",
            "Level",
            "Name",
            "Platinum",
            "Proficiency Bonus",
            "Race",
            "Subrace",
            "Silver",
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
        
        let fieldNameViews: [String] = [
            "Attacks",
            "Features and Traits",
            "Items",
            "Skills"
        ]
        
        for (index, field) in textFieldOutlets.enumerated() {
            if let text = field.text, text.isEmpty {
                showAlert(forMissingField: fieldNames[index])
                return
            }
        }
        
        for (index, field) in textViewOutlets.enumerated() {
            if let text = field.text, text.isEmpty {
                showAlert(forMissingField: fieldNameViews[index])
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
            
            for (index, key) in viewAttributes.enumerated() {
                characterToEdit.setValue(textViewOutlets[index].text, forKey: key)
            }
            
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
            
            for (index, key) in viewAttributes.enumerated() {
                character.setValue(textViewOutlets[index].text, forKey: key)
            }
            
            if (gameNameDropdown.titleLabel!.text == "Game Name") {
                character.setValue("None", forKey: "gameName")
            } else {
                character.setValue(gameNameDropdown.titleLabel!.text, forKey: "gameName")
            }
            
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
    
    
    @IBAction func fillInCharacterSheet(_ sender: Any) {
        charName.text = "Moulder Bouldercrash"
        race.text = "Human"
        subRace.text = "-"
        charClass.text = "Druid"
        charSubclass.text = "Land - Forest"
        
        xP.text = "milestone"
        level.text = "20"
        profBonus.text = "+6"
        alignment.text = "NG"
        armorClass.text = "14"
        speed.text = "30"
        
        strScore.text = "10"
        conScore.text = "16"
        wisScore.text = "20"
        
        strMod.text = "+0"
        conMod.text = "+3"
        wisMod.text = "+5"

        dexScore.text = "14"
        intScore.text = "14"
        chaScore.text = "10"

        dexMod.text = "+2"
        intMod.text = "+2"
        chaMod.text = "+0"

        hp.text = "120"
        currHP.text = "109"

        hitDice.text = "20d8"
        currHitDice.text = "10d8"

        tempHp.text = "0"
        inspiration.text = "2"

        strSaveProfBonus.text = "+0"
        conSaveProfBonus.text = "+3"
        wisSaveProfBonus.text = "+11"

        dexSaveProfBonus.text = "+2"
        intSaveProfBonus.text = "+7"
        chaSaveProfBonus.text = "+0"

        skills.text = "Animal Handling +11 \nMedicine +7 \nNature +7 \nPerception +11"

        attacks.text = "sickle - 1d4 + 0 slashing damage"

        copper.text = "4"
        silver.text = "2"
        gold.text = "5"
        electrum.text = "1"
        platinum.text = "2"

        featuresAndTraits.text = "You know Druidic, the secret language of druids. You can speak the language and use it to leave hidden messages. You and others who know this language automatically spot such a message. Others spot the message's presence with a successful DC 15 Wisdom (Perception) check but can't decipher it without magic. \n\n Wild Shape \nStarting at 2nd level, you can use your action to magically assume the shape of a beast that you have seen before. You can use this feature twice. You regain expended uses when you finish a short or long rest. Timeless Body \nStarting at 18th level, the primal magic that you wield causes you to age more slowly. For every 10 years that pass, your body ages only 1 year. \nBeast Spells        \nBeginning at 18th level, you can cast many of your druid spells in any shape you assume using Wild Shape. You can perform the somatic and verbal components of a druid spell while in a beast shape, but you aren't able to provide material components. \nArchdruid \nAt 20th level, you can use your Wild Shape an unlimited number of times. \nAdditionally, you can ignore the verbal and somatic components of your druid spells, as well as any material components that lack a cost and aren't consumed by a spell. You gain this benefit in both your normal shape and your beast shape from Wild Shape."

        items.text = "hide armor, druidic focus, worn travelers clothes, pouch, sickle"
        
        
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
