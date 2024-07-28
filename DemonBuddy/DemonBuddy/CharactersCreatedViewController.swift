//
//  CharactersCreatedViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 7/21/24.
//

import UIKit

import FirebaseAuth

import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

class CharactersCreatedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CharacterCreationDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var characterList: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchCharacter()

    }
    
    
    
    // allows us to fetch characters from core data
    func fetchCharacter() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Character")
                
                // Filter characters by userID
                if let userID = Auth.auth().currentUser?.uid {
                    let predicate = NSPredicate(format: "userID == %@", userID)
                    fetchRequest.predicate = predicate
                }
                
                do {
                    characterList = try context.fetch(fetchRequest)
                    tableView.reloadData()
                    
                } catch {
                    print("Failed to fetch characters: \(error)")
                }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createCharacter" {
            if let destinationVC = segue.destination as? NewCharacterViewController {
                destinationVC.delegate = self
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characterList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath) as! CharacterViewTableCell
        let character = characterList[indexPath.row]
        // grab character and game name
        cell.charName.text = (character.value(forKey: "name") as? String ?? "")
        cell.gameName.text = (character.value(forKey: "gameName") as? String ?? "")
        return cell
    }

    // Swipe to delete from tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let characterToDelete = characterList[indexPath.row]
            characterList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            context.delete(characterToDelete)
            saveContext()
        }
    }
    
    @IBAction func filterPressed(_ sender: Any) {
    }
    
    @IBAction func addNotePressed(_ sender: Any) {
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
