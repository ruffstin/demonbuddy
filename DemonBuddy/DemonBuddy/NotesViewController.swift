//
//  NotesViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/16/24.
//

import UIKit
import CoreData
import FirebaseAuth

var notes: [NSManagedObject] = []

protocol RefreshTable {
    func refreshTable()
}

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshTable{
    
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
    
    let cellIdentifier = "noteCell"
    
    var nameSortSelected = false
    var gameSortSelected = false
    var descSortSelected = false
    var gameFilterSelected = false
    
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
        refreshTable()
    }
    
    // Checks if user has Notes if not then creates an entity to store them
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
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotesCell
        let row = indexPath.row
        
        if let name = notes[row].value(forKey: "title") as? String {
            cell.noteName?.text = name
        }
        
        if let game = notes[row].value(forKey: "gameName") as? String {
            cell.noteGameName?.text = game
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(notes[indexPath.row])
            notes.remove(at: indexPath.row)
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
    
    @IBAction func addNotePressed(_ sender: Any) {
    }
    
    @IBAction func filtersDonePressed(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.dimBackgroundView.alpha = 0
            self.selectFiltersView.alpha = 0
        }
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
            nameSortFilter.backgroundColor = UIColor(named: "Primary Color")
        } else {
            nameSortFilter.backgroundColor = UIColor(named: "Secondary Color")
        }
    }
    
    @IBAction func gameNameSortFilterPressed(_ sender: Any) {
        gameSortSelected = !gameSortSelected
        if gameSortSelected {
            gameNameSortFilter.backgroundColor = UIColor(named: "Primary Color")
        } else {
            gameNameSortFilter.backgroundColor = UIColor(named: "Secondary Color")
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
    
    @IBAction func gameNameFilterPressed(_ sender: Any) {
        gameFilterSelected = true
    }
    
    // Return all notes for the current user
    func retrieveNotes() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        if let user = Auth.auth().currentUser?.uid {
            let predicate = NSPredicate(format: "userID == %@", user)
            request.predicate = predicate
        }
        
        do {
            if let fetchedResults = try context.fetch(request) as? [NSManagedObject] {
                notes = fetchedResults
            } else {
                notes = []
            }
        } catch {
            print("Error occured while retrieving data")
            abort()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateNote", let newNoteVC = segue.destination as? NewNoteViewController {
            newNoteVC.delegate = self
        } else if segue.identifier == "toEditNote", let newNoteVC = segue.destination as? NewNoteViewController, let selectedNote = tableView.indexPathForSelectedRow?.row {
            newNoteVC.delegate = self
            newNoteVC.noteToEdit = notes[selectedNote]
        }
    }
    
    func refreshTable() {
        retrieveNotes()
        tableView.reloadData()
    }
}
