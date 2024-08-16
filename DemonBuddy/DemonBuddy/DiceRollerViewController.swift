//
//  DiceRollerViewController.swift
//  DemonBuddy
//
//  Created by Mark Mills on 7/28/24.
//

import UIKit
import AVFoundation
import AudioToolbox

class DiceRollerViewController: UIViewController {


    @IBOutlet weak var d4Num: UITextField!
    @IBOutlet weak var d6Num: UITextField!
    @IBOutlet weak var d8Num: UITextField!
    @IBOutlet weak var d10Num: UITextField!
    @IBOutlet weak var d12Num: UITextField!
    @IBOutlet weak var d20Num: UITextField!

    @IBOutlet weak var d4Image: UIImageView!
    @IBOutlet weak var d6Image: UIImageView!
    @IBOutlet weak var d8Image: UIImageView!
    @IBOutlet weak var d10Image: UIImageView!
    @IBOutlet weak var d12Image: UIImageView!
    @IBOutlet weak var d20Image: UIImageView!
    // @IBOutlet weak var mainDiceImage: UIImageView!
    
    @IBOutlet weak var rollButton: UIButton!
    
    @IBOutlet weak var totalNum: UILabel!
        
    @IBOutlet weak var reset: UIButton!
    
    // setting variables passed in from settingsVC
    var audioPlayer: AVAudioPlayer?
    var soundFlag: Bool!
    var vibrationFlag: Bool!
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        reset.isEnabled = false
        reset.isHidden = true

        // Access the sound and vibration flags from UserDefaults
        soundFlag = UserDefaults.standard.bool(forKey: "soundEnabled")
        vibrationFlag = UserDefaults.standard.bool(forKey: "vibrationEnabled")
        // Listen for background color changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackgroundColorChange(notification:)), name: .backgroundColorDidChange, object: nil)
               
        // Apply the saved background color on load
        applySavedBackgroundColor()
        
        d4Image.isHidden = true
        d6Image.isHidden = true
        d8Image.isHidden = true
        d10Image.isHidden = true
        d12Image.isHidden = true
        d20Image.isHidden = true
    }
    
    
    let diceSides = [4, 6, 8, 10, 12, 20]
    var diceTextFields : [UITextField] {
        return [d4Num, d6Num, d8Num, d10Num, d12Num, d20Num]
    }
    
    var diceImageViews  : [UIImageView] {
        return [d4Image, d6Image, d8Image, d10Image, d12Image, d20Image]
    }
    
    var diceToAnimate = [false, false, false, false, false, false]

    @IBAction func rollButtonClicked(_ sender: Any) {
        
        for textField in diceTextFields {
            if let text = textField.text, Int(text) == nil {
                showAlert()
                return
            }
        }
        
            var totalRolled = 0
            
            for (index, textField) in diceTextFields.enumerated() {
                if let text = textField.text, let numberOfRolls = Int(text) {
                    let sides = diceSides[index]
                    if numberOfRolls > 0 {
                        for _ in 1...numberOfRolls {
                            let roll = Int.random(in: 1...sides)
                            totalRolled += roll
                        }
                        // make note of which dice are being rolled
                        diceToAnimate[index] = true
                    // ensure that if no dice of this size, don't have them animating
                    } else {
                        diceToAnimate[index] = false
                    }
                }
            }
        
        if (totalRolled > 0) {
            totalNum.text = "Total: \(totalRolled)"
            reset.isEnabled = true
            reset.isHidden = false
            
            // only make sound/vibrate the phone/or animate IF there are dice selected to roll
            soundNShakeNAnimate()
        }
    }

    func soundNShakeNAnimate() {
        //issue, the sound will only play if the user intializes the settings by clicking on the settings tab so, upon logging in or going to the home screen I need to intialize these flags and send them to DiceRoller VC for the sound to work
        if soundFlag {
            playSound(named: "dice-142528")
            //print("sound on")
        } else {
            print("sound off")
        }
        
        if vibrationFlag{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            // have something to show that haptics are happening?
            
            //print("vib on")
        } else {
            print("vib off")
        }
        
        animateDice()
    }
    
    // animate dice images
    func animateDice() {
        for (index, imageView) in diceImageViews.enumerated() {
            if diceToAnimate[index] {
                imageView.isHidden = false
                imageView.alpha = 0.0
                imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    imageView.alpha = 1.0
                    imageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                }, completion: { _ in
                    
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                    imageView.transform = CGAffineTransform.identity
                }, completion: nil)
                })
                
            } else {
                imageView.isHidden = true
            }
        }
    }

    // clean out the dice tray and reset the num of values
    @IBAction func resetButtonpressed(_ sender: Any) {
        d4Num.text = "0"
        d6Num.text = "0"
        d8Num.text = "0"
        d10Num.text = "0"
        d12Num.text = "0"
        d20Num.text = "0"
        totalNum.text = "Total:"
        // clear our the tray itself/hide images here
        d4Image.isHidden = true
        d6Image.isHidden = true
        d8Image.isHidden = true
        d10Image.isHidden = true
        d12Image.isHidden = true
        d20Image.isHidden = true
        
        reset.isEnabled = false
        reset.isHidden = true
    }
    
    func showAlert() {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter valid integers in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    
    func playSound(named soundName: String){
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
                //print("Unable to find sound file \(soundName)")
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error.localizedDescription)")
            }
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
}
