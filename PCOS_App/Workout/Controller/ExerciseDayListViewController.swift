//
//  ExerciseDayListViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 15/01/26.
//

import UIKit

class ExerciseDayListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    

        @IBOutlet weak var noSymptomsLabel: UILabel!
        @IBOutlet weak var dateLabel: UILabel!
        @IBOutlet weak var daysSymptom: UITableView!
     //   @IBOutlet weak var CycleDayLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    
        
        var selectedDate: Date!
    var completedWorkout: CompletedWorkout?

        private let calendar = Calendar.current
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTableView()
            loadAndDisplay()
        }
        
        private func setupUI() {
            // Initially hide no symptoms label
            noSymptomsLabel.isHidden = true
            noSymptomsLabel.text = "No symptoms logged for this day"
            noSymptomsLabel.textColor = .systemGray
            noSymptomsLabel.font = .systemFont(ofSize: 16)
            noSymptomsLabel.textAlignment = .center
            
            durationLabel.font = .systemFont(ofSize: 14, weight: .regular)
            durationLabel.textColor = .secondaryLabel
            durationLabel.textAlignment = .center
            durationLabel.text = "0 min"
        }
    private func formattedWorkoutDuration(_ seconds: Int) -> String {
        let totalMinutes = seconds / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            if minutes > 0 {
                return "\(hours) hr \(minutes) min"
            } else {
                return "\(hours) hr"
            }
        } else if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(seconds) sec"
        }
    }

        
        private func setupTableView() {
    //        daysSymptom.backgroundColor = UIColor(red: 252.0/255.0, green: 238.0/255.0, blue: 237.0/255.0, alpha: 1.0)
            daysSymptom.delegate = self
            daysSymptom.dataSource = self
            daysSymptom.separatorStyle = .none
            daysSymptom.rowHeight = 60
            daysSymptom.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
            
            // Register custom cell
            daysSymptom.register(UITableViewCell.self, forCellReuseIdentifier: "SymptomCell")
        }
        
        private func loadAndDisplay() {
            updateDateLabel()
            
            loadWorkout()

        }
        
        private func updateDateLabel() {
            guard let selectedDate = selectedDate else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
           // formatter.dateFormat = "EEEE, MMMM d, yyyy"

            dateLabel.text = formatter.string(from: selectedDate)
            dateLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            dateLabel.textAlignment = .center
        }
        
    private func loadWorkout() {

        guard let workout = completedWorkout else {
            daysSymptom.isHidden = true
            noSymptomsLabel.isHidden = false
            noSymptomsLabel.text = "No exercises completed"
            
            

            return
        }

        daysSymptom.isHidden = false
        noSymptomsLabel.isHidden = true
        durationLabel.isHidden = false
        
        durationLabel.text = "\(formattedWorkoutDuration(workout.durationSeconds)) workout"
        daysSymptom.reloadData()
    }

        

        
        //  Public Method to Update Date
        func updateDate(_ newDate: Date) {
            
            selectedDate = newDate
            completedWorkout = CompletedWorkoutsDataStore.shared.workout(on: newDate)
            loadAndDisplay()
        }

        // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        completedWorkout?.exercises.count ?? 0
    }


        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell", for: indexPath)

        guard let workoutExercise = completedWorkout?.exercises[indexPath.row] else {
            return cell
        }

        var content = UIListContentConfiguration.subtitleCell()

        content.text = workoutExercise.exercise.name
        content.textProperties.font = .systemFont(ofSize: 16, weight: .medium)

        if let imageName = workoutExercise.exercise.image {
            content.image = UIImage(named: imageName)
            content.imageProperties.cornerRadius = 8
            content.imageProperties.maximumSize = CGSize(width: 44, height: 44)
        }

        content.secondaryText = nil

        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

        
        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 64
        }
    

    private func hasWorkout(_ date: Date) -> Bool {
        CompletedWorkoutsDataStore.shared.hasCompletedWorkout(on: date)
    }

}
