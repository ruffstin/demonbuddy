//
//  HomeViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/11/24.
//

import UIKit
import FirebaseAuth
import CoreData

internal var gameNames: [String]!

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var createNameView: UIView!
    @IBOutlet weak var createNameStackView: UIStackView!
    @IBOutlet weak var createNameButtonsStackView: UIStackView!
    @IBOutlet weak var gameNameTextField: UITextField!
    
    @IBOutlet weak var gameNameTableView: UITableView!
    
    
    @IBOutlet weak var secretButton: UIButton!
    
    @IBOutlet weak var demonBuddyLine: UILabel!
    
    var userGameNames: NSManagedObject!
    var dimBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNameView.isHidden = false
        
        dimBackgroundView = UIView(frame: self.view.bounds)
        dimBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimBackgroundView.alpha = 0
        
        createNameView.alpha = 0
        
        createNameStackView.addArrangedSubview(createNameButtonsStackView)
        createNameView.addSubview(createNameStackView)
        view.addSubview(dimBackgroundView)
        view.addSubview(createNameView)

        gameNameTableView.delegate = self
        gameNameTableView.dataSource = self
        
        demonBuddyLine.text = "What Infernal Magicks are we going to get up to today MASTER?"
        
        retrieveGameNames()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gameNameTableView.dequeueReusableCell(withIdentifier: "gameNameCell", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = gameNames[row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let controller = UIAlertController(
                title: "Delete Game Name",
                message: "Deleting game name will delete all associated Notes, Characters, and Monsters/NPCs",
                preferredStyle: .alert
            )
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            controller.addAction(UIAlertAction(title: "Delete", style: .destructive){
                _ in
                
                // Delete game name and all associated content
                if var listOfNames = self.userGameNames.value(forKey: "names") as? [String] {
                    self.deleteGameNameAssociations(nameOfGame: listOfNames[indexPath.row])
                    listOfNames.remove(at: indexPath.row)
                    self.userGameNames.setValue(listOfNames, forKey: "names")
                    gameNames.remove(at: indexPath.row)
                }
                
                self.gameNameTableView.deleteRows(at: [indexPath], with: .fade)
                saveContext()
            })
            present(controller, animated: true)
        }
        gameNameTableView.reloadData()
    }
    
    func deleteGameNameAssociations(nameOfGame: String) {
        let notesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let charactersRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
        let npcsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NPCorMonster")
        let spellsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SpellSheet")
        
        let deleteRequests: [NSFetchRequest] = [notesRequest, charactersRequest, npcsRequest, spellsRequest]
        
        // Create predicate to match entities to user and game name
        let user = (Auth.auth().currentUser?.uid as? String)!
        let userPredicate = NSPredicate(format: "userID == %@", user)
        let gamePredicate = NSPredicate(format: "gameName == %@", nameOfGame)
        let userAndGamePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, gamePredicate])
        
        // For each entity request, get the matching instances and delete them
        for deleteRequest in deleteRequests {
            deleteRequest.predicate = userAndGamePredicate
            do {
                if let fetchedResults = try context.fetch(deleteRequest) as? [NSManagedObject] {
                    for entity in fetchedResults {
                        context.delete(entity)
                        saveContext()
                    }
                }
            } catch {
                print("Could not delete entity")
            }
        }
    }
    
    func retrieveGameNames() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GameNames")
        let user = (Auth.auth().currentUser?.uid as? String)!
        let predicate = NSPredicate(format: "userID == %@", user)
        request.predicate = predicate
        
        do {
            if let fetchedResults = try context.fetch(request) as? [NSManagedObject],
               let gameNamesForUser = fetchedResults.first {
                userGameNames = gameNamesForUser
                if let listOfNames = gameNamesForUser.value(forKey: "names") as? [String] {
                    gameNames = []
                    for name in listOfNames {
                        gameNames.append(name)
                    }
                }
            } else {
                let newGameName = NSEntityDescription.insertNewObject(forEntityName: "GameNames", into: context)
                newGameName.setValue(user, forKey: "userID")
                newGameName.setValue([], forKey: "names")
                saveContext()
            }
        } catch {
            print("Could not populate table")
        }
    }
    
    @IBAction func addGameNamePressed(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 1
            self.createNameView.alpha = 1
        }
    }
    
    // Add the new name to CoreData and gameNames
    @IBAction func doneNamePressed(_ sender: Any) {
        if let text = gameNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            if var listOfNames = userGameNames.value(forKey: "names") as? [String] {
                listOfNames.append(gameNameTextField.text!)
                userGameNames.setValue(listOfNames, forKey: "names")
                gameNames.append(gameNameTextField.text!)
            }
            
            saveContext()
            gameNameTableView.reloadData()
        }
        gameNameTextField.text = nil
        
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 0
            self.createNameView.alpha = 0
        }
    }
    
    @IBAction func cancelNamePressed(_ sender: Any) {
        gameNameTextField.text = nil
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 0
            self.createNameView.alpha = 0
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch{
            print("signout error")
        }
    }
}
