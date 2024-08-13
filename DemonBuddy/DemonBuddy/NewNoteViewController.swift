//
//  NewNoteViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/25/24.
//

import UIKit
import CoreData
import FirebaseAuth

class NewNoteViewController: UIViewController {
    
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var gameNameDropdown: UIButton!
    
    var delegate: UIViewController!
    
    var note: NSManagedObject?
    var noteToEdit: NSManagedObject?
    var gameNameOptions: [UIAction]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateGameNameMenu()

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = "Edited on: \(dateFormatter.string(from: date))"
        
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(buttonsView)
        view.addSubview(stackView)
        
        if noteToEdit != nil {
            if let title = noteToEdit?.value(forKey: "title") as? String {
                titleTextView.text = title
            }
            if let game = noteToEdit?.value(forKey: "gameName") as? String {
                gameNameDropdown.setTitle(game, for: .normal)
            }
            if let text = noteToEdit?.value(forKey: "noteText") as? String {
                textView.text = text
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
    
    // Dismiss the screen
    @IBAction func cancelNote(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // Create Note
    @IBAction func donePressed(_ sender: Any) {
        if ((titleTextView.text?.isEmpty) == nil) {
            let controller = UIAlertController(
                title: "Missing Title",
                message: "Input a title",
                preferredStyle: .alert
            )
            
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            present(controller, animated: true)
        } else {
            let title = titleTextView.text
            let game = gameNameDropdown.title(for: .normal)
            let userID = Auth.auth().currentUser?.uid
            let noteText = textView.text
            let date = dateLabel.text
            
            if noteToEdit != nil{
                // Update existing Note instance
                noteToEdit?.setValue(title, forKey:  "title")
                noteToEdit?.setValue(game, forKey: "gameName")
                noteToEdit?.setValue(date, forKey: "date")
                noteToEdit?.setValue(noteText, forKey: "noteText")
            } else {
                // Create new Note instance
                let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context)
                note.setValue(title, forKey: "title")
                note.setValue(game, forKey: "gameName")
                note.setValue(userID, forKey: "userID")
                note.setValue(noteText, forKey: "noteText")
                note.setValue(date, forKey: "date")
            }
            
            saveContext()
            
            let notesVC = delegate as! RefreshTable
            notesVC.refreshTable()
            
            self.dismiss(animated: true)
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
