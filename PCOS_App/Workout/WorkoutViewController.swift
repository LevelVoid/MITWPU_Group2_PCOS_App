//
//  WorkoutViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class WorkoutViewController: UIViewController {
    
    private var cards: [Card] = [Card(name: "Duration", image: "clock",toBeDone: 120, done: 0, unit: "min"), Card(name:"Cals burnt", image: "flame.fill", toBeDone: 300, done: 0, unit: "kcal"), Card(name: "Steps", image: "shoeprints.fill", toBeDone: 800, done: 500)]
    private var exploreRoutine: [Routine] = []
    private var currentPhase: Phase = .unknown
    private var recommendedRoutineId: UUID?
    
    private var selectedPredefinedRoutine: Routine?
    private var selectedRoutine: Routine?
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Workout"
        navigationController?.navigationBar.prefersLargeTitles = true
       
        setupNavigation()
        registerCells()
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress(_:))
            )
            longPressGesture.minimumPressDuration = 0.5
            collectionView.addGestureRecognizer(longPressGesture)
        
    }
    //calendar 
    private func setupNavigation() {
        let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarTapped))
        navigationItem.rightBarButtonItem = calendar
    }
    //why to use obj c function here?
    @objc func calendarTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WorkoutCalendarViewController") as? WorkoutCalendarViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func generateLayout()->UICollectionViewLayout {
        //collectionView.backgroundColor=UIColor(hex: "FCEEED")
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            // Header for all sections
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(sectionIndex == 0 ? 10 : 50) // Reduce header height for section 0
            )
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )
            
            if sectionIndex == 0 {
                // Daily Goals - horizontal, non-scrollable, dynamic sizing
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0 / 3.0),
                    heightDimension: .absolute(160)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(160)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0) // Negative top inset to pull it up
                section.boundarySupplementaryItems = [headerItem]
                return section
                
            } else if sectionIndex == 1 {
                
                
                // My Routines - horizontal scrolling cards
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(170)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(150)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
                section.boundarySupplementaryItems = [headerItem]
                return section
                
            } else {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(140)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(140)
                )
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                section.interGroupSpacing = 0
                section.boundarySupplementaryItems = [headerItem]
                
                return section
                
            }
        }, configuration: configuration)
        
        return layout
    }
    
    
    
    func registerCells() {
        
        collectionView.register(UINib(nibName: "GoalCards", bundle: nil), forCellWithReuseIdentifier: "workout_Goal_Cell")
        
        collectionView.register(
            UINib(nibName: "ExploreRoutinesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "explore_routines_cell"
        )
        collectionView.register(
            UINib(nibName: "MyRoutinesEmptyCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "my_routines_empty_cell"
        )
        
        collectionView.register(
            UINib(nibName: "MyRoutinesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "my_routines_cell"
        )
        
        // Register header as supplementary view (not as a cell)
        collectionView.register(
            UINib(nibName: "HeaderCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )
    }
    
    
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PredefinedRoutines" {
            if let vc = segue.destination as? PredefinedRoutinesViewController {
                vc.routine = selectedPredefinedRoutine
            }
        }
        //passing the routine data forward
        if segue.identifier == "showRoutinePreview",
           let vc = segue.destination as? RoutinePreviewViewController,
           let routine = selectedRoutine {
            vc.routine = routine
        }
    }
    
}

extension WorkoutViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return cards.count
        } else if section == 1 {
            let count = UserRoutineDataStore.shared.loadAll().count
            
            // If empty → show ONE placeholder cell
            return count == 0 ? 1 : count + 1
            //if true->return one cell and if false->return no of cells
            //            return WorkoutSessionManager.shared.savedRoutines.count
        } else {
            return exploreRoutine.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "workout_Goal_Cell", for: indexPath) as! GoalCards
            cell.configureCell(cards[indexPath.row])
            return cell
            
        } else if indexPath.section == 1 {
            //NEW
            let routines = UserRoutineDataStore.shared.loadAll()
            
            // EMPTY STATE
            if routines.isEmpty {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "my_routines_empty_cell",
                    for: indexPath
                ) as! MyRoutinesEmptyCollectionViewCell
                
                return cell
            } else {
                if indexPath.item != routines.count {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "my_routines_cell", for: indexPath) as! MyRoutinesCollectionViewCell
                    let routine = routines[indexPath.row]
                    cell.configureCell(with: routine)
                    
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "my_routines_empty_cell",
                        for: indexPath
                    ) as! MyRoutinesEmptyCollectionViewCell
                    
                    return cell
                }
            }
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "explore_routines_cell", for: indexPath) as! ExploreRoutinesCollectionViewCell
            let routine = exploreRoutine[indexPath.row]
            let isRecommended = routine.id == recommendedRoutineId
            cell.configureCell(routine, isRecommended: isRecommended)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,at indexPath:IndexPath)->UICollectionReusableView{
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderCollectionReusableView
        //headerView.backgroundColor = .red
        
        if indexPath.section == 0 {
            headerView.configureHeader(with:"")
        }
        else if indexPath.section == 1{
            headerView.configureHeader(with:"My Created Routines")
        } else if  indexPath.section == 2{
            headerView.configureHeader(with:"Routines You Could Try")
        }
        return headerView
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
                // Handle goal card tap
                let selectedCard = cards[indexPath.item]
                navigateToMetrics(for: selectedCard)
                
        case 1:
            let routines = UserRoutineDataStore.shared.loadAll()
            //guard !routines.isEmpty else { return }
            if routines.isEmpty {
                if indexPath.item == 0 {
                    performSegue(withIdentifier: "showCreateRoutine", sender: nil)
                }
            } else {
                if indexPath.item < routines.count {
                    let routine = routines[indexPath.item]
                    selectedRoutine = routine
                    performSegue(withIdentifier: "showRoutinePreview", sender: nil)

                } else {
                    performSegue(withIdentifier: "showCreateRoutine", sender: nil)
                }
            }
            
            
        case 2:
            let routine = exploreRoutine[indexPath.item]
            selectedRoutine = routine
            performSegue(withIdentifier: "showRoutinePreview", sender: nil)
            
            
        default:
            return
        }
    }
    private func navigateToMetrics(for card: Card) {
        // Map Card to GoalType
        let goalType: GoalType
        
        switch card.name {
//        case "Calories burnt":
//            goalType = .calories
        case "Cals burnt":
            goalType = .calories
        case "Steps":
            goalType = .steps
        case "Duration":
            goalType = .duration
        default:
            return
        }
        
        // Instantiate MetricsViewController
        if let metricsVC = storyboard?.instantiateViewController(withIdentifier: "MetricsViewController") as? MetricsViewController {
            metricsVC.goalType = goalType
            navigationController?.pushViewController(metricsVC, animated: true)
        }
    }
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {

        // We only want one trigger
        guard gesture.state == .began else { return }

        let point = gesture.location(in: collectionView)

        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return
        }

        // Only allow delete in "My Routines" section
        guard indexPath.section == 1 else { return }

        let routines = UserRoutineDataStore.shared.loadAll()

        // Ignore empty/add cell
        guard !routines.isEmpty, indexPath.item < routines.count else {
            return
        }

        let routine = routines[indexPath.item]
        //hapticbefore deleting 
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        showDeleteAlert(for: routine, at: indexPath)
    }
    private func showDeleteAlert(for routine: Routine, at indexPath: IndexPath) {

        let alert = UIAlertController(
            title: "Delete Routine?",
            message: "This routine will be permanently deleted.",
            preferredStyle: .alert
        )

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            let routines = UserRoutineDataStore.shared.loadAll(); if indexPath.item < routines.count { UserRoutineDataStore.shared.delete(routines[indexPath.item]) }
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(alert, animated: true)
    }
}

// Add this method to WorkoutViewController.swift

extension WorkoutViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let calendar = Calendar.current
        let today = Date()

        // Update current phase and phase-filtered routines
        currentPhase = CycleDataStore.shared.currentPhaseInfo().phase
        
        var routinesList = RoutineDataStore.shared.routines(for: currentPhase)
        let recommended = RoutineDataStore.shared.recommendedRoutine(for: currentPhase)
        recommendedRoutineId = recommended.id
        
        if let index = routinesList.firstIndex(where: { $0.id == recommended.id }) {
            let item = routinesList.remove(at: index)
            routinesList.insert(item, at: 0)
        }
        exploreRoutine = routinesList


        // Duration card: total in-app workout seconds today
        cards[2].done = Double(CompletedWorkoutsDataStore.shared.loadAll().filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }.reduce(0) { $0 + $1.durationSeconds })


        // Cals card: start from today's real session calories (persisted on disk)
        // HealthKit will add background calories on top once the async fetch returns
        let todaySessionCals = CompletedWorkoutsDataStore.shared.loadAll()
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0.0) { $0 + $1.caloriesBurned }
        cards[1].done = todaySessionCals

        // Steps card: keep last known value; HealthKit update will replace it below
        // (cards[2].done is untouched here — fetchHealthKitData fills it)

        syncWorkoutsToActivityStore()
        collectionView.reloadData()

        // Fetch live HealthKit data and update cards + DataStore
        fetchHealthKitData()
    }
    
    // NEW METHOD: Sync all completed workouts to activity store
    private func syncWorkoutsToActivityStore() {
        let completedWorkouts = CompletedWorkoutsDataStore.shared.loadAll().filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        
        print("Syncing \(completedWorkouts.count) workouts to activity store...")
        
        for workout in completedWorkouts {
            DailyActivityDataStore.shared.syncWorkout(workout)
        }
        
        print("Sync complete!")
    }
    
    // MARK: - HealthKit Live Data
    
    /// Fetches today's real steps and calories from HealthKit and updates both the UI cards
    /// and the DailyActivityDataStore (so MetricsViewController charts also reflect real data).
    private func fetchHealthKitData() {
        var hkSteps: Int = 0
        var hkCalories: Double = 0
        let group = DispatchGroup()
        
        // --- Steps ---
        group.enter()
        HealthKitManager.shared.fetchTodaySteps { steps in
            hkSteps = steps
            group.leave()
        }
        
        // --- Active Calories ---
        group.enter()
        HealthKitManager.shared.fetchTodayActiveCalories { cals in
            hkCalories = cals
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            // Steps card — real HealthKit value
            if hkSteps > 0 {
                self.cards[2].done = Double(hkSteps)
            }

            // Cals card — HealthKit all-day background + today's in-app session calories
            let todaySessionCals = CompletedWorkoutsDataStore.shared.loadAll()
                .filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
                .reduce(0.0) { $0 + $1.caloriesBurned }
            self.cards[1].done = hkCalories + todaySessionCals

            // Persist into DataStore so MetricsViewController charts reflect real HK data
            DailyActivityDataStore.shared.mergeHealthKitData(
                steps: hkSteps,
                healthKitDailyCalories: Int(hkCalories)
            )

            self.collectionView.reloadData()
        }
    }
}
