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

## Usage

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SMNumberWheel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SMNumberWheel"
```

## Author

Sina Moetakef, sina.moetakef@gmail.com

## License

SMNumberWheel is available under the MIT license. See the LICENSE file for more info.
