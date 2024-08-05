//
//  CreatedMonstersorNPCViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 7/21/24.
//

import UIKit
import CoreData
import FirebaseAuth

var monstersAndNpcs: [NSManagedObject] = []

protocol RefreshMonsterTable {
    func refreshMonsters()
}

class CreatedMonstersorNPCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshMonsterTable{
    
    // Outlets for views
    @IBOutlet weak var sortFiltersStackView: UIStackView!
    @IBOutlet weak var filterButtonsStackView: UIStackView!
    @IBOutlet weak var filtersStackView: UIStackView!
    @IBOutlet weak var selectFiltersView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // Outlets for buttons
    @IBOutlet weak var nameSortFilter: UIButton!
    @IBOutlet weak var gameNameSortFilter: UIButton!
    @IBOutlet weak var orderSortFilter: UIButton!
    @IBOutlet weak var gameNameFilter: UIButton!
    
    let cellIdentifier = "creationCell"
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshMonsters()
    }
    
    // Checks if user has NPCs or Monsters if not then creates an entity to store them
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monstersAndNpcs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SavedCreationCell
        let row = indexPath.row
        
        if let name = monstersAndNpcs[row].value(forKey: "creatureName") as? String {
            cell.creationName?.text = name
        }
        
        if let game = monstersAndNpcs[row].value(forKey: "gameName") as? String {
            cell.gameName?.text = game
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(monstersAndNpcs[indexPath.row])
            monstersAndNpcs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
            grabMonsters(otherPredicate: predicate, sortPredicateName: sortBy, ascOrder: !descSortSelected)
        } else {
            grabMonsters(sortPredicateName: sortBy, ascOrder: !descSortSelected)
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
    
    // Return all monsters and npcs for the current user
    func grabMonsters(otherPredicate: NSPredicate? = nil, sortPredicateName: String? = nil, ascOrder: Bool = true) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NPCorMonster")
        
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
                monstersAndNpcs = fetchedResults
            } else {
                monstersAndNpcs = []
            }
        } catch {
            print("Error occured while retrieving data")
            abort()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "creatMonsterOrNpc", let newMonsterAndNPC = segue.destination as? NewNPCMonsterViewController {
            newMonsterAndNPC.delegate = self
            
        } else if segue.identifier == "editMonsterOrNpc", let newMonsterAndNPC = segue.destination as? NewNPCMonsterViewController, let selectedMonsterOrNpc = tableView.indexPathForSelectedRow?.row {
            newMonsterAndNPC.delegate = self
            newMonsterAndNPC.monsterOrNpcToEdit = monstersAndNpcs[selectedMonsterOrNpc]
        }
    }
    
    func refreshMonsters() {
        grabMonsters()
        tableView.reloadData()
    }
    
}
