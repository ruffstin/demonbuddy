//
//  CharactersCreatedViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 7/21/24.
//

import UIKit
import FirebaseAuth
import CoreData

var characterList: [NSManagedObject] = []

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

protocol RefreshCharacterTable{
    func refreshCharacters()
}

class CharactersCreatedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshCharacterTable {
    func refreshCharacters() {
            fetchCharacters()
            tableView.reloadData()
    }

    // Outlets for views
    @IBOutlet weak var sortFiltersStackView: UIStackView!
    @IBOutlet weak var filterButtonsStackView: UIStackView!
    @IBOutlet weak var filtersStackView: UIStackView!
    @IBOutlet weak var selectFiltersView: UIView!
    
    // Outlets for buttons
    @IBOutlet weak var nameSortFilter: UIButton!
    @IBOutlet weak var gameNameSortFilter: UIButton!
    @IBOutlet weak var orderSortFilter: UIButton!
    @IBOutlet weak var gameNameFilter: UIButton!
    
    let cellIdentifier = "creationCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameSortSelected = false
    var gameSortSelected = false
    var descSortSelected = false
    
    var dimBackgroundView: UIView!
    
    var gameNameOptions: [UIAction]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectFiltersView.isHidden = false
        
        dimBackgroundView = UIView(frame: self.view.bounds)
        dimBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimBackgroundView.alpha = 0
        
        selectFiltersView.alpha = 0
        
        filtersStackView.addSubview(sortFiltersStackView)
        filtersStackView.addSubview(filterButtonsStackView)
        
        selectFiltersView.addSubview(filtersStackView)
        
        view.addSubview(dimBackgroundView)
        view.addSubview(selectFiltersView)
        selectFiltersView.layer.cornerRadius = 10
        selectFiltersView.layer.masksToBounds = true
        
        populateGameNameOptions()
        
        let menu = UIMenu(title: "Game Names", options: .displayInline, children: gameNameOptions)
        gameNameFilter.menu = menu
        gameNameFilter.showsMenuAsPrimaryAction = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Listen for background color changes
       NotificationCenter.default.addObserver(self, selector: #selector(handleBackgroundColorChange(notification:)), name: .backgroundColorDidChange, object: nil)
       
       // Apply the saved background color on load
       applySavedBackgroundColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCharacters()
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

    
    // Checks if user has characters if not then creates an entity to store them
    func populateGameNameOptions() {
        gameNameOptions = [
            UIAction(title: "None") {
                _ in self.gameNameFilter.setTitle("None", for: .normal)
            }
        ]
        for name in gameNames {
            gameNameOptions.append(UIAction(title: name) {
                _ in self.gameNameFilter.setTitle(name, for: .normal)
            })
        }
    }
    
    // allows us to fetch characters from core data
    func fetchCharacters(otherPredicate: NSPredicate? = nil, sortPredicateName: String? = nil, ascOrder: Bool = true) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
        
        if let user = Auth.auth().currentUser?.uid {
            let userPredicate = NSPredicate(format: "userID == %@", user)
            
            if otherPredicate != nil {
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, otherPredicate!])
                request.predicate = compoundPredicate
            } else {
                request.predicate = userPredicate
            }
            
            if sortPredicateName != nil {
                let sortPredicate = NSSortDescriptor(key: sortPredicateName, ascending: ascOrder)
                request.sortDescriptors = [sortPredicate]
            }
        }
        
        do {
            if let fetchedResults = try context.fetch(request) as? [NSManagedObject] {
                characterList = fetchedResults
            } else {
                characterList = []
            }
        } catch {
            print("Error occured while retrieving data")
            abort()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createCharacter", let newCharacter = segue.destination as? NewCharacterViewController {
            newCharacter.delegate = self
            
        } else if segue.identifier == "editCharacter", let newCharacter = segue.destination as? NewCharacterViewController, let selectedCharacter = tableView.indexPathForSelectedRow?.row {
            newCharacter.delegate = self
            newCharacter.characterToEdit = characterList[selectedCharacter]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characterList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "creationCell", for: indexPath) as! SavedCreationCell
        let character = characterList[indexPath.row]
        // grab character and game name
        cell.creationName.text = (character.value(forKey: "name") as? String ?? "")
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
        tableView.reloadData()
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 1
            self.selectFiltersView.alpha = 1
        }
    }
    
    @IBAction func filtersDonePressed(_ sender: Any) {
        var sortBy: String!
        if nameSortSelected {
            sortBy = "title"
        } else if gameSortSelected {
            sortBy = "gameName"
        }
        
        if gameNameFilter.titleLabel!.text != "Game Name" {
            let predicate = NSPredicate(format: "gameName == %@", gameNameFilter.titleLabel!.text!)
            fetchCharacters(otherPredicate: predicate, sortPredicateName: sortBy, ascOrder: !descSortSelected)
        } else {
            fetchCharacters(sortPredicateName: sortBy, ascOrder: !descSortSelected)
        }
        
        tableView.reloadData()
        
        resetFilters()
        
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 0
            self.selectFiltersView.alpha = 0
        }
    }
    
    
    func resetFilters() {
        nameSortSelected = false
        gameSortSelected = false
        descSortSelected = false
        gameNameFilter.setTitle("Game Name", for: .normal)
        
        nameSortFilter.backgroundColor = UIColor(named: "DilutedDemonBloodColor")
        gameNameSortFilter.backgroundColor = UIColor(named: "DilutedDemonBloodColor")
        orderSortFilter.setTitle("Asc", for: .normal)
    }
    
    @IBAction func filtersCancelPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 0
            self.selectFiltersView.alpha = 0
        }
    }
    
    @IBAction func nameSortFilterPressed(_ sender: Any) {
        nameSortSelected = !nameSortSelected
        if nameSortSelected {
            nameSortFilter.backgroundColor = UIColor(named: "PureDemonBloodColor")
        } else {
            nameSortFilter.backgroundColor = UIColor(named: "DilutedDemonBloodColor")
        }
    }
    
    @IBAction func gameNameSortFilterPressed(_ sender: Any) {
        gameSortSelected = !gameSortSelected
        if gameSortSelected {
            gameNameSortFilter.backgroundColor = UIColor(named: "PureDemonBloodColor")
        } else {
            gameNameSortFilter.backgroundColor = UIColor(named: "DilutedDemonBloodColor")
        }
    }
    
    @IBAction func orderSortFilterPressed(_ sender: Any) {
        descSortSelected = !descSortSelected
        if descSortSelected {
            orderSortFilter.setTitle("Desc", for: .normal)
        } else {
            orderSortFilter.setTitle("Asc", for: .normal)
        }
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
