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
            
            // gamename would be edited per Joseph's implementation
            if let game = monsterOrNpcToEdit?.value(forKey: "gameName") as? String {
                gameName.text = game
            }
            if let creatureName = monsterOrNpcToEdit?.value(forKey: "creatureName") as? String {
                creatureNameText.text = creatureName
            }
            if let hitPointsValue = monsterOrNpcToEdit?.value(forKey: "hitPoints") as? String {
                hitPoints.text = hitPointsValue
            }
            if let armorClassValue = monsterOrNpcToEdit?.value(forKey: "armorClass") as? String {
                armorClass.text = armorClassValue
            }
            if let speedValue = monsterOrNpcToEdit?.value(forKey: "speed") as? String {
                speed.text = speedValue
            }
            if let challengeRatingValue = monsterOrNpcToEdit?.value(forKey: "challengeRating") as? String {
                challengeRating.text = challengeRatingValue
            }
            if let xpValue = monsterOrNpcToEdit?.value(forKey: "xp") as? String {
                xpToEarn.text = xpValue
            }
            if let strengthValue = monsterOrNpcToEdit?.value(forKey: "strength") as? String {
                strength.text = strengthValue
            }
            if let constitutionValue = monsterOrNpcToEdit?.value(forKey: "constitution") as? String {
                constitution.text = constitutionValue
            }
            if let dexterityValue = monsterOrNpcToEdit?.value(forKey: "dexterity") as? String {
                dexterity.text = dexterityValue
            }
            if let intelligenceValue = monsterOrNpcToEdit?.value(forKey: "intelligence") as? String {
                intelligence.text = intelligenceValue
            }
            if let wisdomValue = monsterOrNpcToEdit?.value(forKey: "wisdom") as? String {
                wisdom.text = wisdomValue
            }
            if let charismaValue = monsterOrNpcToEdit?.value(forKey: "charisma") as? String {
                charisma.text = charismaValue
            }
            if let skillsValue = monsterOrNpcToEdit?.value(forKey: "skills") as? String {
                skills.text = skillsValue
            }
            if let sensesValue = monsterOrNpcToEdit?.value(forKey: "senses") as? String {
                senses.text = sensesValue
            }
            if let languagesValue = monsterOrNpcToEdit?.value(forKey: "languages") as? String {
                languages.text = languagesValue
            }
            if let creatureFeaturesValue = monsterOrNpcToEdit?.value(forKey: "creatureFeatures") as? String {
                creatureFeatures.text = creatureFeaturesValue
            }
            if let actionsValue = monsterOrNpcToEdit?.value(forKey: "actions") as? String {
                actions.text = actionsValue
            }
            if let itemsValue = monsterOrNpcToEdit?.value(forKey: "items") as? String {
                items.text = itemsValue
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
            
            // Check for all required fields
            guard let game = gameName.text, !game.isEmpty else {
                showAlert(forMissingField: "Game Name")
                return
            }
            
            guard let creatureName = creatureNameText.text, !creatureName.isEmpty else {
                showAlert(forMissingField: "Creature Name")
                return
            }
            
            guard let maxHP = hitPoints.text, !maxHP.isEmpty else {
                showAlert(forMissingField: "Hit Points")
                return
            }
            
            guard let armor = armorClass.text, !armor.isEmpty else {
                showAlert(forMissingField: "Armor Class")
                return
            }
            
            guard let movement = speed.text, !movement.isEmpty else {
                showAlert(forMissingField: "Speed")
                return
            }
            
            guard let cR = challengeRating.text, !cR.isEmpty else {
                showAlert(forMissingField: "Challenge Rating")
                return
            }
            
            guard let xP = xpToEarn.text, !xP.isEmpty else {
                showAlert(forMissingField: "XP to Earn")
                return
            }
            
            guard let str = strength.text, !str.isEmpty else {
                showAlert(forMissingField: "Strength")
                return
            }
            
            guard let dex = dexterity.text, !dex.isEmpty else {
                showAlert(forMissingField: "Dexterity")
                return
            }
            
            guard let con = constitution.text, !con.isEmpty else {
                showAlert(forMissingField: "Constitution")
                return
            }
            
            guard let int = intelligence.text, !int.isEmpty else {
                showAlert(forMissingField: "Intelligence")
                return
            }
            
            guard let wis = wisdom.text, !wis.isEmpty else {
                showAlert(forMissingField: "Wisdom")
                return
            }
            
            guard let cha = charisma.text, !cha.isEmpty else {
                showAlert(forMissingField: "Charisma")
                return
            }
            
            guard let skillsProf = skills.text, !skillsProf.isEmpty else {
                showAlert(forMissingField: "Skills")
                return
            }
            
            guard let radar = senses.text, !radar.isEmpty else {
                showAlert(forMissingField: "Senses")
                return
            }
            
            guard let speech = languages.text, !speech.isEmpty else {
                showAlert(forMissingField: "Languages")
                return
            }
            
            guard let abilities = creatureFeatures.text, !abilities.isEmpty else {
                showAlert(forMissingField: "Creature Features")
                return
            }
            
            guard let attacks = actions.text, !attacks.isEmpty else {
                showAlert(forMissingField: "Actions")
                return
            }
            
            guard let loot = items.text, !loot.isEmpty else {
                showAlert(forMissingField: "Items")
                return
            }
            
            // All required fields are present, proceed with entity creation
            let userID = Auth.auth().currentUser?.uid
            
            if let monsterOrNpcToEdit = monsterOrNpcToEdit {
                // Update existing monsters/npc instance
                monsterOrNpcToEdit.setValue(game, forKey: "gameName")
                monsterOrNpcToEdit.setValue(creatureName, forKey: "creatureName")
                monsterOrNpcToEdit.setValue(maxHP, forKey: "hitPoints")
                monsterOrNpcToEdit.setValue(armor, forKey: "armorClass")
                monsterOrNpcToEdit.setValue(movement, forKey: "speed")
                monsterOrNpcToEdit.setValue(cR, forKey: "challengeRating")
                monsterOrNpcToEdit.setValue(xP, forKey: "xp")
                monsterOrNpcToEdit.setValue(str, forKey: "strength")
                monsterOrNpcToEdit.setValue(dex, forKey: "dexterity")
                monsterOrNpcToEdit.setValue(con, forKey: "constitution")
                monsterOrNpcToEdit.setValue(int, forKey: "intelligence")
                monsterOrNpcToEdit.setValue(wis, forKey: "wisdom")
                monsterOrNpcToEdit.setValue(cha, forKey: "charisma")
                monsterOrNpcToEdit.setValue(skillsProf, forKey: "skills")
                monsterOrNpcToEdit.setValue(radar, forKey: "senses")
                monsterOrNpcToEdit.setValue(speech, forKey: "languages")
                monsterOrNpcToEdit.setValue(abilities, forKey: "creatureFeatures")
                monsterOrNpcToEdit.setValue(attacks, forKey: "actions")
                monsterOrNpcToEdit.setValue(loot, forKey: "items")
                // Add additional logic for NPC vs Monster if needed
            } else {
                // Create new NPC/Monster instance
                let monsterOrNpc = NSEntityDescription.insertNewObject(forEntityName: "NPCorMonster", into: context)
                monsterOrNpc.setValue(userID, forKey: "userID")
                monsterOrNpc.setValue(game, forKey: "gameName")
                monsterOrNpc.setValue(creatureName, forKey: "creatureName")
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
                // Add additional logic for NPC vs Monster if needed
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
