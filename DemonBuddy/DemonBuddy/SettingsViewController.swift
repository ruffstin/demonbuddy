//
//  SettingsViewController.swift
//  DemonBuddy
//
//  Created by Mihir Arora on 7/21/24.
//

import UIKit
import CoreData

//sends a notification to the other VCs to changer their background colors based on what is selected in the PopupMenu
extension Notification.Name {
    static let backgroundColorDidChange = Notification.Name("backgroundColorDidChange")
}

//recieves the settings from core data and stores it in the list
var settingsList: [Settings] = []

class SettingsViewController: UIViewController {
    
    //connection to the popUpMenu
    @IBOutlet weak var colorPopupMenu: UIButton!
    //flag if the user wants vibration
    @IBOutlet weak var vibrationSwitch: UISwitch!
    //flag if the user wants sound
    @IBOutlet weak var soundSwitch: UISwitch!
    //stores the current background color selected
    var currColor: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // gets the values from core data and stores it in the settingsList
//        settingsList = getSettings().map { entity in
//            let settingsEntity = entity as! AppSettings
//            return Settings(color: settingsEntity.backgroundColor ?? "", sound: settingsEntity.soundEnabled, vibration: settingsEntity.vibrationEnabled)
//        }
//        // after getting the settings from core data, apply the settings to the insatnce variables if there is core data
//        if let settings = settingsList.first {
//            currColor = settings.color.lowercased()
//            soundSwitch.setOn(settings.sound, animated: false)
//            vibrationSwitch.setOn(settings.vibration, animated: false)
//            colorPopupMenu.setTitle(settings.color, for: .normal)
//            updateBackgroundColor(newColor: settings.color)
//        } else {
//            //default settings if there is no core data so these are the applied settings
//            currColor = "gray"
//            soundSwitch.setOn(true, animated: false)
//            vibrationSwitch.setOn(true, animated: false)
//            colorPopupMenu.setTitle("gray", for: .normal)
//            updateBackgroundColor(newColor: "gray")
//        }
        //set up pop up button menu
        setPopupButton()
        
    }
    
    // the segue sends the sound and vibration switch boolean values to the play screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsToPlaySegue",
           let playVC = segue.destination as? DiceRollerViewController {
             playVC.delegate = self //pointer to itself passed to DiceRollerVC
             //send the boolean values to the play screen instance variables
             playVC.soundFlag = soundSwitch.isOn
             playVC.vibrationFlag = vibrationSwitch.isOn
        }
    }

    func setPopupButton() {
        //if the currColor is not assigned based on core data then the default color is gray
        let currentSelection = currColor.isEmpty ? "gray" : currColor.lowercased()
        let optionClosure = {(action: UIAction) in
            self.updateBackgroundColor(newColor: action.title)
        }
        
        let menuItems: [UIAction] = [
            UIAction(title: "gray", state: currentSelection == "gray" ? .on : .off, handler: optionClosure),
            UIAction(title: "mint", state: currentSelection == "mint" ? .on : .off, handler: optionClosure),
            UIAction(title: "orange", state: currentSelection == "orange" ? .on : .off, handler: optionClosure),
            UIAction(title: "red", state: currentSelection == "pink" ? .on : .off, handler: optionClosure),
            UIAction(title: "green", state: currentSelection == "purple" ? .on : .off, handler: optionClosure)
        ]
        //the menu displays the color that is chosen based on the string chosen in menuItems
        colorPopupMenu.menu = UIMenu(children: menuItems)
        colorPopupMenu.showsMenuAsPrimaryAction = true
        colorPopupMenu.changesSelectionAsPrimaryAction = true
        
    }
    
    // update the background color of the settings screen and send the notification signal to the other screens
    func updateBackgroundColor(newColor: String) {
        //update currColor if it has been changed from gray
        currColor = newColor.lowercased()
        var color: UIColor
        
        switch newColor.lowercased() {
        case "gray":
            color = UIColor.systemBackground
        case "mint":
            color = UIColor.systemMint
        case "orange":
            color = UIColor.systemOrange
        case "red":
            color = UIColor.systemRed
        case "green":
            color = UIColor.systemGreen
        default:
            color = UIColor.systemBackground
        }
        
        self.view.backgroundColor = color
        //sends the signal to the other screens what the color the background is
        NotificationCenter.default.post(name: .backgroundColorDidChange, object: color)
        //clear the core data before saving new setting changes
        clearCoreData()
        storeSettings(backgroundColor: newColor, soundEnabled: soundSwitch.isOn, vibrationEnabled: vibrationSwitch.isOn)
    }

    //when the sound switch is switched then clear the previous core data and store it with the new values
    @IBAction func soundSwitchPressed(_ sender: Any) {
        clearCoreData()
        storeSettings(backgroundColor: currColor, soundEnabled: soundSwitch.isOn, vibrationEnabled: vibrationSwitch.isOn)
    }
    
    //when the vibration switch is switched then tclear the previous core data and store it with the new values
    @IBAction func vibrationSwitchPressed(_ sender: Any) {
        clearCoreData()
        storeSettings(backgroundColor: currColor, soundEnabled: soundSwitch.isOn, vibrationEnabled: vibrationSwitch.isOn)
    }
    
    // if the user wants to have the default settings
    @IBAction func defaultButtonPressed(_ sender: Any) {
        clearCoreData()
        vibrationSwitch.setOn(true, animated: true)
        soundSwitch.setOn(true, animated: true)
        colorPopupMenu.setTitle("gray", for: .normal)
        updateBackgroundColor(newColor: "gray")
        storeSettings(backgroundColor: "gray", soundEnabled: soundSwitch.isOn, vibrationEnabled: vibrationSwitch.isOn)
    }
    
    //core data function to save it
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
    
    //set the values for core data then save it by calling saveContext()
    func storeSettings(backgroundColor:String, soundEnabled: Bool, vibrationEnabled: Bool){
        let settings = NSEntityDescription.insertNewObject(forEntityName: "AppSettings", into: context)
        //set the values of the attributes then save it to core data
        settings.setValue(backgroundColor, forKey: "backgroundColor")
        settings.setValue(soundEnabled, forKey: "soundEnabled")
        settings.setValue(vibrationEnabled, forKey: "vibrationEnabled")
        saveContext()
    }
    
    //fetch/get the settings from core data
    func getSettings() -> [NSManagedObject] {
        //make the request from core data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AppSettings")
        //this is the data structure that will be returned with the values from core data
        var fetchedResults: [NSManagedObject]? = nil
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            print("failed to load settings from core data")
            
        }
        return fetchedResults ?? []
    }
    
    //remove the core data values
    func clearCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AppSettings")
        do {
            if let fetchedResults = try context.fetch(request) as? [NSManagedObject] {
                for result in fetchedResults {
                    context.delete(result)
                }
                saveContext()
            }
        } catch {
            print("error while clearing core data")
        }
    }
    
}
