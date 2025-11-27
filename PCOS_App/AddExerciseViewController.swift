//
//  AddExerciseViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class AddExerciseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // Data source
    private var exercises: [Exercise] = []
    // Optional: track selected exercise IDs if you need them later
    private var selectedExerciseIDs = Set<UUID>()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Exercise"
        //navigationController?.navigationBar.prefersLargeTitles = true

        // Load data from the data store
        exercises = ExerciseDataStore.shared.allExercises

        tableView.dataSource = self
        tableView.delegate = self

        // Allow multiple selection
        tableView.allowsMultipleSelection = true

        // Optional sizing
        // tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        tableView.reloadData()
    }
}

extension AddExerciseViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "add_exercise_cell", for: indexPath) as? AddExerciseTableViewCell else {
            return UITableViewCell()
        }

        let exercise = exercises[indexPath.row]

        // Configure labels
        cell.exerciseNameHeadline.text = exercise.name
        cell.muscleTypeSubheadline.text = exercise.muscleGroup.displayName

        // Configure image (ensure the asset exists with the same name)
        if let imageName = exercise.image, !imageName.isEmpty {
            cell.addExerciseImageView.image = UIImage(named: imageName)
        } else {
            cell.addExerciseImageView.image = nil // or a placeholder image
        }

        // Reflect selection state (if you track it)
        if selectedExerciseIDs.contains(exercise.id) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }

        return cell
    }
}

extension AddExerciseViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = exercises[indexPath.row]
        // Keep it selected (do not call deselect here)
        selectedExerciseIDs.insert(exercise.id)
        // If you want custom visual feedback beyond default highlight, reload cell or update accessoryType:
        if let cell = tableView.cellForRow(at: indexPath) { cell.accessoryType = .checkmark
            cell.selectionStyle = .none//added to remover grey tint when row selected
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let exercise = exercises[indexPath.row]
        selectedExerciseIDs.remove(exercise.id)
        // If using accessoryType:
        if let cell = tableView.cellForRow(at: indexPath) { cell.accessoryType = .none }
    }
}
