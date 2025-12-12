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
        title = "Create New Routine"
        navigationController?.navigationBar.prefersLargeTitles = false
        saveRoutineButton.isEnabled = false
        
        setupUI()
        registerCells()
        updateUI()

        // Add text field delegate
            routineNameTextField.delegate = self
            
            print("🎬 CreateRoutineViewController loaded")
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
        routineNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            
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
        
        //  ADD THIS LINE to update save button properly:
        textFieldDidChange()
        
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
    
    
    
    @IBAction func saveRoutineButton(_ sender: UIBarButtonItem) {
        // 1. Validate routine name
            guard let name = routineNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else {
                // Show alert if name is empty
                let alert = UIAlertController(
                    title: "Missing Name",
                    message: "Please enter a name for your routine.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            
            // 2. Validate exercises
            guard !routineExercises.isEmpty else {
                let alert = UIAlertController(
                    title: "No Exercises",
                    message: "Please add at least one exercise to your routine.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }

            // 3. Create routine
            let routine = Routine(
                id: UUID(),
                name: name,
                exercises: routineExercises
            )

            // 4. Save to manager (FIXED: now uses addRoutine)
            WorkoutSessionManager.shared.addRoutine(routine)
            
            // 5. Show success message
            let alert = UIAlertController(
                title: "✅ Routine Saved!",
                message: "\"\(name)\" has been saved with \(routineExercises.count) exercises.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                // 6. Navigate back
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
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
    
  /*  private func handleSelectedExercises(_ exercises: [Exercise]) {
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
        }*/
    
    private func handleSelectedExercises(_ exercises: [Exercise]) {
        print("📥 Received \(exercises.count) exercises")
        
        let newRoutineExercises = exercises.map { exercise in
            if exercise.isCardio {
                print("🏃 Adding cardio: \(exercise.name)")
                return RoutineExercise(
                    exercise: exercise,
                    numberOfSets: 1,
                    reps: 0,
                    weightKg: 0,
                    restTimerSeconds: nil,
                    durationSeconds: 600,
                    notes: nil
                )
            } else {
                print("💪 Adding strength: \(exercise.name)")
                return RoutineExercise(
                    exercise: exercise,
                    numberOfSets: 3,
                    reps: 10,
                    weightKg: 0,
                    restTimerSeconds: 60,
                    durationSeconds: nil,
                    notes: nil
                )
            }
        }
        
        routineExercises.append(contentsOf: newRoutineExercises)
        print("📊 Total exercises in routine: \(routineExercises.count)")
        
        updateUI()
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
extension CreateRoutineViewController: UITextFieldDelegate {
    // ✅ ADD THIS METHOD:
    @objc private func textFieldDidChange() {
        let hasName = !(routineNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasExercises = !routineExercises.isEmpty
        
        saveRoutineButton.isEnabled = hasName && hasExercises
        
        print("📝 Name: '\(routineNameTextField.text ?? "")' | Has exercises: \(hasExercises) | Save enabled: \(saveRoutineButton.isEnabled)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

