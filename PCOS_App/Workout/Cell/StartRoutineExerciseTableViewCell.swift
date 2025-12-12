//
//  StartRoutineExerciseTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class StartRoutineExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var muscleLabel: UILabel!
    @IBOutlet weak var restTimerLabel: UILabel!

    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!

    @IBOutlet weak var doneButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var onDoneTapped: ((Bool) -> Void)?
    var onInfoTapped: (() -> Void)?

    @IBAction func infoButtonTapped(_ sender: UIButton) {
        onInfoTapped?()
    }


    func configure(with exercise: WorkoutExercise) {
        setCountLabel.text = "\(exercise.sets.count)"
            repsLabel.text = "\(exercise.sets.first?.reps ?? 0)"
            weightLabel.text = "\(exercise.sets.first?.weightKg ?? 0)"
        doneButton.isSelected = exercise.sets.allSatisfy { $0.isCompleted }
        
        
        
        exerciseNameLabel.text = exercise.exercise.name
        muscleLabel.text = exercise.exercise.muscleGroup.displayName
        exerciseImageView.image = UIImage(named: exercise.exercise.image ?? "")
        
        let rest = exercise.sets.first?.restTimerSeconds ?? 0
        restTimerLabel.text = "Rest Timer : \(rest) secs"

        //setCountLabel.text = "\(exercise.sets.first?.setNumber ?? 1)"
        //weightLabel.text = "\(exercise.sets.first?.weightKg ?? 0)"
        //repsLabel.text = "\(exercise.sets.first?.reps ?? 0)"

        // Correct handling of completion state
        let isDone = exercise.sets.first?.isCompleted ?? false

        doneButton.isSelected = isDone   //  THIS WAS MISSING
        let imageName = isDone ? "checkmark.square.fill" : "square"
        doneButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()

            let newImage = sender.isSelected ? "checkmark.square.fill" : "square"
            sender.setImage(UIImage(systemName: newImage), for: .normal)

            // send the NEW state up
            onDoneTapped?(sender.isSelected)   // 0 because you're only showing 1 set per exercise for now
        
    }
    func setupCardStyle() {
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = false

        // Shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08   // very soft
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // Improve performance
        cardView.layer.shouldRasterize = true
        cardView.layer.rasterizationScale = UIScreen.main.scale
    }
}
