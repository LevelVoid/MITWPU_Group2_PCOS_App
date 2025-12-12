//
//  PredefinedRoutinesViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class PredefinedRoutinesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var routine: Routine!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var routineNameLabel: UILabel!
    @IBOutlet weak var exercisesTableView: UITableView!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        routineNameLabel.text = routine.name
        title = routine.name
        navigationController?.navigationBar.prefersLargeTitles = false
        descriptionLabel.text = routine.routineDescription
        exercisesTableView.delegate = self
        exercisesTableView.dataSource = self
        exercisesTableView.register(
                    UINib(nibName: "PredefinedExerciseTableViewCell", bundle: nil),
                    forCellReuseIdentifier: "predefined_exercise_cell"
                )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return routine.exercises.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "predefined_exercise_cell",
                for: indexPath
            ) as! PredefinedExerciseTableViewCell
            
            let item = routine.exercises[indexPath.row]
            
            cell.exerciseNameLabel.text = item.exercise.name
            
            if item.exercise.isCardio {
                // Convert seconds → minutes
                let minutes = (item.durationSeconds ?? 0) / 60
                cell.detailLabel.text = "\(minutes) min"
            } else {
                cell.detailLabel.text = "\(item.numberOfSets) sets • \(item.reps) reps"
            }
            
            cell.thumbnailImage.image = UIImage(named: item.exercise.image ?? "placeholder")
            
            return cell
        }
        
        // MARK: - Save Routine
        @IBAction func saveRoutineTapped(_ sender: UIButton) {
            WorkoutSessionManager.shared.addRoutine(routine)
            
            navigationController?.popViewController(animated: true)
        }
    }
    


