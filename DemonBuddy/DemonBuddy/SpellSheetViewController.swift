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
    
    @IBOutlet weak var cantrips: UITextField!
    @IBOutlet weak var level1Spells: UITextField!
    @IBOutlet weak var level2Spells: UITextField!
    @IBOutlet weak var level3Spells: UITextField!
    @IBOutlet weak var level4Spells: UITextField!
    @IBOutlet weak var level5Spells: UITextField!
    @IBOutlet weak var level6Spells: UITextField!
    @IBOutlet weak var level7Spells: UITextField!
    @IBOutlet weak var level8Spells: UITextField!
    @IBOutlet weak var level9Spells: UITextField!
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

    
    var spellSheetOutlets: [UITextField] {
        return [
            cantrips, level1Spells, level2Spells, level3Spells, level4Spells,
            level5Spells, level6Spells, level7Spells, level8Spells, level9Spells,
            level1SpellSlots, level2SpellSlots, level3SpellSlots, level4SpellSlots,
            level5SpellSlots, level6SpellSlots, level7SpellSlots, level8SpellSlots,
            level9SpellSlots, spellAttackBonus, spellCastingAbility, spellCastingClass,
            spellSaveDC
        ]
    }
    
    let spellSheetAttributes: [String] = [
        "cantrips", "level1Spells", "level2Spells", "level3Spells", "level4Spells",
        "level5Spells", "level6Spells", "level7Spells", "level8Spells", "level9Spells",
        "level1SpellSlots", "level2SpellSlots", "level3SpellSlots", "level4SpellSlots",
        "level5SpellSlots", "level6SpellSlots", "level7SpellSlots", "level8SpellSlots",
        "level9SpellSlots", "spellAttackBonus", "spellCastingAbility", "spellCastingClass",
        "spellSaveDC"
    ]

    
    /*
     delegate (if needed)
     spellSheetToEdit
     
     */
    
    
    
    var delegate: UIViewController!
    
    var caster: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*
         if caster has spellsheet -> fill in values
         for (index, key) in attributes.enumerated() {
             if let textToInput = spellSheetToEdit?.value(forKey: key) as? String {
                 textFieldOutlets[index].text = textToInput
             }
         }
         */
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
        
        /*
         list of all fieldNames
         let fieldNames: [String] = []
         
         
         // display error
         for (index, field) in textFieldOutlets.enumerated() {
             if let text = field.text, text.isEmpty {
                 showAlert(forMissingField: fieldNames[index])
                 return
             }
         }
         */
        
        /*
         if caster does not have spellsheet create one,
         
         else update values
         */
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
