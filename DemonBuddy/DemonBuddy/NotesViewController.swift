//
//  NotesViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/16/24.
//

import UIKit

class NotesViewController: UIViewController {

    
    @IBOutlet weak var sortFiltersStackView: UIStackView!
    @IBOutlet weak var filterButtonsStackView: UIStackView!
    
    @IBOutlet weak var filtersStackView: UIStackView!
    @IBOutlet weak var selectFiltersView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersStackView.addSubview(sortFiltersStackView)
        filtersStackView.addSubview(filterButtonsStackView)
        
        selectFiltersView.addSubview(filtersStackView)
        
        view.addSubview(selectFiltersView)
        selectFiltersView.layer.cornerRadius = 10
        selectFiltersView.layer.masksToBounds = true
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        if selectFiltersView.isHidden {
            selectFiltersView.isHidden = false
        } else {
            selectFiltersView.isHidden = true
        }
    }
    
    @IBAction func addNotePressed(_ sender: Any) {
    }
    
    
    @IBAction func filtersDonePressed(_ sender: Any) {
        selectFiltersView.isHidden = true
    }
    
    
    @IBAction func filtersCancelPressed(_ sender: Any) {
        selectFiltersView.isHidden = true
    }
    
}
