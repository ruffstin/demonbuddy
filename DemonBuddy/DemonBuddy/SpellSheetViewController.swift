//
//  SpellSheetViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 7/28/24.
//

import UIKit
import CoreData
import FirebaseAuth

class SpellSheetViewController: UIViewController {
    
    @IBOutlet weak var cantrips: UITextView!
    @IBOutlet weak var level1Spells: UITextView!
    @IBOutlet weak var level2Spells: UITextView!
    @IBOutlet weak var level3Spells: UITextView!
    @IBOutlet weak var level4Spells: UITextView!
    @IBOutlet weak var level5Spells: UITextView!
    @IBOutlet weak var level6Spells: UITextView!
    @IBOutlet weak var level7Spells: UITextView!
    @IBOutlet weak var level8Spells: UITextView!
    @IBOutlet weak var level9Spells: UITextView!
    
    // text views are required for storing a lot of text verses 1 or two lines
    
    @IBOutlet weak var level1SpellSlots: UITextField!
    @IBOutlet weak var level2SpellSlots: UITextField!
    @IBOutlet weak var level3SpellSlots: UITextField!
    @IBOutlet weak var level4SpellSlots: UITextField!
    @IBOutlet weak var level5SpellSlots: UITextField!
    @IBOutlet weak var level6SpellSlots: UITextField!
    @IBOutlet weak var level7SpellSlots: UITextField!
    @IBOutlet weak var level8SpellSlots: UITextField!
    @IBOutlet weak var level9SpellSlots: UITextField!
    @IBOutlet weak var spellAttackBonus: UITextField!
    @IBOutlet weak var spellCastingAbility: UITextField!
    @IBOutlet weak var spellCastingClass: UITextField!
    @IBOutlet weak var spellSaveDC: UITextField!
    
    
    
    
    
    
    @IBOutlet weak var reset: UIButton!
    
    
    var spellSheetViewOutlets: [UITextView] {
        return [
            cantrips, level1Spells, level2Spells, level3Spells, level4Spells,
            level5Spells, level6Spells, level7Spells, level8Spells, level9Spells
        ]
    }
    
    var spellSheetOutlets: [UITextField] {
        return [
            level1SpellSlots, level2SpellSlots, level3SpellSlots, level4SpellSlots,
            level5SpellSlots, level6SpellSlots, level7SpellSlots, level8SpellSlots,
            level9SpellSlots, spellAttackBonus, spellCastingAbility, spellCastingClass,
            spellSaveDC
        ]
    }
    
    
    // spellsheetattribs1
    let spellSheetAttributeViews: [String] = [
        "cantrips", "level1Spells", "level2Spells", "level3Spells", "level4Spells",
        "level5Spells", "level6Spells", "level7Spells", "level8Spells", "level9Spells"
    ]
    
    // spellsheetattribs2
    let spellSheetAttributesFields: [String] = [ // attribs2
        "level1SpellSlots", "level2SpellSlots", "level3SpellSlots", "level4SpellSlots",
        "level5SpellSlots", "level6SpellSlots", "level7SpellSlots", "level8SpellSlots",
        "level9SpellSlots", "spellAttackBonus", "spellCastingAbility", "spellCastingClass",
        "spellSaveDC"
    ]
    
    
    var character: Character!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reset.isEnabled = false
        reset.isHidden = true

        // if we properly segued from a character page
        if let character = character {
            // if said character has a saved spellSheet fill in the values
            if character.spellSheet != nil {
                for (index, value) in spellSheetAttributeViews.enumerated() {
                    if let value = character.spellSheet?.value(forKey: value) as? String {
                        spellSheetViewOutlets[index].text = value
                    }
                }
                
                for (index, value) in spellSheetAttributesFields.enumerated() {
                    if let value = character.spellSheet?.value(forKey: value) as? String {
                        spellSheetOutlets[index].text = value
                    }
                }
                reset.isEnabled = true
                reset.isHidden = false
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

    
    @IBAction func resetButtonPressed(_ sender: Any) {
        for textField in spellSheetOutlets {
                textField.text = ""
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
        
        
         let spellSheetFieldNames: [String] = [
             "Cantrips", "Level 1 Spells", "Level 2 Spells", "Level 3 Spells", "Level 4 Spells",
             "Level 5 Spells", "Level 6 Spells", "Level 7 Spells", "Level 8 Spells", "Level 9 Spells",
             "Level 1 Spell Slots", "Level 2 Spell Slots", "Level 3 Spell Slots", "Level 4 Spell Slots",
             "Level 5 Spell Slots", "Level 6 Spell Slots", "Level 7 Spell Slots", "Level 8 Spell Slots",
             "Level 9 Spell Slots", "Spell Attack Bonus", "Spell Casting Ability", "Spell Casting Class",
             "Spell Save DC"
         ]

        // display error
        for (index, field) in spellSheetOutlets.enumerated() {
            if let text = field.text, text.isEmpty {
                showAlert(forMissingField: spellSheetFieldNames[index])
                return
            }
        }
        
        
        // update a created spellSheet or create a new spellSheet
        
        if let spellSheet = character.spellSheet {
            for (index, key) in spellSheetAttributeViews.enumerated() {
                spellSheet.setValue(spellSheetViewOutlets[index].text, forKey: key)
            }
             
            for (index, key) in spellSheetAttributesFields.enumerated() {
                spellSheet.setValue(spellSheetOutlets[index].text, forKey: key)
            }
            
        } else {
            let spellSheet = NSEntityDescription.insertNewObject(forEntityName: "SpellSheet", into: context)
            for (index, key) in spellSheetAttributeViews.enumerated() {
                spellSheet.setValue(spellSheetViewOutlets[index].text, forKey: key)
            }
             
            for (index, key) in spellSheetAttributesFields.enumerated() {
                spellSheet.setValue(spellSheetOutlets[index].text, forKey: key)
            }

            // attach the spellSheet to the corresponding Character
            character.spellSheet = spellSheet as? SpellSheet

        }
        
        saveContext()
        
        reset.isEnabled = true
        reset.isHidden = false
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
