//
//  RoutineExerciseTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 01/12/25.
//

import UIKit
class RoutineExerciseTableViewCell: UITableViewCell {
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var muscleTypeLabel: UILabel!
    @IBOutlet weak var exerciseImageView: UIImageView!
    
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var restTimerLabel: UILabel!
    @IBOutlet weak var durationTextField: UITextField! // for cardio only
    
    // StackViews (recommended)
    @IBOutlet weak var strengthStackView: UIStackView!
    @IBOutlet weak var cardioStackView: UIStackView!
    
    // CRITICAL: Callback to notify parent when values change
    var onValueChanged: (() -> Void)?
    
    // Keep reference to the model so we can update it
    private var routineExercise: RoutineExercise?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        exerciseImageView.contentMode = .scaleAspectFill
        exerciseImageView.clipsToBounds = true
        exerciseImageView.layer.cornerRadius = 8
        
        exerciseNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        exerciseNameLabel.textColor = .label
        
        muscleTypeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        muscleTypeLabel.textColor = .secondaryLabel
        
        // Set up text field delegates to detect changes
        setsTextField.delegate = self
        repsTextField.delegate = self
        weightTextField.delegate = self
        durationTextField.delegate = self
        
        // Add target for editing changed events (real-time updates)
        setsTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repsTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        durationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // Optional: Reset cell when reused
    override func prepareForReuse() {
        super.prepareForReuse()
        exerciseImageView.image = nil
        exerciseNameLabel.text = nil
        muscleTypeLabel.text = nil
    }
    
    func configure(with model: RoutineExercise) {
        
        self.routineExercise = model
        
        exerciseNameLabel.text = model.exercise.name
        muscleTypeLabel.text = model.exercise.muscleGroup.displayName
        
        // Load image
        if let img = model.exercise.image {
            exerciseImageView.image = UIImage(named: img)
        } else {
            exerciseImageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
        }
        
        // Show appropriate UI based on exercise type
        if model.exercise.isCardio {
            strengthStackView.isHidden = true
            cardioStackView.isHidden = false
            
            // Default to 10 minutes (600 seconds) if not set
            let durationInSeconds = model.durationSeconds ?? 600
            let minutes = durationInSeconds / 60
            durationTextField.text = "\(minutes)"
            
        } else {
            strengthStackView.isHidden = false
            cardioStackView.isHidden = true
            
            setsTextField.text = "\(model.numberOfSets)"
            repsTextField.text = "\(model.reps)"
            weightTextField.text = "\(model.weightKg)"
            
            //commenting as using a action button currently will modify later -> i.e.e resttimer has no label
//            let rest = model.restTimerSeconds ?? 60
//            restTimerLabel.text = "Rest: \(rest)s"
        }
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
            guard var exercise = routineExercise else { return }
            
            // Update the model based on which field changed
            if textField == setsTextField {
                if let value = Int(textField.text ?? ""), value > 0 {
                    exercise.numberOfSets = value
                }
            } else if textField == repsTextField {
                if let value = Int(textField.text ?? ""), value > 0 {
                    exercise.reps = value
                }
            } else if textField == weightTextField {
                if let value = Int(textField.text ?? ""), value >= 0 {
                    exercise.weightKg = value
                }
            } else if textField == durationTextField {
                // Duration is in minutes in the UI, convert to seconds
                if let minutes = Int(textField.text ?? ""), minutes > 0 {
                    exercise.durationSeconds = minutes * 60
                }
            }
            
            // Update our local reference
            self.routineExercise = exercise
            
            // Notify parent that values changed
            onValueChanged?()
        }
        
        // MARK: - Public getter for updated model
        func getRoutineExercise() -> RoutineExercise? {
            return routineExercise
        }
    }

    // MARK: - UITextFieldDelegate
    extension RoutineExerciseTableViewCell: UITextFieldDelegate {
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            // Final validation when user finishes editing
            textFieldDidChange(textField)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // Only allow numbers
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
    }
