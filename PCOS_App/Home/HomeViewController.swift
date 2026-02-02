//
//  HomeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    // Storing selected symptoms
    private var selectedSymptoms: [SymptomItem] = []
    private var recommendationCards : [Recommendation] = recommendations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Today"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let bgColor = UIColor(hex: "#FCEEED")
        collectionView.backgroundColor = bgColor
        view.backgroundColor = bgColor
        
        let calendar = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(leftBarButtonTapped)
        )
        
        let profile = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        
        navigationItem.rightBarButtonItems = [profile, calendar]
        
        registerCells()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\nThis is HomeVC:",selectedSymptoms)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func loadTodaysSymptoms() {
        if let data = UserDefaults.standard.data(forKey: "todaysSymptoms"),
           let symptoms = try? JSONDecoder().decode([SymptomItem].self, from: data) {
            
            // Check if symptoms are from today
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Filter only symptoms logged today
            let todaysSymptoms = symptoms.filter { symptom in
                let symptomDate = calendar.startOfDay(for: symptom.date!)
                return symptomDate == today
            }
            
            selectedSymptoms = todaysSymptoms
            
            // Update UserDefaults with filtered symptoms
            if let encoded = try? JSONEncoder().encode(todaysSymptoms) {
                UserDefaults.standard.set(encoded, forKey: "todaysSymptoms")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    func registerCells() {
        collectionView.register(
            UINib(nibName: "HomeHeaderCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "home_header"
        )
        
        collectionView.register(
            UINib(nibName: "AddSymptomCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "AddSymptomCollectionViewCell"
        )
        
        collectionView.register(
            UINib(nibName: "SymptomItemCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: SymptomItemCollectionViewCell.identifier
        )
        collectionView.register(
            UINib(nibName: "CyclePatternCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "cycle_pattern_cell"
        )
        collectionView.register(
            UINib(nibName: "HomeRecommendationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "recommendation_cell"
        )
        collectionView.register(
            UINib(nibName: "HeaderCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )
    }
    
    @objc func addTapped() {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func leftBarButtonTapped() {
        
        // COMMENTED OUT: Will pass period dates to FullCalendarViewController later
        /*
         if let vc = storyboard?.instantiateViewController(withIdentifier: "FullCalendarViewController") as? FullCalendarViewController {
         // Load saved period dates
         var periodDates: [Date] = []
         if let timestamps = UserDefaults.standard.array(forKey: "SavedPeriodDates") as? [TimeInterval] {
         periodDates = timestamps.map { Date(timeIntervalSince1970: $0) }.sorted()
         }
         
         // Pass the dates to FullCalendarViewController
         vc.periodDates = periodDates
         
         navigationController?.pushViewController(vc, animated: true)
         }
         */
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FullCalendarViewController") as? FullCalendarViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createHomeHeaderSection()
            case 1: return self.createSymptomSection()
            case 2: return self.createCycleSection()
            case 3: return self.createRecommendationSection()
            default:
                return nil
            }
        }
    }
    
    func createHomeHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(450))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }
    
    func createSymptomSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .absolute(100)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 16, trailing: 20
        )
        section.orthogonalScrollingBehavior = .continuous
        addHeader(to: section)
        return section
    }
    
    func createCycleSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
        return section
    }
    func createRecommendationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(285), // Fixed width for each card
            heightDimension: .absolute(196) // Adjusted height
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(285),
            heightDimension: .absolute(196)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16 // Space between cards
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 20,
            trailing: 16
        )
        section.orthogonalScrollingBehavior = .continuous // Enable horizontal scrolling
        
        addHeader(to: section)
        return section
    }
    
    func addHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "header",
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
    }
}



extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return selectedSymptoms.count + 1
        case 2:
            return 1
        case 3:
            return recommendationCards.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_header", for: indexPath) as! HomeHeaderCollectionViewCell
            cell.delegate = self
            //the cell will load and display cycle data
            return cell
        }
        else if indexPath.section == 1 {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSymptomCollectionViewCell", for: indexPath) as! AddSymptomCollectionViewCell
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomItemCollectionViewCell", for: indexPath) as! SymptomItemCollectionViewCell
            let symptom = selectedSymptoms[indexPath.item - 1]
            
            cell.configureWithCategory(with: symptom)
            return cell
        }
        else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cycle_pattern_cell", for: indexPath) as! CyclePatternCollectionViewCell
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendation_cell", for: indexPath) as! HomeRecommendationCollectionViewCell
            let recommendation = recommendationCards[indexPath.item]
            cell.configure(with: recommendation)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    
    func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,at indexPath:IndexPath)->UICollectionReusableView{
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderCollectionReusableView
        
        if indexPath.section == 1 {
            headerView.configureHeader(with:"Symptoms")
        } else if indexPath.section == 3{
            headerView.configureHeader(with:"What May Happen Next")
        }else {
            headerView.configureHeader(with:"Explore Routines")
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            if indexPath.item == 0 {
                performSegue(withIdentifier: "showSymptomLogger", sender: self)
            }
        }
        
        if indexPath.section == 2 {
            performSegue(withIdentifier: "showCycleReport", sender: nil)
        }
        
        if indexPath.section == 3 {
            if indexPath.item == 0 {
                performSegue(withIdentifier: "showProtein", sender: self)
            } else if indexPath.item == 1 {
                performSegue(withIdentifier: "showInsulin", sender: self)
            } else if indexPath.item == 2 {
                performSegue(withIdentifier: "showWorkoutPush", sender: self)
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSymptomLogger",
           let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
            
            symptomLoggerVC.delegate = self
            
            symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
            
            symptomLoggerVC.onSymptomsSelected = { [weak self] symptoms in
                guard let self = self else { return }
                
                self.selectedSymptoms = symptoms
                
                // Save with today's date key
                let todaysKey = self.getTodaysKey()
                if let encoded = try? JSONEncoder().encode(symptoms) {
                    UserDefaults.standard.set(encoded, forKey: todaysKey)
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    // Helper to get today's key
    private func getTodaysKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "symptoms_\(formatter.string(from: Date()))"
    }
    
}

extension HomeViewController: DataPassDelegate {
    func passData(symptoms: [SymptomItem]) -> [SymptomItem] {
        self.selectedSymptoms = symptoms
        let todaysKey = self.getTodaysKey()
        if let encoded = try? JSONEncoder().encode(symptoms) {
            UserDefaults.standard.set(encoded, forKey: todaysKey)
        }
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        return symptoms
    }
}
extension HomeViewController: HomeHeaderCollectionViewCellDelegate {
    func homeHeaderCellDidTapLogPeriod(_ cell: HomeHeaderCollectionViewCell) {
        let calendarVC = LogPeriodCalendarViewController()
        calendarVC.delegate = self
        
        // Present in a navigation controller for the navigation bar to show
        let navController = UINavigationController(rootViewController: calendarVC)
        navController.modalPresentationStyle = .pageSheet // or .formSheet for smaller size
        
        // Optional: Configure sheet presentation (iOS 15+)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()] // Full screen height
            sheet.prefersGrabberVisible = true // Show the handle at top
        }
        
        present(navController, animated: true)
    }
}

// LogPeriodCalendarDelegate
extension HomeViewController: LogPeriodCalendarDelegate {
    func didSavePeriodDates(_ dates: [Date], cycleDay: Int) {
        print("Received period dates: \(dates.count) dates")
        print("Current cycle day: \(cycleDay)")
        
        // Reload the header section to update the cycle day label
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadSections(IndexSet(integer: 0))
        }
        
        // for debug
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dates.forEach { date in
            print("Period date: \(formatter.string(from: date))")
        }
    }
}




