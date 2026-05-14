//
//  RoutinePreviewViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class RoutinePreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routine.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "routine_preview_cell",
                    for: indexPath
                ) as? RoutinePreviewTableViewCell else {
                    return UITableViewCell()
                }

                let routineExercise = routine.exercises[indexPath.row]
       
        let completedWorkout = CompletedWorkoutsDataStore.shared.loadAll()
                    .first { $0.routineName == routine.name }
        
        let workoutExercise = completedWorkout?.exercises.first {
            $0.id == routineExercise.id || $0.exercise.name == routineExercise.exercise.name
        }

        cell.configure(
            with: routineExercise,
            workoutExercise: workoutExercise
        )


        cell.onInfoTapped = { [weak self] in
            self?.showExerciseInfo(routineExercise.exercise)
        }

            return cell
    }
    

    @IBOutlet weak var EstRoutineTimeOutlet: UILabel!
    @IBOutlet weak var NoOfExerciseOutlet: UILabel!
    @IBOutlet weak var RoutineImageOutlet: UIImageView!
    @IBOutlet weak var timeTagContainer: UIView!
    @IBOutlet weak var exerciseTagContainer: UIView!
    @IBOutlet weak var RoutinePreviewTableViewOutlet: UITableView!
    @IBOutlet weak var playImageView: UIImageView!

    var routine: Routine!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = routine.name
        view.backgroundColor=UIColor(hex: "#FCEEED")
        navigationController?.navigationBar.prefersLargeTitles = false
        setupContainerStyle()
        configureRoutineHeader()
        setupTable()
        setupPlayTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWorkoutEndedEarly), name: Notification.Name("WorkoutEndedEarly"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleWorkoutEndedEarly() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Active workout exists:",
                 WorkoutSessionManager.shared.activeWorkout != nil)

        RoutinePreviewTableViewOutlet.reloadData()
    }

    private func setupPlayTap() {
        playImageView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(playTapped)
        )

        playImageView.addGestureRecognizer(tapGesture)
    }
    @objc private func playTapped() {
        startWorkout()
    }
    private func startWorkout() {

        let manager = WorkoutSessionManager.shared

        // Check if we can resume
        if let completedWorkout = CompletedWorkoutsDataStore.shared.loadAll().first(
                    where: { $0.routineName == routine.name }
        ),
        let resumePoint = completedWorkout.resumePoint() {

            let activeWorkout = ActiveWorkout(
                routine: routine,
                exercises: completedWorkout.exercises
            )

            manager.activeWorkout = activeWorkout

            launchWorkout(
                activeWorkout: activeWorkout,
                exerciseIndex: resumePoint.exerciseIndex,
                setIndex: resumePoint.setIndex
            )
            return
        }

        //  Else start fresh
        var workoutExercises = routine.exercises.map {
            $0.generateWorkoutExercise()
        }
        
        let estimatedDuration = routine.estimatedDurationSeconds
        if estimatedDuration < 600 {
            if let cardioExercise = ExerciseDataStore.shared.allExercises.first(where: { $0.name == "Electric Bicycle" }) {
                let dynamicCardio = RoutineExercise(exercise: cardioExercise, durationSeconds: 60)
                workoutExercises.append(dynamicCardio.generateWorkoutExercise())
            }
        }

        let activeWorkout = ActiveWorkout(
            routine: routine,
            exercises: workoutExercises
        )

        manager.activeWorkout = activeWorkout

        launchWorkout(
            activeWorkout: activeWorkout,
            exerciseIndex: 0,
            setIndex: 0
        )
    }
    private func launchWorkout(
        activeWorkout: ActiveWorkout,
        exerciseIndex: Int,
        setIndex: Int
    ) {
        let storyboard = UIStoryboard(name: "Workout", bundle: nil)

        let countdownVC = storyboard.instantiateViewController(
            withIdentifier: "CountdownViewController"
        ) as! CountdownViewController

        countdownVC.modalPresentationStyle = .fullScreen

        countdownVC.onCountdownFinished = { [weak self] in
            guard let self else { return }

            let workoutVC = storyboard.instantiateViewController(
                withIdentifier: "WorkoutPlayerViewController"
            ) as! WorkoutPlayerViewController

            workoutVC.activeWorkout = activeWorkout
            workoutVC.exerciseIndex = exerciseIndex
            workoutVC.currentSetIndex = setIndex
            workoutVC.workoutExercise = activeWorkout.exercises[exerciseIndex]

            let nav = UINavigationController(rootViewController: workoutVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }

        present(countdownVC, animated: false)
    }


    private func setupContainerStyle() {
        timeTagContainer.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        timeTagContainer.layer.cornerRadius = exerciseTagContainer.frame.height / 2
        exerciseTagContainer.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        exerciseTagContainer.layer.cornerRadius = exerciseTagContainer.frame.height / 2
        RoutineImageOutlet.layer.cornerRadius=0
    }
    private func configureRoutineHeader() {
       // RoutineNameOutlet.text = routine.name
        NoOfExerciseOutlet.text = "\(routine.totalExercises) Exercises"
        EstRoutineTimeOutlet.text = routine.formattedDuration
        setRoutineImage()
    }

    private func setRoutineImage() {
        if let imageName = routine.thumbnailImageName {
            RoutineImageOutlet.image = UIImage(named: imageName)
            RoutineImageOutlet.contentMode = .scaleAspectFill
        }
    }
    private func setupTable() {
        RoutinePreviewTableViewOutlet.delegate = self
        RoutinePreviewTableViewOutlet.dataSource = self
        RoutinePreviewTableViewOutlet.rowHeight = 120
        RoutinePreviewTableViewOutlet.register(
            UINib(nibName: "RoutinePreviewTableViewCell", bundle: nil),
            forCellReuseIdentifier: "routine_preview_cell"
        )
    }
    private func showExerciseInfo(_ exercise: Exercise) {
        performSegue(withIdentifier: "InfoModal", sender: exercise)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InfoModal" {
            
            if let nav = segue.destination as? UINavigationController,
               let infoVC = nav.topViewController as? InfoModalViewController,
               let exercise = sender as? Exercise {
                infoVC.exercise = exercise
            }
            
            
        }
           
    }
    
    

}
