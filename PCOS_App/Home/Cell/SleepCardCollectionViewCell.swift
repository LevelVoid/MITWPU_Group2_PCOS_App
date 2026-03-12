//
//  SleepCardCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 04/02/26.
//


import UIKit

// MARK: - Delegate
protocol SleepCardCollectionViewCellDelegate: AnyObject {
    func sleepCardDidTapLogSleep(_ cell: SleepCardCollectionViewCell)
}

class SleepCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var Card: UIView!

    weak var delegate: SleepCardCollectionViewCellDelegate?

    @IBOutlet weak var lastNightTitle: UILabel!
    @IBOutlet weak var moonIcon: UIImageView!
    @IBOutlet weak var hoursValueLabel: UILabel!
    @IBOutlet weak var hoursTextLabel: UILabel!
    @IBOutlet weak var minutesValueLabel: UILabel!
    @IBOutlet weak var minutesTextLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emptyStateLabel: UILabel!

    // MARK: - Log Button
    private let logSleepButton = UIButton(type: .system)

    override func awakeFromNib() {
        super.awakeFromNib()
        Card.layer.cornerRadius = 20
        setupButton()
    }

    // MARK: - Button Setup

    private func setupButton() {

        logSleepButton.setTitle("Log Your Sleep", for: .normal)
        logSleepButton.setTitleColor(.white, for: .normal)
        logSleepButton.backgroundColor = UIColor(hex: "#FE7A96")
        logSleepButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        logSleepButton.layer.cornerRadius = 20
        logSleepButton.translatesAutoresizingMaskIntoConstraints = false

        logSleepButton.addTarget(
            self,
            action: #selector(logSleepTapped),
            for: .touchUpInside
        )

        Card.addSubview(logSleepButton)

        NSLayoutConstraint.activate([
            logSleepButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 16),
            logSleepButton.bottomAnchor.constraint(lessThanOrEqualTo: Card.bottomAnchor, constant: -20),
            logSleepButton.leadingAnchor.constraint(equalTo: Card.leadingAnchor, constant: 30),
            logSleepButton.trailingAnchor.constraint(equalTo: Card.trailingAnchor, constant: -30),
            logSleepButton.heightAnchor.constraint(equalToConstant: 34.33)
        ])
    }

    // MARK: - Configure

    func configure(with healthKitSleep: SleepData?, manualLog: SleepLog?) {

        hideAll()

        if let data = healthKitSleep {
            let h = Int(data.totalHours)
            let m = Int((data.totalHours - Double(h)) * 60)
            
            hoursValueLabel.text = "\(h)"
            minutesValueLabel.text = "\(m)"
            subtitleLabel.text = tipText(for: data.quality)
            moonIcon.tintColor = qualityColor(data.quality)

            showDataElements()

        } else if let log = manualLog {
            hoursValueLabel.text = "\(log.hours)"
            minutesValueLabel.text = "\(log.minutes)"
            subtitleLabel.text = observation(for: log.hours)
            moonIcon.tintColor = .label

            showDataElements()
            emptyStateLabel.isHidden = true

        } else {
            lastNightTitle.isHidden = false
            emptyStateLabel.isHidden = false
            logSleepButton.isHidden = false
        }
    }

    // MARK: - Actions

    @objc private func logSleepTapped() {
        delegate?.sleepCardDidTapLogSleep(self)
    }

    // MARK: - Helpers

    private func showDataElements() {
        lastNightTitle.isHidden = false
        moonIcon.isHidden = false
        hoursValueLabel.isHidden = false
        hoursTextLabel.isHidden = false
        minutesValueLabel.isHidden = false
        minutesTextLabel.isHidden = false
        subtitleLabel.isHidden = false
    }

    private func hideAll() {
        lastNightTitle.isHidden = true
        moonIcon.isHidden = true
        hoursValueLabel.isHidden = true
        hoursTextLabel.isHidden = true
        minutesValueLabel.isHidden = true
        minutesTextLabel.isHidden = true
        subtitleLabel.isHidden = true
        emptyStateLabel.isHidden = true
        logSleepButton.isHidden = true
    }

    private func observation(for hours: Int) -> String {
        switch hours {
        case ..<5: return "You slept very little. Try to rest more tonight."
        case 5..<6: return "Below recommended sleep. Aim for 7–8 hours."
        case 6..<7: return "Almost there! A little more sleep would help."
        case 7...8: return "Great sleep! This supports hormone balance."
        default: return "You slept more than usual. Listen to your body."
        }
    }

    private func qualityColor(_ quality: SleepQuality) -> UIColor {
        switch quality {
        case .poor: return UIColor(hex: "#FF6B6B")
        case .fair: return UIColor(hex: "#FFB347")
        case .good: return UIColor(hex: "#4CAF50")
        case .excellent: return UIColor(hex: "#7BC8F6")
        }
    }

    private func tipText(for quality: SleepQuality) -> String {
        switch quality {
        case .poor: return "Try to get at least 7h of sleep."
        case .fair: return "You're close! An extra 30–60 min helps."
        case .good: return "Great sleep! Helps hormone balance."
        case .excellent: return "Excellent sleep supports energy levels."
        }
    }
}
