import Foundation
import UIKit

let ORDER_TIME_GAP = 15
let START_HOUR = 7
let END_HOUR = 22
//let END_HOUR = 20

private extension Selector {
    static let buttonTapped = #selector(DatePickerDialog.buttonTapped)
    static let deviceOrientationDidChange = #selector(DatePickerDialog.deviceOrientationDidChange)
}

open class DatePickerDialog: UIView {
    public typealias DatePickerCallback = ( Date? ) -> Void

    // MARK: - Constants
    private let kDefaultButtonHeight: CGFloat = 50
    private let kDefaultButtonSpacerHeight: CGFloat = 1
    private let kCornerRadius: CGFloat = 7
    private let kDoneButtonTag: Int = 1

    // MARK: - Views
    private var dialogView: UIView!
    
    private var titleLabel: UILabel!
    private var descLabel: UILabel!
//    private var timeSlot: UILabel!
    private var timeDelayLabel: UILabel!
    
    open var datePicker: UIDatePicker!
    var startTime:Int! = START_HOUR
    var endTime:Int! = END_HOUR
    private var cancelButton: UIButton!
    private var doneButton: UIButton!

    // MARK: - Variables
    private var defaultDate: Date?
    private var datePickerMode: UIDatePicker.Mode?
    private var callback: DatePickerCallback?
    var showCancelButton: Bool = false
    var locale: Locale?

    private var textColor: UIColor!
    private var buttonColor: UIColor!
    private var font: UIFont!
    
//    public var tint: UIColor = {
//        if #available(iOS 13, *) {
//            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
//                if UITraitCollection.userInterfaceStyle == .dark {
//                    /// Return the color for Dark Mode
//                    return .gray
//                } else {
//                    /// Return the color for Light Mode
//                    return .white
//                }
//            }
//        } else {
//            /// Return a fallback color for iOS 12 and lower.
//            return .white
//        }
//    }()

    // MARK: - Dialog initialization
    @objc public init(textColor: UIColor = UIColor.black,
                buttonColor: UIColor = UIColor.blue,
                font: UIFont = .boldSystemFont(ofSize: 15),
                locale: Locale? = nil,
                showCancelButton: Bool = true) {
        let size = UIScreen.main.bounds.size
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.textColor = textColor
        self.buttonColor = buttonColor
        self.font = font
        self.showCancelButton = showCancelButton
        self.locale = locale
        setupView()
    }

    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupView() {
        dialogView = createContainerView()

        dialogView?.layer.shouldRasterize = true
        dialogView?.layer.rasterizationScale = UIScreen.main.scale

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        dialogView?.layer.opacity = 0.5
        dialogView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
//        dialogView?.backgroundColor = self.tint

        if let dialogView = dialogView {
            addSubview(dialogView)
        }
    }

    /// Handle device orientation changes
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        self.frame = UIScreen.main.bounds
        let dialogSize = CGSize(width: 300, height: 230 + kDefaultButtonHeight + kDefaultButtonSpacerHeight)
        dialogView.frame = CGRect(
            x: (UIScreen.main.bounds.size.width - dialogSize.width) / 2,
            y: (UIScreen.main.bounds.size.height - dialogSize.height) / 2,
            width: dialogSize.width,
            height: dialogSize.height
        )
    }

    /// Create the dialog view, and animate opening the dialog
    open func show(
        _ title: String,
        doneButtonTitle: String = "Done",
        cancelButtonTitle: String = "Cancel",
        defaultDate: Date = Date(),
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        datePickerMode: UIDatePicker.Mode = .dateAndTime,
        callback: @escaping DatePickerCallback
    ) {
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: .normal)
        if showCancelButton { self.cancelButton.setTitle(cancelButtonTitle, for: .normal) }
        self.datePickerMode = datePickerMode
        self.callback = callback
        self.defaultDate = defaultDate
//        defaultDate.
        self.datePicker.datePickerMode = self.datePickerMode ?? UIDatePicker.Mode.date
        self.datePicker.date = self.defaultDate ?? Date()
        
        if let locale = self.locale { self.datePicker.locale = locale }

        /* Add dialog to main window */
        guard let appDelegate = UIApplication.shared.delegate else { fatalError() }
        guard let window = appDelegate.window else { fatalError() }
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)

        NotificationCenter.default.addObserver(
            self,
            selector: .deviceOrientationDidChange,
            name: UIDevice.orientationDidChangeNotification, object: nil
        )

        /* Anim */
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.dialogView?.layer.opacity = 1
                self.dialogView?.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }
        )
    }

    /// Dialog close animation then cleaning and removing the view from the parent
    private func close() {
        let currentTransform = self.dialogView.layer.transform

        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + .pi * 270 / 180), 0, 0, 0)

        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [],
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
//                self.backgroundColor = self.tint
                let transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.transform = transform
                self.dialogView.layer.opacity = 0
            }
        ) { _ in
            for v in self.subviews {
                v.removeFromSuperview()
            }

            self.removeFromSuperview()
            self.setupView()
        }
    }

    /// Creates the container view here: create the dialog, then add the custom content and buttons
    private func createContainerView() -> UIView {
        let screenSize = UIScreen.main.bounds.size
        let dialogSize = CGSize(width: 340, height: 260 + kDefaultButtonHeight + kDefaultButtonSpacerHeight)

        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)

        // This is the dialog's container; we attach the custom content and the buttons to this one
        let container = UIView(frame: CGRect(
            x: (screenSize.width - dialogSize.width) / 2,
            y: (screenSize.height - dialogSize.height) / 2,
            width: dialogSize.width,
            height: dialogSize.height
        ))

        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = container.bounds
        gradient.colors = [
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor
        ]

        let cornerRadius = kCornerRadius
        gradient.cornerRadius = cornerRadius
        container.layer.insertSublayer(gradient, at: 0)

        container.layer.cornerRadius = cornerRadius
        container.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        container.layer.borderWidth = 1
        container.layer.shadowRadius = cornerRadius + 5
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowPath = UIBezierPath(
            roundedRect: container.bounds,
            cornerRadius: container.layer.cornerRadius
        ).cgPath
        
        
        
        
        
//        container.backgroundColor = self.tint

        // There is a line above the button
        let yPosition = container.bounds.size.height - kDefaultButtonHeight - kDefaultButtonSpacerHeight
        let lineView = UIView(frame: CGRect(
            x: 0,
            y: yPosition,
            width: container.bounds.size.width,
            height: kDefaultButtonSpacerHeight
        ))

        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        container.addSubview(lineView)

        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 320, height: 30))
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = self.textColor
        self.titleLabel.font = self.font.withSize(17)
        container.addSubview(self.titleLabel)
        
        //Description
        self.descLabel = UILabel(frame: CGRect(x: 10, y: 40, width: 320, height: 20))
        self.descLabel.textAlignment = .center
        self.descLabel.textColor = self.textColor
        self.descLabel.font = self.font.withSize(12)
        container.addSubview(self.descLabel)
//
//
//        self.timeSlot = UILabel(frame: CGRect(x: 10, y: 40, width: 320, height: 20))
//        self.timeSlot.textAlignment = .center
//        self.timeSlot.textColor = self.textColor
//        self.timeSlot.font = self.font.withSize(12)
//        container.addSubview(self.timeSlot)
        
        
        //Title
        self.timeDelayLabel = UILabel(frame: CGRect(x: 10, y: 60, width: 320, height: 20))
        self.timeDelayLabel.textAlignment = .center
        self.timeDelayLabel.textColor = self.textColor
        self.timeDelayLabel.font = self.font.withSize(12)
        container.addSubview(self.timeDelayLabel)
        
        
        //Time Slot
//        self.timeSlot = UILabel(frame: CGRect(x: 10, y: 60, width: 320, height: 20))
//        self.timeSlot.textAlignment = .center
//        self.timeSlot.textColor = self.textColor
//        self.timeSlot.font = self.font.withSize(12)
//        container.addSubview(self.timeSlot)

        self.datePicker = configuredDatePicker()
        container.addSubview(self.datePicker)

        // Add the buttons
        addButtonsToView(container: container)

        return container
    }

    fileprivate func configuredDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 60, width: 0, height: 0))
        datePicker.setValue(self.textColor, forKeyPath: "textColor")
        datePicker.autoresizingMask = .flexibleRightMargin
        datePicker.frame.size.width = 340
//        datePicker.date.addTimeInterval(50000)
        datePicker.frame.size.height = 216
        datePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
//        datePicker.backgroundColor = self.tint
        return datePicker
    }

    /// Add buttons to container
    private func addButtonsToView(container: UIView) {
        var buttonWidth = container.bounds.size.width / 2

        var leftButtonFrame = CGRect(
            x: 0,
            y: container.bounds.size.height - kDefaultButtonHeight,
            width: buttonWidth,
            height: kDefaultButtonHeight
        )
        var rightButtonFrame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - kDefaultButtonHeight,
            width: buttonWidth,
            height: kDefaultButtonHeight
        )
        if showCancelButton == false {
            buttonWidth = container.bounds.size.width
            leftButtonFrame = CGRect()
            rightButtonFrame = CGRect(
                x: 0,
                y: container.bounds.size.height - kDefaultButtonHeight,
                width: buttonWidth,
                height: kDefaultButtonHeight
            )
        }
        let interfaceLayoutDirection = UIApplication.shared.userInterfaceLayoutDirection
        let isLeftToRightDirection = interfaceLayoutDirection == .leftToRight

        if showCancelButton {
            self.cancelButton = UIButton(type: .custom) as UIButton
            self.cancelButton.frame = isLeftToRightDirection ? leftButtonFrame : rightButtonFrame
            self.cancelButton.setTitleColor(self.buttonColor, for: .normal)
            self.cancelButton.setTitleColor(self.buttonColor, for: .highlighted)
            self.cancelButton.titleLabel?.font = self.font.withSize(14)
            self.cancelButton.layer.cornerRadius = kCornerRadius
            self.cancelButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
            container.addSubview(self.cancelButton)
        }

        self.doneButton = UIButton(type: .custom) as UIButton
        self.doneButton.frame = isLeftToRightDirection ? rightButtonFrame : leftButtonFrame
        self.doneButton.tag = kDoneButtonTag
        self.doneButton.setTitleColor(self.buttonColor, for: .normal)
        self.doneButton.setTitleColor(self.buttonColor, for: .highlighted)
        self.doneButton.titleLabel?.font = self.font.withSize(14)
        self.doneButton.layer.cornerRadius = kCornerRadius
        self.doneButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
        container.addSubview(self.doneButton)
    }

    @objc func buttonTapped(sender: UIButton) {
        if sender.tag == kDoneButtonTag {
            print(datePicker.date)
            self.callback?(self.datePicker.date)
        } else {
            self.callback?(nil)
        }

        close()
    }
    
    open func show(
        _ title: String,
        doneButtonTitle: String = "Done",
        cancelButtonTitle: String = "Cancel",
        startTime:Int,
        endTime:Int,
        minimumDate: Date? = nil,
        datePickerMode: UIDatePicker.Mode = .dateAndTime,
        callback: @escaping DatePickerCallback
    ) {
//
//        let mate = Date()
//        Calendar.current.date(byAdding: .day, value: 2, to: mate)
        let calendar = Calendar.current
//        let date = calendar.date(bySettingHour: 18, minute: 2, second: 2, of: Date())!
        let date = Date()
        
        var timeInterval = DateComponents()
//        timeInterval.month = 2
//        timeInterval.day = 3
        timeInterval.hour = 3
//        timeInterval.minute = 5
//        timeInterval.second = 6
//        let futureDate = Calendar.current.date(byAdding: timeInterval, to: Date())!

        var sTime = START_HOUR
        let hour = calendar.component(.hour, from: date)
        var isNextDay:Bool = false;
        let minGapPlusCTime = hour + ORDER_TIME_GAP
        if(minGapPlusCTime > endTime){
            isNextDay = true
        }
        
        if(isNextDay){
            let diff = (minGapPlusCTime) - (24)
            
            if diff <= startTime {
                sTime = diff + (startTime - diff)
            }
            else{
                sTime = diff
            }
            
            
        } else {
            sTime = minGapPlusCTime
        }
        


        let cDate = isNextDay ? Calendar.current.date(byAdding: .day, value: 1, to: date) : date
//        cDate?.addingTimeInterval(TimeInterval(10 * 60))
        
        var minDateComponents = calendar.dateComponents([.day, .month, .year], from: cDate!)
        
        minDateComponents.setValue(sTime, for: .hour)
        minDateComponents.minute = 0

        self.titleLabel.text = "Delivery Time"
        self.descLabel.text = "Select Time 7:00 AM - 11:00 PM"
        
//        self.timeSlot.text = "Expected delivery time between \(getTime(time: hour)) - \(getTime(time: hour + 2))"
        
        self.doneButton.setTitle(doneButtonTitle, for: .normal)
        if showCancelButton { self.cancelButton.setTitle(cancelButtonTitle, for: .normal) }
        self.datePickerMode = datePickerMode
        self.callback = callback
//        self.datePicker.minuteInterval = 30
//        self.datePicker.date.addingTimeInterval(30.0 * 60)
        
        self.datePicker.date = Calendar.current.date(from: minDateComponents)! //self.defaultDate ?? Date()
        
        self.datePicker.minimumDate = Calendar.current.date(from: minDateComponents)
        
//        self.datePicker.minimumDate = Calendar.current.date(byAdding: timeInterval, to: self.datePicker.date)
        
//        self.datePicker.minimumDate?.addingTimeInterval(TimeInterval(30 * 60))
        if let locale = self.locale {
            self.datePicker.locale = locale
        }

        /* Add dialog to main window */
        
        guard let appDelegate = UIApplication.shared.delegate else { fatalError() }
        guard let window = appDelegate.window else { fatalError() }
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)

        NotificationCenter.default.addObserver(
            self,
            selector: .deviceOrientationDidChange,
            name: UIDevice.orientationDidChangeNotification, object: nil
        )

        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView?.layer.opacity = 1
                self.dialogView?.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }
        )
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: picker.date)
        let minute = calendar.component(.minute, from: picker.date)
        
        
        if(hour < self.startTime){
            var minDateComponents = calendar.dateComponents([.day, .month, .year], from: picker.date)
            minDateComponents.setValue(self.startTime, for: .hour)
            self.datePicker.setDate(Calendar.current.date(from: minDateComponents)!, animated: true)
//            self.timeSlot.text = "Expected delivery time between \(getTime(time: hour)) - \(getTime(time: hour + 2))"
            
        }else if(hour >= self.endTime && minute >= 0){
            var maxDateComponents = calendar.dateComponents([.day, .month, .year], from: picker.date)
            maxDateComponents.setValue(self.endTime, for: .hour)
                maxDateComponents.setValue(0, for: .minute)
                self.datePicker.setDate(Calendar.current.date(from: maxDateComponents)!, animated: true)
//                self.timeSlot.text = "Expected delivery time between \(getTime(time: hour)) - \(getTime(time: hour + 2))"
                
        }
    }
    
    func getTime(time: Int) -> String {
        if (time < 12){
            return "\(time):00Am"
        }else {
            return "\(time - 12):00Pm"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
