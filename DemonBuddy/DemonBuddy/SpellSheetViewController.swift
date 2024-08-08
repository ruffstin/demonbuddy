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

    @IBOutlet weak var testSpell: UITextField!
    
    /*
     insert all outlets here
     
     */
    
    /*
     array for the outlets
     */
    
    /*
     array for the attributes
     */
    
    /*
     delegate (if needed)
     spellSheetToEdit
     
     */
    
    var delegate: UIViewController!
    
    var caster: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*
         if spell sheet existed beforehand -> fill in values
         for (index, key) in attributes.enumerated() {
             if let textToInput = spellSheetToEdit?.value(forKey: key) as? String {
                 textFieldOutlets[index].text = textToInput
             }
         }
         */
    }
    
    @IBAction func savetest(_ sender: Any) {
        
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
         create/save spellsheet
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
