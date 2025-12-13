//
//  WorkoutViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class WorkoutViewController: UIViewController {
    
    private var cards: [Card] = [Card(name:"Calories burnt", image: "flame.fill"),Card(name: "Steps", image: "figure.walk"), Card(name: "Duration", image: "stopwatch.fill")]
    private var exploreRoutine: [Routine] = RoutineDataStore.shared.predefinedRoutines
    
    private var selectedPredefinedRoutine: Routine?
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Workout"
        navigationController?.navigationBar.prefersLargeTitles = true
        registerCells()
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        //setupExploreData()
    }
    
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        // Navigate to your Create Routine screen
        performSegue(withIdentifier: "showCreateRoutine", sender: nil)
    }
    
    
    func generateLayout()->UICollectionViewLayout {
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
                configuration.interSectionSpacing = 20

                let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                    
                    // Header for all sections
                    let headerSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(50)
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
                            heightDimension: .fractionalWidth(1/3.0)
                        )
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
                        
                        let groupSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .estimated(120)
                        )
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                        section.boundarySupplementaryItems = [headerItem]
                        return section
                        
                    } else if sectionIndex == 1 {
                        // My Routines - horizontal scrolling cards
                        let itemSize = NSCollectionLayoutSize(
                            widthDimension: .absolute(200),
                            heightDimension: .absolute(125)
                        )
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        
                        let groupSize = NSCollectionLayoutSize(
                            widthDimension: .absolute(205),
                            heightDimension: .absolute(125)
                        )
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.orthogonalScrollingBehavior = .groupPaging
                        section.interGroupSpacing = 12
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                        section.boundarySupplementaryItems = [headerItem]
                        return section
                        
                    } else {
                        // Explore Routines - 2 column grid
                        let itemSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(0.5),
                            heightDimension: .absolute(130)
                        )
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 12, trailing: 6)
                        
                        let groupSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(150)
                        )
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
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
    
    
    
    //to reload the screen for latest routines to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PredefinedRoutines" {
            if let vc = segue.destination as? PredefinedRoutinesViewController {
                vc.routine = selectedPredefinedRoutine
            }
        }
    }

}
    
extension WorkoutViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return cards.count
        } else if section == 1 {
            return WorkoutSessionManager.shared.savedRoutines.count
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "my_routines_cell", for: indexPath) as! MyRoutinesCollectionViewCell
            let routine = WorkoutSessionManager.shared.savedRoutines[indexPath.row]
            cell.configureCell(with: routine)
            cell.onStartTapped = { [weak self] in
                guard let self = self else {return}
                let workoutExercises = routine.exercises.map{$0.generateWorkoutExercise()}
                let activeWorkout = ActiveWorkout(routine: routine, exercises: workoutExercises)
                WorkoutSessionManager.shared.activeWorkout = activeWorkout
                self.performSegue(withIdentifier: "showStartRoutine", sender: nil)
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "explore_routines_cell", for: indexPath) as! ExploreRoutinesCollectionViewCell
            cell.configureCell(exploreRoutine[indexPath.row])
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
            headerView.configureHeader(with:"Daily Goals")
        } else if indexPath.section == 1{
            headerView.configureHeader(with:"My Routines")
        } else {
            headerView.configureHeader(with:"Explore Routines")
        }
        return headerView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Only handle taps for Predefined Routines section
        guard indexPath.section == 2 else { return }
        
        let routine = exploreRoutine[indexPath.item]
        selectedPredefinedRoutine = routine
        
        performSegue(withIdentifier: "PredefinedRoutines", sender: nil)
    }
    

}
