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

let defaults = UserDefaults.standard

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
        
        getDefaultData()
        print(defaults.dictionaryRepresentation())
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
        saveDefaultData()
    }

    //when the sound switch is switched then clear the previous core data and store it with the new values
    @IBAction func soundSwitchPressed(_ sender: Any) {
        saveDefaultData()
    }
    
    //when the vibration switch is switched then tclear the previous core data and store it with the new values
    @IBAction func vibrationSwitchPressed(_ sender: Any) {
        saveDefaultData()
    }
    
    // if the user wants to have the default settings
    @IBAction func defaultButtonPressed(_ sender: Any) {
        vibrationSwitch.setOn(true, animated: true)
        soundSwitch.setOn(true, animated: true)
        colorPopupMenu.setTitle("gray", for: .normal)
        updateBackgroundColor(newColor: "gray")
    }
    
    func saveDefaultData() {
        defaults.set(currColor, forKey: "backgroundColor")
        defaults.set(soundSwitch.isOn, forKey: "soundEnabled")
        defaults.set(vibrationSwitch.isOn, forKey: "vibrationEnabled")
        defaults.synchronize()
    }
    
    func getDefaultData() {
        //need to comeback and see if this is what I want in the case that the keyValue pair is nil
        currColor = defaults.string(forKey: "backgroundColor") ?? "gray"
        colorPopupMenu.setTitle(currColor, for: .normal)
        updateBackgroundColor(newColor: currColor)
        soundSwitch.setOn(defaults.bool(forKey: "soundEnabled"), animated: false)
        vibrationSwitch.setOn(defaults.bool(forKey: "vibrationEnabled"), animated: false)
    }
    
    func clearDefaultButton() {
        defaults.removeObject(forKey: "backgroundColor")
        defaults.removeObject(forKey: "soundEnabled")
        defaults.removeObject(forKey: "vibrationEnabled")
    }
    
}
