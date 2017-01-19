# SMNumberWheel
version 1.0.0

[![CI Status](http://img.shields.io/travis/Sina Moetakef/SMNumberWheel.svg?style=flat)](https://travis-ci.org/Sina Moetakef/SMNumberWheel)
[![Version](https://img.shields.io/cocoapods/v/SMNumberWheel.svg?style=flat)](http://cocoapods.org/pods/SMNumberWheel)
[![License](https://img.shields.io/cocoapods/l/SMNumberWheel.svg?style=flat)](http://cocoapods.org/pods/SMNumberWheel)
[![Platform](https://img.shields.io/cocoapods/p/SMNumberWheel.svg?style=flat)](http://cocoapods.org/pods/SMNumberWheel)

## Introduction

SMNumberWheel is a custom made control (subclass of UIControl) for iOS, written in Swift, which is ideal for picking numbers instead of typing them by software keyboards. The main idea is to be
able to pick numbers very fast and and yet accurate. The wheel works with reading the angular speed of user's finger. The slower you spin the wheel, the more accurate values are changed (up to 4
fraction digits accurate). The more rotation speed results in exponentially faster value changes.

![alt tag] (https://github.com/SinaMoetakef/SMNumberWheel/blob/master/Example/SMNumberWheel/SMNumberWheel.png)

## Features
- Highly customizable through properties which results in thousands of different designs.
- Renders in InterfaceBuilder, has customizable properties visible with Attributes Inspector (InterfaceBuilder).
- Supports sounds and haptic feedbacks (iPhone 7 and iPhone 7+)
- Built-in buttons: Stepper buttons and central reset button.
- supports iOS 9.0 and above

## Installation

SMNumberWheel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SMNumberWheel"
```

## Video links
- [Demonstration] (https://youtu.be/DIWpGOlDGOw)
- [Customizing the wheel] (https://youtu.be/NTEsCepLYBY)
- [Connecting to code] (https://youtu.be/r_eG3oPFMfk)

# Usage
## Adding from code
Sample code:
``` swift
let wheel = SMNumberWheel(frame: CGRect(x: 100, y: 100, width: 180, height: 180))
wheel.majorIndicators = 4
wheel.majorIndicatorType = .diamond
wheel.minorIndicatorType = .none
wheel.ringColor = UIColor.red
wheel.strokeColor = UIColor.red
wheel.stepper = false
wheel.hapticFeedback = true
// continue setting up the properties ...
wheel.delegate = self
self.view.addSubview(wheel)
```

## Adding from InterfaceBuilder
After installing the pod:
- Add a view to the ViewController's view hierarchy using InterfaceBuilder
- Setup constranits of the view
- Set the view's class to be SMNumberWheel and choose the ModuleName
- Wait for the InterfaceBuilder to render the wheel

## Customizing the Wheel using InterfaceBuilder
- Have the view selected.
- Open Attributes Inspector section
- Change properties available for the wheel like sizes, colors, styles, ...
- The changes will be rendered in InterfaceBuilder.

## Connecting to code and receive events
Like all other widgets, you can easily drag an `outlet` from the viewController to your code. In order to connect events, you can use either of the following methods:
- Drag a target action from the viewController to your code and choose `Value Changed` as event type
- implement the delegate methods to get more events.

```swift
extension viewController : SMNumberWheelDelegate {
    func SMNumberWheelDidResetToDefaultValue(_ numberWheel: SMNumberWheel) {
        // Happens when the central button is tapped and the wheel is set to it's initial value
    }
    func SMNumberWheelValueChanged(_ numberWheel: SMNumberWheel) {
        // Happens when the value of the wheel changes.
    }
    func SMNumberWheelReachedLimit(_ numberWheel: SMNumberWheel, stayedAtLimit: Bool) {
        // Notifies the developer that the value of the wheel has reached one of the limits.
    }
    func SMNumberWheelStepperKeyPressed(_ numberWheel: SMNumberWheel, rightKey: Bool) {
        // Notifies that a tap on one of the stepper keys is detected. 
        // rightKey == true -> tapped on right key, otherwise tapped on the left key.
    }
    func SMNumberWheelChangedAppearance(_ numberWheel: SMNumberWheel, minimized: Bool) {
        // Notifies the developer that the visual state of the wheel is changed (minimized or maximized).
    }
}
```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Sina Moetakef, sina.moetakef@gmail.com

## License

SMNumberWheel is available under the MIT license. See the LICENSE file for more info.
