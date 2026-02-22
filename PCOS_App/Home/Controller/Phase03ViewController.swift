//
//  Phase03ViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 19/02/26.
//

import UIKit

class Phase03ViewController: UIViewController {

    var phaseSignal: PhaseSignal!
    
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
        headingLabel.text = phaseSignal.support.heading
    }
    
    private func configureSupportCards() {

        configureCardForCategory(
            category: .physicalCare,
            imageView: card1Image,
            label: card1Label,
            containerView: card1View
        )

        configureCardForCategory(
            category: .dietNutrition,
            imageView: card2Image,
            label: card2Label,
            containerView: card2View
        )

        configureCardForCategory(
            category: .miscellaneous,
            imageView: card3Image,
            label: card3Label,
            containerView: card3View
        )
    }

    
    private func configureCardForCategory(
        category: SupportCategory,
        imageView: UIImageView,
        label: UILabel,
        containerView: UIView
    ) {

        guard let action = PhaseSupportRotationStore.shared
            .nextSupportAction(for: phaseSignal, category: category)
        else {
            containerView.isHidden = true
            return
        }

        label.text = action.text

        switch category {
        case .dietNutrition:
            imageView.image = UIImage(
                named: SupportCategoryAssets.dietNutritionImage
            )

        case .physicalCare:
            imageView.image = UIImage(
                named: SupportCategoryAssets.physicalCareImage
            )

        case .miscellaneous:
            imageView.image = UIImage(
                named: SupportCategoryAssets.miscellaneousImage
            )
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
