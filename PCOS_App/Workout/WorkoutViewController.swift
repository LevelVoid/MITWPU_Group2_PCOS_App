//
//  WorkoutViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

enum ExploreRoutineItem {
    case createCustom
    case predefined(Routine)
}

class WorkoutViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    private var exploreItems: [ExploreRoutineItem] = []
    private var selectedPredefinedRoutine: Routine?

    
    @IBOutlet weak var durationGoalCard: UIView!
    @IBOutlet weak var stepsGoalCard: UIView!
    @IBOutlet weak var caloriesGoalCard: UIView!
    
    @IBOutlet weak var caloriesProgressView: CircularProgressView!
    @IBOutlet weak var durationProgressView: CircularProgressView!
    @IBOutlet weak var stepsProgressView: CircularProgressView!
    
    @IBOutlet weak var flameIcon: UIImageView!
    @IBOutlet weak var durationIcon: UIImageView!
    @IBOutlet weak var stepsIcon: UIImageView!
    
    @IBOutlet weak var myRoutinesSuperView: UIView!
    @IBOutlet weak var emptyMyRoutineOutlet: UIView!
    @IBOutlet weak var myRoutinesCollectionOutlet: UICollectionView!
    
    @IBOutlet weak var exploreRoutinesCollectionOutlet: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Workout"
        navigationController?.navigationBar.prefersLargeTitles = true
            registerCells()
            
            exploreRoutinesCollectionOutlet.dataSource = self
            exploreRoutinesCollectionOutlet.delegate = self

            myRoutinesCollectionOutlet.dataSource = self
            myRoutinesCollectionOutlet.delegate = self

        // Use a flow layout configured for horizontal scrolling if needed
            if let layout = myRoutinesCollectionOutlet.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumInteritemSpacing = 12
                layout.minimumLineSpacing = 12
                layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            }
        setupDailyGoalRings()
            //setting up the explore
            setupExploreData()
    }
    
    private func setupExploreData() {
        exploreItems=[
            .createCustom
        ] + RoutineDataStore.shared.predefinedRoutines.map {.predefined($0)}
    }

 //   Distinguish between collection views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == exploreRoutinesCollectionOutlet {
            return exploreItems.count
        } else {
            // Return count for myRoutinesCollectionOutlet
            return WorkoutSessionManager.shared.savedRoutines.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == exploreRoutinesCollectionOutlet {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "explore_routines_cell",
                for: indexPath
            ) as! ExploreRoutinesCollectionViewCell
            
            let item = exploreItems[indexPath.item]
            switch item {
            case .createCustom:
                cell.configureCreateRoutine()

                    // ADD CALLBACK
                    cell.onCreateRoutineTapped = { [weak self] in
                        self?.handleCreateCustomRoutine()
                    }
            case .predefined(let routine):
                cell.configureRoutine(routine)
            }
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "my_routines_cell",
                for: indexPath
            ) as! MyRoutinesCollectionViewCell

            let routine = WorkoutSessionManager.shared.savedRoutines[indexPath.item]
            cell.configure(with: routine)

            
            cell.onStartTapped = { [weak self] in
                guard let self = self else { return }

                print("▶️ Starting routine: \(routine.name)")

                // Convert RoutineExercise → WorkoutExercise
                let workoutExercises = routine.exercises.map { $0.generateWorkoutExercise() }

                // Create active workout
                let activeWorkout = ActiveWorkout(
                    routine: routine,
                    exercises: workoutExercises
                )

                // Store globally
                WorkoutSessionManager.shared.activeWorkout = activeWorkout

                // Navigate to StartRoutine screen
                self.performSegue(withIdentifier: "showStartRoutine", sender: nil)
            }

            return cell

            
        }
    }
    func setupDailyGoalRings() {
        caloriesGoalCard.bringSubviewToFront(flameIcon)
        stepsGoalCard.bringSubviewToFront(stepsIcon)
        durationGoalCard.bringSubviewToFront(durationIcon)
        // CALORIES
        let caloriesBurnt = 520.0
        let caloriesGoal = 600.0
        caloriesProgressView.progress = caloriesBurnt / caloriesGoal
        caloriesProgressView.progressColor = UIColor(red: 0xFE/255,
                                                  green: 0x7A/255,
                                                  blue: 0x96/255,
                                                     alpha: 0.8)
        caloriesProgressView.trackColor = UIColor.systemGray5
        caloriesProgressView.lineWidth = 6

        // STEPS
        let steps = 5422.0
        let stepsGoal = 10000.0
        stepsProgressView.progress = steps / stepsGoal
        stepsProgressView.progressColor = UIColor(red: 0xFE/255,
                                                  green: 0x7A/255,
                                                  blue: 0x96/255,
                                                  alpha: 0.8)
        stepsProgressView.trackColor = UIColor.systemGray5
        stepsProgressView.lineWidth = 6

        // DURATION
        let durationMinutes = 80.0   // 1h 20min
        let durationGoal = 120.0     // 2h
        durationProgressView.progress = durationMinutes / durationGoal
        durationProgressView.progressColor = UIColor(red: 0xFE/255,
                                                  green: 0x7A/255,
                                                  blue: 0x96/255,
                                                  alpha: 0.8)
        durationProgressView.trackColor = UIColor.systemGray5
        durationProgressView.lineWidth = 6
    }

    
    
    private func handleCreateCustomRoutine() {
        print("➡️ Create Custom Routine tapped")

        // Navigate to your Create Routine screen
        performSegue(withIdentifier: "showCreateRoutine", sender: nil)
    }

    //as collection view cells not visible->performing segues via code 

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == exploreRoutinesCollectionOutlet {
            let item = exploreItems[indexPath.item]
            switch item {
            case .createCustom:
                performSegue(withIdentifier: "showCreateRoutine", sender: nil)
            case .predefined(let routine):
                self.selectedPredefinedRoutine = routine
                    performSegue(withIdentifier: "PredefinedRoutines", sender: nil)
            }
        }

        // DO NOT handle MyRoutines click here!
    }


    override func viewDidLayoutSubviews() {
        [caloriesGoalCard,stepsGoalCard,durationGoalCard].forEach {
            card in
            card.layer.cornerRadius = 16
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.06
            card.layer.shadowOffset = CGSize(width: 0, height: 3)
            card.layer.shadowRadius = 6
            card.layer.masksToBounds = false
            
        }
        emptyMyRoutineOutlet.layer.cornerRadius = 20
        emptyMyRoutineOutlet.layer.borderWidth = 1
        emptyMyRoutineOutlet.layer.borderColor = UIColor.systemGray5.cgColor
    }
    func registerCells() {
        exploreRoutinesCollectionOutlet.register(
            UINib(nibName: "ExploreRoutinesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "explore_routines_cell"
        )

        myRoutinesCollectionOutlet.register(
            UINib(nibName: "MyRoutinesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "my_routines_cell"
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == exploreRoutinesCollectionOutlet {
            // your explore cell size (example)
            return CGSize(width: 160, height: 160)
        } else {
            // my routines card size
            return CGSize(width: 500, height: 100)
        }
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return collectionView == exploreRoutinesCollectionOutlet
    }

    
    
    //to reload the screen for latest routines to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMyRoutinesUI()
    }

    private func updateMyRoutinesUI() {
        let savedCount = WorkoutSessionManager.shared.savedRoutines.count
        myRoutinesCollectionOutlet.isHidden = (savedCount == 0)
        emptyMyRoutineOutlet.isHidden = (savedCount != 0)
        myRoutinesCollectionOutlet.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PredefinedRoutines" {
            if let vc = segue.destination as? PredefinedRoutinesViewController {
                vc.routine = selectedPredefinedRoutine
            }
        }
    }

    
    
    
    
//    @IBAction func startRoutine1Tapped(_ sender: UIButton) {
//
//        guard let routine = WorkoutSessionManager.shared.savedRoutines.first else {
//                print("❌ No routines found!")
//                return
//            }
//
//            // Convert to live workout exercises
//            let liveExercises = routine.exercises.map { $0.generateWorkoutExercise() }
//
//            WorkoutSessionManager.shared.activeWorkout =
//                ActiveWorkout(routine: routine, exercises: liveExercises)
//
//            performSegue(withIdentifier: "showStartRoutine", sender: nil)
//            }
//            
//            // Helper method to show alerts
//            private func showAlert(title: String, message: String) {
//                let alert = UIAlertController(
//                    title: title,
//                    message: message,
//                    preferredStyle: .alert
//                )
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                present(alert, animated: true)
//            }
//            
//            // Optional: Add this to help with debugging
//            override func viewWillAppear(_ animated: Bool) {
//                super.viewWillAppear(animated)
//                
//                // Print current state when screen appears
//                print("=== WORKOUT HOME APPEARED ===")
//                print("📊 Saved routines: \(WorkoutSessionManager.shared.savedRoutines.count)")
//                
//                for (index, routine) in WorkoutSessionManager.shared.savedRoutines.enumerated() {
//                    print("  [\(index)] \(routine.name) - \(routine.exercises.count) exercises")
//                }
//            }
      }
