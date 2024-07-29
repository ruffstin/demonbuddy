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
    @IBOutlet weak var createGameNameView: UIView!
    @IBOutlet weak var createGameNameStackView: UIStackView!
    @IBOutlet weak var createGameButtonStack: UIStackView!
    
    @IBOutlet weak var newGameTextInput: UITextField!
    
    var delegate: UIViewController!
    
    var note: NSManagedObject?
    var noteToEdit: NSManagedObject?
    var gameNameOptions: [UIAction]!
    var dimBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGameNameView.isHidden = false
        
        dimBackgroundView = UIView(frame: self.view.bounds)
        dimBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimBackgroundView.alpha = 0
        
        createGameNameView.alpha = 0
        
        gameNameOptions = [
            UIAction(title: "None")
            { _ in self.gameNameDropdown.setTitle("None", for: .normal) },
            UIAction(title: "Create Game Name")
            { _ in self.createNewGameName()}
        ]
        
        updateGameNameMenu()

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = "Edited on: \(dateFormatter.string(from: date))"
        
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(buttonsView)
        createGameNameStackView.addArrangedSubview(createGameButtonStack)
        createGameNameView.addSubview(createGameNameStackView)
        view.addSubview(stackView)
        view.addSubview(dimBackgroundView)
        view.addSubview(createGameNameView)
        
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
    }
    
    func updateGameNameMenu() {
        let menu = UIMenu(title: "Game Names", options: .displayInline, children: gameNameOptions)
        gameNameDropdown.menu = menu
        gameNameDropdown.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func gameNamePressed(_ sender: Any) {
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
    
    func createNewGameName() {
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 1
            self.createGameNameView.alpha = 1
        }
    }
    
    @IBAction func newGameCreatePressed(_ sender: Any) {
        let newAction = UIAction(title: newGameTextInput.text!) {
            _ in self.gameNameDropdown.setTitle(self.newGameTextInput.text!, for: .normal)
        }
        self.gameNameDropdown.setTitle(newGameTextInput.text!, for: .normal)
        gameNameOptions.insert(newAction, at: gameNameOptions.count - 1)
        updateGameNameMenu()
        newGameTextInput.text = nil
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 0
            self.createGameNameView.alpha = 0
        }
    }
    
    @IBAction func newGameCancelPressed(_ sender: Any) {
        newGameTextInput.text = nil
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 0
            self.createGameNameView.alpha = 0
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
