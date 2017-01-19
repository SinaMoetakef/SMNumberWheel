//
//  ViewController.swift
//  SMNumberWheel
//
//  Created by Sina Moetakef on 01/15/2017.
//  Copyright (c) 2017 Sina Moetakef. All rights reserved.
//

import UIKit
import SMNumberWheel

class ViewController: UIViewController {
    
    // properties
    @IBOutlet weak var demoWheel: SMNumberWheel!
    @IBOutlet weak var demoLabel: UILabel!

    // Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.demoWheel.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Navigation
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardsSegues.fromContainerViewToPropertiesVC {
            // connect propertiesViewController's delegate
            if let propertiesVC = segue.destination as? WheelPropertiesTableViewController {
                propertiesVC.delegate = self
            }
        }
    }

}

extension ViewController : WheelPropertiesTableViewControllerDelegate {
    func getDemoWheelFor(propertyViewController: WheelPropertiesTableViewController) -> SMNumberWheel {
        return self.demoWheel
    }
}

extension ViewController : SMNumberWheelDelegate {
    func SMNumberWheelDidResetToDefaultValue(_ numberWheel: SMNumberWheel) {
        print("Did Reset")
    }
    func SMNumberWheelValueChanged(_ numberWheel: SMNumberWheel) {
        self.demoLabel.text = numberWheel.valueAsString
    }
    func SMNumberWheelReachedLimit(_ numberWheel: SMNumberWheel, stayedAtLimit: Bool) {
        if stayedAtLimit == true {
            print("Stayed at Limit")
        } else {
            print("Reached/Passed Limit")
        }

    }
    func SMNumberWheelStepperKeyPressed(_ numberWheel: SMNumberWheel, rightKey: Bool) {
        if rightKey == true {
            print("Right Stepper Key")
        } else {
            print("Left Stepper Key")
        }
    }
    func SMNumberWheelChangedAppearance(_ numberWheel: SMNumberWheel, minimized: Bool) {
        if minimized == true {
            print("Did minimize")
        } else {
            print("Did Maximize")
        }
    }
}
