//
//  GaugeSliderView.swift
//  GaugeSlider
//
//  Created by Edgar Žigis on 23/08/2019.
//  Copyright © 2019 Edgar Žigis. All rights reserved.
//

import UIKit

public enum GaugeSliderCountingMethod {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

public enum GaugeSliderDelegationMode: Equatable {
    case immediate(interval: CGFloat)
    case singular
}

@IBDesignable
public class GaugeSliderView: UIView {
    
    //  MARK: - Static variables -
    
    private static let minValue: CGFloat = -1.20
    private static let midValue: CGFloat = -0.5
    private static let maxValue: CGFloat = 0.20
    private static let startingAngle: CGFloat = -45
    
    //  MARK: - Open variables -
    
    open var onProgressChanged: (Int)->() = { progress in }
    open var onButtonAction: ()->() = { }
    
    /**
     * Sets not filled sliding path color
     */
    @IBInspectable
    open var blankPathColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
     * Sets filled sliding path color
     */
    @IBInspectable
    open var fillPathColor = UIColor.green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
     * Sets vertical indicator color
     */
    @IBInspectable
    open var indicatorColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
     * Sets dashed unit colors
     */
    @IBInspectable
    open var unitColor = UIColor.darkGray {
        didSet {
            unitLabel.textColor = unitColor
        }
    }
    
    /**
     * Sets dashed unit labels colors
     */
    @IBInspectable
    open var unitIndicatorColor = UIColor.lightGray {
        didSet {
            unitIndicatorLabels.forEach {
                $0.textColor = unitIndicatorColor
            }
        }
    }
    
    /**
     * Sets value placeholder color (eg. Warming)
     */
    @IBInspectable
    open var placeholderColor = UIColor.lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    /**
     * Sets custom control color (eg. Automatic)
     */
    @IBInspectable
    open var customControlColor = UIColor.green {
        didSet {
            customControlButton.backgroundColor = customControlColor.withAlphaComponent(0.1)
            customControlButton.setTitleColor(customControlColor, for: .normal)
        }
    }
    
    /**
     * Sets sliding path width
     */
    @IBInspectable
    open var trackWidth: CGFloat = 32 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
     * Toggles custom control visibility
     */
    @IBInspectable
    open var isCustomControlActive = false {
        didSet {
            customControlButton.backgroundColor = customControlColor.withAlphaComponent(isCustomControlActive ? 0.6 : 0.1)
            customControlButton.setTitleColor(isCustomControlActive ? UIColor.white : customControlColor, for: .normal)
        }
    }
    
    /**
     * Sets slider progress by percentage
     */
    @IBInspectable
    open var progress: CGFloat = 0 {
        didSet {
            if  Int(oldValue) != Int(progress) && allowCallBack && !internalActionsInProgress {
                switch delegationMode {
                case .immediate(let interval):
                    if abs(progress - previousProgressValue) >= interval {
                        previousProgressValue = progress
                        onProgressChanged(Int(progress))
                    }
                default:
                    onProgressChanged(Int(progress))
                }
            }
            updateViews()
        }
    }
    
    /**
     * Sets current slider value
     */
    @IBInspectable
    open var value: CGFloat {
        set {
            allowCallBack = false
            internalActionsInProgress = true
            let amplitude = maxValue - minValue
            progress = ((newValue - minValue) / amplitude) * 100
            allowCallBack = true
            internalActionsInProgress = false
        }
        get {
            return CGFloat(Int(minValue + (maxValue - minValue) * (progress / 100)))
        }
    }
    
    /**
     * Sets minimum slider value
     */
    @IBInspectable
    open var minValue: CGFloat = 5 {
        didSet {
            updateViews()
        }
    }
    
    /**
     * Sets maximum slider value
     */
    @IBInspectable
    open var maxValue: CGFloat = 25 {
        didSet {
            updateViews()
        }
    }
    
    /**
     * Sets unit value (eg. temperature, speed etc.)
     */
    @IBInspectable
    open var unit = "°" {
        didSet {
            updateViews()
        }
    }
    
    /**
     * Sets value placeholder
     */
    @IBInspectable
    open var placeholder = "Warming" {
        didSet {
            updateViews()
        }
    }
    
    /**
     * Sets custom control title
     */
    @IBInspectable
    open var customControlButtonTitle = "• Auto" {
        didSet {
            updateViews()
        }
    }
    
    /**
     * Sets custom control visibility
     */
    @IBInspectable
    open var customControlButtonVisible = true {
        didSet {
            customControlButton.isHidden = !customControlButtonVisible
        }
    }
    
    /**
     * Sets unit font
     */
    @IBInspectable
    open var unitFont = UIFont.systemFont(ofSize: 67) {
        didSet {
            unitLabel.font = unitFont
        }
    }
    
    /**
     * Sets placeholder font
     */
    @IBInspectable
    open var placeholderFont = UIFont.systemFont(ofSize: 17, weight: .medium) {
        didSet {
            placeholderLabel.font = placeholderFont
        }
    }
    
    /**
     * Sets unit indicator font
     */
    @IBInspectable
    open var unitIndicatorFont = UIFont.systemFont(ofSize: 16, weight: .medium) {
        didSet {
            unitIndicatorLabels.forEach {
                $0.font = unitIndicatorFont
            }
        }
    }
    
    /**
     * Sets left icon
     */
    @IBInspectable
    open var leftIcon = UIImage(named: "snowIcon")
    
    /**
     * Sets right icon
     */
    @IBInspectable
    open var rightIcon = UIImage(named: "sunIcon")
    
    /**
     * Sets counting method animation
     */
    open var countingMethod = GaugeSliderCountingMethod.easeInOut
  
    /**
     * .singular will emit only single event after gesture finish
     * .immediate will emit multiple events after every progress value change
     */
    open var delegationMode = GaugeSliderDelegationMode.singular
    
    //  MARK: - Private variables -
    
    private var timer: CADisplayLink?
    private var startValue: CGFloat = 0
    private var destinationValue: CGFloat = 0
    private var timerProgress: TimeInterval = 0
    private var timerLastUpdate: TimeInterval = 0
    private var timerTotalTime: TimeInterval = 0
    private var progressCounter: ProgressCounter!
    
    private var allowCallBack = true {
        didSet {
            if oldValue == false && allowCallBack && !internalActionsInProgress {
                onProgressChanged(Int(progress))
            }
        }
    }
    private var internalActionsInProgress = false
    private var previousProgressValue: CGFloat = 0
    
    private var endPoint = CGPoint.zero
    private var totalArcDistance = CGFloat.leastNonzeroMagnitude
    
    private let unitLabel = UILabel()
    private let unitIndicatorLabels = [UILabel(), UILabel(), UILabel()]
    private let placeholderLabel = UILabel()
    private let customControlButton = UIButton()
    
    private let leftIconView = UIImageView()
    private let rightIconView = UIImageView()
    
    //  MARK: - UI methods -
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawPath(in: rect, color: blankPathColor, thickness: 1.5, trackWidth: trackWidth, capturePoints: true)
        
        drawMeter(in: rect, color: blankPathColor, startAngle: .pi * GaugeSliderView.minValue - 0.02, endAngle: -.pi - 0.04)
        drawMeter(in: rect, color: blankPathColor, startAngle: -.pi + 0.05, endAngle: .pi * GaugeSliderView.midValue - 0.05)
        drawMeter(in: rect, color: blankPathColor, startAngle: .pi * GaugeSliderView.midValue + 0.04, endAngle: 0 - 0.04)
        drawMeter(in: rect, color: blankPathColor, startAngle: 0.06, endAngle: .pi * GaugeSliderView.maxValue + 0.03)
        
        drawMeterIndicator(in: rect, color: blankPathColor, angle: -.pi)
        drawMeterIndicator(in: rect, color: blankPathColor, angle: -.pi / 2)
        drawMeterIndicator(in: rect, color: blankPathColor, angle: 0)
        
        let range = GaugeSliderView.maxValue + abs(GaugeSliderView.minValue)
        let currentValue = GaugeSliderView.minValue + range * progress / 100
        
        drawPath(in: rect, color: fillPathColor, thickness: 2.5, trackWidth: trackWidth, endValue: currentValue)
        drawPath(in: rect, color: indicatorColor, thickness: 2.5, trackWidth: trackWidth * 1.6, startValue: currentValue - 0.01, endValue: currentValue, drawShadow: true)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        updateViews()
    }
    
    private func addGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onGesture(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onGesture(_:))))
    }
    
    private func addViews() {
        unitLabel.font = unitFont
        unitLabel.textColor = unitColor
        addSubview(unitLabel)
        
        placeholderLabel.font = placeholderFont
        placeholderLabel.textColor = placeholderColor
        addSubview(placeholderLabel)
        
        unitIndicatorLabels.forEach {
            $0.font = unitIndicatorFont
            $0.textColor = unitIndicatorColor
            addSubview($0)
        }
        
        leftIconView.image = leftIcon
        leftIconView.contentMode = .scaleAspectFit
        addSubview(leftIconView)
        
        rightIconView.image = rightIcon
        rightIconView.contentMode = .scaleAspectFit
        addSubview(rightIconView)
        
        customControlButton.backgroundColor = customControlColor.withAlphaComponent(0.1)
        customControlButton.setTitleColor(customControlColor, for: .normal)
        customControlButton.layer.cornerRadius = 16
        customControlButton.addTarget(self, action: #selector(onCustomButton), for: .touchUpInside)
        addSubview(customControlButton)
        
        updateViews()
    }
    
    private func positionViews() {
        unitLabel.sizeToFit()
        unitLabel.frame.origin.x = (frame.width - unitLabel.frame.width) / 2
        unitLabel.frame.origin.y = (frame.height - unitLabel.frame.height) / 2
        
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin.x = (frame.width - placeholderLabel.frame.width) / 2
        placeholderLabel.frame.origin.y = unitLabel.frame.origin.y + unitLabel.frame.height + 4
        
        unitIndicatorLabels[0].sizeToFit()
        unitIndicatorLabels[0].frame.origin.x = trackWidth * 2.4
        unitIndicatorLabels[0].frame.origin.y = (frame.height - unitIndicatorLabels[0].frame.height) / 2
        
        unitIndicatorLabels[1].sizeToFit()
        unitIndicatorLabels[1].frame.origin.x = (frame.width - unitIndicatorLabels[1].frame.width) / 2
        unitIndicatorLabels[1].frame.origin.y = trackWidth * 2.4
        
        unitIndicatorLabels[2].sizeToFit()
        unitIndicatorLabels[2].frame.origin.x = frame.width - trackWidth * 2.4 - unitIndicatorLabels[2].frame.width
        unitIndicatorLabels[2].frame.origin.y = unitIndicatorLabels[0].frame.origin.y
        
        leftIconView.frame.size = CGSize(width: 24, height: 24)
        leftIconView.frame.origin = CGPoint(x: frame.width - endPoint.x - 24 - trackWidth / 2.5, y: endPoint.y + 4)
        
        rightIconView.frame.size = CGSize(width: 24, height: 24)
        rightIconView.frame.origin = CGPoint(x: endPoint.x + trackWidth / 2.5, y: endPoint.y + 4)
        
        customControlButton.frame.size = CGSize(
            width: frame.width - leftIconView.frame.origin.x * 2 - CGFloat(96),
            height: 28
        )
        customControlButton.frame.origin = CGPoint(x: leftIconView.frame.origin.x + 48, y: endPoint.y + 4)
        customControlButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    }
    
    func updateViews() {
        setNeedsDisplay()
        
        let diff = maxValue - minValue
        unitLabel.text = "\(Int(minValue + diff * (progress / 100)))\(unit)"
        placeholderLabel.text = placeholder
        
        unitIndicatorLabels[0].text = "\(Int((maxValue - minValue) / 7))"
        unitIndicatorLabels[1].text = "\(Int((maxValue - minValue) / 2))"
        unitIndicatorLabels[2].text = "\(Int(maxValue - (maxValue - minValue) / 7))"
        
        customControlButton.setTitle(customControlButtonTitle, for: .normal)
        
        positionViews()
    }
    
    public func setCurrentValue(_ value: CGFloat, animated: Bool) {
        guard value >= minValue && value <= maxValue else {
            return
        }
        let targetValue = (value - minValue) / (maxValue - minValue) * 100
        
        if animated {
            internalActionsInProgress = true
            animateProgress(from: progress, to: targetValue)
        } else {
            if delegationMode == .singular {
                allowCallBack = false
            }
            progress = targetValue
        }
    }
    
    //  MARK: - Paths -
    
    private func drawPath(
        in rect: CGRect,
        color: UIColor,
        thickness: CGFloat,
        trackWidth: CGFloat,
        startValue: CGFloat = GaugeSliderView.minValue,
        endValue: CGFloat = GaugeSliderView.maxValue,
        drawShadow: Bool = false,
        capturePoints: Bool = false
        ) {
        let context = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath()
        path.addArc(
            withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2 - trackWidth + (trackWidth - self.trackWidth) * 1.5,
            startAngle: .pi * startValue,
            endAngle: .pi * endValue,
            clockwise: true
        )
        
        if capturePoints && endPoint == CGPoint.zero {
            if let point = path.firstPoint() {
                endPoint = CGPoint(x: rect.width - point.x - trackWidth * 1.5, y: point.y)
                totalArcDistance = getPointDistanceFromStart(to: endPoint)
                updateViews()
            }
        }
        
        color.setStroke()
        path.lineWidth = trackWidth
        
        if drawShadow {
            context?.setShadow(offset: CGSize(width: 0, height: 6), blur: 10)
        }
        
        context?.saveGState()
        context?.setLineDash(phase: 0, lengths: [thickness, 12.5 - thickness])
        
        path.stroke()
        
        context?.restoreGState()
    }
    
    private func drawMeter(in rect: CGRect, color: UIColor, startAngle: CGFloat, endAngle: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath()
        path.addArc(
            withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2 - trackWidth * 2 + 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        color.setStroke()
        path.lineWidth = 4
        
        context?.saveGState()
        context?.setLineDash(phase: 0, lengths: [1, 8])
        
        path.stroke()
        
        context?.restoreGState()
    }
    
    private func drawMeterIndicator(in rect: CGRect, color: UIColor, angle: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath()
        path.addArc(
            withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2 - trackWidth * 2 - 1.5,
            startAngle: angle - 0.01,
            endAngle: angle,
            clockwise: true
        )
        
        color.setStroke()
        path.lineWidth = 12
        
        context?.saveGState()
        context?.setLineDash(phase: 0, lengths: [1, totalArcDistance / 16])
        
        path.stroke()
        
        context?.restoreGState()
    }
    
    //  MARK: - Time functions -
    
    private func animateProgress(from start: CGFloat, to destination: CGFloat) {
        startValue = start
        destinationValue = destination
        
        timer?.invalidate()
        timer = nil
        
        if delegationMode == .singular {
            allowCallBack = false
        }
        
        timerProgress = 0
        timerTotalTime = TimeInterval(0.5)
        timerLastUpdate = Date.timeIntervalSinceReferenceDate
        
        switch countingMethod {
        case .linear:
            progressCounter = ProgressCounterLinear()
        case .easeIn:
            progressCounter = ProgressCounterEaseIn()
        case .easeOut:
            progressCounter = ProgressCounterEaseOut()
        case .easeInOut:
            progressCounter = ProgressCounterEaseInOut()
        }
        
        timer = CADisplayLink(target: self, selector: #selector(updateProgressValue(_:)))
        timer?.preferredFramesPerSecond = 30
        timer?.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        timer?.add(to: RunLoop.main, forMode: RunLoop.Mode.tracking)
    }
    
    @objc func updateProgressValue(_ timer: Timer) {
        let now = Date.timeIntervalSinceReferenceDate
        timerProgress = timerProgress + now - timerLastUpdate
        timerLastUpdate = now
        
        if timerProgress >= timerTotalTime {
            self.timer?.invalidate()
            self.timer = nil
            timerProgress = timerTotalTime
        }
        
        if timerProgress == timerTotalTime {
            allowCallBack = true
        }
        
        progress = currentTimerValue()
        
        if timerProgress == timerTotalTime {
            internalActionsInProgress = false
        }
    }
    
    @objc private func onCustomButton() {
        guard !isCustomControlActive else {
            return
        }
        isCustomControlActive = true
        onButtonAction()
    }
    
    private func currentTimerValue() -> CGFloat {
        if timerProgress == 0 {
            return 0
        } else if timerProgress >= timerTotalTime {
            return destinationValue
        }
        let newValue = progressCounter.update(CGFloat(timerProgress / timerTotalTime))
        return startValue + newValue * (destinationValue - startValue)
    }
    
    //  MARK: - Gestures -
    
    @objc private func onGesture(_ recognizer: UIGestureRecognizer) {
        let currentPoint = recognizer.location(in: self)
        if point(inside: currentPoint, with: nil) {
            let currentDistance = getPointDistanceFromStart(to: currentPoint)
            let canonicalProgress = (currentDistance / totalArcDistance) * 100
            let calculatedValue = max(0, min(canonicalProgress, 100))
            if recognizer is UITapGestureRecognizer {
                animateProgress(from: progress, to: calculatedValue)
            } else if recognizer is UIPanGestureRecognizer {
                if recognizer.state == .began && delegationMode == .singular {
                    allowCallBack = false
                }
                progress = calculatedValue
                if recognizer.state == .ended && delegationMode == .singular {
                    allowCallBack = true
                }
            }
        }
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let currentLimit = pow(center.x - point.x, 2) + pow(center.y - point.y, 2)
        
        let outerBoxLimit = pow(bounds.size.width / 2, 2)
        if currentLimit > outerBoxLimit {
            return false
        }
        
        let innerBoxLimit = pow(bounds.size.width / 4, 2)
        if currentLimit < innerBoxLimit {
            return false
        }
        
        let isInsideOfActiveBoundary = point.y < endPoint.y + bounds.size.height / 6  // 16% offset permit
        if !isInsideOfActiveBoundary {
            return false
        }
        
        return true
    }
    
    private func getPointDistanceFromStart(to point: CGPoint) -> CGFloat {
        let radii = bounds.width / 2 - trackWidth
        let circumference = radii * 2 * .pi
        let maxAngle = 360 + GaugeSliderView.startingAngle * 2
        
        var angle = radiansToDegrees(atan2(point.x - bounds.midX, point.y - bounds.midY)) + GaugeSliderView.startingAngle + 180.0
        angle = (90.0 - angle).truncatingRemainder(dividingBy: 360.0)
        
        while angle < 0.0 {
            angle += 360.0
        }
        if point.x < radii && angle > maxAngle {
            angle = 0
        }
        angle = max(0, min(angle, maxAngle))
        
        return angle / 360 * circumference
    }
    
    private func radiansToDegrees(_ angle: CGFloat) -> CGFloat {
        return angle / .pi * 180.0
    }
    
    //  MARK: - Init -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestures()
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestures()
        addViews()
    }
}
