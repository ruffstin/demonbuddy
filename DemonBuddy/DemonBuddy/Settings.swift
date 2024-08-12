//
//  Settings.swift
//  DemonBuddy
//
//  Created by Mihir Arora on 8/12/24.
//

import Foundation

class Settings {
    var color: String
    var sound: Bool
    var vibration: Bool
    
    init(color: String, sound: Bool, vibration: Bool) {
        self.color = color
        self.sound = sound
        self.vibration = vibration
    }
}
