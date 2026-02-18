//
//  Signal03ViewController.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 18/02/26.
//

import UIKit

final class Signal03ViewController: UIViewController {
    
    var signal: PCOSSignal!
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var card1Image: UIImageView!
    @IBOutlet weak var card1Label: UILabel!
    
    @IBOutlet weak var card2Image: UIImageView!
    @IBOutlet weak var card2Label: UILabel!
    
    @IBOutlet weak var card3Image: UIImageView!
    @IBOutlet weak var card3Label: UILabel!
    
    
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var card2View: UIView!
    @IBOutlet weak var card3View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureSupportCards()
    }
    
    private func setupUI() {
        card1View.layer.cornerRadius = 16
        card2View.layer.cornerRadius = 16
        card3View.layer.cornerRadius = 16
        headingLabel.text = signal.supportHeading
    }
    
    private func configureSupportCards() {

        configureCardForCategory(
            category: .dietNutrition,
            imageView: card1Image,
            label: card1Label
        )

        configureCardForCategory(
            category: .physicalCare,
            imageView: card2Image,
            label: card2Label
        )

        configureCardForCategory(
            category: .miscellaneous,
            imageView: card3Image,
            label: card3Label
        )
    }
    
    private func configureCardForCategory(
        category: SupportCategory,
        imageView: UIImageView,
        label: UILabel
    ) {

        guard let action = SupportRotationStore.shared
            .nextSupportAction(for: signal, category: category)
        else {
            imageView.superview?.isHidden = true
            return
        }

        label.text = action.text

        switch category {
        case .dietNutrition:
            imageView.image = UIImage(named: SupportCategoryAssets.dietNutritionImage)

        case .physicalCare:
            imageView.image = UIImage(named: SupportCategoryAssets.physicalCareImage)

        case .miscellaneous:
            imageView.image = UIImage(named: SupportCategoryAssets.miscellaneousImage)
        }
    }


    
    private func configureCard(
        imageView: UIImageView,
        label: UILabel,
        action: SupportAction
    ) {
        
        label.text = action.text
        
        switch action.category {
        case .dietNutrition:
            imageView.image = UIImage(named: SupportCategoryAssets.dietNutritionImage)
            
        case .physicalCare:
            imageView.image = UIImage(named: SupportCategoryAssets.physicalCareImage)
            
        case .miscellaneous:
            imageView.image = UIImage(named: SupportCategoryAssets.miscellaneousImage)
        }
    }
}

