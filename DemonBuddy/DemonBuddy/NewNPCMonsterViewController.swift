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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updateGameNameMenu()
        
        if monsterOrNpcToEdit != nil {
            
            // fill in with appropriate values
            
            /*
             creatureNameText
             hitPoints
             armorClass
             speed
             challengeRating
             xpToEarn
             strength
             constitution
             dexterity
             intelligence
             charisma
             skills
             senses
             languages
             creatureFeatures
             actions
             items
             
             
             
             if let title = noteToEdit?.value(forKey: "title") as? String {
             titleTextView.text = title
             }
             if let game = noteToEdit?.value(forKey: "gameName") as? String {
             gameNameDropdown.setTitle(game, for: .normal)
             }
             if let text = noteToEdit?.value(forKey: "noteText") as? String {
             textView.text = text
             }*/
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
        
        // add npc VS Monster?
        let userID = Auth.auth().currentUser?.uid
        let game = gameName.text // will be changed per Joseph's implementation?
        let creatureName = creatureNameText.text
        let maxHP = hitPoints.text
        let armor = armorClass.text
        let movement = speed.text
        let cR = challengeRating.text
        let xP = xpToEarn.text
        let str = strength.text
        let dex = dexterity.text
        let con = constitution.text
        let int = intelligence.text
        let wis = intelligence.text
        let cha = charisma.text
        let skillsProf = skills.text
        let radar = senses.text
        let speech = languages.text
        let abilities = creatureFeatures.text
        let attacks = actions.text
        let loot = items.text
        
        // npc vs monster?
         
        if monsterOrNpcToEdit != nil{
         
         // Update existing monsters/npc instance
            monsterOrNpcToEdit?.setValue(game, forKey:  "gameName")
            monsterOrNpcToEdit?.setValue(creatureName, forKey: "creatureName")
            // monsterOrNpcToEdit?.setValue(date, forKey: "date") no date yet but can be added
            monsterOrNpcToEdit?.setValue(maxHP, forKey: "hitPoints")
            monsterOrNpcToEdit?.setValue(armor, forKey: "armorClass")
            monsterOrNpcToEdit?.setValue(movement, forKey: "speed")
            monsterOrNpcToEdit?.setValue(cR, forKey: "challengeRating")
            monsterOrNpcToEdit?.setValue(xP, forKey: "xp")
            monsterOrNpcToEdit?.setValue(str, forKey: "strength")
            monsterOrNpcToEdit?.setValue(dex, forKey: "dexterity")
            monsterOrNpcToEdit?.setValue(con, forKey: "constitution")
            monsterOrNpcToEdit?.setValue(int, forKey: "intelligence")
            monsterOrNpcToEdit?.setValue(wis, forKey: "wisdom")
            monsterOrNpcToEdit?.setValue(cha, forKey: "charisma")
            monsterOrNpcToEdit?.setValue(skillsProf, forKey: "skills")
            monsterOrNpcToEdit?.setValue(radar, forKey: "senses")
            monsterOrNpcToEdit?.setValue(speech, forKey: "languages")
            monsterOrNpcToEdit?.setValue(abilities, forKey: "creatureFeatures")
            monsterOrNpcToEdit?.setValue(attacks, forKey: "actions")
            monsterOrNpcToEdit?.setValue(loot, forKey: "items")
            
            // npc vs monster boolean? add here
            
            
            
         } else {
         // Create new NPC/Monster instance
             let monsterOrNpc = NSEntityDescription.insertNewObject(forEntityName: "NPCorMonster", into: context)
             monsterOrNpc.setValue(userID, forKey: "userID")
             // note.setValue(date, forKey: "date") add date?
             
             monsterOrNpcToEdit?.setValue(game, forKey:  "gameName")
             monsterOrNpcToEdit?.setValue(creatureName, forKey: "creatureName")
             // monsterOrNpcToEdit?.setValue(date, forKey: "date") no date yet but can be added
             monsterOrNpc.setValue(maxHP, forKey: "hitPoints")
             monsterOrNpc.setValue(armor, forKey: "armorClass")
             monsterOrNpc.setValue(movement, forKey: "speed")
             monsterOrNpc.setValue(cR, forKey: "challengeRating")
             monsterOrNpc.setValue(xP, forKey: "xp")
             monsterOrNpc.setValue(str, forKey: "strength")
             monsterOrNpc.setValue(dex, forKey: "dexterity")
             monsterOrNpc.setValue(con, forKey: "constitution")
             monsterOrNpc.setValue(int, forKey: "intelligence")
             monsterOrNpc.setValue(wis, forKey: "wisdom")
             monsterOrNpc.setValue(cha, forKey: "charisma")
             monsterOrNpc.setValue(skillsProf, forKey: "skills")
             monsterOrNpc.setValue(radar, forKey: "senses")
             monsterOrNpc.setValue(speech, forKey: "languages")
             monsterOrNpc.setValue(abilities, forKey: "creatureFeatures")
             monsterOrNpc.setValue(attacks, forKey: "actions")
             monsterOrNpc.setValue(loot, forKey: "items")
             
             // npc vs monster boolean? add here
        }
        
        saveContext()
        
        let monstersAndNpcVC = delegate as! RefreshMonsterTable
        monstersAndNpcVC.refreshMonsters()
        
        self.dismiss(animated: true)
        //}
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
