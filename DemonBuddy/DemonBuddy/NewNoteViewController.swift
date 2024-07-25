//
//  NewNoteViewController.swift
//  DemonBuddy
//
//  Created by Joseph Arteaga on 7/25/24.
//

import UIKit

class NewNoteViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateLabel.text = dateFormatter.string(from: date)
        
        self.view.addSubview(textView)
    }
    
    
    
    @IBAction func gameNamePressed(_ sender: Any) {
    }
    
    // Dismiss the screen
    @IBAction func cancelNote(_ sender: Any) {
        
    }
    
    // Create Note
    @IBAction func donePressed(_ sender: Any) {
        
    }
    
}
