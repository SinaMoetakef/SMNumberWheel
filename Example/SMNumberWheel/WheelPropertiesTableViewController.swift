//
//  WheelPropertiesTableViewController.swift
//  SMNumberWheel
//
//  Created by Sina Moetakef on 2017-01-18.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import SMNumberWheel

protocol WheelPropertiesTableViewControllerDelegate: class {
    func getDemoWheelFor(propertyViewController: WheelPropertiesTableViewController) -> SMNumberWheel
}

class WheelPropertiesTableViewController: UITableViewController {
    
    // properties - UI Components
    @IBOutlet weak var autoMinimizeSwitch: UISwitch!
    @IBOutlet weak var autoMinimizeTimeLabel: UILabel!

    @IBOutlet weak var enabledSwitch: UISwitch!
    
    @IBOutlet weak var initialValueTextField: UITextField!
    @IBOutlet weak var lowerLimitTextField: UITextField!
    @IBOutlet weak var upperLimitTextField: UITextField!
    @IBOutlet weak var behaviorOnLimitsSegment: UISegmentedControl!
    @IBOutlet weak var outputTypeSegment: UISegmentedControl!
    @IBOutlet weak var outputPrecisionSegment: UISegmentedControl!
    
    @IBOutlet weak var lockRotationSwitch: UISwitch!
    @IBOutlet weak var decelerateSwitch: UISwitch!
    @IBOutlet weak var ringWidthLabel: UILabel!
    @IBOutlet weak var ringWidthStepper: UIStepper!
    @IBOutlet weak var strokeWidthLabel: UILabel!
    @IBOutlet weak var strokeWidthStepper: UIStepper!
    
    @IBOutlet weak var buttonEnabledSwitch: UISwitch!
    @IBOutlet weak var labelVisibleSwitch: UISwitch!
    @IBOutlet weak var centralLabelTextField: UITextField!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontSizeStepper: UIStepper!
    
    @IBOutlet weak var stepperSwitch: UISwitch!
    @IBOutlet weak var stepValueLabel: UILabel!
    @IBOutlet weak var stepValueStepper: UIStepper!
    
    @IBOutlet weak var majorIndicatorsLabel: UILabel!
    @IBOutlet weak var majorIndicatorsStepper: UIStepper!
    @IBOutlet weak var majorIndicatorSizeLabel: UILabel!
    @IBOutlet weak var majorIndicatorSizeStepper: UIStepper!
    @IBOutlet weak var majorIndicatorTypeSegment: UISegmentedControl!
    
    @IBOutlet weak var minorIndicatorsLabel: UILabel!
    @IBOutlet weak var minorIndicatorsStepper: UIStepper!
    @IBOutlet weak var minorIndicatorSizeLabel: UILabel!
    @IBOutlet weak var minorIndicatorSizeStepper: UIStepper!
    @IBOutlet weak var minorIndicatorTypeSegment: UISegmentedControl!
    
    // properties
    weak var delegate: WheelPropertiesTableViewControllerDelegate?

    // LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            self.updateUIComponentsFrom(wheel: wheel)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ------------------ Setup properties on SMNumberWheel ------------------
    // General
    @IBAction func soundSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.sounds = sender.isOn
        }
    }
    @IBAction func hapticFeedbackSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.hapticFeedback = sender.isOn
        }
    }
    @IBAction func enabledSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.isEnabled = sender.isOn
        }
    }
    @IBAction func autoMinimizeSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.autoMinimize = sender.isOn
        }
    }
    @IBAction func autoMinimizeTime(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.autoMinimizeTime = sender.value
            self.autoMinimizeTimeLabel.text = "\(sender.value) s"
        }
    }

    
    // Design Examples
    @IBAction func designExampleAction(_ sender: UISegmentedControl) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            switch sender.selectedSegmentIndex {
            case 0:
                self.applyDefaultAppearanceOn(wheel: wheel)
            case 1:
                self.applyRedDesignOn(wheel: wheel)
            case 2:
                self.applyGreenDesignOn(wheel: wheel)
            case 3:
                self.applyBrownDesignOn(wheel: wheel)
            case 4:
                self.applyWhiteDesignOn(wheel: wheel)
            default:
                self.applySunDesignOn(wheel: wheel)
            }
            self.updateUIComponentsFrom(wheel: wheel)
        }
    }
    private func applyDefaultAppearanceOn(wheel: SMNumberWheel) {
        wheel.tintColor = UIColor(red: 0.086, green: 0.494, blue: 0.984, alpha: 1.00)
        wheel.ringColor = nil
        wheel.ringColorHighlighted = nil
        wheel.ringColorClockwiseRotation = nil
        wheel.ringColorCounterclockwiseRotation = nil
        wheel.strokeColor = nil
        wheel.strokeColorStateClockwiseRotation = nil
        wheel.strokeColorStateCounterClockwiseRotation = nil
        wheel.strokeColorStateHighlighted = nil
        wheel.buttonBackgroundColorStateNormal = nil
        wheel.buttonBackgroundColorStateHighlighted = nil
        wheel.labelColorStateNormal = nil
        wheel.labelColorStateHighlighted = nil
        wheel.stepperColor = nil
        wheel.stepperBorderColor = nil
        wheel.stepperBackgroundColor = nil
        wheel.stepperBackgroundColorStateHighlighted = nil
        wheel.indicatorColor = nil
        wheel.indicatorColorHighlighted = nil
        wheel.indicatorColorClockwiseRotation = nil
        wheel.indicatorColorCounterClockwiseRotation = nil
        wheel.ringStroke = 1
        wheel.majorIndicators = 4
        wheel.majorIndType = 1
        wheel.majorIndSize = 0
        wheel.minorIndicators = 12
        wheel.minorIndType = 1
        wheel.minorIndSize = 0
        wheel.indicatorStroke = 1
        wheel.indicatorFill = true
        wheel.stepper = true
        wheel.indicatorStroke = 1
        wheel.ringWidth = 0.0
    }
    private func applyRedDesignOn(wheel: SMNumberWheel) {
        self.applyDefaultAppearanceOn(wheel: wheel)
        wheel.ringStroke = 0
        wheel.majorIndicators = 5
        wheel.majorIndType = 2
        wheel.majorIndSize = 37
        wheel.minorIndicators = 40
        wheel.minorIndType = 4
        wheel.minorIndSize = 0
        wheel.indicatorStroke = 1
        wheel.indicatorFill = true
        wheel.tintColor = UIColor(red: 0.902, green: 0.329, blue: 0.435, alpha: 1.00)
    }
    private func applyGreenDesignOn(wheel: SMNumberWheel) {
        self.applyDefaultAppearanceOn(wheel: wheel)
        wheel.ringStroke = 1
        wheel.majorIndicators = 6
        wheel.majorIndType = 2
        wheel.majorIndSize = 37
        wheel.minorIndicators = 18
        wheel.minorIndType = 1
        wheel.minorIndSize = 0
        wheel.indicatorStroke = 1
        wheel.indicatorFill = true
        wheel.tintColor = UIColor(red: 0.259, green: 0.882, blue: 0.722, alpha: 1.00)
        wheel.stepperBackgroundColor = UIColor(red: 0.202, green: 0.687, blue: 0.558, alpha: 1.00)
        wheel.stepperBorderColor = UIColor(red: 0.202, green: 0.687, blue: 0.558, alpha: 1.00)
        wheel.strokeColor = UIColor(red: 0.202, green: 0.687, blue: 0.558, alpha: 1.00)
        wheel.indicatorColor = UIColor(red: 0.202, green: 0.687, blue: 0.558, alpha: 1.00)
        wheel.stepperColor = UIColor.white
        wheel.labelColorStateNormal = UIColor(red: 0.202, green: 0.687, blue: 0.558, alpha: 1.00)
    }
    private func applyBrownDesignOn(wheel: SMNumberWheel) {
        self.applyDefaultAppearanceOn(wheel: wheel)
        wheel.ringStroke = 0
        wheel.majorIndicators = 8
        wheel.majorIndType = 2
        wheel.majorIndSize = 20
        wheel.minorIndicators = 32
        wheel.minorIndType = 2
        wheel.minorIndSize = 4
        wheel.indicatorStroke = 1
        wheel.indicatorFill = true
        wheel.tintColor = UIColor(red: 0.899, green: 0.673, blue: 0.528, alpha: 1.00)
        wheel.buttonBackgroundColorStateNormal = UIColor(red: 0.996, green: 0.962, blue: 0.903, alpha: 1.00)
        wheel.ringWidth = 26.0
    }
    private func applyWhiteDesignOn(wheel: SMNumberWheel) {
        self.applyDefaultAppearanceOn(wheel: wheel)
        wheel.ringStroke = 1
        wheel.majorIndicators = 10
        wheel.majorIndType = 1
        wheel.majorIndSize = 5
        wheel.minorIndicators = 60
        wheel.minorIndType = 3
        wheel.minorIndSize = 5
        wheel.indicatorStroke = 1
        wheel.indicatorFill = true
        wheel.tintColor = UIColor.lightGray
        wheel.ringColor = UIColor.white
        wheel.ringColorHighlighted = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.00)
        wheel.ringColorClockwiseRotation = UIColor(red: 0.9, green: 0.93, blue: 0.91, alpha: 1.00)
        wheel.ringColorCounterclockwiseRotation = UIColor(red: 0.93, green: 0.9, blue: 0.91, alpha: 1.00)
        wheel.buttonBackgroundColorStateNormal = UIColor(red: 0.958, green: 0.958, blue: 0.958, alpha: 1.00)
        wheel.buttonBackgroundColorStateHighlighted = UIColor.lightGray
        wheel.labelColorStateHighlighted = UIColor.darkGray
        wheel.indicatorColor = UIColor.lightGray
        wheel.stepperColor = UIColor.lightGray
        wheel.stepperBackgroundColor = UIColor.white
        wheel.stepperBackgroundColorStateHighlighted = UIColor.darkGray
    }
    private func applySunDesignOn(wheel: SMNumberWheel) {
        self.applyDefaultAppearanceOn(wheel: wheel)
        wheel.ringStroke = 0.5
        wheel.majorIndicators = 8
        wheel.majorIndType = 5
        wheel.majorIndSize = 14
        wheel.minorIndicators = 48
        wheel.minorIndType = 3
        wheel.minorIndSize = 5
        wheel.indicatorStroke = 1
        wheel.indicatorFill = true
        wheel.tintColor = UIColor(red: 0.996, green: 0.745, blue: 0.584, alpha: 1.00)
        wheel.ringColor = UIColor(red: 0.996, green: 0.962, blue: 0.903, alpha: 1.00)
        wheel.indicatorColor = UIColor(red: 0.996, green: 0.757, blue: 0.377, alpha: 1.00)
        wheel.buttonBackgroundColorStateNormal = UIColor(red: 0.996, green: 0.135, blue: 0.344, alpha: 1.00)
        wheel.labelColorStateNormal = UIColor.black
        wheel.indicatorStroke = 1.5
        wheel.buttonBackgroundColorStateHighlighted = UIColor(red: 0.996, green: 0.135, blue: 0.344, alpha: 0.2)
        wheel.labelColorStateHighlighted = UIColor(red: 0.996, green: 0.135, blue: 0.344, alpha: 1.00)
        wheel.stepperColor = UIColor.white
        wheel.stepper = false
    }
    private func updateUIComponentsFrom(wheel: SMNumberWheel) {
        self.initialValueTextField.text = wheel.getDefaultValue() == nil ? nil : "\(wheel.getDefaultValue()!)"
        self.lowerLimitTextField.text = wheel.lowerLimit == nil ? "" : "\(wheel.lowerLimit!)"
        self.upperLimitTextField.text = wheel.upperLimit == nil ? "" : "\(wheel.upperLimit!)"
        self.behaviorOnLimitsSegment.selectedSegmentIndex = wheel.behaviorOnLimits.rawValue
        switch wheel.outputType {
        case .floatingPoint:
            self.outputTypeSegment.selectedSegmentIndex = 1
        case .integer:
            self.outputTypeSegment.selectedSegmentIndex = 0
        }
        self.lockRotationSwitch.isOn = wheel.lockRotation
        self.decelerateSwitch.isOn = wheel.decelerate
        self.autoMinimizeSwitch.isOn = wheel.autoMinimize
        self.buttonEnabledSwitch.isOn = wheel.buttonEnabled
        self.labelVisibleSwitch.isOn = wheel.labelVisible
        self.centralLabelTextField.text = wheel.centralLabelText == nil ? "" : wheel.centralLabelText!
        self.stepperSwitch.isOn = wheel.stepper
        
        self.ringWidthStepper.value = Double(wheel.ringWidth)
        self.ringWidthStepper.minimumValue = 0.0
        self.ringWidthStepper.autorepeat = true
        self.ringWidthLabel.text = wheel.ringWidth == 0.0 ? "Auto" : "\(wheel.ringWidth)"
        
        self.strokeWidthStepper.value = Double(wheel.ringStroke)
        self.strokeWidthStepper.minimumValue = 0.0
        self.strokeWidthStepper.autorepeat = true
        self.strokeWidthLabel.text = "\(wheel.ringStroke)"
        
        self.fontSizeStepper.value = Double(wheel.fontSize)
        self.fontSizeStepper.minimumValue = 0.0
        self.fontSizeStepper.autorepeat = true
        self.fontSizeLabel.text = "\(wheel.fontSize)"
        
        self.stepValueStepper.value = Double(wheel.stepValue)
        self.stepValueStepper.minimumValue = 0.0
        self.stepValueStepper.autorepeat = true
        self.stepValueLabel.text = "\(wheel.stepValue)"
        
        self.majorIndicatorsStepper.value = Double(wheel.majorIndicators)
        self.majorIndicatorsStepper.minimumValue = 0.0
        self.majorIndicatorsStepper.autorepeat = true
        self.majorIndicatorsLabel.text = "\(wheel.majorIndicators)"
        
        self.majorIndicatorTypeSegment.selectedSegmentIndex = wheel.majorIndicatorType.rawValue
        
        self.majorIndicatorSizeStepper.value = Double(wheel.majorIndSize)
        self.majorIndicatorSizeStepper.minimumValue = 0.0
        self.majorIndicatorSizeStepper.autorepeat = true
        self.majorIndicatorSizeLabel.text = wheel.majorIndSize == 0 ? "Auto" : "\(wheel.majorIndSize)"
        
        self.minorIndicatorsStepper.value = Double(wheel.minorIndicators)
        self.minorIndicatorsStepper.minimumValue = 0.0
        self.minorIndicatorsStepper.autorepeat = true
        self.minorIndicatorsLabel.text = "\(wheel.minorIndicators)"
        
        self.minorIndicatorTypeSegment.selectedSegmentIndex = wheel.minorIndicatorType.rawValue
        
        self.minorIndicatorSizeStepper.value = Double(wheel.minorIndSize)
        self.minorIndicatorSizeStepper.minimumValue = 0.0
        self.minorIndicatorSizeStepper.autorepeat = true
        self.minorIndicatorSizeLabel.text = wheel.minorIndSize == 0 ? "Auto" : "\(wheel.minorIndSize)"
        
        self.enabledSwitch.isOn = wheel.isEnabled
    }
    
    // Model Setup
    @IBAction func dfaultValueEntered(_ sender: UITextField) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            if let defaultValue = sender.text?.doubleValue {
                wheel.setDefaultValue(newValue: defaultValue)
            } else {
                wheel.setDefaultValue(newValue: nil)
                sender.text = nil
            }
        }
    }
    @IBAction func lowerLimitEntered(_ sender: UITextField) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.lowerLimit = sender.text?.doubleValue
            if sender.text?.doubleValue == nil {
                sender.text = nil
            }
        }
    }
    @IBAction func upperLimitEntered(_ sender: UITextField) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.upperLimit = sender.text?.doubleValue
            if sender.text?.doubleValue == nil {
                sender.text = nil
            }
        }
    }
    @IBAction func behaviourOnLimitsChanged(_ sender: UISegmentedControl) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            switch sender.selectedSegmentIndex {
            case 0:
                wheel.behaviorOnLimits = .stayAtLimit
            case 1:
                wheel.behaviorOnLimits = .wrap
            default:
                wheel.behaviorOnLimits = .passLimit
            }
        }
    }
    @IBAction func outputTypeChanged(_ sender: UISegmentedControl) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            if sender.selectedSegmentIndex == 0 {
                wheel.outputType = .integer
                self.outputPrecisionSegment.selectedSegmentIndex = 0
                self.outputPrecisionSegment.isEnabled = false
            } else {
                wheel.outputType = .floatingPoint(fractionDigits: UInt8(self.outputPrecisionSegment.selectedSegmentIndex+1))
                self.outputPrecisionSegment.isEnabled = true
            }
        }
    }
    @IBAction func outputPrecisionChanged(_ sender: UISegmentedControl) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.outputType = .floatingPoint(fractionDigits: UInt8(sender.selectedSegmentIndex+1))
        }
    }
    
    // Ring
    @IBAction func lockRotationSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.lockRotation = sender.isOn
        }
    }
    @IBAction func decelerateSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.decelerate = sender.isOn
        }
    }
    @IBAction func ringWidthStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.ringWidth = CGFloat(sender.value)
            if sender.value == 0 {
                self.ringWidthLabel.text = "Auto"
            } else {
                self.ringWidthLabel.text = "\(sender.value)"
            }
        }
    }
    @IBAction func strokeWidthStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.ringStroke = CGFloat(sender.value)
            self.strokeWidthLabel.text = "\(sender.value)"
        }
    }
    
    // Central Button
    @IBAction func buttonEnabledSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.buttonEnabled = sender.isOn
        }
    }
    @IBAction func labelVisibleSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.labelVisible = sender.isOn
        }
    }
    @IBAction func labelTextEntered(_ sender: UITextField) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            var textToSet: String? = nil
            if sender.text != nil && sender.text!.isEmpty == false {
                textToSet = sender.text
            }
            wheel.centralLabelText = textToSet
        }
    }
    @IBAction func fontSizeStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.fontSize = CGFloat(sender.value)
            self.fontSizeLabel.text = "\(sender.value)"
        }
    }
    
    // Stepper
    @IBAction func stepperSwitchAction(_ sender: UISwitch) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.stepper = sender.isOn
        }
    }
    @IBAction func stepValueStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.stepValue = sender.value
            self.stepValueLabel.text = "\(sender.value)"
        }
    }
    
    // Indicators
    @IBAction func majoIndicatorStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.majorIndicators = UInt(sender.value)
            self.majorIndicatorsLabel.text = "\(sender.value)"
        }
    }
    @IBAction func majorIndicatorSizeStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.majorIndSize = CGFloat(sender.value)
            if sender.value == 0 {
                self.majorIndicatorSizeLabel.text = "Auto"
            } else {
                self.majorIndicatorSizeLabel.text = "\(sender.value)"
            }
        }
    }
    @IBAction func majorIndicatorTypeSegmentAction(_ sender: UISegmentedControl) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.majorIndType = sender.selectedSegmentIndex
        }
    }
    @IBAction func minorIndicatorsStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.minorIndicators = UInt(sender.value)
            self.minorIndicatorsLabel.text = "\(sender.value)"
        }
    }
    @IBAction func minorIndicatorSizeStepperAction(_ sender: UIStepper) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.minorIndSize = CGFloat(sender.value)
            if sender.value == 0 {
                self.minorIndicatorSizeLabel.text = "Auto"
            } else {
                self.minorIndicatorSizeLabel.text = "\(sender.value)"
            }
        }
    }
    @IBAction func minorIndicatorTypeSegmentAction(_ sender: UISegmentedControl) {
        if let wheel = self.delegate?.getDemoWheelFor(propertyViewController: self) {
            wheel.minorIndType = sender.selectedSegmentIndex
        }
    }
    
    // Misc
    @IBAction func returnButtonAction(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
}
