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
    
   
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var gradientOverlayView: UIView!
    @IBOutlet weak var cycleDayLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var predictionLabel: UILabel!
    @IBOutlet weak var logPeriodButton: UIButton!
    
    weak var delegate: HomeHeaderCollectionViewCellDelegate?
    
    private let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        setupMultiStopGradient()
    }
    
    private func setup() {
        headerImageView.image = UIImage(named: "home_image_trial_2")
        headerImageView.contentMode = .scaleToFill
        headerImageView.clipsToBounds = true
        
        logPeriodButton.layer.cornerRadius = 30
        logPeriodButton.tintColor = UIColor(hex: "#FE7A96")
        logPeriodButton.addTarget(self, action: #selector(logPeriodButtonTapped), for: .touchUpInside)
    }
    
    @objc private func logPeriodButtonTapped() {
        delegate?.homeHeaderCellDidTapLogPeriod(self)
    }
    
    private func setupMultiStopGradient() {
        gradientOverlayView.backgroundColor = .clear
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.9, 0.95]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        headerImageView.layer.mask = gradientLayer
        self.contentView.backgroundColor = UIColor(hex: "#FCEEED")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = headerImageView.bounds
    }

    // MARK: - Public Configuration

    func configure(cycleDay: Int, phase: Phase, prediction: PeriodPrediction) {
        cycleDayLabel.text = cycleDay > 0 ? "Cycle Day \(cycleDay)" : "No Cycle Logged"
        phaseLabel.text = phase.displayName
        quoteLabel.text = phase.quote

        if prediction.confidence == .none {
            predictionLabel.isHidden = true
        } else {
            predictionLabel.isHidden = false
            predictionLabel.text = "\(prediction.summaryText)"
        }
    }
}
