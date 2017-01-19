//
//  SMNumberWheel.swift
//  SMNumberWheel
//
//  Created by Sina Moetakef on 2015-05-04.
//  Copyright (c) 2015 Sina Moetakef. All rights reserved.
//

import UIKit
import AudioToolbox


public protocol SMNumberWheelDelegate: class {
    func SMNumberWheelDidResetToDefaultValue(_ numberWheel: SMNumberWheel)
    func SMNumberWheelValueChanged(_ numberWheel: SMNumberWheel)
    func SMNumberWheelReachedLimit(_ numberWheel: SMNumberWheel, stayedAtLimit: Bool)
    func SMNumberWheelStepperKeyPressed(_ numberWheel: SMNumberWheel, rightKey: Bool)
    func SMNumberWheelChangedAppearance(_ numberWheel: SMNumberWheel, minimized: Bool)
}

@IBDesignable open class SMNumberWheel: UIControl {
    
    // MARK: enums
    /** Used to describe the behavior of control when reaching limits set by user. When a limit is reached the SMNumberWheelReachedLimit(...) from delegate will be called. */
    public enum BehaviorOnLimits: Int {
        case stayAtLimit = 0
        case wrap        = 1
        case passLimit   = 2
    }
    /** Used to Set the value type for central label and valueAsString property of the control. */
    public enum ValueType {
        case floatingPoint (fractionDigits: UInt8)
        case integer
    }
    /** Used to set the shape of indicators. */
    public enum IndicatorType: Int {
        case none              = 0
        case circular          = 1
        case linearCenter      = 2
        case linearInnerStroke = 3
        case linearOuterStroke = 4
        case diamond           = 5
    }
    fileprivate enum SMNumberWheelComponents {
        case ring
        case centralButton
        case topIndicator
        case forwardButton
        case backwardButton
    }
    fileprivate enum SMNumberWheelComponentState: Int {
        case normal                   = 0
        case highlighted              = 1
        case disabled                 = 2
        case clockwiseRotation        = 3
        case counterClockwiseRotation = 4
    }
    fileprivate enum SMNumberWheelRotation: Int {
        case clockwise        = 1
        case idle             = 0
        case counterClockwise = -1
    }
    
    // MARK: properties
    fileprivate let π: CGFloat = CGFloat(M_PI)
    
    // MARK: NumberWheel Settings
    // ----------------------------------------------------------------------------
    /** Use different identifiers to identify different controls when using delegation. */
    @IBInspectable open var identifier: String = ""
    /** Sets the Default value. If set outside of lower and upper limit ranges, it will extend the range in calculations. By default: 0.0 */
    fileprivate var defaultValue: Double? {
        didSet {
            if let value = self.defaultValue {
                if self.currentStringOnLabel == nil {
                    self.currentValue = value
                    self.updateLabelLayer()
                }
            }
        }
    }
    /** Sets lower limit (Minimum value) of the value. This is an optional value. Default: nil. If after setting the default value gets out of limits, the default value will also get updated. */
    open var lowerLimit: Double? {
        didSet {
            if let min = self.lowerLimit, let defVal = self.defaultValue {
                self.defaultValue = max(min, defVal)
            }
        }
    }
    /** Sets upper limit (Maximum value) of the value. This is an optional value. Default: nil. If after setting the default value gets out of limits, the default value will also get updated. */
    open var upperLimit: Double? {
        didSet {
            if let max = self.upperLimit, let defVal = self.defaultValue {
                self.defaultValue = min(max, defVal)
            }
        }
    }
    /** Sets the sensitivity of Wheel. Higher values will result in faster value changings. Set it to nil to let the system handle it.*/
    open var sensitivity: Double?
    /** Describes the behavior of control when it's value reaches upper or lower limits. Default: .stayAtLimit */
    open var behaviorOnLimits: BehaviorOnLimits = BehaviorOnLimits.stayAtLimit
    /** Describes the output type. (Integer / Floating point with specified number of fraction digits). Default: .integer */
    open var outputType: ValueType = ValueType.integer { didSet {self.updateLabelLayer()} }
    /** Current value as String respecting output type. */
    open var valueAsString: String {
        var vString = ""
        switch self.outputType {
        case .integer:
            vString =  "\(Int64(round(self.currentValue)))"
        case .floatingPoint(let fractionDigits):
            vString =  String(format: "%.\(fractionDigits)f", self.currentValue)
        }
        return vString
    }
    /** Current value as Double */
    open var valueAsDouble: Double { return self.currentValue }
    /** Current value as Int64 */
    open var valueAsInt64: Int64 { return Int64(round(self.currentValue)) }
    
    fileprivate var currentValue: Double = 0.0
    fileprivate var previousValue: Double = 0.0
    fileprivate var currentStringOnLabel: String?
    
    // MARK: Ring Properties
    // ----------------------------------------------------------------------------
    /** Plays a tik sound when value changes on integers */
    @IBInspectable open var sounds: Bool = false
    /** Plays a haptic feedback when value changes on integers. Available only on iOS 10 and above for iPhone 7, 7+ and later. */
    @IBInspectable open var hapticFeedback = false
    /** By setting it to true all rotation animations and decelerations will be disabled. */
    @IBInspectable open var lockRotation: Bool = false
    /** Determine if the wheel should continue rotating and decelerating after user spins the wheel.*/
    @IBInspectable open var decelerate: Bool = true {
        didSet {
            if self.decelerate == false { self.stopRotation() }
        }
    }
    /** Setting this property to false will eliminate bouncing back of the wheel, when it reaches a limit, and it has to stay at that limit. */
    @IBInspectable open var bounceBack: Bool = true
    /** By setting it to true, the control will minimize itself after 1.5 seconds being idle. */
    @IBInspectable open var autoMinimize: Bool = false {
        didSet {
            if self.autoMinimize == true {
                if self.deceleration == false {
                    self.autoMinimizeTimer =  Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(SMNumberWheel.minimizeWheel), userInfo: nil, repeats: false)
                }
            } else {
                if self.isEnabled == true { self.maximizeWheel() }
            }
        }
    }
    /** Set the width of rotating ring. Set it to 0.0 to let the system pick the best width automatically. */
    @IBInspectable open var ringWidth: CGFloat = 0 {
        didSet {
            self.updateGeometryVariables()
            self.calculateAllPaths()
            self.updateLayers()
        }
    }
    /** Set the outer Stroke Width for ring. Default: 1.0 */
    @IBInspectable open var ringStroke: CGFloat = 1.0 {didSet {
        self.ringDrawableWidth = self.calculateRingDrawableWidth()
        self.updateLayers()
        }
    }
    /** Set the outer Stroke Color for ring when control is in highlighted state. This value is optional. */
    open var strokeColorStateHighlighted: UIColor? = nil {
        didSet {
            self.calculateRingStrokeColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set the outer Stroke Color for ring when user is rotating his/her finger on wheel. (Clockwise). This value is optional. */
    open var strokeColorStateClockwiseRotation: UIColor? = nil {
        didSet {
            self.calculateRingStrokeColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set the outer Stroke Color for ring when user is rotating his/her finger on wheel. (Counter Clockwise). This value is optional. */
    open var strokeColorStateCounterClockwiseRotation: UIColor? = nil {
        didSet {
            self.calculateRingStrokeColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set fill color of the ring. Default: Tint color. This value is optional. */
    @IBInspectable open var ringColor: UIColor? = nil {
        didSet {
            self.calculateRingFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set ring's outer Stroke Color. Default: Tint color. This value is optional. */
    @IBInspectable open var strokeColor: UIColor? = nil {
        didSet {
            self.calculateRingStrokeColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set fill color of the ring for highlighted state. This value is optional. */
    open var ringColorHighlighted: UIColor? = nil {
        didSet {
            self.calculateRingFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set fill color of the ring when user is rotating his/her finger on wheel. (Clockwise). This value is optional. */
    open var ringColorClockwiseRotation: UIColor? = nil {
        didSet {
            self.calculateRingFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set fill color of the ring when user is rotating his/her finger on wheel. (Counter Clockwise). This value is optional. */
    open var ringColorCounterclockwiseRotation: UIColor? = nil {
        didSet {
            self.calculateRingFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    fileprivate var ringState: SMNumberWheelComponentState = SMNumberWheelComponentState.normal {didSet {self.updateLayerColors(animated: true)}}
    
    // MARK: Haptic engine properties.
    fileprivate var _feedbackGenerator: Any?
    @available(iOS 10,*)
    fileprivate var feedbackGenerator: UIImpactFeedbackGenerator? {
        get {
            return _feedbackGenerator as? UIImpactFeedbackGenerator
        }
        set {
            _feedbackGenerator = newValue
        }
    }
    
    // MARK: Central button properties
    // ----------------------------------------------------------------------------
    /** Enable/Disable the central button. Default: enabled */
    @IBInspectable open var buttonEnabled: Bool = true {
        didSet {
            self.calculateCentralButtonFillColor()
            self.calculateLabelColor()
            if self.buttonEnabled == false {
                self.buttonState = SMNumberWheelComponentState.disabled
            } else {
                self.buttonState = SMNumberWheelComponentState.normal
            }
        }
    }
    /** Set fill color of central button for normal state. Default: background color of view. This value is optional */
    @IBInspectable open var buttonBackgroundColorStateNormal: UIColor? = nil {
        didSet {
            self.calculateCentralButtonFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set fill color of central button for highlighted state. This value is optional. */
    open var buttonBackgroundColorStateHighlighted: UIColor? = nil {
        didSet {
            self.calculateCentralButtonFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    fileprivate var buttonState: SMNumberWheelComponentState = SMNumberWheelComponentState.normal {didSet {self.updateLayerColors(animated: true)}}
    
    // MARK: Central Label
    // ----------------------------------------------------------------------------
    /** Sets the string to be shown at the center of control. This string will be shown instead of current value. Set it to nil to show the current value. System will reduce the size of text automatically to fit in the central area. */
    open var centralLabelText: String? { didSet {self.updateLabelLayer()} }
    /** Set visibility of central label. Default: true */
    @IBInspectable open var labelVisible: Bool = true {
        didSet {
            if self.labelVisible == true {
                self.labelLayer.isHidden = false
                self.updateLabelLayer()
            } else {
                self.labelLayer.isHidden = true
            }
        }
    }
    /** Font size for central Button. Default: 32. If the text doesn't fit in center area, system will auto-reduce the font size. */
    @IBInspectable open var fontSize: CGFloat = 32 {didSet {self.updateLabelLayer()}}
    /** Set color for central label in normal state. Default: Tint color */
    @IBInspectable open var labelColorStateNormal: UIColor? = nil {
        didSet {
            self.calculateLabelColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set color for central label in highlighted state. Default: background color of view. This value is optional. */
    open var labelColorStateHighlighted: UIColor? = nil {
        didSet {
            self.calculateLabelColor()
            self.updateLayerColors(animated: true)
        }
    }
    fileprivate var labelFont: UIFont { return UIFont.systemFont(ofSize: self.fontSize) }
    
    // MARK: Stepper
    // ----------------------------------------------------------------------------
    /** Set the visibility of steppers on top of the control. Default value: true */
    @IBInspectable open var stepper: Bool = true {
        didSet {
            if self.stepper == true {
                if self.isMinimized == false {
                    self.topIndicatorLayer.isHidden = false
                    self.topIndicatorAreaLayer.isHidden = false
                }
            } else {
                self.topIndicatorLayer.isHidden = true
                self.topIndicatorAreaLayer.isHidden = true
            }
        }
    }
    /** Amount of change in value when user presses stepper buttons. */
    @IBInspectable open var stepValue: Double = 1.0
    /** Sets the color of steppers. Default: white color. This value is optional. */
    @IBInspectable open var stepperColor: UIColor? = nil {
        didSet { self.updateLayerColors(animated: true) }
    }
    /** Sets the background color for Steppers area. Default: tint color. This value is optional. */
    @IBInspectable open var stepperBackgroundColor: UIColor? {
        didSet {
            self.calculateTopIndicatorFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Sets the background color for Steppers area when steppers are highlighted. Default: tint color. This value is optional. */
    open var stepperBackgroundColorStateHighlighted: UIColor? {
        didSet {
            self.calculateTopIndicatorFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Sets the stroke color of stepper area. This value is optional. */
    @IBInspectable open var stepperBorderColor: UIColor? {
        didSet {
            self.calculateTopIndicatorStrokeColor()
            self.updateLayerColors(animated: true)
        }
    }
    fileprivate var stepperState: SMNumberWheelComponentState = SMNumberWheelComponentState.normal {didSet {self.updateLayerColors(animated: true)}}
    
    // MARK: Indicators
    // ----------------------------------------------------------------------------
    /** Set the outer Stroke Width for indicators. Default: 1.0 */
    open var indicatorStroke: CGFloat = 1.0 {didSet {self.updateLayerWidths()}}
    /** Number of major indicators shown on the ring. Default: 4 */
    @IBInspectable open var majorIndicators: UInt = 4 {
        didSet {
            self.pathForRingIndicators = self.calculatePathForRingIndicators()
            self.updateLayerPaths()
        }
    }
    /** Type of major Indicators. Between 0 and 5. Default: 1 = circular. You can also set majorIndicatorType property directly in code. */
    @IBInspectable open var majorIndType: Int = 1 {
        didSet {
            var type = IndicatorType.none
            switch self.majorIndType {
            case 0:
                type = IndicatorType.none
            case 1:
                type = IndicatorType.circular
            case 2:
                type = IndicatorType.linearCenter
            case 3:
                type = IndicatorType.linearInnerStroke
            case 4:
                type = IndicatorType.linearOuterStroke
            case 5:
                type = IndicatorType.diamond
            default:
                type = IndicatorType.none
            }
            self.majorIndicatorType = type
        }
    }
    /** Set size of major indicators. Set it to ZERO for automatic calculation. Default: 0.0  */
    @IBInspectable open var majorIndSize: CGFloat = 0.0 {
        didSet {
            self.pathForRingIndicators = self.calculatePathForRingIndicators()
            self.updateLayerPaths()
        }
    }
    /** Number of minor indicators shown on the ring. Default: 12 */
    @IBInspectable open var minorIndicators: UInt = 12 {
        didSet {
            self.pathForRingIndicators = self.calculatePathForRingIndicators()
            self.updateLayerPaths()
        }
    }
    /** Type of minor Indicators. Between 0 and 5. Default: 1 = circular. You can also set majorIndicatorType property directly in code. */
    @IBInspectable open var minorIndType: Int = 1 {
        didSet {
            var type = IndicatorType.none
            switch self.minorIndType {
            case 0:
                type = IndicatorType.none
            case 1:
                type = IndicatorType.circular
            case 2:
                type = IndicatorType.linearCenter
            case 3:
                type = IndicatorType.linearInnerStroke
            case 4:
                type = IndicatorType.linearOuterStroke
            case 5:
                type = IndicatorType.diamond
            default:
                type = IndicatorType.none
            }
            self.minorIndicatorType = type
        }
    }
    /** Set size of minor indicators. Set it to ZERO for automatic calculation. Default: 0.0 */
    @IBInspectable open var minorIndSize: CGFloat = 0.0 {
        didSet {
            self.pathForRingIndicators = self.calculatePathForRingIndicators()
            self.updateLayerPaths()
        }
    }
    /** Set indicator color. Default: White color. This value is optional. */
    @IBInspectable open var indicatorColor: UIColor? = nil {
        didSet {
            self.calculateIndicatorFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** By setting it to false only the border of indicators will be drawn. */
    @IBInspectable open var indicatorFill: Bool = true {
        didSet {
            self.updateLayerColors(animated: true)
        }
    }
    /** Set indicator color when control is in highlighted state. This value is optional. */
    open var indicatorColorHighlighted: UIColor? = nil {
        didSet {
            self.calculateIndicatorFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set indicator color when user is rotating his/her finger on wheel. (Clockwise). This value is optional. */
    open var indicatorColorClockwiseRotation: UIColor? = nil {
        didSet {
            self.calculateIndicatorFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** set indicator color when user is rotating his/her finger on wheel. (Counter Clockwise). This value is optional. */
    open var indicatorColorCounterClockwiseRotation: UIColor? = nil {
        didSet {
            self.calculateIndicatorFillColor()
            self.updateLayerColors(animated: true)
        }
    }
    /** Set shape of minor indicators. Default: .circular */
    open var minorIndicatorType: IndicatorType = IndicatorType.circular {
        didSet {
            self.pathForRingIndicators = self.calculatePathForRingIndicators()
            self.updateLayerPaths()
        }
    }
    /** Set shape of major indicators. Default: .circular */
    open var majorIndicatorType: IndicatorType = IndicatorType.circular {
        didSet {
            self.pathForRingIndicators = self.calculatePathForRingIndicators()
            self.updateLayerPaths()
        }
    }
    fileprivate var allIndicators: UInt { return self.minorIndicators + self.majorIndicators }
    
    // MARK: Layers
    // ----------------------------------------------------------------------------
    fileprivate var ringLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var ringStrokeLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var centralButtonLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var topIndicatorAreaLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var topIndicatorLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var indicatorsLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var labelLayer: CATextLayer = CATextLayer()
    
    // MARK: Calculated Geometry variables
    // ----------------------------------------------------------------------------
    fileprivate var centerPoint: CGPoint = CGPoint()
    fileprivate var ringOuterRadius: CGFloat = 0.0
    fileprivate var ringDefaultWidth: CGFloat = 0.0
    fileprivate var ringInnerRadius: CGFloat = 0.0
    fileprivate var ringDrawableWidth: CGFloat = 0.0
    fileprivate var topIndicatorWidth: CGFloat = 0.0
    
    // MARK: Calculated Color variables
    // ----------------------------------------------------------------------------
    fileprivate var ringStrokeColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor(), UIColor()]
    fileprivate var ringFillColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor(), UIColor()]
    fileprivate var centralButtonFillColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor(), UIColor()]
    fileprivate var indicatorFillColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor(), UIColor()]
    fileprivate var labelColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor(), UIColor()]
    fileprivate var topIndicatorFillColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor(), UIColor()]
    fileprivate var topIndicatorStrokeColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor(), UIColor()]
    
    // MARK: Calculated path variables
    // ----------------------------------------------------------------------------
    fileprivate var pathsForRing: (forStroke: UIBezierPath, forFill: UIBezierPath, forCalculations: UIBezierPath) = (UIBezierPath(), UIBezierPath(), UIBezierPath())
    fileprivate var pathForCentralButton: UIBezierPath = UIBezierPath()
    fileprivate var pathForTopIndicator: UIBezierPath = UIBezierPath()
    fileprivate var pathForTopIndicatorArea: (forDraw: UIBezierPath, forward: UIBezierPath, backward: UIBezierPath) = (UIBezierPath(), UIBezierPath(), UIBezierPath())
    fileprivate var pathForRingIndicators: UIBezierPath = UIBezierPath()
    
    // MARK: Misc
    // ----------------------------------------------------------------------------
    fileprivate var lastTouchTime: CFTimeInterval = CACurrentMediaTime()
    fileprivate var touchedComponent: SMNumberWheelComponents?
    fileprivate var currentAngularSpeed: Double = 0.0
    fileprivate var displayTimer: CADisplayLink?
    fileprivate var rotation: SMNumberWheelRotation = SMNumberWheelRotation.clockwise
    fileprivate var deceleration: Bool = false
    fileprivate var indicatorsTransform : CATransform3D = CATransform3D()
    fileprivate var isMinimized: Bool = false
    fileprivate var autoMinimizeTimer: Timer = Timer()
    fileprivate var lastValue: Double = 0.0
    
    // MARK: Wiring up (Delegation)
    // ----------------------------------------------------------------------------
    /** use this Delegate to connect this control to your code. You should implement all methods of the protocol within receiver's class. */
    open weak var delegate: SMNumberWheelDelegate?
    
    // MARK: Overrided variables
    // ----------------------------------------------------------------------------
    override open var bounds: CGRect {
        didSet {
            self.updateGeometryVariables()
            self.updateLayerFrames(self.frame)
            self.updateLayerBounds(self.bounds)
            self.calculateAllPaths()
            self.updateLayerPaths()
            self.updateLayerWidths()
        }
    }
    override open var frame: CGRect {
        didSet {
            self.updateGeometryVariables()
            self.updateLayerFrames(self.frame)
            self.updateLayerBounds(self.bounds)
            self.calculateAllPaths()
            self.updateLayerPaths()
            self.updateLayerWidths()
        }
    }
    /** Enable/Disable control. Changes to the control are animated. For non-animated settings, use userInteractionEnabled property instead. */
    override open var isEnabled: Bool {
        didSet {
            if self.isEnabled == true {
                if self.autoMinimize == false {
                    self.maximizeWheel()
                }
                self.isUserInteractionEnabled = true
                self.labelLayer.opacity = 1.0
                if self.isMinimized == true {
                    self.ringStrokeLayer.fillColor = self.centralButtonFillColor[0].cgColor
                }
            } else {
                self.minimizeWheel()
                self.isUserInteractionEnabled = false
                if buttonState != SMNumberWheelComponentState.disabled {
                    self.labelLayer.opacity = 0.3
                }
                self.ringStrokeLayer.fillColor = self.centralButtonFillColor[2].cgColor
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    // MARK: Methods
    // ----------------------------------------------------------------------------
    
    // MARK: Initializers
    // ----------------------------------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.calculateRingStrokeColor()
        self.calculateRingFillColor()
        self.calculateCentralButtonFillColor()
        self.calculateIndicatorFillColor()
        self.calculateLabelColor()
        self.calculateTopIndicatorFillColor()
        self.calculateTopIndicatorStrokeColor()
        
        self.addSubLayersToView()
        if let defValue = self.defaultValue {
            self.currentValue = defValue
        }
        
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.calculateRingStrokeColor()
        self.calculateRingFillColor()
        self.calculateCentralButtonFillColor()
        self.calculateIndicatorFillColor()
        self.calculateLabelColor()
        self.calculateTopIndicatorFillColor()
        self.calculateTopIndicatorStrokeColor()
        
        self.addSubLayersToView()
        if let defValue = self.defaultValue {
            self.currentValue = defValue
        }
    }
    override open func tintColorDidChange() {
        self.calculateRingStrokeColor()
        self.calculateRingFillColor()
        self.calculateIndicatorFillColor()
        self.calculateLabelColor()
        self.calculateTopIndicatorFillColor()
        self.calculateTopIndicatorStrokeColor()
        self.updateLayerColors(animated: true)
        if self.isMinimized == true {
            self.ringStrokeLayer.lineWidth = 1.25
        }
    }
    
    // MARK: User Interaction
    // ----------------------------------------------------------------------------
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.autoMinimizeTimer.invalidate()
        let touchedPoint = touch.location(in: self)
        self.lastTouchTime = CACurrentMediaTime()
        if self.touchedComponent == nil && self.pathForTopIndicatorArea.forward.contains(touchedPoint) {
            self.touchedComponent = SMNumberWheelComponents.forwardButton
        }
        if self.touchedComponent == nil && self.pathForTopIndicatorArea.backward.contains(touchedPoint) {
            self.touchedComponent = SMNumberWheelComponents.backwardButton
        }
        if self.touchedComponent == nil && self.pathsForRing.forCalculations.contains(touchedPoint) {
            self.touchedComponent = SMNumberWheelComponents.ring
        }
        if self.touchedComponent == nil && self.pathForCentralButton.contains(touchedPoint) {
            self.touchedComponent = SMNumberWheelComponents.centralButton
        }
        if self.isMinimized == true {
            self.touchedComponent = SMNumberWheelComponents.ring
            self.maximizeWheel()
        }
        
        if let component = self.touchedComponent {
            switch component {
            case .forwardButton:
                if self.stepper == false {
                    self.touchedComponent = SMNumberWheelComponents.ring
                    self.stopRotation()
                    self.currentAngularSpeed = 0.0
                    self.ringState = SMNumberWheelComponentState.highlighted
                } else {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self.stepperState = SMNumberWheelComponentState.highlighted
                    CATransaction.commit()
                }
            case .backwardButton:
                if self.stepper == false {
                    self.touchedComponent = SMNumberWheelComponents.ring
                    self.stopRotation()
                    self.currentAngularSpeed = 0.0
                    self.ringState = SMNumberWheelComponentState.highlighted
                } else {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self.stepperState = SMNumberWheelComponentState.highlighted
                    CATransaction.commit()
                }
            case .ring:
                self.stopRotation()
                self.currentAngularSpeed = 0.0
                self.ringState = SMNumberWheelComponentState.highlighted
            case .centralButton:
                if self.buttonEnabled == true {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self.buttonState = SMNumberWheelComponentState.highlighted
                    CATransaction.commit()
                } else {
                    self.touchedComponent = nil
                }
            default:
                self.touchedComponent = nil
            }
        }
        if self.touchedComponent != nil {
            sendActions(for: UIControlEvents.touchDown)
        }
        
        if self.hapticFeedback == true {
            if #available(iOS 10, *) {
                self.feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                self.feedbackGenerator?.prepare()
            }
        }
        
        return self.touchedComponent != nil
    }
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchedPoint = touch.location(in: self)
        if let component = self.touchedComponent {
            switch component {
            case .forwardButton:
                if self.pathForTopIndicatorArea.forward.contains(touchedPoint) {
                    if self.stepper == true {
                        self.stepperState = SMNumberWheelComponentState.highlighted
                    }
                } else {
                    if self.stepper == true {
                        self.stepperState = SMNumberWheelComponentState.normal
                    }
                }
            case .backwardButton:
                if self.pathForTopIndicatorArea.backward.contains(touchedPoint) {
                    if self.stepper == true {
                        self.stepperState = SMNumberWheelComponentState.highlighted
                    }
                } else {
                    if self.stepper == true {
                        self.stepperState = SMNumberWheelComponentState.normal
                    }
                }
            case .ring:
                let timeInterval: CFTimeInterval = CACurrentMediaTime() - self.lastTouchTime
                self.lastTouchTime = CACurrentMediaTime()
                let moveElements = self.calculateMove(touch, timeInterval: timeInterval, center: self.centerPoint)
                self.currentAngularSpeed = moveElements.angularSpeed
                self.rotation = moveElements.movementAngle > 0 ? SMNumberWheelRotation.clockwise : SMNumberWheelRotation.counterClockwise
                if self.changeValue(speed: moveElements.angularSpeed, rotation: self.rotation) == true {
                    self.ringState = self.rotation == SMNumberWheelRotation.clockwise ? SMNumberWheelComponentState.clockwiseRotation : SMNumberWheelComponentState.counterClockwiseRotation
                    self.rotateIndicatorsLayer(angle: CGFloat(moveElements.movementAngle))
                }
            case .centralButton:
                if self.pathForCentralButton.contains(touchedPoint) {
                    if self.buttonEnabled == false { self.buttonState = SMNumberWheelComponentState.disabled } else { self.buttonState = SMNumberWheelComponentState.highlighted }
                } else {
                    if self.buttonEnabled == false { self.buttonState = SMNumberWheelComponentState.disabled } else { self.buttonState = SMNumberWheelComponentState.normal }
                }
            default:
                if self.buttonEnabled == false { self.buttonState = SMNumberWheelComponentState.disabled } else { self.buttonState = SMNumberWheelComponentState.normal }
                if self.stepper == true { self.stepperState = SMNumberWheelComponentState.normal }
                self.ringState = SMNumberWheelComponentState.normal
            }
        }
        if self.touchedComponent != nil {
            sendActions(for: UIControlEvents.touchDragInside)
        }
        return true
    }
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touchedPoint = touch?.location(in: self) {
            if let component = self.touchedComponent {
                switch component {
                case .forwardButton:
                    if self.pathForTopIndicatorArea.forward.contains(touchedPoint) {
                        self.stopRotation()
                        if self.shiftValue(increment: true) == true {
                            let angleOfRotation = min(5.0 * π / 180 * CGFloat(self.stepValue) , π )
                            self.rotateIndicatorsLayer(angle: angleOfRotation, animated: true)
                        }
                    }
                case .backwardButton:
                    if self.pathForTopIndicatorArea.backward.contains(touchedPoint) {
                        self.stopRotation()
                        if self.shiftValue(increment: false) == true {
                            let angleOfRotation = min(5.0 * π / 180 * CGFloat(self.stepValue) , π )
                            self.rotateIndicatorsLayer(angle: angleOfRotation * (-1), animated: true)
                        }
                    }
                case .ring:
                    if self.currentAngularSpeed > 1 && self.lockRotation == false {
                        self.lastTouchTime = CACurrentMediaTime()
                        self.startDeceleration()
                    }
                case .centralButton:
                    if self.pathForCentralButton.contains(touchedPoint) && self.defaultValue != nil {
                        self.resetValueToInitial(shouldNotifyCallback: true)
                        self.stopRotation()
                        self.rotateIndicatorsToInitial()
                    }
                default:
                    break
                }
            }
        }
        if self.touchedComponent != nil {
            sendActions(for: UIControlEvents.touchUpInside)
        }
        if self.buttonEnabled == false { self.buttonState = SMNumberWheelComponentState.disabled } else { self.buttonState = SMNumberWheelComponentState.normal }
        if self.stepper == true { self.stepperState = SMNumberWheelComponentState.normal }
        if self.deceleration == false {self.ringState = SMNumberWheelComponentState.normal}
        self.touchedComponent = nil
        if self.autoMinimize == true && self.deceleration == false {
            self.autoMinimizeTimer =  Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(SMNumberWheel.minimizeWheel), userInfo: nil, repeats: false)
        }
    }
    
    // MARK: Dynamics
    // ----------------------------------------------------------------------------
    /** Rotates indicators with desired angle (Radians) in desired direction.  */
    open func rotateIndicatorsLayer(angle: CGFloat, animated: Bool = false) {
        if self.lockRotation == true { return }
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        self.indicatorsLayer.transform = CATransform3DRotate(self.indicatorsLayer.transform, angle, 0, 0, 1)
        CATransaction.commit()
    }
    /** Rotates indicators to their initial position.  */
    open func rotateIndicatorsToInitial() {
        if self.lockRotation == true { return }
        self.indicatorsLayer.transform = CATransform3DMakeRotation(0.0, 0, 0, 1)
    }
    fileprivate func startDeceleration() {
        if self.lockRotation == true || self.decelerate == false {
            self.currentAngularSpeed = 0.0
            return
        }
        self.stopRotation()
        self.displayTimer = CADisplayLink(target: self, selector: #selector(SMNumberWheel.rotateOnDeceleration(_:)))
        self.displayTimer!.frameInterval = 1
        self.displayTimer!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        self.deceleration = true
        self.ringState = self.rotation == SMNumberWheelRotation.clockwise ? SMNumberWheelComponentState.clockwiseRotation : SMNumberWheelComponentState.counterClockwiseRotation
    }
    @objc fileprivate func rotateOnDeceleration(_ sender: CADisplayLink) {
        if self.currentAngularSpeed < 0.1 {
            if #available(iOS 10, *) {
                self.feedbackGenerator = nil
            }
            self.stopRotation()
            self.currentAngularSpeed = 0.0
            if self.autoMinimize == true { self.minimizeWheel() }
        } else {
            self.currentAngularSpeed = self.currentAngularSpeed * 0.985
            let timeElapsed = CACurrentMediaTime() - self.lastTouchTime
            self.lastTouchTime = CACurrentMediaTime()
            let newAngle: CGFloat = CGFloat(timeElapsed) * CGFloat(self.currentAngularSpeed) * CGFloat(self.rotation.rawValue)
            self.rotateIndicatorsLayer(angle: newAngle)
            self.changeValue(speed: self.currentAngularSpeed, rotation: self.rotation)
        }
    }
    /** Stops the rotation of wheel if it is in deceleration mode. */
    open func stopRotation() {
        self.displayTimer?.invalidate()
        self.ringState = SMNumberWheelComponentState.normal
        self.deceleration = false
    }
    fileprivate func changeRotationOnReachingLimits() {
        if self.bounceBack == false {
            self.currentAngularSpeed = 0
            return
        }
        if let newRotation = SMNumberWheelRotation(rawValue: self.rotation.rawValue * (-1)) {
            self.rotation = newRotation
            self.ringState = self.rotation == SMNumberWheelRotation.clockwise ? SMNumberWheelComponentState.clockwiseRotation : SMNumberWheelComponentState.counterClockwiseRotation
        }
        let multiplier: Double = Double(min(self.bounds.width, self.bounds.height)) < 200 ? Double(min(self.bounds.width, self.bounds.height)) / 200 : 1.0
        self.currentAngularSpeed = self.currentAngularSpeed * 0.1 * multiplier
    }
    
    //MARK: Change control state (Minimize/Maximize)
    // ----------------------------------------------------------------------------
    /** Forces wheel to minimize itself. */
    @objc open func minimizeWheel() {
        if self.isMinimized == true { return }
        let scaleFactor = self.ringOuterRadius == 0 ? 0 : self.ringInnerRadius / self.ringOuterRadius
        let newIndicatorTransform = CATransform3DScale(self.indicatorsLayer.transform, scaleFactor, scaleFactor, 1)
        self.indicatorsTransform = self.indicatorsLayer.transform
        self.currentAngularSpeed = 0.0
        self.ringLayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
        self.ringStrokeLayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
        self.indicatorsLayer.transform = newIndicatorTransform
        self.ringStrokeLayer.lineWidth = 1.25
        self.ringStrokeLayer.fillColor = self.centralButtonFillColor[0].cgColor
        self.centralButtonLayer.isHidden = true
        self.indicatorsLayer.opacity = 0.0
        self.ringLayer.opacity = 0.0
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.topIndicatorLayer.isHidden = true
        self.topIndicatorAreaLayer.isHidden = true
        CATransaction.commit()
        self.isMinimized = true
        self.delegate?.SMNumberWheelChangedAppearance(self, minimized: true)
    }
    /** Forces wheel to restore to full size. If Auto Minimize is set to true, the wheel will auto-minimize itself after 1.5 seconds being idle. */
    open func maximizeWheel() {
        if self.isMinimized == false { return }
        self.ringStrokeLayer.transform = CATransform3DMakeScale(1, 1, 1)
        self.ringLayer.transform = CATransform3DMakeScale(1, 1, 1)
        self.indicatorsLayer.transform = self.indicatorsTransform
        self.ringStrokeLayer.lineWidth = self.ringStroke
        self.ringStrokeLayer.fillColor = nil
        self.centralButtonLayer.isHidden = false
        self.ringLayer.opacity = 1.0
        self.topIndicatorLayer.isHidden = !self.stepper
        self.topIndicatorAreaLayer.isHidden = !self.stepper
        self.indicatorsLayer.opacity = 1.0
        self.isMinimized = false
        self.delegate?.SMNumberWheelChangedAppearance(self, minimized: false)
    }
    
    // MARK: Paths
    // ----------------------------------------------------------------------------
    fileprivate func calculateAllPaths() {
        self.pathsForRing = self.calculatePathsForRing()
        self.pathForCentralButton = self.calculatePathForCentralButton()
        self.pathForTopIndicator = self.calculatePathForTopIndicator()
        self.pathForTopIndicatorArea = self.calculatePathForTopIndicatorArea()
        self.pathForRingIndicators = self.calculatePathForRingIndicators()
    }
    fileprivate func calculatePathsForRing() -> (forStroke: UIBezierPath, forFill: UIBezierPath, forCalculations: UIBezierPath) {
        var strokePath: UIBezierPath = UIBezierPath()
        var fillPath: UIBezierPath = UIBezierPath()
        var calcPath: UIBezierPath = UIBezierPath()
        
        // StrokePath
        strokePath = UIBezierPath(arcCenter: self.centerPoint, radius: self.ringOuterRadius - self.ringStroke / 2, startAngle: 3 * π / 2 , endAngle: 3 * π / 2 + 2 * π, clockwise: true)
        
        // FillPath
        let averageRadius = (self.ringInnerRadius + self.ringOuterRadius) / 2.0
        fillPath = UIBezierPath(arcCenter: self.centerPoint, radius: averageRadius, startAngle: 3 * π / 2, endAngle: 3 * π / 2 + 2 * π, clockwise: true)
        
        // calcPath
        calcPath = UIBezierPath(arcCenter: self.centerPoint, radius: self.ringOuterRadius - self.ringStroke / 2, startAngle: 3 * π / 2, endAngle: 3 * π / 2 + 2 * π, clockwise: true)
        calcPath.addArc(withCenter: self.centerPoint, radius: self.ringInnerRadius + self.ringStroke / 2, startAngle: 3 * π / 2 + 2 * π, endAngle: 3 * π / 2, clockwise: false)
        calcPath.close()
        
        return (strokePath, fillPath, calcPath)
    }
    fileprivate func calculatePathForCentralButton() -> UIBezierPath {
        let path = UIBezierPath(arcCenter: self.centerPoint, radius: self.ringInnerRadius, startAngle: 0.0, endAngle: 2 * π, clockwise: true)
        path.lineWidth = self.ringStroke
        return path
    }
    fileprivate func calculatePathForTopIndicator() -> UIBezierPath {
        if self.topIndicatorWidth < 1 { return UIBezierPath() }
        
        let midRadius = self.ringOuterRadius - self.topIndicatorWidth / 2
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: self.centerPoint.x + self.topIndicatorWidth / 6, y: self.centerPoint.y - self.ringOuterRadius +  self.topIndicatorWidth / 4))
        path.addLine(to: CGPoint(x: self.centerPoint.x + 2 / 3 * self.topIndicatorWidth, y: self.centerPoint.y - midRadius))
        path.addLine(to: CGPoint(x: self.centerPoint.x + self.topIndicatorWidth / 6, y: self.centerPoint.y - self.ringOuterRadius +  3 / 4 * self.topIndicatorWidth))
        path.close()
        path.move(to: CGPoint(x: self.centerPoint.x - self.topIndicatorWidth / 6, y: self.centerPoint.y - self.ringOuterRadius +  self.topIndicatorWidth / 4))
        path.addLine(to: CGPoint(x: self.centerPoint.x - 2 / 3 * self.topIndicatorWidth, y: self.centerPoint.y - midRadius))
        path.addLine(to: CGPoint(x: self.centerPoint.x - self.topIndicatorWidth / 6, y: self.centerPoint.y - self.ringOuterRadius + 3 / 4 * self.topIndicatorWidth))
        path.close()
        
        
        return path
    }
    fileprivate func calculatePathForTopIndicatorArea() -> (forDraw: UIBezierPath, forward: UIBezierPath, backward: UIBezierPath) {
        if self.topIndicatorWidth < 1 { return (UIBezierPath(), UIBezierPath(), UIBezierPath()) }
        let midRadius = self.ringOuterRadius - self.topIndicatorWidth / 2
        let inRadius = self.ringOuterRadius - self.topIndicatorWidth
        
        let startAngle = 5 * π / 2 + self.angleOfLine(self.centerPoint, point2: CGPoint(x: self.centerPoint.x + 2 / 3 * self.topIndicatorWidth, y: self.centerPoint.y - midRadius)) + 12 * π / 180
        let endingAngle = 5 * π / 2 + self.angleOfLine(self.centerPoint, point2: CGPoint(x: self.centerPoint.x - 2 / 3 * self.topIndicatorWidth, y: self.centerPoint.y - midRadius)) - 12 * π / 180
        
        let topAreaDraw = UIBezierPath(arcCenter: self.centerPoint, radius: self.ringOuterRadius, startAngle: startAngle, endAngle: endingAngle, clockwise: false)
        topAreaDraw.addArc(withCenter: self.centerPoint, radius: inRadius, startAngle: endingAngle, endAngle: startAngle, clockwise: true)
        topAreaDraw.close()
        topAreaDraw.lineWidth = 1.0
        
        let topAreaForward = UIBezierPath(arcCenter: self.centerPoint, radius: self.ringOuterRadius, startAngle: 3 * π / 2, endAngle: startAngle, clockwise: true)
        topAreaForward.addArc(withCenter: self.centerPoint, radius: inRadius, startAngle: startAngle, endAngle: 3 * π / 2, clockwise: false)
        topAreaForward.close()
        topAreaForward.lineWidth = 1.0
        
        let topAreaBackward = UIBezierPath(arcCenter: self.centerPoint, radius: self.ringOuterRadius, startAngle: 3 * π / 2, endAngle: endingAngle, clockwise: false)
        topAreaBackward.addArc(withCenter: self.centerPoint, radius: inRadius, startAngle: endingAngle, endAngle: 3 * π / 2, clockwise: true)
        topAreaBackward.close()
        topAreaBackward.lineWidth = 1.0
        
        
        return (topAreaDraw, topAreaForward, topAreaBackward)
    }
    fileprivate func calculatePathForRingIndicators() -> UIBezierPath {
        let resultPath = UIBezierPath()
        if self.allIndicators > 0 {
//            let startAngle: CGFloat = 3 * π / 2
//            var endingAngle: CGFloat = startAngle + 2 * π
            let averageRadius = (self.ringInnerRadius + self.ringOuterRadius) / 2.0
            var indicatorCenterPoint: CGPoint = CGPoint(x: self.centerPoint.x, y: self.centerPoint.y - averageRadius)
            var currentAngle: CGFloat = 3 * π / 2
            let angleIncrement: CGFloat = 2.0 * π / CGFloat(self.allIndicators)
            for indCounter: UInt in 0...(self.allIndicators - 1) {
                let isMajor: Bool = self.majorIndicators <= 0 ? false : indCounter % (self.allIndicators / self.majorIndicators) == 0
                if isMajor == true {
                    let indSize = self.sizeForIndicator(self.majorIndicatorType, isMajor: true)
                    if let newPath = self.pathForSingleIndicator(type: self.majorIndicatorType, onAngle: currentAngle, isMajorIndicator: true, size: indSize) {
                        resultPath.append(newPath)
                    }
                } else {
                    let indSize = self.sizeForIndicator(self.minorIndicatorType, isMajor: false)
                    if let newPath = self.pathForSingleIndicator(type: self.minorIndicatorType, onAngle: currentAngle, isMajorIndicator: false, size: indSize) {
                        resultPath.append(newPath)
                    }
                }
                indicatorCenterPoint = self.rotatePoint(indicatorCenterPoint, around: self.centerPoint, angle: angleIncrement)
                currentAngle = currentAngle + angleIncrement
            }
        }
        return resultPath
    }
    fileprivate func pathForSingleIndicator(type: IndicatorType, onAngle angle: CGFloat, isMajorIndicator: Bool, size: CGFloat) -> UIBezierPath? {
        let averageRadius = (self.ringInnerRadius + self.ringOuterRadius) / 2.0
        let indicatorCenter = self.rotatePoint(CGPoint(x: self.centerPoint.x, y: self.centerPoint.y-averageRadius), around: self.centerPoint, angle: angle + π / 2)
        var path = UIBezierPath()
        switch type {
        case .circular:
            path = UIBezierPath(arcCenter: indicatorCenter, radius: size / 2, startAngle: 0.0, endAngle: 2 * π, clockwise: true)
            break
        case .diamond:
            let p1 = CGPoint(x: indicatorCenter.x, y: indicatorCenter.y - size/1.8)
            let p2 = CGPoint(x: indicatorCenter.x + size / 4, y: indicatorCenter.y)
            let p3 = CGPoint(x: indicatorCenter.x, y: indicatorCenter.y + size/1.8)
            let p4 = CGPoint(x: indicatorCenter.x - size / 4, y: indicatorCenter.y)
            path.move(to: self.rotatePoint(p1, around: indicatorCenter, angle: angle + π/2))
            path.addLine(to: self.rotatePoint(p2, around: indicatorCenter, angle: angle + π/2))
            path.addLine(to: self.rotatePoint(p3, around: indicatorCenter, angle: angle + π/2))
            path.addLine(to: self.rotatePoint(p4, around: indicatorCenter, angle: angle + π/2))
            path.close()
            break
        case .linearCenter:
            let point1 = self.rotatePoint(CGPoint(x: indicatorCenter.x, y: indicatorCenter.y + size / 2), around: indicatorCenter, angle: angle + π / 2)
            let point2 = self.rotatePoint(CGPoint(x: indicatorCenter.x, y: indicatorCenter.y - size / 2), around: indicatorCenter, angle: angle + π / 2)
            path.move(to: point1)
            path.addLine(to: point2)
            break
        case .linearInnerStroke:
            let lineCenter = self.rotatePoint(CGPoint(x: self.centerPoint.x, y: self.centerPoint.y - self.ringInnerRadius - size / 2), around: self.centerPoint, angle: angle + π / 2)
            let point1t = self.rotatePoint(CGPoint(x: lineCenter.x, y: lineCenter.y + size / 2), around: lineCenter, angle: angle + π / 2)
            let point2t = self.rotatePoint(CGPoint(x: lineCenter.x, y: lineCenter.y - size / 2), around: lineCenter, angle: angle + π / 2)
            path.move(to: point1t)
            path.addLine(to: point2t)
            break
        case .linearOuterStroke:
            let lineCenter = self.rotatePoint(CGPoint(x: self.centerPoint.x, y: self.centerPoint.y - self.ringOuterRadius + size / 2), around: self.centerPoint, angle: angle + π / 2)
            let point1t = self.rotatePoint(CGPoint(x: lineCenter.x, y: lineCenter.y + size / 2), around: lineCenter, angle: angle + π / 2)
            let point2t = self.rotatePoint(CGPoint(x: lineCenter.x, y: lineCenter.y - size / 2), around: lineCenter, angle: angle + π / 2)
            path.move(to: point1t)
            path.addLine(to: point2t)
            break
        default:
            return nil
        }
        return path
    }
    
    // MARK: Accessory Functions
    // ----------------------------------------------------------------------------
    fileprivate func updateGeometryVariables() {
        self.centerPoint = self.calculateCenterPoint()
        self.ringOuterRadius = self.calculateRingOuterRadius()
        self.ringDefaultWidth = self.calculateRingDefaultWidth()
        self.ringInnerRadius = self.calculateRingInnerRadius()
        self.ringDrawableWidth = self.calculateRingDrawableWidth()
        self.topIndicatorWidth = self.calculateTopIndicatorWidth()
    }
    fileprivate func angleOfLine(_ point1: CGPoint, point2: CGPoint) -> CGFloat {
        let dy = point2.y - point1.y
        let dx = point2.x - point1.x
        return atan2(-dx , dy)
    }
    fileprivate func rotatePoint(_ point1: CGPoint, around point: CGPoint, angle: CGFloat) -> CGPoint {
        let rotatedX = cos(angle) * (point1.x - point.x) - sin(angle) * (point1.y-point.y) + point.x
        let rotatedY = sin(angle) * (point1.x - point.x) + cos(angle) * (point1.y - point.y) + point.y
        return CGPoint(x: rotatedX, y: rotatedY)
    }
    fileprivate func sizeForIndicator(_ type: IndicatorType, isMajor: Bool) -> CGFloat {
        var minorSize = self.minorIndSize == 0.0 ? self.ringDrawableWidth / 9 : self.minorIndSize
        var majorSize = self.majorIndSize == 0.0 ? self.ringDrawableWidth / 3 : self.majorIndSize
        let minorMultiplier: CGFloat = self.minorIndSize == 0.0 ? 0.9 : 1.0
        let majorMultiplier: CGFloat = self.majorIndSize == 0.0 ? 1.2 : 1.0
        minorSize = min(max(minorSize, 0.0), self.ringDrawableWidth)
        majorSize = min(max(majorSize, 0.0), self.ringDrawableWidth)
        var indSize = isMajor == true ? majorSize : minorSize
        if type == IndicatorType.linearCenter || type == IndicatorType.linearInnerStroke || type == IndicatorType.linearOuterStroke {
            indSize = isMajor == true ? majorSize * majorMultiplier : minorSize * minorMultiplier
        }
        return indSize
    }
    fileprivate func calculateCenterPoint() -> CGPoint {
        return CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
    fileprivate func calculateRingOuterRadius() -> CGFloat {
        return min(self.bounds.width, self.bounds.height) / 2.0
    }
    fileprivate func calculateRingDefaultWidth() -> CGFloat {
        switch self.ringOuterRadius {
        case 0...100:
            return self.ringOuterRadius / 2.5
        default:
            return min(max(self.ringOuterRadius / 3.0 ,40), 60)
        }
    }
    fileprivate func calculateRingInnerRadius() -> CGFloat {
        return self.ringWidth == 0 ? (self.ringOuterRadius - self.ringDefaultWidth) : (self.ringOuterRadius - self.ringWidth)
    }
    fileprivate func calculateRingDrawableWidth() -> CGFloat {
        return self.ringOuterRadius - self.ringInnerRadius - self.ringStroke
    }
    fileprivate func calculateTopIndicatorWidth() -> CGFloat {
        
        let wheelWidth = self.ringOuterRadius - self.ringInnerRadius
        if self.ringOuterRadius < 50 {
            return 0.0
        } else {
            return max(35.0, wheelWidth)
        }
    }
    fileprivate func properFontSizeForLabel() -> CGFloat {
        let labelText = self.centralLabelText == nil ? self.valueAsString : self.centralLabelText!
        let maxTextWidth = self.ringInnerRadius * 2 - 20
        if maxTextWidth <= 1 { return 0.0 }
        var result = self.fontSize
        var font = UIFont.systemFont(ofSize: result)
        var valueAttributes = [NSFontAttributeName: font]
        while (labelText as NSString).size(attributes: valueAttributes).width > maxTextWidth {
            result = result - 1
            font = UIFont.systemFont(ofSize: result)
            valueAttributes = [NSFontAttributeName: font]
        }
        return result
    }
    fileprivate func calculateMove(_ touch: UITouch, timeInterval: CFTimeInterval, center: CGPoint) -> (linearDistance: Double, linearSpeed: Double, movementAngle: Double, angularSpeed: Double) {
        let currentPoint: CGPoint = touch.location(in: self)
        let previousPoint: CGPoint = touch.previousLocation(in: self)
        let moveX = currentPoint.x - previousPoint.x
        let moveY = currentPoint.y - previousPoint.y
        let distance: Double = sqrt((Double) ((moveX * moveX) + (moveY * moveY)))
        let speed = distance / timeInterval
        
        var movementAngle = self.calculateAngleBetweenTwoLines(AngleVertex: self.centerPoint, point1: previousPoint, point2: currentPoint)
        if movementAngle > 3.14 {
            movementAngle = 0.0
        } else if movementAngle < -3.14 {
            movementAngle = 0.0
        }
        let angularSpeed = abs(movementAngle) / timeInterval
        return (distance, speed, movementAngle, angularSpeed)
    }
    fileprivate func calculateAngleBetweenTwoLines(AngleVertex: CGPoint, point1: CGPoint, point2: CGPoint) -> Double {
        let v1 = CGVector(dx: point1.x - AngleVertex.x, dy: point1.y - AngleVertex.y)
        let v2 = CGVector(dx: point2.x - AngleVertex.x, dy: point2.y - AngleVertex.y)
        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
        // var deg = angle * CGFloat(180.0 / M_PI)
        return Double(angle)
    }
    
    // MARK: Layers
    // ----------------------------------------------------------------------------
    fileprivate func addSubLayersToView() {
        self.updateLayers()
        self.layer.addSublayer(self.ringLayer)
        self.layer.addSublayer(self.ringStrokeLayer)
        self.layer.addSublayer(self.centralButtonLayer)
        self.layer.addSublayer(self.indicatorsLayer)
        self.layer.addSublayer(self.topIndicatorAreaLayer)
        self.layer.addSublayer(self.topIndicatorLayer)
        self.layer.addSublayer(self.labelLayer)
        self.centralButtonLayer.zPosition = 0.0
        self.ringStrokeLayer.zPosition = 0.1
        self.ringLayer.zPosition = 0.2
        self.indicatorsLayer.zPosition = 0.3
        self.topIndicatorAreaLayer.zPosition = 0.4
        self.topIndicatorLayer.zPosition = 0.5
        self.labelLayer.zPosition = 0.6
    }
    fileprivate func updateLayers() {
        self.updateLayerFrames(self.frame) // Also updates label layer
        self.updateLayerBounds(self.bounds) // Also updates label layer
        self.updateLayerPaths()
        self.updateLayerColors(animated: true)
        self.updateLayerWidths()
        self.updateLayerShadows()
        self.ringLayer.contentsScale = UIScreen.main.scale
        self.ringStrokeLayer.contentsScale = UIScreen.main.scale
        self.centralButtonLayer.contentsScale = UIScreen.main.scale
        self.topIndicatorAreaLayer.contentsScale = UIScreen.main.scale
        self.topIndicatorLayer.contentsScale = UIScreen.main.scale
        self.indicatorsLayer.contentsScale = UIScreen.main.scale
        self.ringLayer.contentsScale = UIScreen.main.scale
        self.labelLayer.contentsScale = UIScreen.main.scale
    }
    fileprivate func updateLayerFrames(_ rect: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.ringLayer.frame = rect
        self.ringStrokeLayer.frame = rect
        self.centralButtonLayer.frame = rect
        self.topIndicatorAreaLayer.frame = rect
        self.indicatorsLayer.frame = rect
        self.ringLayer.position = self.centerPoint
        self.ringStrokeLayer.position = self.centerPoint
        self.centralButtonLayer.position = self.centerPoint
        self.topIndicatorAreaLayer.position = self.centerPoint
        self.indicatorsLayer.position = self.self.centerPoint
        CATransaction.commit()
        self.updateLabelLayer()
    }
    fileprivate func updateLayerBounds(_ rect: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.ringLayer.bounds = rect
        self.ringStrokeLayer.bounds = rect
        self.centralButtonLayer.bounds = rect
        self.topIndicatorAreaLayer.bounds = rect
        self.indicatorsLayer.bounds = rect
        self.ringLayer.position = self.centerPoint
        self.ringStrokeLayer.position = self.centerPoint
        self.centralButtonLayer.position = self.centerPoint
        self.topIndicatorAreaLayer.position = self.centerPoint
        self.indicatorsLayer.position = self.self.centerPoint
        CATransaction.commit()
        self.updateLabelLayer()
    }
    fileprivate func updateLayerPaths() {
        self.ringLayer.path = self.pathsForRing.forFill.cgPath
        self.ringStrokeLayer.path = self.pathsForRing.forStroke.cgPath
        self.centralButtonLayer.path = self.pathForCentralButton.cgPath
        self.indicatorsLayer.path = self.pathForRingIndicators.cgPath
        self.topIndicatorAreaLayer.path = self.pathForTopIndicatorArea.forDraw.cgPath
        self.topIndicatorLayer.path = self.pathForTopIndicator.cgPath
    }
    fileprivate func updateLayerColors(animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        self.ringLayer.strokeColor = self.ringFillColor[self.ringState.rawValue].cgColor
        self.ringLayer.fillColor = nil
        self.ringStrokeLayer.strokeColor = self.ringStrokeColor[self.ringState.rawValue].cgColor
        if self.isMinimized == true {
            self.ringStrokeLayer.fillColor = self.centralButtonFillColor[0].cgColor
        } else {
            self.ringStrokeLayer.fillColor = nil
        }
        self.centralButtonLayer.strokeColor = self.ringStrokeColor[self.ringState.rawValue].cgColor
        self.centralButtonLayer.fillColor = self.centralButtonFillColor[self.buttonState.rawValue].cgColor
        self.topIndicatorAreaLayer.strokeColor = self.topIndicatorStrokeColor[0].cgColor
        self.topIndicatorAreaLayer.fillColor = self.topIndicatorFillColor[self.stepperState.rawValue].cgColor
        self.topIndicatorLayer.fillColor = self.stepperColor == nil ? self.indicatorFillColor[self.ringState.rawValue].cgColor : self.stepperColor!.cgColor
        self.topIndicatorLayer.strokeColor = self.topIndicatorLayer.fillColor
        self.indicatorsLayer.fillColor = self.indicatorFill == true ? self.indicatorFillColor[self.ringState.rawValue].cgColor : nil
        self.indicatorsLayer.strokeColor = self.indicatorFillColor[self.ringState.rawValue].cgColor
        self.labelLayer.foregroundColor = self.labelColor[self.buttonState.rawValue].cgColor
        CATransaction.commit()
    }
    fileprivate func updateLayerWidths() {
        self.ringLayer.lineWidth = self.ringOuterRadius - self.ringInnerRadius - self.ringStroke
        self.ringStrokeLayer.lineWidth = self.ringStroke
        self.centralButtonLayer.lineWidth = self.ringStroke
        self.indicatorsLayer.lineWidth = self.indicatorStroke
        self.indicatorsLayer.lineCap = kCALineCapRound
        self.topIndicatorAreaLayer.lineWidth = 0.75
        self.topIndicatorAreaLayer.lineCap = kCALineCapRound
        self.topIndicatorLayer.lineWidth = 1.0
        self.topIndicatorLayer.lineCap = kCALineCapRound
    }
    fileprivate func updateLabelLayer() {
        if self.labelVisible == false { return }
        let labelText = self.centralLabelText == nil ? self.valueAsString : self.centralLabelText!
        let properSize = self.properFontSizeForLabel()
        let font = UIFont.systemFont(ofSize: properSize)
        let valueAttributes = [NSFontAttributeName: font]
        let textSize = (self.valueAsString as NSString).size(attributes: valueAttributes)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.labelLayer.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: textSize.height)
        self.labelLayer.position = self.centerPoint
        self.labelLayer.font = font
        self.labelLayer.fontSize = properSize
        self.labelLayer.string = labelText
        self.labelLayer.alignmentMode = kCAAlignmentCenter
        CATransaction.commit()
    }
    fileprivate func updateLayerShadows() {
        self.topIndicatorAreaLayer.shadowColor = UIColor.black.cgColor
        self.topIndicatorAreaLayer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.topIndicatorAreaLayer.shadowRadius = 3
        self.topIndicatorAreaLayer.shadowOpacity = 0.65
    }
    fileprivate func removeAllLayers() {
        self.ringLayer.removeFromSuperlayer()
        self.centralButtonLayer.removeFromSuperlayer()
        self.topIndicatorAreaLayer.removeFromSuperlayer()
        self.indicatorsLayer.removeFromSuperlayer()
        self.labelLayer.removeFromSuperlayer()
    }
    
    // MARK: Colors
    // ----------------------------------------------------------------------------
    fileprivate func calculateRingStrokeColor() {
        let normalStateColor = self.strokeColor == nil ? self.tintColor : self.strokeColor!
        self.ringStrokeColor[0] = normalStateColor!
        self.ringStrokeColor[1] = self.strokeColorStateHighlighted == nil ? normalStateColor! : self.strokeColorStateHighlighted!
        self.ringStrokeColor[2] = self.ringStrokeColor[0].withAlphaComponent(0.5)
        self.ringStrokeColor[3] = self.strokeColorStateClockwiseRotation == nil ? normalStateColor! : self.strokeColorStateClockwiseRotation!
        self.ringStrokeColor[4] = self.strokeColorStateCounterClockwiseRotation == nil ? normalStateColor! : self.strokeColorStateCounterClockwiseRotation!
    }
    fileprivate func calculateRingFillColor() {
        let normalStateColor = self.ringColor == nil ? self.tintColor : self.ringColor!
        self.ringFillColor[0] = normalStateColor!
        self.ringFillColor[1] = self.ringColorHighlighted == nil ? normalStateColor! : self.ringColorHighlighted!
        self.ringFillColor[2] = self.ringFillColor[0].withAlphaComponent(0.5)
        self.ringFillColor[3] = self.ringColorClockwiseRotation == nil ? normalStateColor! : self.ringColorClockwiseRotation!
        self.ringFillColor[4] = self.ringColorCounterclockwiseRotation == nil ? normalStateColor! : self.ringColorCounterclockwiseRotation!
    }
    fileprivate func calculateCentralButtonFillColor() {
        let backGround: UIColor = self.backgroundColor == nil ? UIColor.clear : self.backgroundColor!
//        let labelColor = self.labelColorStateNormal == nil ? tintColor : self.labelColorStateNormal!
        self.centralButtonFillColor[0] = self.buttonBackgroundColorStateNormal == nil ? backGround : self.buttonBackgroundColorStateNormal!
        self.centralButtonFillColor[1] = self.buttonBackgroundColorStateHighlighted == nil ? backGround : self.buttonBackgroundColorStateHighlighted!
        self.centralButtonFillColor[2] = self.centralButtonFillColor[0]
        self.centralButtonFillColor[3] = self.centralButtonFillColor[0]
        self.centralButtonFillColor[4] = self.centralButtonFillColor[0]
    }
    fileprivate func calculateIndicatorFillColor() {
        self.indicatorFillColor[0] = self.indicatorColor == nil ? UIColor.white : self.indicatorColor!
        self.indicatorFillColor[1] = self.indicatorColorHighlighted == nil ? self.indicatorFillColor[0] : self.indicatorColorHighlighted!
        self.indicatorFillColor[2] = self.indicatorFillColor[0]
        self.indicatorFillColor[3] = self.indicatorColorClockwiseRotation == nil ? self.indicatorFillColor[0] : self.indicatorColorClockwiseRotation!
        self.indicatorFillColor[4] = self.indicatorColorCounterClockwiseRotation == nil ? self.indicatorFillColor[0] : self.indicatorColorCounterClockwiseRotation!
    }
    fileprivate func calculateLabelColor() {
        self.labelColor[0] = self.labelColorStateNormal == nil ? tintColor : self.labelColorStateNormal!
        self.labelColor[1] = self.labelColorStateHighlighted == nil ? UIColor.clear : self.labelColorStateHighlighted!
        self.labelColor[2] = self.labelColorStateNormal == nil ? tintColor.withAlphaComponent(0.3) : self.labelColorStateNormal!.withAlphaComponent(0.3)
        self.labelColor[3] = self.labelColor[0]
        self.labelColor[4] = self.labelColor[0]
    }
    fileprivate func calculateTopIndicatorFillColor() {
        self.topIndicatorFillColor[0] = self.stepperBackgroundColor == nil ? self.ringFillColor[self.ringState.rawValue] : self.stepperBackgroundColor!
        self.topIndicatorFillColor[1] = self.stepperBackgroundColorStateHighlighted == nil ? self.ringFillColor[self.ringState.rawValue] : self.stepperBackgroundColorStateHighlighted!
        self.topIndicatorFillColor[2] = self.topIndicatorFillColor[0]
        self.topIndicatorFillColor[3] = self.topIndicatorFillColor[0]
        self.topIndicatorFillColor[4] = self.topIndicatorFillColor[0]
    }
    fileprivate func calculateTopIndicatorStrokeColor() {
        self.topIndicatorStrokeColor[0] = self.stepperBorderColor == nil ? self.ringStrokeColor[self.ringState.rawValue] : self.stepperBorderColor!
        self.topIndicatorStrokeColor[1] = self.topIndicatorStrokeColor[0]
        self.topIndicatorStrokeColor[2] = self.topIndicatorStrokeColor[0]
        self.topIndicatorStrokeColor[3] = self.topIndicatorStrokeColor[0]
        self.topIndicatorStrokeColor[4] = self.topIndicatorStrokeColor[0]
    }
    
    // MARK: Interface builder
    // ----------------------------------------------------------------------------
    override open func prepareForInterfaceBuilder() {
        self.updateGeometryVariables()
        self.calculateAllPaths()
        self.addSubLayersToView()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    }
    */
    
    // MARK: Model
    // ----------------------------------------------------------------------------
    fileprivate func valueLimits() -> (minValue: Double?, maxValue: Double?) {
        var minimum = self.lowerLimit
        var maximum = self.upperLimit
        
        if minimum != nil && maximum != nil {
            if minimum! > maximum! {
                let temp = minimum!
                minimum = maximum
                maximum = temp
            }
        }
        if let defValue = self.defaultValue {
            if minimum != nil {
                if defValue < minimum! { self.defaultValue = minimum! }
            }
            if maximum != nil {
                if defValue > maximum! { self.defaultValue = maximum! }
            }
        }
        return (minimum, maximum)
    }
    fileprivate func optimizedSensitivity() -> Double {
        if let decidedSensitivity = self.sensitivity {
            return decidedSensitivity * decidedSensitivity / 100
        } else {
            let limits = self.valueLimits()
            var result = 0.1
            if limits.minValue != nil && limits.maxValue != nil {
                let range = limits.maxValue! - limits.minValue!
                switch range {
                case 0..<100:
                    result = 0.05
                case 100..<500:
                    result = 0.085
                case 500..<1000:
                    result = 0.1
                case 1000..<2000:
                    result = 0.13
                default:
                    result = 0.14
                }
            }
            result = result * Double(min(self.bounds.width, self.bounds.height)) / 168
            return result * result
        }
    }
    @discardableResult
    fileprivate func changeValue(speed: Double, rotation: SMNumberWheelRotation) -> Bool {
        var sensitivityMultiplier = 4.0
        switch self.outputType {
        case .integer:
            sensitivityMultiplier = 4.0
        case .floatingPoint(let fractionDigits):
            switch fractionDigits {
            case 0:
                sensitivityMultiplier = 4.0
            case 1:
                sensitivityMultiplier = 2.0
            case 2:
                sensitivityMultiplier = 1.0
            default:
                sensitivityMultiplier = 0.2
            }
        }
        let mult: Double = Double(rotation.rawValue) * sensitivityMultiplier
        let valueToBeAdded = mult * speed * speed * optimizedSensitivity()
        let newValue = self.currentValue + valueToBeAdded
        return self.setToNewValue(newValue, shouldNotifyCallback: true)
    }
    /** Increase/Decrease the current value by stepperValue. Animations should be handeled manually using rotateIndicatorsLayer(#angle: CGFloat, animated: Bool) function. Returns false if new value is out of range. */
    @discardableResult
    open func shiftValue(increment: Bool) -> Bool {
        let mult: Double = increment == true ? 1.0 : -1.0
        let valueToBeAdded = mult * abs(self.stepValue)
        let newValue = round(self.currentValue) + valueToBeAdded
        self.delegate?.SMNumberWheelStepperKeyPressed(self, rightKey: increment)
        return self.setToNewValue(newValue, shouldNotifyCallback: true)
    }
    /** Sets the default value of the Wheel. This value is optional. If the default value is outside of range of lower limit and higher limit, it will take the nearest limit. If instead of the provided value the nearest limit is picked the function returns false. */
    @discardableResult
    open func setDefaultValue(newValue: Double?) -> Bool {
        let limits = self.valueLimits()
        if var result = newValue {
            if let min = limits.minValue {
                result = max(min, result)
            }
            if let max = limits.maxValue {
                result = min(max, result)
            }
            let accepted = newValue == result ? true : false
            self.defaultValue = result
            return accepted
        } else {
            self.defaultValue = nil
            return true
        }
    }
    /** returns the default value set on the wheel */
    open func getDefaultValue() -> Double? {
        return self.defaultValue
    }
    
    /** Sets the current value to new Value. Animations should be handeled manually using rotateIndicatorsLayer(#angle: CGFloat, animated: Bool) function. Returns false if new value is out of range. */
    @discardableResult
    open func setValue(newValue: Double) -> Bool {
        return self.setToNewValue(newValue, shouldNotifyCallback: false)
    }
    @discardableResult
    fileprivate func setToNewValue(_ newValue: Double, shouldNotifyCallback: Bool) -> Bool {
        let limits = self.valueLimits()
        var wheelNewValue = newValue
        var result = true
        self.lastValue = self.currentValue
        switch self.behaviorOnLimits {
        case .wrap:
            if let max = limits.maxValue {
                if wheelNewValue > max {
                    if let min = limits.minValue {
                        wheelNewValue = min
                        self.delegate?.SMNumberWheelReachedLimit(self, stayedAtLimit: false)
                    }
                }
            }
            if let min = limits.minValue {
                if wheelNewValue < min {
                    if let max = limits.maxValue {
                        wheelNewValue = max
                        self.delegate?.SMNumberWheelReachedLimit(self, stayedAtLimit: false)
                    }
                }
            }
        case .stayAtLimit:
            if let max = limits.maxValue {
                if wheelNewValue > max {
                    wheelNewValue = max
                    self.delegate?.SMNumberWheelReachedLimit(self, stayedAtLimit: true)
                    if self.deceleration == true {self.changeRotationOnReachingLimits()}
                    result = false
                }
            }
            if let min = limits.minValue {
                if wheelNewValue < min {
                    wheelNewValue = min
                    self.delegate?.SMNumberWheelReachedLimit(self, stayedAtLimit: true)
                    if self.deceleration == true {self.changeRotationOnReachingLimits()}
                    result = false
                }
            }
        default :
            self.currentValue = wheelNewValue
            if let min = limits.minValue {
                if (wheelNewValue - min) * (self.previousValue - min) <= 0 {
                    self.delegate?.SMNumberWheelReachedLimit(self, stayedAtLimit: false)
                }
            }
            if let max = limits.maxValue {
                if (wheelNewValue - max) * (self.previousValue - max) <= 0 {
                    self.delegate?.SMNumberWheelReachedLimit(self, stayedAtLimit: false)
                }
            }
            result = true
        }
        self.previousValue = self.currentValue
        self.currentValue = wheelNewValue
        if self.currentStringOnLabel != self.valueAsString && self.centralLabelText == nil {
            if shouldNotifyCallback == true {
                sendActions(for: UIControlEvents.valueChanged)
                self.delegate?.SMNumberWheelValueChanged(self)
            }
            self.updateLabelLayer()
            self.currentStringOnLabel = self.valueAsString
        }
        
        // playing sounds
        if self.sounds == true {
            switch self.outputType {
            case .integer:
                if round(self.lastValue) != round(self.currentValue) {
                    AudioServicesPlaySystemSound(1104)
                }
            case .floatingPoint:
                if Int(self.lastValue) != Int(self.currentValue) {
                    AudioServicesPlaySystemSound(1104)
                }
            }
        }
        
        // playing haptic feedback
        if self.hapticFeedback == true {
            switch self.outputType {
            case .integer:
                if round(self.lastValue) != round(self.currentValue) {
                    if #available(iOS 10, *) {
                        self.feedbackGenerator?.impactOccurred()
                        self.feedbackGenerator?.prepare()
                    }
                }
            case .floatingPoint:
                if Int(self.lastValue) != Int(self.currentValue) {
                    if #available(iOS 10, *) {
                        self.feedbackGenerator?.impactOccurred()
                        self.feedbackGenerator?.prepare()
                    }
                }
            }
        }
        return result
    }
    /** Sets the current value to default Value (if the default value is set before). Animations should be handeled manually using rotateIndicatorsLayer(#angle: CGFloat, animated: Bool) function. */
    open func resetToDefaultValue() {
        self.resetValueToInitial(shouldNotifyCallback: false)
    }
    fileprivate func resetValueToInitial(shouldNotifyCallback: Bool) {
        if let defValue = self.defaultValue {
            self.setToNewValue(defValue, shouldNotifyCallback: shouldNotifyCallback)
            self.delegate?.SMNumberWheelDidResetToDefaultValue(self)
            if self.currentStringOnLabel != self.valueAsString {
                self.updateLabelLayer()
                self.currentStringOnLabel = self.valueAsString
            }
        }
    }
}
