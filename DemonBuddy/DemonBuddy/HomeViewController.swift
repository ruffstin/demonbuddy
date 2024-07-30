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
            // Update the user's game names list
            if var listOfNames = userGameNames.value(forKey: "names") as? [String] {
                listOfNames.remove(at: indexPath.row)
                userGameNames.setValue(listOfNames, forKey: "names")
                gameNames.remove(at: indexPath.row)
            }
            
            gameNameTableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
        }
        gameNameTableView.reloadData()
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
        if var listOfNames = userGameNames.value(forKey: "names") as? [String] {
            listOfNames.append(gameNameTextField.text!)
            userGameNames.setValue(listOfNames, forKey: "names")
            gameNames.append(gameNameTextField.text!)
        }
        
        saveContext()
        gameNameTableView.reloadData()
        
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
