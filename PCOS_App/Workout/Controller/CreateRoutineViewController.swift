//
//  CreateRoutineViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class CreateRoutineViewController: UIViewController {
    // Same VC for before and after adding exercise - Apple's Guidelines (Human Interface Guidelines) "Within a screen, adapt content to reflect state changes."

    
    @IBOutlet weak var saveRoutineButton: UIBarButtonItem!
    
    @IBOutlet weak var routineNameTextField: UITextField!
    
    @IBOutlet weak var estimatedDurationLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet weak var exerciseCountLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var emptyStateImageView: UIImageView!
    @IBOutlet weak var emptyStateAddButton: UIButton!
    
    @IBOutlet weak var exerciseTableView: UITableView!
    
    private var routineExercises: [RoutineExercise] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveRoutineButton.isEnabled = false
        
        setupUI()
        registerCells()
        updateUI()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateUI()
        }
        
    private func setupUI() {
            containerView.bringSubviewToFront(exerciseTableView)
            
            exerciseTableView.delegate = self
            exerciseTableView.dataSource = self
            exerciseTableView.estimatedRowHeight = 88
            exerciseTableView.rowHeight = UITableView.automaticDimension
            
        }
    
    func registerCells() {
        exerciseTableView.register(
            UINib(
                nibName: "RoutineExerciseTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "routine_exercise_cell"
        )
    }
    
    private func updateUI() {
            let hasExercises = !routineExercises.isEmpty
            
            // Toggle visibility
            emptyStateView.isHidden = hasExercises
            exerciseTableView.isHidden = !hasExercises
            
            // Update stats
            updateStats()
            saveRoutineButton.isEnabled = hasExercises
            
            // Reload table
            exerciseTableView.reloadData()
        }
    
    private func updateStats() {

        // Exercise count
                exerciseCountLabel.text = "\(routineExercises.count)"
                
                // Total sets (only for non-cardio exercises)
                let totalSets = routineExercises.reduce(0) { total, ex in
                    total + (ex.exercise.isCardio ? 0 : ex.numberOfSets)
                }
                setCountLabel.text = "\(totalSets)"
                
                // FIXED: Estimated duration calculation
                let totalDuration = routineExercises.reduce(0) { total, ex in
                    if ex.exercise.isCardio {
                        // For cardio: use durationSeconds (default or user-inputted)
                        return total + (ex.durationSeconds ?? 0)
                    } else {
                        // For strength exercises:
                        // Estimate 4 seconds per rep + rest time, multiplied by number of sets
                        let secondsPerRep = 4
                        let activeTimePerSet = ex.reps * secondsPerRep
                        let restTimePerSet = ex.restTimerSeconds ?? 0
                        let totalTimePerSet = activeTimePerSet + restTimePerSet
                        return total + (totalTimePerSet * ex.numberOfSets)
                    }
                }
                
                estimatedDurationLabel.text = formatDuration(totalDuration)
            
    }

    
    private func formatDuration(_ seconds: Int) -> String {
            let minutes = seconds / 60
            if minutes > 60 {
                let hours = minutes / 60
                let remainingMinutes = minutes % 60
                return "\(hours)h \(remainingMinutes)m"
            }
            return "\(minutes)m"
        }
    

    @IBAction func showAddExerciseOnTap(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddExercise", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showAddExercise" {
//                if let navController = segue.destination as? UINavigationController,
//                   let addExerciseVC = navController.topViewController as? AddExerciseViewController {
//                    
//                    // Pass callback to receive selected exercises
//                    addExerciseVC.onExercisesSelected = { [weak self] selectedExercises in
//                        self?.handleSelectedExercises(selectedExercises)
//                    }
//                }
                if let addVC = segue.destination as? AddExerciseViewController {
                            addVC.onExercisesSelected = { [weak self] selectedExercises in
                                self?.handleSelectedExercises(selectedExercises)
                            }
                        }
            }
        }
    
    private func handleSelectedExercises(_ exercises: [Exercise]) {
        // Convert Exercise to RoutineExercise with default sets
               
               //OLD CODE WITH PLANNED SETS STRUCT(now deleted)
       //            let newRoutineExercises = exercises.map { exercise in
       //                RoutineExercise(
       //                    exercise: exercise,
       //                    sets: [
       //                        PlannedSet(setNumber: 1, reps: 10, weightKg: 0, restTimerSeconds: 60)
       //                    ]
       //                )
       //            }
               
//               let newRoutineExercises = exercises.map { exercise in
//                   RoutineExercise(exercise: exercise)
//               }
//                   
//                   // Add to existing exercises
//                   routineExercises.append(contentsOf: newRoutineExercises)
//                   
//                   // Update UI
//                   updateUI()
        
        let newRoutineExercises = exercises.map { exercise in
                    // Set appropriate defaults based on exercise type
                    if exercise.isCardio {
                        return RoutineExercise(
                            exercise: exercise,
                            numberOfSets: 1,  // Cardio doesn't use sets
                            reps: 0,          // Cardio doesn't use reps
                            weightKg: 0,      // Cardio doesn't use weight
                            restTimerSeconds: nil,
                            durationSeconds: 600,  // Default 10 minutes
                            notes: nil
                        )
                    } else {
                        return RoutineExercise(
                            exercise: exercise,
                            numberOfSets: 3,
                            reps: 10,
                            weightKg: 0,
                            restTimerSeconds: 60,  // Default 60 seconds rest
                            durationSeconds: nil,
                            notes: nil
                        )
                    }
                }
                
                routineExercises.append(contentsOf: newRoutineExercises)
                updateUI()
               }
    func exerciseDidUpdate() {
            updateStats()
        }
           }

// MARK: - UITableViewDataSource
extension CreateRoutineViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routineExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "routine_exercise_cell",
            for: indexPath
        ) as? RoutineExerciseTableViewCell else {
            return UITableViewCell()
        }
        
        let routineExercise = routineExercises[indexPath.row]
        
        // IMPORTANT: Pass a reference so cell can notify when values change
        cell.configure(with: routineExercise)
        
        // CRITICAL: Callback to update stats AND the model when cell values change
        cell.onValueChanged = { [weak self] in
            guard let self = self else { return }
            
            // Get the updated exercise from the cell (if it has changes)
            // Since cells store a copy, we need to update our array
            if let updatedCell = tableView.cellForRow(at: indexPath) as? RoutineExerciseTableViewCell,
               let updatedExercise = updatedCell.getRoutineExercise() {
                self.routineExercises[indexPath.row] = updatedExercise
            }
            
            self.updateStats()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateRoutineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Navigate to exercise detail/edit screen
    }
    
    // Enable swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            routineExercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateUI()
        }
    }
}

