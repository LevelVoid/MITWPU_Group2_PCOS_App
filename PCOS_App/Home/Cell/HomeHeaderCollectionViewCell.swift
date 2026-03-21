//
//  HomeHeaderCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

protocol HomeHeaderCollectionViewCellDelegate: AnyObject {
    func homeHeaderCellDidTapLogPeriod(_ cell: HomeHeaderCollectionViewCell)
}

class HomeHeaderCollectionViewCell: UICollectionViewCell {
    
    
    //@IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var expectedLabel: UILabel!
    @IBOutlet weak var headerCardView: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cycleDayLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var predictionLabel: UILabel!
    @IBOutlet weak var logPeriodButton: UIButton!
    @IBOutlet weak var calendarIcon: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    weak var delegate: HomeHeaderCollectionViewCellDelegate?
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        cellView.backgroundColor = .clear
        
        // Bottom constraint added in code (not XIB) to avoid canvas size conflicts
        let bottomConstraint = cellView.bottomAnchor.constraint(equalTo: headerCardView.bottomAnchor, constant: 16)
        bottomConstraint.priority = UILayoutPriority(999)
        bottomConstraint.isActive = true
        
        headerCardView.backgroundColor = .clear
        headerCardView.layer.cornerRadius = 24
        headerCardView.clipsToBounds = true
        setupGradient()
        
        expectedLabel.textColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.60)
        
        // Make the button a perfect pill using UIButton.Configuration
        if var config = logPeriodButton.configuration {
            config.cornerStyle = .capsule
            logPeriodButton.configuration = config
        }
        logPeriodButton.tintColor = UIColor(hex: "#ffffff").withAlphaComponent(0.25)
        logPeriodButton.addTarget(self, action: #selector(logPeriodButtonTapped), for: .touchUpInside)
    }
    
    @objc private func logPeriodButtonTapped() {
        delegate?.homeHeaderCellDidTapLogPeriod(self)
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.949, green: 0.541, blue: 0.690, alpha: 1).cgColor, // #f28ab0
            UIColor(red: 0.910, green: 0.376, blue: 0.478, alpha: 1).cgColor  // #e8607a
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.cornerRadius = 24
        
        // Ensure view's own background doesn't paint over the gradient
        headerCardView.backgroundColor = .clear
        // Insert behind all subviews
        headerCardView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Gradient frame updated here — bounds are correct now
        gradientLayer.frame = headerCardView.bounds
    }
    
    // MARK: - Public Configuration
    
    func configure(cycleDay: Int, phase: Phase, prediction: PeriodPrediction) {
        // ── Cycle Day ──
        cycleDayLabel.text = cycleDay > 0 ? "Cycle Day \(cycleDay)" : "No Cycle Logged"
        
        // ── Phase Label ──
        if phase == .unknown {
            phaseLabel.isHidden = true
        } else {
            phaseLabel.isHidden = false
            phaseLabel.text = phase.displayName
        }
        
        // ── Quote ──
        quoteLabel.text = phase.quote
        
        // ── Prediction Section ──
        // Always keep the prediction row visible so the card layout stays consistent
        configurePrediction(prediction, cycleDay: cycleDay)
    }
    
    private func configurePrediction(_ prediction: PeriodPrediction, cycleDay: Int) {
        // Always show the separator, icon, and labels — just change the content
        separatorView.isHidden = false
        calendarIcon.isHidden = false
        expectedLabel.isHidden = false
        predictionLabel.isHidden = false
        
        switch prediction.confidence {
        case .none:
            if cycleDay > 0 {
                // User has logged a period, but needs a second one to complete a cycle
                expectedLabel.text = "Period Prediction"
                predictionLabel.text = "More data needed"
                predictionLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            } else {
                // Truly no data
                expectedLabel.text = "Get Started"
                predictionLabel.text = "Log your first period"
                predictionLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            }
            
        case .low, .medium, .high:
            guard let days = prediction.daysUntil else {
                // Has cycles but can't predict yet
                expectedLabel.text = "Period Prediction"
                predictionLabel.text = "Log more cycles"
                predictionLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                return
            }
            
            if prediction.isLate {
                // ── Irregular cycle ──
                expectedLabel.text = "Cycle Update"
                predictionLabel.text = "Cycle may be irregular"
                predictionLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                
            } else if days == 0 {
                // ── Period may start today ──
                expectedLabel.text = "Expected Period"
                predictionLabel.text = "Today"
                predictionLabel.font = .boldSystemFont(ofSize: 22)
                
            } else if days < 0 {
                // ── Period is late (but not irregular-level late) ──
                let overdue = abs(days)
                expectedLabel.text = "Overdue"
                predictionLabel.text = "Period \(overdue) day\(overdue == 1 ? "" : "s") late"
                predictionLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                
            } else {
                // ── Normal upcoming period — show date ──
                expectedLabel.text = "Expected Period"
                if let date = prediction.predictedStartDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d"
                    predictionLabel.text = formatter.string(from: date)
                } else {
                    predictionLabel.text = "\(days) day\(days == 1 ? "" : "s")"
                }
                predictionLabel.font = .boldSystemFont(ofSize: 22)
            }
        }
    }
}
