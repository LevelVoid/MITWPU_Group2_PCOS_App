//
//  SleepLoggerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/03/26.
//

import UIKit

class SleepLoggerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var sleepTimeLabel: UILabel!
    @IBOutlet weak var sleepTimeTextField: UITextField!
    @IBOutlet weak var sleepTimeChevron: UIImageView!
    
    @IBOutlet weak var wakeTimeLabel: UILabel!
    @IBOutlet weak var wakeTimeTextField: UITextField!
    @IBOutlet weak var wakeTimeChevron: UIImageView!
    
    @IBOutlet weak var totalSleepLabel: UILabel!
    @IBOutlet weak var totalSleepValueLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingSlider: UISlider!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var notTodayButton: UIButton!
    
    // MARK: - Properties
    private let sleepTimePicker = UIDatePicker()
    private let wakeTimePicker = UIDatePicker()
    
    /// When true, shows alternate title/subtitle instead of default storyboard strings.
    var isNotNowMode: Bool = false

    /// Optional override for the title label (takes precedence over isNotNowMode defaults).
    var customTitle: String? = nil

    /// Optional override for the subtitle label (takes precedence over isNotNowMode defaults).
    var customSubtitle: String? = nil
    
    /// Called after the user successfully saves their sleep log.
    var onSleepSaved: (() -> Void)?

    /// Called when the user taps "Not Now" — lets the caller know to show the pink log button.
    var onDismissedWithoutSaving: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCloseButton()
        setupPickers()
        updateTotalSleep()
        applyModeLabels()
        // Detect swipe-to-dismiss
        presentationController?.delegate = self
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // The sheet controller provides its own dimmed backdrop – no need for a custom one
        view.backgroundColor = .systemBackground
        
        // Container
        containerView.layer.cornerRadius = 24
        containerView.backgroundColor = .white
        
        // Chevrons
        sleepTimeChevron.tintColor = UIColor(hex: "#FE7A96")
        wakeTimeChevron.tintColor = UIColor(hex: "#FE7A96")
        
        // Save button
        saveButton.backgroundColor = UIColor(hex: "#FE7A96")
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 25
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        // Wire programmatically (storyboard IBAction connections are absent)
        saveButton.addTarget(self, action: #selector(saveTapped(_:)), for: .touchUpInside)
        
        // Not today button
        notTodayButton.setTitleColor(.gray, for: .normal)
        notTodayButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        // Wire programmatically
        notTodayButton.addTarget(self, action: #selector(notTodayTapped(_:)), for: .touchUpInside)
        
        // Rating slider
        ratingSlider.minimumValue = 1.0
        ratingSlider.maximumValue = 5.0
        ratingSlider.value = 3.5
        ratingSlider.minimumTrackTintColor = UIColor(hex: "#FE7A96")
        ratingSlider.maximumTrackTintColor = UIColor(hex: "#FE7A96").withAlphaComponent(0.2)
        // Wire programmatically
        ratingSlider.addTarget(self, action: #selector(ratingSliderChanged(_:)), for: .valueChanged)
    }

    private func setupCloseButton() {
        let closeImage = UIImage(systemName: "xmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .regular))
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.systemGray3
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    /// Applies title/subtitle overrides — customTitle/customSubtitle take priority, then isNotNowMode defaults.
    private func applyModeLabels() {
        if let title = customTitle {
            titleLabel.text = title
        } else if isNotNowMode {
            titleLabel.text = "Welcome Back!"
        }

        if let subtitle = customSubtitle {
            subtitleLabel.text = subtitle
        } else if isNotNowMode {
            subtitleLabel.text = "Log your sleep today"
        }
        // else: keep whatever text is set in the XIB/Storyboard
    }
    
    private func setupPickers() {
        // Sleep time picker
        sleepTimePicker.datePickerMode = .time
        sleepTimePicker.preferredDatePickerStyle = .wheels
        sleepTimePicker.addTarget(self, action: #selector(sleepTimeChanged), for: .valueChanged)
        
        // Set default to 11:45 PM
        let calendar = Calendar.current
        if let sleepTime = calendar.date(bySettingHour: 23, minute: 45, second: 0, of: Date()) {
            sleepTimePicker.date = sleepTime
        }
        
        sleepTimeTextField.inputView = sleepTimePicker
        sleepTimeTextField.text = formatTime(sleepTimePicker.date)
        
        // Wake time picker
        wakeTimePicker.datePickerMode = .time
        wakeTimePicker.preferredDatePickerStyle = .wheels
        wakeTimePicker.addTarget(self, action: #selector(wakeTimeChanged), for: .valueChanged)
        
        // Set default to 7:05 AM
        if let wakeTime = calendar.date(bySettingHour: 7, minute: 5, second: 0, of: Date()) {
            wakeTimePicker.date = wakeTime
        }
        
        wakeTimeTextField.inputView = wakeTimePicker
        wakeTimeTextField.text = formatTime(wakeTimePicker.date)
        
        // Toolbar for pickers
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePickerTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        sleepTimeTextField.inputAccessoryView = toolbar
        wakeTimeTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissedWithoutSaving?()
        }
    }

    @objc private func sleepTimeChanged() {
        sleepTimeTextField.text = formatTime(sleepTimePicker.date)
        updateTotalSleep()
    }
    
    @objc private func wakeTimeChanged() {
        wakeTimeTextField.text = formatTime(wakeTimePicker.date)
        updateTotalSleep()
    }
    
    @objc private func donePickerTapped() {
        view.endEditing(true)
    }
    
    @objc func ratingSliderChanged(_ sender: UISlider) {
        // Slider value stored on save; no live label needed right now
    }
    
    @objc func saveTapped(_ sender: UIButton) {
        let sleepLog = SleepLog(
            sleepTime: sleepTimePicker.date,
            wakeTime: wakeTimePicker.date,
            rating: Double(ratingSlider.value)
        )
        SleepDataStore.shared.saveSleepLog(sleepLog)
        
        dismiss(animated: true) { [weak self] in
            self?.onSleepSaved?()
        }
    }

    @objc func notTodayTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.onDismissedWithoutSaving?()
        }
    }

    // MARK: - Helpers
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func updateTotalSleep() {
        var sleepTime = sleepTimePicker.date
        var wakeTime = wakeTimePicker.date
        
        // If wake time is earlier than sleep time, assume wake time is next day
        if wakeTime < sleepTime {
            wakeTime = Calendar.current.date(byAdding: .day, value: 1, to: wakeTime) ?? wakeTime
        }
        
        let duration = wakeTime.timeIntervalSince(sleepTime)
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        totalSleepValueLabel.text = "\(hours) hours \(minutes) mins"
    }
}

// MARK: - Swipe-to-dismiss detection
extension SleepLoggerViewController: UIAdaptivePresentationControllerDelegate {
    /// Called when the user swipes the sheet down to dismiss it
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismissedWithoutSaving?()
    }
}

