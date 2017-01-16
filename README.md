# SMNumberWheel

[![CI Status](http://img.shields.io/travis/Sina Moetakef/SMNumberWheel.svg?style=flat)](https://travis-ci.org/Sina Moetakef/SMNumberWheel)
[![Version](https://img.shields.io/cocoapods/v/SMNumberWheel.svg?style=flat)](http://cocoapods.org/pods/SMNumberWheel)
[![License](https://img.shields.io/cocoapods/l/SMNumberWheel.svg?style=flat)](http://cocoapods.org/pods/SMNumberWheel)
[![Platform](https://img.shields.io/cocoapods/p/SMNumberWheel.svg?style=flat)](http://cocoapods.org/pods/SMNumberWheel)

## Introduction

SMNumberWheel is a custom made control (subclass of UIControl) for iOS, written in Swift, which is ideal for picking numbers instead of typing them by software keyboards. The main idea is to be
able to pick numbers very fast and and yet accurate. The wheel works with reading the angular speed of user's finger. The slower you spin the wheel, the more accurate values are changed (up to 4
fraction digits accurate). The more rotation speed results in exponentially faster value changes.

## Features
- Connecting to code: Target Actions (drag to code) + Delegate methods.
- Built-in buttons: Stepper buttons and central reset button.
- Highly customizable through properties which results in thousands of different designs.
- Renders in InterfaceBuilder, has customizable properties visible with Attributes Inspector (InterfaceBuilder).
- Supports sounds and haptic feedbacks (iPhone 7 and iPhone 7+)
- supports iOS 9.0 and above

## Installation

SMNumberWheel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SMNumberWheel"
```

# Usage
## Adding to InterfaceBuilder
- Add a view to your ViewController/View using InterfaceBuilder
- Setup constranits of the view
- Set the view's class to be SMNumberWheel
- Wait for a moment for the InterfaceBuilder to render the wheel

## Costumizing the Wheel
- Have the view selected.
- There are many properties available on Attributes Inspector section of the Interface Builder that you can change (Colors, Styles, Sizes, ...)

## Connecting to code
Like all other widgets, you can easily drag an outlet from the viewController to your code. In order to connect events, you can use either of the following methods:
- Drag a target action from the viewController to your code and choose `Value Changed` as event type
- implement the delegate methods to get more events.

```swift
extension viewController : SMNumberWheelDelegate {
    func SMNumberWheelDidResetToDefaultValue(_ numberWheel: SMNumberWheel) {
    }
    func SMNumberWheelValueChanged(_ numberWheel: SMNumberWheel) {
    }
    func SMNumberWheelReachedLimit(_ numberWheel: SMNumberWheel, stayedAtLimit: Bool) {
    }
    func SMNumberWheelStepperKeyPressed(_ numberWheel: SMNumberWheel, rightKey: Bool) {
    }
    func SMNumberWheelChangedAppearance(_ numberWheel: SMNumberWheel, minimized: Bool) {
    }
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements


## Author

Sina Moetakef, sina.moetakef@gmail.com

## License

SMNumberWheel is available under the MIT license. See the LICENSE file for more info.
