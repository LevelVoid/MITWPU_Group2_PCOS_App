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
    private let logSleepButton = PillButton(type: .system)

    override func awakeFromNib() {
        super.awakeFromNib()
        Card.layer.cornerRadius = 20
        Card.layer.borderWidth = 0

        setupButton()
    }

    // MARK: - Button Setup

    private func setupButton() {
        // Log sleep button removed
    }

    // MARK: - Configure

    func configure(with healthKitSleep: SleepData?, manualLog: SleepLog?) {

        hideAll()

        if let data = healthKitSleep {
            // Cap at 24h to handle HealthKit overlapping-sample anomalies
            let capped = min(data.totalHours, 24.0)
            let h = Int(capped)
            let m = Int((capped - Double(h)) * 60)
            
            hoursValueLabel.text = "\(h)"
            minutesValueLabel.text = "\(m)"
            subtitleLabel.text = tipText(for: data.quality)
            moonIcon.tintColor = qualityColor(data.quality)

            showDataElements()

        } else if let log = manualLog {
            hoursValueLabel.text = "\(log.hours)"
            minutesValueLabel.text = "\(log.minutes)"
            subtitleLabel.text = observation(for: log.hours)
            subtitleLabel.textColor = .secondaryLabel
            moonIcon.tintColor = .label

            showDataElements()
            emptyStateLabel.isHidden = true

        } else {
            lastNightTitle.isHidden = false
            emptyStateLabel.isHidden = false
            logSleepButton.isHidden = true
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
        case ..<5: return "Under 5 hours disrupts cortisol and insulin regulation. Prioritise sleep tonight."
        case 5..<6: return "Below the recommended range. Sleep debt accumulates and can worsen PCOS symptoms."
        case 6..<7: return "Slightly under the 7–8 hour target. Consistent rest supports hormone balance."
        case 7...8: return "Within the optimal range. Quality sleep aids cortisol and metabolic function."
        case 9...10: return "Extended sleep may indicate recovery need. Monitor energy levels through the day."
        default:    return "Excess sleep can affect circadian rhythm. Aim for a consistent 7–8 hour window."
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
        case .poor:      return "Poor sleep elevates cortisol, impacting insulin and androgen levels."
        case .fair:      return "Fair sleep quality. An additional 30–60 min may reduce hormonal disruption."
        case .good:      return "Good sleep supports metabolic and reproductive hormone regulation."
        case .excellent: return "Optimal rest achieved. Consistent sleep strengthens hormonal and immune function."
        }
    }
}

// Custom button class to handle its own corner radius updates
class PillButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure pill shape on every layout update
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
}
