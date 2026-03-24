//
//  SleepLoggerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/03/26.
//

import UIKit

class SleepLoggerViewController: UIViewController {
    
    // MARK: - Outlets (Kept to prevent storyboard crash)
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
    
    @IBOutlet weak var saveButton: UIButton! // Exact IBoutlet name
    @IBOutlet weak var notTodayButton: UIButton!
    
    // MARK: - Properties
    
    /// When true, shows alternate title/subtitle instead of default storyboard strings.
    var isNotNowMode: Bool = false
    var customTitle: String? = nil
    var customSubtitle: String? = nil
    var onSleepSaved: (() -> Void)?
    var onDismissedWithoutSaving: (() -> Void)?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let dismissButton = UIButton(type: .system)
    private let customSaveButton = UIButton(type: .system)
    
    private let bedIconCircle = UIView()
    private let bedIconImageView = UIImageView()
    private let customTitleLabel = UILabel()
    
    private let ratingsContainer = UIView()
    private var ratingRowViews: [UIView] = []
    
    private let pickersContainer = UIView()
    private let startsLabel = UILabel()
    private let startsPicker = UIDatePicker()
    private let endsLabel = UILabel()
    private let endsPicker = UIDatePicker()
    
    private let durationContainer = UIView()
    private let durationLabel = UILabel()
    private let durationValueLabel = UILabel()
    
    private var selectedRating: SleepRating = .normal
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgrammaticUI()
        setupDefaultTimes()
        updateRatingUI()
        presentationController?.delegate = self
    }
    
    // MARK: - Setup Logic
    private func setupDefaultTimes() {
        let now = Date()
        
        startsPicker.maximumDate = now
        endsPicker.maximumDate = now
        
        startsPicker.date = now
        endsPicker.date = now
    }
    
    private func setupProgrammaticUI() {
        // Hide all original storyboard outlets via subviews iteration if they exist
        view.subviews.forEach { $0.removeFromSuperview() }
        
        view.backgroundColor = .white
        
        // 1. Scroll View Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.isHidden = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        // 2. Top Nav
        setupTopNav()
        
        // 3. Bed Header
        setupBedHeader()
        
        // 4. Time Pickers
        setupTimePickersContainer()
        
        // 5. Duration
        setupDurationContainer()
        
        // 6. Ratings
        setupRatingsContainer()
        
        // Bottom pinning
        NSLayoutConstraint.activate([
            ratingsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func applyGlassmorphism(to button: UIButton) {
        button.backgroundColor = .white
        button.layer.cornerRadius = 28 // 56x56 from the constraints
        
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.systemGray6.cgColor

        // Subtle shadow around circle
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        button.clipsToBounds = false
    }
    
    private func setupTopNav() {
        // Dismiss Button
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        let xConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        dismissButton.setImage(UIImage(systemName: "xmark", withConfiguration: xConfig), for: .normal)
        dismissButton.tintColor = .label
        dismissButton.layer.cornerRadius = 28
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        contentView.addSubview(dismissButton)
        applyGlassmorphism(to: dismissButton)

        // Save Button
        customSaveButton.translatesAutoresizingMaskIntoConstraints = false
        let checkConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        customSaveButton.setImage(UIImage(systemName: "checkmark", withConfiguration: checkConfig), for: .normal)
        customSaveButton.tintColor = .label
        customSaveButton.layer.cornerRadius = 28
        customSaveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        contentView.addSubview(customSaveButton)
        applyGlassmorphism(to: customSaveButton)
        
        let navTitleLabel = UILabel()
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.text = "Log your sleep"
        navTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        navTitleLabel.textColor = .black
        navTitleLabel.textAlignment = .center
        contentView.addSubview(navTitleLabel)
        
        NSLayoutConstraint.activate([
            dismissButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dismissButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            dismissButton.widthAnchor.constraint(equalToConstant: 56),
            dismissButton.heightAnchor.constraint(equalToConstant: 56),
            
            navTitleLabel.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor),
            navTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            customSaveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            customSaveButton.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor),
            customSaveButton.widthAnchor.constraint(equalToConstant: 56),
            customSaveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupBedHeader() {
        bedIconCircle.translatesAutoresizingMaskIntoConstraints = false
        bedIconCircle.backgroundColor = .clear
        contentView.addSubview(bedIconCircle)
        
        bedIconImageView.translatesAutoresizingMaskIntoConstraints = false
        bedIconImageView.image = UIImage(named: "sleep_illustration")
        bedIconImageView.contentMode = .scaleAspectFill
        bedIconImageView.clipsToBounds = true
        bedIconImageView.layer.cornerRadius = 24
        bedIconCircle.addSubview(bedIconImageView)
        
        customTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        customTitleLabel.text = "Sleep Logger"
        customTitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        customTitleLabel.textColor = .black
        customTitleLabel.textAlignment = .center
        customTitleLabel.isHidden = true // The uploaded design has no text below the illustration, only on the nav bar. Let's hide it from the body.
        contentView.addSubview(customTitleLabel)
        
        NSLayoutConstraint.activate([
            bedIconCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bedIconCircle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 16),
            bedIconCircle.widthAnchor.constraint(equalToConstant: 240),
            bedIconCircle.heightAnchor.constraint(equalToConstant: 200),
            
            bedIconImageView.leadingAnchor.constraint(equalTo: bedIconCircle.leadingAnchor),
            bedIconImageView.trailingAnchor.constraint(equalTo: bedIconCircle.trailingAnchor),
            bedIconImageView.topAnchor.constraint(equalTo: bedIconCircle.topAnchor),
            bedIconImageView.bottomAnchor.constraint(equalTo: bedIconCircle.bottomAnchor),
            
            customTitleLabel.topAnchor.constraint(equalTo: bedIconCircle.bottomAnchor, constant: 0),
            customTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customTitleLabel.heightAnchor.constraint(equalToConstant: 0) // Collapse space
        ])
    }
    
    private func setupRatingsContainer() {
        ratingsContainer.translatesAutoresizingMaskIntoConstraints = false
        ratingsContainer.backgroundColor = .white
        ratingsContainer.layer.cornerRadius = 16
        ratingsContainer.layer.borderWidth = 1
        ratingsContainer.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(ratingsContainer)
        
        NSLayoutConstraint.activate([
            ratingsContainer.topAnchor.constraint(equalTo: durationContainer.bottomAnchor, constant: 16),
            ratingsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            ratingsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        var previousRowBottom: NSLayoutYAxisAnchor = ratingsContainer.topAnchor
        
        for (index, rating) in SleepRating.allCases.enumerated() {
            let rowView = UIView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            rowView.tag = rating.rawValue
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ratingTapped(_:)))
            rowView.addGestureRecognizer(tap)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = rating.title
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .gray
            label.tag = 101
            rowView.addSubview(label)
            
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            let checkConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            checkmark.preferredSymbolConfiguration = checkConfig
            checkmark.tintColor = UIColor(hex: "#007AFF")
            checkmark.isHidden = true
            checkmark.tag = 102
            rowView.addSubview(checkmark)
            
            ratingsContainer.addSubview(rowView)
            ratingRowViews.append(rowView)
            
            NSLayoutConstraint.activate([
                rowView.topAnchor.constraint(equalTo: previousRowBottom),
                rowView.leadingAnchor.constraint(equalTo: ratingsContainer.leadingAnchor),
                rowView.trailingAnchor.constraint(equalTo: ratingsContainer.trailingAnchor),
                rowView.heightAnchor.constraint(equalToConstant: 48),
                
                label.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
                label.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                
                checkmark.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
                checkmark.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
            ])
            
            previousRowBottom = rowView.bottomAnchor
            
            if index < SleepRating.allCases.count - 1 {
                let divider = UIView()
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.backgroundColor = UIColor.systemGray5
                ratingsContainer.addSubview(divider)
                
                NSLayoutConstraint.activate([
                    divider.topAnchor.constraint(equalTo: rowView.bottomAnchor),
                    divider.leadingAnchor.constraint(equalTo: ratingsContainer.leadingAnchor, constant: 16),
                    divider.trailingAnchor.constraint(equalTo: ratingsContainer.trailingAnchor, constant: -16),
                    divider.heightAnchor.constraint(equalToConstant: 1)
                ])
                previousRowBottom = divider.bottomAnchor
            }
        }
        
        ratingsContainer.bottomAnchor.constraint(equalTo: previousRowBottom, constant: 8).isActive = true
    }
    
    private func setupTimePickersContainer() {
        pickersContainer.translatesAutoresizingMaskIntoConstraints = false
        pickersContainer.backgroundColor = .white
        pickersContainer.layer.cornerRadius = 16
        pickersContainer.layer.borderWidth = 1
        pickersContainer.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(pickersContainer)
        
        NSLayoutConstraint.activate([
            pickersContainer.topAnchor.constraint(equalTo: customTitleLabel.bottomAnchor, constant: 32),
            pickersContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            pickersContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // Starts
        startsLabel.translatesAutoresizingMaskIntoConstraints = false
        startsLabel.text = "Starts"
        startsLabel.font = .systemFont(ofSize: 16)
        startsLabel.textColor = .gray
        pickersContainer.addSubview(startsLabel)
        
        startsPicker.translatesAutoresizingMaskIntoConstraints = false
        startsPicker.datePickerMode = .dateAndTime
        startsPicker.preferredDatePickerStyle = .compact
        startsPicker.tintColor = UIColor(hex: "#007AFF")
        startsPicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        pickersContainer.addSubview(startsPicker)
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.systemGray5
        pickersContainer.addSubview(divider)
        
        // Ends
        endsLabel.translatesAutoresizingMaskIntoConstraints = false
        endsLabel.text = "Ends"
        endsLabel.font = .systemFont(ofSize: 16)
        endsLabel.textColor = .gray
        pickersContainer.addSubview(endsLabel)
        
        endsPicker.translatesAutoresizingMaskIntoConstraints = false
        endsPicker.datePickerMode = .dateAndTime
        endsPicker.preferredDatePickerStyle = .compact
        endsPicker.tintColor = UIColor(hex: "#007AFF")
        endsPicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        pickersContainer.addSubview(endsPicker)
        
        NSLayoutConstraint.activate([
            startsLabel.leadingAnchor.constraint(equalTo: pickersContainer.leadingAnchor, constant: 16),
            startsLabel.topAnchor.constraint(equalTo: pickersContainer.topAnchor, constant: 16),
            
            startsPicker.trailingAnchor.constraint(equalTo: pickersContainer.trailingAnchor, constant: -16),
            startsPicker.centerYAnchor.constraint(equalTo: startsLabel.centerYAnchor),
            
            divider.topAnchor.constraint(equalTo: startsLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: pickersContainer.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: pickersContainer.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            endsLabel.leadingAnchor.constraint(equalTo: pickersContainer.leadingAnchor, constant: 16),
            endsLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            endsLabel.bottomAnchor.constraint(equalTo: pickersContainer.bottomAnchor, constant: -16),
            
            endsPicker.trailingAnchor.constraint(equalTo: pickersContainer.trailingAnchor, constant: -16),
            endsPicker.centerYAnchor.constraint(equalTo: endsLabel.centerYAnchor)
        ])
    }
    
    private func setupDurationContainer() {
        durationContainer.translatesAutoresizingMaskIntoConstraints = false
        durationContainer.backgroundColor = .white
        durationContainer.layer.cornerRadius = 16
        durationContainer.layer.borderWidth = 1
        durationContainer.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(durationContainer)
        
        NSLayoutConstraint.activate([
            durationContainer.topAnchor.constraint(equalTo: pickersContainer.bottomAnchor, constant: 16),
            durationContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            durationContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = "You slept for"
        durationLabel.font = .systemFont(ofSize: 16)
        durationLabel.textColor = .gray
        durationContainer.addSubview(durationLabel)
        
        durationValueLabel.translatesAutoresizingMaskIntoConstraints = false
        durationValueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        durationValueLabel.textColor = .black
        durationContainer.addSubview(durationValueLabel)
        
        NSLayoutConstraint.activate([
            durationLabel.leadingAnchor.constraint(equalTo: durationContainer.leadingAnchor, constant: 16),
            durationLabel.topAnchor.constraint(equalTo: durationContainer.topAnchor, constant: 20),
            durationLabel.bottomAnchor.constraint(equalTo: durationContainer.bottomAnchor, constant: -20),
            
            durationValueLabel.trailingAnchor.constraint(equalTo: durationContainer.trailingAnchor, constant: -16),
            durationValueLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor)
        ])
        
        updateDurationLabel()
    }
    
    // MARK: - Actions
    
    @objc private func ratingTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let rating = SleepRating(rawValue: view.tag) else { return }
        selectedRating = rating
        updateRatingUI()
    }
    
    private func updateRatingUI() {
        for row in ratingRowViews {
            let label = row.viewWithTag(101) as? UILabel
            let checkmark = row.viewWithTag(102) as? UIImageView
            
            if row.tag == selectedRating.rawValue {
                label?.textColor = .black
                checkmark?.isHidden = false
            } else {
                label?.textColor = .gray
                checkmark?.isHidden = true
            }
        }
    }
    
    @objc private func timeChanged() {
        var sleepTime = startsPicker.date
        var wakeTime = endsPicker.date
        
        // Auto-adjust wake day logic 
        if wakeTime < sleepTime {
            wakeTime = Calendar.current.date(byAdding: .day, value: 1, to: wakeTime) ?? wakeTime
            endsPicker.date = wakeTime
        }
        
        updateDurationLabel()
    }
    
    private func updateDurationLabel() {
        let tempLog = SleepLog(sleepTime: startsPicker.date, wakeTime: endsPicker.date, rating: selectedRating)
        durationValueLabel.text = tempLog.displayString
    }
    
    @objc private func dismissTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissedWithoutSaving?()
        }
    }
    
    @objc private func saveTapped() {
        let sleepLog = SleepLog(sleepTime: startsPicker.date, wakeTime: endsPicker.date, rating: selectedRating)
        SleepDataStore.shared.saveSleepLog(sleepLog)
        
        dismiss(animated: true) { [weak self] in
            self?.onSleepSaved?()
        }
    }
}

// MARK: - Swipe-to-dismiss detection
extension SleepLoggerViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismissedWithoutSaving?()
    }
}

