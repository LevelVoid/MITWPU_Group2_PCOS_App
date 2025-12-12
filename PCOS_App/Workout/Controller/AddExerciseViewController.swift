//
//  AddExerciseViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit
//note all the methods are inside this class
class AddExerciseViewController: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExerciseSearchBar: UISearchBar!
    @IBOutlet weak var muscleTypeFilterButton: UIButton!
    @IBOutlet weak var equipmentsFilterButton: UIButton!
    // Data source
    private var exercises: [Exercise] = []
    private var filteredExercises : [Exercise] = []
    // Optional: track selected exercise IDs if you need them later
    private var selectedExerciseIDs = Set<UUID>()
    
    //(([Exercise]) -> Void)? means: "A function that takes an array of Exercise and returns nothing"
    var onExercisesSelected: (([Exercise]) -> Void)?

    //varaibles for storing filter selection
    //using sets to prevent duplicates and search faster : set.contains()-> O(1)
    private var selectedEquipment: Set<Equipment> = []
    private var selectedMuscleType: Set<MuscleGroup> = []
    
    private var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Exercise"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        saveButton.isEnabled = false
        
        setupUI()
        loadData()
        applyFilters()//initial data with no filters would be displayed
        
    }
    private func setupUI(){
        addExerciseSearchBar.delegate = self
        //addExerciseSearchBar.placeholder="Search Exercises"
        
        //setup filter buttons
        equipmentsFilterButton.setTitle("All Equipment", for: .normal)
        muscleTypeFilterButton.setTitle("All Muscles", for: .normal)
        updateButtonAppearance()
        
        //setup table view
        
        //you are telling the table:"This view controller (self) will provide the data for your rows."
        tableView.dataSource = self
        //you are telling the table:"This view controller (self) will handle interactions and behavior."
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = 88
    }
    
    private func loadData(){
        // We access the shared (singleton) instance of ExerciseDataStore using `.shared`.
        // Singleton means there is only ONE instance of this class in the entire app.
        // This avoids creating multiple copies of the data store and keeps all data
        // consistent (a single source of truth).
        // From that single shared instance, we read `allExercises`
        // and assign that list to our local `exercises` variable.
        exercises = ExerciseDataStore.shared.allExercises
    }
    
    //Button actions
    @IBAction func showEquipmentSelectionButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showEquipmentSelectionVC", sender: nil)
    }
    
    @IBAction func showMuscleSelectionButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showMuscleSelectionVC", sender: nil)
    }
    
    
    
    //filtering logic
    private func applyFilters(){
        //Start with the complete list, then progressively narrow it down based on active filters.
        var result = exercises
        
        //applying equipment filter on the add exercise screen
        if !selectedEquipment.isEmpty && !selectedEquipment.contains(.allEquipment) {
                result = result.filter { exercise in
                    selectedEquipment.contains(exercise.equipment)
                }
            }
        //applying muscle group filter
        if !selectedMuscleType.isEmpty && !selectedMuscleType.contains(.allMuscles){
            result=result.filter{
                exercise in selectedMuscleType.contains(exercise.muscleGroup)
            }
        }
        
        //applying search text filter
        if !searchText.isEmpty{
            result=result.filter{
                exercise in
                exercise.name.lowercased().contains(searchText.lowercased()) ||
                exercise.muscleGroup.displayName.lowercased().contains(searchText.lowercased())
            }
        }
        //updating filtered exercises and reload table
        filteredExercises = result
        tableView.reloadData()
        restoreSelectionState()
        updateButtonAppearance()
    }
    
    // NEW METHOD: Restore checkmarks for selected exercises
    private func restoreSelectionState() {
        for (index, exercise) in filteredExercises.enumerated() {
            if selectedExerciseIDs.contains(exercise.id) {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                
                // Also update the cell's accessory if it's visible
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                    cell.selectionStyle = .none
                }
            }
        }
    }
    
    private func updateButtonAppearance(){
        //update equipment button
        if selectedEquipment.isEmpty||selectedEquipment.contains(.allEquipment){
            equipmentsFilterButton.setTitle( "All Equipment", for: .normal)
            equipmentsFilterButton.backgroundColor = .systemGray5
            equipmentsFilterButton.setTitleColor(.label, for: .normal)
        }
        else if selectedEquipment.count==1 {
            // `selectedEquipment.first` may be nil (if nothing is selected),
            // so we use optional chaining (`?.displayName`) to safely access the name.
            // If it's nil, the nil-coalescing operator (`??`) provides a fallback title: "Equipment".
            equipmentsFilterButton.setTitle(selectedEquipment.first?.displayName ?? "Equipment",for : .normal)
            equipmentsFilterButton.backgroundColor = .systemBlue
            equipmentsFilterButton.setTitleColor(.white, for: .normal)
        }
        else{
            equipmentsFilterButton.setTitle("\(selectedEquipment.count) Equipments", for: .normal)
            equipmentsFilterButton.backgroundColor = .systemBlue
            equipmentsFilterButton.setTitleColor(.white, for: .normal)
        }
        if selectedMuscleType.isEmpty||selectedMuscleType.contains(.allMuscles){
            muscleTypeFilterButton.setTitle( "All Muscles", for: .normal)
            muscleTypeFilterButton.backgroundColor = .systemGray5
            muscleTypeFilterButton.setTitleColor(.label, for: .normal)
        }
        else if selectedMuscleType.count==1 {
            muscleTypeFilterButton.setTitle(selectedMuscleType.first?.displayName ?? " Muscle",for : .normal)
            muscleTypeFilterButton.backgroundColor = .systemBlue
            muscleTypeFilterButton.setTitleColor(.white, for: .normal)
        }
        else{
            muscleTypeFilterButton.setTitle("\(selectedMuscleType.count) Muscles", for: .normal)
            muscleTypeFilterButton.backgroundColor = .systemBlue
            muscleTypeFilterButton.setTitleColor(.white, for: .normal)
        }
    }
    
    private func updateSaveButtonState() {
        saveButton.isEnabled = !selectedExerciseIDs.isEmpty
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        **Why two unwraps?**
//
//        The destination is wrapped in a **Navigation Controller** (for the close/save buttons at top):
//        ```
//        segue.destination
//            ↓
//        ┌────────────────────────────────┐
//        │ UINavigationController         │  ← First unwrap
//        │  ┌──────────────────────────┐  │
//        │  │[Cancel]  Equipment [Save]│  │  Navigation bar
//        │  ├──────────────────────────┤  │
//        │  │EquipmentSelectionVC      │  │  ← Second unwrap
//        │  │                          │  │
//        │  │ ☐ Dumbbells              │  │
//        │  │ ☐ Barbell                │  │
//        │  └──────────────────────────┘  │
//        └────────────────────────────────┘
        
//        AddExerciseVC
//           → UINavigationController (container)
//                 → EquipmentSelectionViewController (top VC)
        
        ///Step 1: Get the navigation controller
        //let navController = segue.destination as? UINavigationController

        ///Step 2: Get the actual view controller inside the navigation controller
        //let selectionVC = navController.topViewController as? EquipmentSelectionViewController
        
        
//        Why wrap it inside navigation controller when presenting modally?
///        Because UIKit doesn’t automatically give modal screens a navigation bar.
///        You would have to build your own bar manually.
        
        if segue.identifier=="showEquipmentSelectionVC"{
            if let navController=segue.destination as? UINavigationController,
               let selectionVC=navController.topViewController as? EquipmentSelectionViewController {
                //pass current selections
                selectionVC.selectedEquipment = selectedEquipment
                //set callback to receive new selections
                selectionVC.onSave = { [weak self] newSelections in
                    self?.selectedEquipment = newSelections
                    self?.applyFilters()
                }
            }
        }
        
//        [weak self]
//        ```
//
//        **Why weak?**
//
//        Prevents a **retain cycle** (memory leak):
//        ```
//        Without [weak self]:
//        AddExerciseVC ──strong──> Closure
//             ↑                        │
//             └────────strong──────────┘
//        Both hold strong references to each other = MEMORY LEAK ❌
//
//        With [weak self]:
//        AddExerciseVC ──strong──> Closure
//             ↑                        │
//             └────────weak───────────┘
//        Closure holds weak reference = NO LEAK ✅
        
        if segue.identifier=="showMuscleSelectionVC"{
            if let navController=segue.destination as? UINavigationController,
               let selectionVC=navController.topViewController as? MuscleTypeSelectionViewController {
                selectionVC.selectedMuscles = selectedMuscleType
                selectionVC.onSave = { [weak self] newSelections in
                    self?.selectedMuscleType = newSelections
                    self?.applyFilters()
                }
            }//in this controller it is called selected muscle types and on muscle modal vc it is called selected muscles 
        }
    }
    
    // MARK: - Add this method to handle saving selected exercises
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // Get selected exercises based on selectedExerciseIDs
        let selectedExercises = exercises.filter { exercise in
            selectedExerciseIDs.contains(exercise.id)
        }
        
        // Call the callback with selected exercises
        onExercisesSelected?(selectedExercises)
        
        // Dismiss this view controller
        //dismiss(animated: true, completion: nil)
        
        navigationController?.popViewController(animated: true)
       
    }

    
}//end of class



//UI Table View Data Source

extension AddExerciseViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredExercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "add_exercise_cell", for: indexPath) as? AddExerciseTableViewCell else {
            return UITableViewCell()
        }
//using filtered exercises instead
        let exercise = filteredExercises[indexPath.row]
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
                    cell.accessoryType = .checkmark
                    cell.selectionStyle = .none
                } else {
                    cell.accessoryType = .none
                    cell.selectionStyle = .default
                }

        return cell
    }
}

extension AddExerciseViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = filteredExercises[indexPath.row]
        // Keep it selected (do not call deselect here)
        selectedExerciseIDs.insert(exercise.id)
        // If you want custom visual feedback beyond default highlight, reload cell or update accessoryType:
        if let cell = tableView.cellForRow(at: indexPath) { cell.accessoryType = .checkmark
            //added to remove grey tint when row selected
            cell.selectionStyle = .none
        }
        
        updateSaveButtonState()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let exercise = filteredExercises[indexPath.row]
            
            selectedExerciseIDs.remove(exercise.id)
            
        // If using accessoryType:
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
        
        updateSaveButtonState()
    }
}
extension AddExerciseViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchText = ""
        searchBar.resignFirstResponder()
        applyFilters()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
