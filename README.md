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
## Adding to InterfaceBuilder
After installing the pod:
- Add a view to the ViewController's view hierarchy using InterfaceBuilder
- Setup constranits of the view
- Set the view's class to be SMNumberWheel and choose the ModuleName
- Wait for the InterfaceBuilder to render the wheel

## Customizing the Wheel
- Have the view selected.
- Open Attributes Inspector section
- Change properties available for the wheel like sizes, colors, styles, ...
- The changes will be rendered in InterfaceBuilder.

## Connecting to code
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

## Properties
```swift
// ----- General Properties -----
/** Use different identifiers to identify different controls when using delegation. */
@IBInspectable open var identifier: String = ""
/** Sets lower limit (Minimum value) on the wheel. This is an optional value. Default: nil. */
open var lowerLimit: Double?
/** Sets upper limit (Maximum value) on the wheel. This is an optional value. Default: nil. */
open var upperLimit: Double?
/** Sets the sensitivity of the Wheel. Higher values will result in faster value changings. 
Set it to nil if you want the system to handle it automatically.*/
open var sensitivity: Double?
/** Describes the behavior of control when it's value reaches upper or lower limits. 
Default: .stayAtLimit */
open var behaviorOnLimits: BehaviorOnLimits
/** Describes the output type. (Integer / Floating point with specified number of fraction digits). 
Default: .integer */
open var outputType: ValueType
/** Current value as String respecting output type. READ ONLY */
open var valueAsString: String
/** Current value as Double. READ ONLY */
open var valueAsDouble: Double
/** Current value as Int64. READ ONLY */
open var valueAsInt64: Int64 
/** Plays a tik sound when value changes on integers. default: false */
@IBInspectable open var sounds: Bool
/** Plays a haptic feedback when value changes on integers. 
Available only on iOS 10 and above for iPhone 7, 7+ and later. default: false */
@IBInspectable open var hapticFeedback: Bool
/** By setting it to true all rotation animations and decelerations will be disabled. 
default: false */
@IBInspectable open var lockRotation: Bool
/** Determine if the wheel should continue rotating and decelerating after user lets go of the the wheel. 
default: true */
@IBInspectable open var decelerate: Bool
/** Setting this property to false will eliminate bouncing back of the wheel, when it reaches a limit. 
default: true */
@IBInspectable open var bounceBack: Bool
/** By setting it to true, the control will minimize itself after 1.5 seconds of being idle. 
default: false */
@IBInspectable open var autoMinimize: Bool
/** Enable/Disable control. Changes to the control are animated. 
For non-animated settings, use userInteractionEnabled property instead. */
override open var isEnabled: Bool

// ----- Ring Properties -----
/** Set the width of rotating ring. Set it to 0.0 to let the system pick the best width automatically. */
@IBInspectable open var ringWidth: CGFloat
/** Set the outer Stroke Width for ring. Default: 1.0 */
@IBInspectable open var ringStroke: CGFloat
/** Set the outer Stroke Color for ring when control is in highlighted state. */
open var strokeColorStateHighlighted: UIColor?
/** Set the outer Stroke Color for ring when user is rotating his/her finger on wheel. (Clockwise). */
open var strokeColorStateClockwiseRotation: UIColor?
/** Set the outer Stroke Color for ring when user is rotating his/her finger on wheel. (Counter Clockwise). */
open var strokeColorStateCounterClockwiseRotation: UIColor?
/** Set fill color of the ring. Default: Tint color. This value is optional. */
@IBInspectable open var ringColor: UIColor?
/** Set ring's outer Stroke Color. Default: Tint color. This value is optional. */
@IBInspectable open var strokeColor: UIColor?
/** Set fill color of the ring for highlighted state. This value is optional. */
open var ringColorHighlighted: UIColor?
/** Set fill color of the ring when user is rotating his/her finger on wheel. (Clockwise). */
open var ringColorClockwiseRotation: UIColor?
/** Set fill color of the ring when user is rotating his/her finger on wheel. (Counter Clockwise). */
open var ringColorCounterclockwiseRotation: UIColor?

// ----- Central Button properties -----
/** Enable/Disable the central button. Default: true */
@IBInspectable open var buttonEnabled: Bool
/** Set fill color of central button for normal state. 
Default: background color of view. This value is optional */
@IBInspectable open var buttonBackgroundColorStateNormal: UIColor?
/** Set fill color of central button for highlighted state. 
This value is optional. */
open var buttonBackgroundColorStateHighlighted: UIColor?
/** Sets the string to be shown at the center of control. 
This string will be shown instead of current value. Set it to nil to show the current value. 
System will reduce the size of text automatically to fit in the central area. */
open var centralLabelText: String?
/** Set visibility of central label. Default: true */
@IBInspectable open var labelVisible: Bool
/** Font size for central Button. Default: 32. 
If the text doesn't fit in center area, system will auto-reduce the font size. */
@IBInspectable open var fontSize: CGFloat
/** Set color for central label in normal state. Default: Tint color */
@IBInspectable open var labelColorStateNormal: UIColor?
/** Set color for central label in highlighted state. 
Default: background color of view. This value is optional. */
open var labelColorStateHighlighted: UIColor?

// ----- Stepper properties -----
/** Set the visibility of steppers on top of the control. Default value: true */
@IBInspectable open var stepper: Bool
/** Amount of value change when user presses stepper buttons. default: 1.0 */
@IBInspectable open var stepValue: Double
/** Sets the color of steppers. Default: white color. This value is optional. */
@IBInspectable open var stepperColor: UIColor?
/** Sets the background color for Steppers area. Default: tint color. 
This value is optional. */
@IBInspectable open var stepperBackgroundColor: UIColor?
/** Sets the background color for Steppers area when steppers are highlighted. 
Default: tint color. This value is optional. */
open var stepperBackgroundColorStateHighlighted: UIColor?
/** Sets the stroke color of stepper area. This value is optional. */
@IBInspectable open var stepperBorderColor: UIColor?

// ----- Ring Indicators -----
/** Set the outer Stroke Width of indicators. Default: 1.0 */
open var indicatorStroke: CGFloat
/** Number of major indicators shown on the ring. Default: 4 */
@IBInspectable open var majorIndicators: UInt
/** 
Type of major Indicators. Between 0 and 5. Default: 1 = circular. 
You can also set majorIndicatorType property directly in code using IndicatorType enum.
0 = IndicatorType.none
1 = IndicatorType.circular
2 = IndicatorType.linearCenter
3 = IndicatorType.linearInnerStroke
4 = IndicatorType.linearOuterStroke
5 = IndicatorType.diamond
*/
@IBInspectable open var majorIndType: Int
/** Set size of major indicators. Set it to 0.0 for automatic calculation. Default: 0.0  */
@IBInspectable open var majorIndSize: CGFloat
/** Number of minor indicators shown on the ring. Default: 12 */
@IBInspectable open var minorIndicators: UInt
/** 
Type of minor Indicators. Between 0 and 5. Default: 1 = circular. 
You can also set majorIndicatorType property directly in code using IndicatorType enum. 
0 = IndicatorType.none
1 = IndicatorType.circular
2 = IndicatorType.linearCenter
3 = IndicatorType.linearInnerStroke
4 = IndicatorType.linearOuterStroke
5 = IndicatorType.diamond
*/
@IBInspectable open var minorIndType: Int 
/** Set size of minor indicators. Set it to 0.0 for automatic calculation. Default: 0.0 */
@IBInspectable open var minorIndSize: CGFloat
/** Set indicator color. Default: White color. This value is optional. */
@IBInspectable open var indicatorColor: UIColor?
/** By setting it to false only the border of indicators will be drawn. */
@IBInspectable open var indicatorFill: Bool
/** Set indicator color when control is in highlighted state. This value is optional. */
open var indicatorColorHighlighted: UIColor?
/** Set indicator color when user is rotating his/her finger on wheel. (Clockwise). 
This value is optional. */
open var indicatorColorClockwiseRotation: UIColor?
/** set indicator color when user is rotating his/her finger on wheel. (Counter Clockwise). 
This value is optional. */
open var indicatorColorCounterClockwiseRotation: UIColor?
/** Set shape of minor indicators. Default: .circular */
open var minorIndicatorType: IndicatorType
/** Set shape of major indicators. Default: .circular */
open var majorIndicatorType: IndicatorType

// ----- Delegate -----
/** use this Delegate to connect this control to your code. 
You should implement all methods of the protocol within receiver's class. */
open weak var delegate: SMNumberWheelDelegate?

```

## Methods
```swift
/** Rotates indicators with desired angle (Radians) in desired direction.  */
open func rotateIndicatorsLayer(angle: CGFloat, animated: Bool = false)
/** Rotates indicators to their initial position.  */
open func rotateIndicatorsToInitial()
/** Stops the rotation of wheel if it is in deceleration mode. */
open func stopRotation()
/** Forces wheel to minimize itself. */
open func minimizeWheel()
/** Forces wheel to restore to full size. 
If Auto Minimize is set to true, the wheel will auto-minimize itself after 1.5 seconds being idle. */
open func maximizeWheel()
/** Increase/Decrease the current value by stepperValue. 
Animations should be handeled manually using rotateIndicatorsLayer(#angle: CGFloat, animated: Bool) function. 
Returns false if new value is out of range. */
open func shiftValue(increment: Bool) -> Bool
/** Sets the default value of the Wheel. This value is optional. 
If the default value is outside of range of lower limit and higher limit, it will take the nearest limit. 
If instead of the provided value the nearest limit is picked the function returns false. */
open func setDefaultValue(newValue: Double?) -> Bool
/** returns the default value set on the wheel */
open func getDefaultValue() -> Double?
/** Sets the current value to a new Value. 
Animations should be handeled manually using rotateIndicatorsLayer(#angle: CGFloat, animated: Bool) function. 
Returns false if new value is out of range. */
open func setValue(newValue: Double) -> Bool
/** Sets the current value to default Value (if the default value is set before). 
Animations should be handeled manually using rotateIndicatorsLayer(#angle: CGFloat, animated: Bool) function. */
open func resetToDefaultValue()
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Sina Moetakef, sina.moetakef@gmail.com

## License

SMNumberWheel is available under the MIT license. See the LICENSE file for more info.
