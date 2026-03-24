//
//  WorkoutPlayerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class WorkoutPlayerViewController: UIViewController {

    @IBOutlet weak var progressViewBar2: UIView!
    @IBOutlet weak var repetitionsText: UILabel!
    
    @IBOutlet weak var RepsOutlet: UILabel!
    @IBOutlet weak var SetNumberOutlet: UILabel!
   
    @IBOutlet weak var GifOutlet: UIImageView!
    
    @IBOutlet weak var PrimaryControlViewOutlet: UIView!
    
    
    //@IBOutlet weak var pauseOutlet: UIImageView!
    
    @IBOutlet weak var pauseContainer: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
   // @IBOutlet weak var skipButton: UIButton!
   // @IBOutlet weak var doneButton: UIButton!
    private var isPaused = false
 
    var timer: Timer?
    var elapsedSeconds = 0
    var workoutExercise: WorkoutExercise!
    var currentSetIndex: Int = 0
    @IBOutlet weak var paceButton: UIButton!

    @IBOutlet weak var bottomContainerView: UIView!
    
   
    @IBOutlet weak var grabberView: UIView!

    @IBOutlet weak var nextExerciseButton: UIButton!
    @IBOutlet weak var prevExerciseButton: UIButton!
    @IBOutlet weak var endWorkoutButton: UIBarButtonItem!
    
    
    private struct ExerciseSegment {
        let container: UIView
        let fill: UIView
        var widthConstraint: NSLayoutConstraint
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        if exerciseSegments.isEmpty {
            
            progressViewBar2.backgroundColor = .clear
            setupExerciseProgressBar()
            updateExerciseProgressBar()
        }
    }
    private var exerciseSegments: [ExerciseSegment] = []
    private func setupExerciseProgressBar() {
        progressViewBar2.subviews.forEach { $0.removeFromSuperview() }
        exerciseSegments.removeAll()

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        progressViewBar2.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: progressViewBar2.topAnchor),
            stack.bottomAnchor.constraint(equalTo: progressViewBar2.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: progressViewBar2.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: progressViewBar2.trailingAnchor)
        ])

        for _ in activeWorkout.exercises {
            let container = UIView()
            container.backgroundColor = .systemGray4
            container.layer.cornerRadius = 3
            container.clipsToBounds = true

            let fill = UIView()
            fill.backgroundColor = UIColor(hex: "#FE7A96")
            fill.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(fill)

            // STORing the width constraint
            let widthConstraint = fill.widthAnchor.constraint(equalToConstant: 0)
            
            NSLayoutConstraint.activate([
                fill.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                fill.topAnchor.constraint(equalTo: container.topAnchor),
                fill.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                widthConstraint
            ])

            stack.addArrangedSubview(container)
            
            // PASS the constraint to the struct
            exerciseSegments.append(.init(
                container: container,
                fill: fill,
                widthConstraint: widthConstraint
            ))
        }
    }

    
    var activeWorkout: ActiveWorkout!
    var exerciseIndex: Int = 0     // which exercise in routine
    
    enum Pace {
        case low
        case medium
        case high

        var secondsPerRep: Int {
            switch self {
            case .low: return 4
            case .medium: return 3
            case .high: return 2
            }
        }
    }
    private var selectedPace: Pace = .medium
    private var completedSetsInCurrentExercise = 0
    private var cardioCompleted = false


    override func viewDidLoad() {
        super.viewDidLoad()

        guard let activeWorkout = activeWorkout else {
            assertionFailure("activeWorkout not injected")
            return
        }

        self.activeWorkout = activeWorkout

        // SAFELY derive active workoutExercise
        self.workoutExercise = activeWorkout.exercises[exerciseIndex]

        
        pauseContainer.layer.cornerRadius = 20
  //      skipButton.layer.cornerRadius = skipButton.frame.height / 2
    //    doneButton.layer.cornerRadius = 0
        
        nextExerciseButton.layer.cornerRadius = 0
   //     endWorkoutButton.layer.cornerRadius = 100
        
        bottomContainerView.layer.cornerRadius = 24
        PrimaryControlViewOutlet.isUserInteractionEnabled = true
        bottomContainerView.isUserInteractionEnabled = true
        SetNumberOutlet.numberOfLines = 0
        SetNumberOutlet.lineBreakMode = .byWordWrapping
        setupBottomContainer()
        //setupGestureRecognizers()
      //  setupPlayTap()
        configureUI()
        setupPaceMenu()
        
        

        
        
        
        //setupBottomSheet()
    }
    private func progressForExercise(_ exercise: WorkoutExercise) -> CGFloat {

        if exercise.exercise.isTimeBased {
            guard let duration = exercise.sets.first?.durationSeconds, duration > 0 else {
                return 0
            }
            let elapsed = duration - elapsedSeconds
            return min(max(CGFloat(elapsed) / CGFloat(duration), 0), 1)
        }

        let totalSets = exercise.sets.count
      //  let completedSets = exercise.sets.filter { $0.isCompleted }.count
        let completedSets=exercise.sets.filter { $0.completionState == .completed }.count

        return CGFloat(completedSets) / CGFloat(max(totalSets, 1))
    }

    private func updateExerciseProgressBar() {
        for (index, segment) in exerciseSegments.enumerated() {
            let exercise = activeWorkout.exercises[index]
            let progress: CGFloat

            //  CARDIO
            if exercise.exercise.isTimeBased {
                guard let duration = exercise.sets.first?.durationSeconds, duration > 0 else {
                    progress = 0
                    continue
                }

                if exercise.sets.first?.completionState == .completed   {
                    progress = 1.0
                } else if index == exerciseIndex {
                    let elapsed = duration - elapsedSeconds
                    progress = max(0, min(CGFloat(elapsed) / CGFloat(duration), 1))
                } else {
                    progress = 0
                }
            }
            // STRENGTH
            else {
                let totalSets = exercise.sets.count
                let completedSets = exercise.sets.filter { $0.completionState == .completed }.count
                progress = CGFloat(completedSets) / CGFloat(max(totalSets, 1))
            }

            //  UPDATE THE CONSTRAINT
            let maxWidth = segment.container.bounds.width
            segment.widthConstraint.constant = maxWidth * progress  //  USE STORED CONSTRAINT

            segment.fill.alpha = progress == 1 ? 1.0 : 1.0
        }
    }


    private func setupPaceMenu() {
        let low = UIAction(title: "Low", image: UIImage(systemName: "tortoise")) { _ in
            self.setPace(.low)
        }

        let medium = UIAction(title: "Medium", image: UIImage(systemName: "figure.walk")) { _ in
            self.setPace(.medium)
        }

        let high = UIAction(title: "High", image: UIImage(systemName: "hare")) { _ in
            self.setPace(.high)
        }

        paceButton.menu = UIMenu(
            title: "Pace",
            options: .displayInline,
            children: [low, medium, high]
        )

        paceButton.showsMenuAsPrimaryAction = true
    }
    private func setPace(_ pace: Pace) {
        //Hiding pace button for cardio exercises
        if workoutExercise.exercise.isTimeBased {
            paceButton.isHidden=true
        }
        selectedPace = pace

        paceButton.setTitle(paceTitle(pace), for: .normal)

        // Reset timer ONLY for strength exercises
        if !isPaused && !workoutExercise.exercise.isTimeBased {
            timer?.invalidate()
            elapsedSeconds = initialTimerSeconds()
            updateTimerDisplay()
            startTimer()
        }
        

    }
    private func paceTitle(_ pace: Pace) -> String {
        switch pace {
        case .low: return "Low Pace"
        case .medium: return "Medium Pace"
        case .high: return "High Pace"
        }
    }

    private func setupBottomContainer() {
        
        bottomContainerView.backgroundColor = .systemBackground
        bottomContainerView.layer.cornerRadius = 20
        bottomContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomContainerView.layer.shadowColor = UIColor.black.cgColor
        bottomContainerView.layer.shadowOpacity = 0.1
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomContainerView.layer.shadowRadius = 8
        
        // Style grabber
        grabberView.backgroundColor = .systemGray3
        grabberView.layer.cornerRadius = 2.5
        
        elapsedSeconds = initialTimerSeconds()

        
       
    }
    private func initialTimerSeconds() -> Int {
        let exercise = workoutExercise.exercise
        let currentSet = workoutExercise.sets[currentSetIndex]

        //  Cardio → fixed duration
        if exercise.isTimeBased {
            return currentSet.durationSeconds ?? 0
        }

        // Strength → reps × pace
        return currentSet.reps * selectedPace.secondsPerRep
    }



    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        elapsedSeconds = initialTimerSeconds()
        updateTimerDisplay()
        startTimer()
        //  FORCE repaint AFTER resume state is ready
           DispatchQueue.main.async {
               self.updateExerciseProgressBar()
           }
    }

       
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           
           // Stop timer when leaving this view
           timer?.invalidate()
           timer = nil
       }

//    private func setupPlayTap() {
//        pauseOutlet.isUserInteractionEnabled = true
//
//        let tapGesture = UITapGestureRecognizer(
//            target: self,
//            action: #selector(pauseTapped)
//        )
//
//        pauseOutlet.addGestureRecognizer(tapGesture)
//    }


    private func configureUI() {
    
        guard let workoutExercise = workoutExercise else {
            assertionFailure("WorkoutExercise not injected before WorkoutPlayerViewController loaded")
            return
        }

        let exercise = workoutExercise.exercise
        let currentSet = workoutExercise.sets[currentSetIndex]
        
        
        title = activeWorkout.routine.name
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if workoutExercise.exercise.isTimeBased {
            RepsOutlet.text = "\(currentSet.durationSeconds ?? 0) sec"
            repetitionsText.text="Duration"
        } else {
            RepsOutlet.text = "\(currentSet.reps)"
            repetitionsText.text = "Reps"
            repetitionsText.isHidden=false
        }

        if workoutExercise.exercise.isTimeBased {
             SetNumberOutlet.isHidden = false
             SetNumberOutlet.text = exercise.name
             SetNumberOutlet.font = .systemFont(ofSize: 22, weight: .bold)
             paceButton.isHidden = true
        } else {
            SetNumberOutlet.text = "\(exercise.name)\nSet \(currentSetIndex + 1) of \(workoutExercise.sets.count)"
            SetNumberOutlet.isHidden = false
            SetNumberOutlet.font = .systemFont(ofSize: 18, weight: .semibold)
            paceButton.isHidden = false
        }

        //WeightOutlet.text = "\(currentSet.weightKg)"
        GifOutlet.image = exercise.gifImage
        GifOutlet.layer.cornerRadius = 20
        GifOutlet.layer.borderWidth = 1
        GifOutlet.layer.borderColor = UIColor.systemGray4.cgColor
        //GifOutlet.contentMode = AspectFit
        paceButton.isHidden = workoutExercise.exercise.isTimeBased
        //disabling next,prev for last,first 
        updatePrevNextButtonState()
//        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        updateTimerDisplay()
        
        
        
        updateExerciseProgressBar()

        
    }

    @IBAction func crossTapped(_ sender: UIBarButtonItem) {
        if activeWorkout.exercises[exerciseIndex].exercise.isTimeBased {
            let duration = workoutExercise.sets.first?.durationSeconds ?? 0
            let completedTime = max(0, duration - elapsedSeconds)
            activeWorkout.exercises[exerciseIndex].sets[0].elapsedSeconds = completedTime
        }
        saveProgressState()
        dismiss(animated: true)
    }
    
    private func saveProgressState() {
        let elapsed = Int(Date().timeIntervalSince(activeWorkout.startTime))
        activeWorkout.durationSeconds = elapsed
        
        // Save the partial workout state so RoutinePreviewViewController sees in-progress checkmarks
        let partialWorkout = CompletedWorkout(
            routineName: activeWorkout.routine.name,
            date: Date(),
            startTime: activeWorkout.startTime,
            durationSeconds: elapsed,
            exercises: activeWorkout.exercises
        )
        CompletedWorkoutsDataStore.shared.save(partialWorkout)
    }
    
 
    @IBAction func endWorkoutTapped(_ sender: UIBarButtonItem) {
                print("end workout tap")
        
        let alert = UIAlertController(
                title: "End Workout?",
                message: "Your progress will be saved. You can resume this workout later.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "End Workout", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.timer?.invalidate()
                
                // Save partial elapsed time for time-based exercises
                if self.activeWorkout.exercises[self.exerciseIndex].exercise.isTimeBased {
                    let duration = self.workoutExercise.sets.first?.durationSeconds ?? 0
                    let completedTime = max(0, duration - self.elapsedSeconds)
                    self.activeWorkout.exercises[self.exerciseIndex].sets[0].elapsedSeconds = completedTime
                }
                
                // Save partial progress WITHOUT marking remaining sets as skipped
                // so they remain .notStarted and are cleanly resumable
                self.saveProgressState()
                self.dismiss(animated: true)
            })
            
            present(alert, animated: true)
        

               
    }


    private func startTimer() {
        timer?.invalidate()

        guard elapsedSeconds > 0 else {
            handleTimerFinished()
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.elapsedSeconds -= 1
            self.updateTimerDisplay()
            
            
//for cardio updating eevery sec 
            if self.workoutExercise.exercise.isTimeBased {
                    self.updateExerciseProgressBar()
                }
            
            if self.elapsedSeconds <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.handleTimerFinished()
                self.updateExerciseProgressBar()

            }
        }
    }
    private func handleTimerFinished() {
        completeCurrentSet(as: .completed)
    }


    private func completeCurrentSet(as state: SetCompletionState) {
        timer?.invalidate()

        var exercise = activeWorkout.exercises[exerciseIndex]

        if exercise.exercise.isTimeBased {
            exercise.sets[0].completionState = state
            activeWorkout.exercises[exerciseIndex] = exercise
            updateExerciseProgressBar()
            
            if exerciseIndex == activeWorkout.exercises.count - 1 {
                finishWorkoutAndShowSummary()
            } else {
                showNextExerciseTransition()
            }
            return
        }

        exercise.sets[currentSetIndex].completionState = state
        activeWorkout.exercises[exerciseIndex] = exercise
        updateExerciseProgressBar()
        
        if currentSetIndex == exercise.sets.count - 1 {
            if exerciseIndex == activeWorkout.exercises.count - 1 {
                finishWorkoutAndShowSummary()
            } else {
                showNextExerciseTransition()
            }
        } else {
            performSegue(withIdentifier: "RestTimeStart", sender: nil)
        }
    }
    
    private func showNextExerciseTransition() {
        let nextIndex = exerciseIndex + 1
        guard nextIndex < activeWorkout.exercises.count else { return }
        
        let nextWorkoutExercise = activeWorkout.exercises[nextIndex]
        
        let transitionVC = NextExerciseTransitionViewController()
        transitionVC.nextExerciseName = nextWorkoutExercise.exercise.name
        transitionVC.nextExerciseGif = nextWorkoutExercise.exercise.gifImage
        transitionVC.currentExerciseIndex = nextIndex + 1
        transitionVC.totalExercises = activeWorkout.exercises.count
        transitionVC.modalPresentationStyle = .overFullScreen
        transitionVC.modalTransitionStyle = .crossDissolve
        
        transitionVC.onTransitionFinished = { [weak self] in
            // Move immediately since the transition took the place of rest
            self?.moveToNextExercise()
        }
        
        updateProgressBar()
        present(transitionVC, animated: true)
    }


        
        private func updateTimerDisplay() {
            let hours = elapsedSeconds / 3600
            let minutes = (elapsedSeconds % 3600) / 60
            let seconds = elapsedSeconds % 60
            timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    
    
   

    private func totalSetsInRoutine() -> Int {
        guard let activeWorkout = activeWorkout else { return 0 }
        return activeWorkout.exercises.reduce(0) { $0 + $1.sets.count }
    }


    private func completedSetsInRoutine() -> Int {
        guard let activeWorkout = activeWorkout else { return 0 }

        return activeWorkout.exercises.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.completionState == .completed }.count
        }
    }


    private func updateProgressBar() {

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    

    @IBAction func nextTapped(_ sender: UIButton) {
        timer?.invalidate()

        var exercise = activeWorkout.exercises[exerciseIndex]

            if exercise.exercise.isTimeBased {
                let duration = exercise.sets.first?.durationSeconds ?? 0
                let completedTime = max(0, duration - elapsedSeconds)
                exercise.sets[0].elapsedSeconds = completedTime
                exercise.sets[0].completionState = .skipped
                activeWorkout.exercises[exerciseIndex] = exercise
                advanceToNextExerciseImmediately()
                return
            }

            exercise.sets[currentSetIndex].completionState = .skipped
            activeWorkout.exercises[exerciseIndex] = exercise

            if currentSetIndex + 1 < exercise.sets.count {
                currentSetIndex += 1
                loadCurrentSetWithoutCompletion()
            } else {
                advanceToNextExerciseImmediately()
            }
    }
    private func markRemainingSetsAsSkipped() {
        for exIndex in exerciseIndex..<activeWorkout.exercises.count {
            var exercise = activeWorkout.exercises[exIndex]

            let startSet = (exIndex == exerciseIndex) ? currentSetIndex : 0
            for i in startSet..<exercise.sets.count {
                if exercise.sets[i].completionState == .notStarted {
                    exercise.sets[i].completionState = .skipped
                }
            }
            activeWorkout.exercises[exIndex] = exercise
        }
    }

    //initially :loadcurrentset
    private func loadNextFirstSet() {
        // FIXED: Skip button should skip the current set, not go to rest
                let exercise = activeWorkout.exercises[exerciseIndex]
                
        // Don't mark as completed when skipping
                if currentSetIndex + 1 < exercise.sets.count {
                    currentSetIndex += 1
                    configureUI() // Reload UI for next set
                    
                    elapsedSeconds = initialTimerSeconds()
                    updateTimerDisplay()
                    startTimer()


                } else {
                    advanceToNextExerciseImmediately()
                }
    }
    @IBAction func previousTapped(_ sender: UIButton) {
        timer?.invalidate()
            goToPreviousLogicalSet()
    }
    private func goToPreviousLogicalSet() {
        
        //within SAME exercise
        //let sets = workoutExercise.sets
        
        if currentSetIndex > 0 {
            // Go to previous set
            currentSetIndex -= 1
            loadCurrentSetWithoutCompletion()
            return
        }
        
        // Move to PREVIOUS exercise
        guard exerciseIndex > 0 else { return }
        
        exerciseIndex -= 1
        workoutExercise = activeWorkout.exercises[exerciseIndex]
        
        let previousSets = workoutExercise.sets
        
        // Find last completed set
        if let lastCompletedIndex = previousSets.lastIndex(where: {$0.completionState == .completed }) {
    

            currentSetIndex = lastCompletedIndex
        } else {
            // All sets were skipped → load last set
            currentSetIndex = previousSets.count - 1
        }

        loadCurrentSetWithoutCompletion()
    }
    private func loadCurrentSetWithoutCompletion() {
        elapsedSeconds = initialTimerSeconds()
        configureUI()
        updateTimerDisplay()
        startTimer()
    }

    private func loadPreviousLastSet() {
        //Skip button should skip the current set, not go to rest
                let exercise = activeWorkout.exercises[exerciseIndex]
                
        // Don't mark as completed when skipping
                if currentSetIndex + 1 < exercise.sets.count {
                    //i.e. if current exercise ke aur sets baaki hai
                    currentSetIndex += 1
                    configureUI() // Reload UI for next set
                    
                    elapsedSeconds = initialTimerSeconds()
                    updateTimerDisplay()
                    startTimer()


                } else {
                    advanceToNextExerciseImmediately()
                }
    }
    
    
    
    private func goToRestBeforeNext() {
        updateProgressBar()
        performSegue(withIdentifier: "RestTimeStart", sender: nil)
    }
    private func advanceToNextExerciseImmediately() {
        exerciseIndex += 1
        currentSetIndex = 0
        elapsedSeconds=0
        
        if exerciseIndex >= activeWorkout.exercises.count {
            finishWorkout()
            return
        }

        workoutExercise = activeWorkout.exercises[exerciseIndex]
                configureUI()
        elapsedSeconds = initialTimerSeconds()
        updateTimerDisplay()
        startTimer()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RestTimeStart" {
            guard let vc = segue.destination as? RestTimeViewController else { return }

            vc.onRestFinished = { [weak self] in
                self?.handlePostRest()
            }
        }
    }
    private func handlePostRest() {
        let exercise = activeWorkout.exercises[exerciseIndex]

        // More sets left in SAME exercise
        if currentSetIndex + 1 < exercise.sets.count {
            currentSetIndex += 1
            configureUI()
            elapsedSeconds = initialTimerSeconds()
            updateTimerDisplay()
            startTimer()
            return
        }

        moveToNextExercise()

    }
    private func moveToNextExercise() {
        exerciseIndex += 1

        // Workout finished
        if exerciseIndex >= activeWorkout.exercises.count {
            finishWorkoutAndShowSummary()
            return
        }

        // New exercise setup
        currentSetIndex = 0
        elapsedSeconds = 0
        timer?.invalidate()

        workoutExercise = activeWorkout.exercises[exerciseIndex]
        configureUI()
        elapsedSeconds = initialTimerSeconds()
        updateTimerDisplay()
        startTimer()

    }

    
    private func finishWorkout() {
            activeWorkout.finish()
            
            let completed = CompletedWorkout(
                routineName: activeWorkout.routine.name,
                date: Date(),
                startTime: activeWorkout.startTime,
                durationSeconds: activeWorkout.durationSeconds,
                exercises: activeWorkout.exercises
            )
            
            // Persist to disk so duration metrics graph shows this session
            CompletedWorkoutsDataStore.shared.save(completed)
            dismiss(animated: true)
        }
        
    private func finishWorkoutAndShowSummary() {
            timer?.invalidate()
            
            let workoutStart = activeWorkout.startTime
            let elapsed = Int(Date().timeIntervalSince(workoutStart))
            activeWorkout.durationSeconds = elapsed
            activeWorkout.finish()
            
            let completedWorkout = CompletedWorkout(
                routineName: activeWorkout.routine.name,
                date: Date(),
                startTime: workoutStart,
                durationSeconds: elapsed,
                exercises: activeWorkout.exercises
            )
            
            // Persist to disk so MetricsViewController duration graph survives app restarts
            CompletedWorkoutsDataStore.shared.save(completedWorkout)
            
            let summaryVC = UIStoryboard(name: "Workout", bundle: nil)
                .instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
            
            summaryVC.completedWorkout = completedWorkout
            navigationController?.pushViewController(summaryVC, animated: true)
        }
   //UNCOMMENT IF NEED : SKIP EXERCSIE instead of set
    
//    @IBAction func skipExerciseTapped(_ sender: UIButton) {
//        timer?.invalidate()
//
//        // Mark all remaining sets as skipped
//        var exercise = activeWorkout.exercises[exerciseIndex]
//
//            for i in currentSetIndex..<exercise.sets.count {
//                exercise.sets[i].isCompleted = true
//            }
//
//            activeWorkout.exercises[exerciseIndex] = exercise
//            //updateProgressBar()
//
//            moveToNextExercise()
//    }

    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        
            isPaused.toggle()

            if isPaused {
                // PAUSE
                sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
                timer?.invalidate()
                timer = nil
            } else {
                // PLAY / RESUME
                sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                startTimer()
                
            }
        }
//disabling next,prev on last,first set of last,first exercise
    private func updatePrevNextButtonState() {

        // Disable Prev only on first set of first exercise
        let isFirstExercise = exerciseIndex == 0
        let isFirstSet = currentSetIndex == 0
        prevExerciseButton.isEnabled = !(isFirstExercise && isFirstSet)

        // Disable Next only on last set of last exercise
        let isLastExercise = exerciseIndex == activeWorkout.exercises.count - 1
        let isLastSet = currentSetIndex == workoutExercise.sets.count - 1
        nextExerciseButton.isEnabled = !(isLastExercise && isLastSet)

        
        prevExerciseButton.alpha = prevExerciseButton.isEnabled ? 1.0 : 0.4
        nextExerciseButton.alpha = nextExerciseButton.isEnabled ? 1.0 : 0.4
    }

    private func isExerciseFullyCompleted(_ exercise: WorkoutExercise) -> Bool {
        if exercise.exercise.isTimeBased {
            return exercise.sets.first?.completionState == .completed
        }
        return exercise.sets.allSatisfy { $0.completionState == .completed }
    }

   
}
