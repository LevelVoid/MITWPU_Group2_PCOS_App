import UIKit

class HomeViewController: UIViewController, DataPassDelegate, HomeHeaderCollectionViewCellDelegate, LogPeriodCalendarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedSymptoms: [SymptomItem] = []
    private var displaySignals: [DisplaySignal] = []
    private var recommendationCards: [Recommendation] = recommendations
    private var allSymptoms: [SymptomItem] = []
    private var aboutPCOSArticles: [AboutPCOSSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        tabBarItem.title = "Today"
        navigationItem.title = ""
        
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
        
        allSymptoms = SymptomDataStore.loadAllSymptomsLastNDays(30)
        loadTodaysSymptoms()
        buildDisplaySignals()
        aboutPCOSArticles = AboutPCOSDataStore.shared.fetchSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTodaysSymptoms()
        buildDisplaySignals()
        collectionView.reloadData()
    }

    private func loadTodaysSymptoms() {
        if let data = UserDefaults.standard.data(forKey: "todaysSymptoms"),
           let symptoms = try? JSONDecoder().decode([SymptomItem].self, from: data) {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let todaysSymptoms = symptoms.filter { symptom in
                let symptomDate = calendar.startOfDay(for: symptom.date!)
                return symptomDate == today
            }
            selectedSymptoms = todaysSymptoms
            if let encoded = try? JSONEncoder().encode(todaysSymptoms) {
                UserDefaults.standard.set(encoded, forKey: "todaysSymptoms")
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func buildDisplaySignals() {
        displaySignals.removeAll()
        let currentPhase = getCurrentPhase()
        let phaseSignals = PhaseSignalDataStore.shared.signals(for: currentPhase)
        displaySignals.append(contentsOf: phaseSignals)
        for symptom in selectedSymptoms {
            if let signal = PCOSSignalStore.signal(for: symptom.name) {
                displaySignals.append(.symptom(signal))
            }
        }
    }

    private func getCurrentPhase() -> Phase {
        return .menstrual
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
            UINib(nibName: "SignalsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "signals_cell"
        )
        collectionView.register(
            UINib(nibName: "QuickActionsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "quick_actions_cell"
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
            UINib(nibName: "SleepCardCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "sleep_card_cell"
        )
        collectionView.register(
            UINib(nibName: "SymptomPatternsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "symptom_patterns_cell"
        )
        collectionView.register(
            UINib(nibName: "AboutPCOSCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "about_pcos_cell"
        )
        collectionView.register(
            UINib(nibName: "HeaderCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )
    }
    
    @objc func addTapped() {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "ProfileTableViewController"
        ) as? ProfileTableViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func leftBarButtonTapped() {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "FullCalendarViewController"
        ) as? FullCalendarViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Compositional Layout
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createHomeHeaderSection()
            case 1: return self.createSignalsSection()
            case 2: return self.createQuickActionsSection()
            case 3: return self.createRecommendationSection()
            case 4: return self.createSleepCardSection()
            case 5: return self.createCycleSection()
            case 6: return self.createSymptomPatternsSection()
            case 7: return self.createAboutPCOSSection()
            default: return nil
            }
        }
    }
    
    func createHomeHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(380)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }
    
    func createSignalsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(105),
            heightDimension: .absolute(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(105),
            heightDimension: .absolute(120)
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
    
    func createQuickActionsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(310)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 10, trailing: 16
        )
        addHeader(to: section)
        return section
    }
    
    func createCycleSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(547)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 10, trailing: 16
        )
        addHeader(to: section)
        return section
    }
    
    func createRecommendationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(285),
            heightDimension: .absolute(196)
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
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 20, trailing: 16
        )
        section.orthogonalScrollingBehavior = .continuous
        addHeader(to: section)
        return section
    }
    
    func createSleepCardSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 16, trailing: 16
        )
        addHeader(to: section)
        return section
    }
    
    func createSymptomPatternsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(340),
            heightDimension: .absolute(320)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(340),
            heightDimension: .absolute(320)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 20, trailing: 16
        )
        section.orthogonalScrollingBehavior = .continuous
        addHeader(to: section)
        return section
    }
    
    func createAboutPCOSSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(340),
            heightDimension: .absolute(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(340),
            heightDimension: .absolute(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 20, trailing: 16
        )
        section.orthogonalScrollingBehavior = .continuous
        addHeader(to: section)
        return section
    }
    
    func addHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "header",
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
    }
    
    // MARK: - DataPassDelegate
    
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
    
    // MARK: - HomeHeaderCollectionViewCellDelegate
    
    func homeHeaderCellDidTapLogPeriod(_ cell: HomeHeaderCollectionViewCell) {
        let calendarVC = LogPeriodCalendarViewController()
        calendarVC.delegate = self
        let navController = UINavigationController(rootViewController: calendarVC)
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(navController, animated: true)
    }
    
    // MARK: - LogPeriodCalendarDelegate
    
    func didSavePeriodDates(_ dates: [Date], cycleDay: Int) {
        print("Received period dates: \(dates.count) dates")
        print("Current cycle day: \(cycleDay)")
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadSections(IndexSet(integer: 0))
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dates.forEach { date in
            print("Period date: \(formatter.string(from: date))")
        }
    }
    
    private func getTodaysKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "symptoms_\(formatter.string(from: Date()))"
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSymptomLogger",
           let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
            symptomLoggerVC.delegate = self
            symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
            symptomLoggerVC.onSymptomsSelected = { [weak self] symptoms in
                guard let self = self else { return }
                self.selectedSymptoms = symptoms
                let todaysKey = self.getTodaysKey()
                if let encoded = try? JSONEncoder().encode(symptoms) {
                    UserDefaults.standard.set(encoded, forKey: todaysKey)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        if segue.identifier == "showSignal01",
           let destination = segue.destination as? Signal01ViewController,
           let signal = sender as? PCOSSignal {
            destination.signal = signal
        }
    }
}

// MARK: - QuickActionsDelegate
extension HomeViewController: QuickActionsDelegate {
    
    func quickActionsDidTapAddMeal() {
        let dietStoryboard = UIStoryboard(name: "Diet", bundle: nil)
        guard let addMealVC = dietStoryboard.instantiateViewController(
            withIdentifier: "AddMealViewController"
        ) as? AddMealViewController else {
            print("Error: Could not instantiate AddMealViewController")
            return
        }
        addMealVC.dietDelegate = self
        navigationController?.pushViewController(addMealVC, animated: true)
    }
    
    func quickActionsDidTapStartWorkout() {
        // Navigate to your workout VC here
    }
}

// MARK: - AddDescribedMealDelegate
extension HomeViewController: AddDescribedMealDelegate {
    func didConfirmMeal(_ food: Food) {
        collectionView.reloadSections(IndexSet(integer: 2))
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 8
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1 + displaySignals.count
        case 2: return 1
        case 3: return recommendationCards.count
        case 4: return 1
        case 5: return 1
        case 6: return allSymptoms.count
        case 7: return aboutPCOSArticles.count
        default: return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "home_header",
                for: indexPath
            ) as! HomeHeaderCollectionViewCell
            cell.delegate = self
            return cell
            
        case 1:
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "AddSymptomCollectionViewCell",
                    for: indexPath
                ) as! AddSymptomCollectionViewCell
                return cell
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "signals_cell",
                for: indexPath
            ) as! SignalsCollectionViewCell
            let signalIndex = indexPath.item - 1
            let displaySignal = displaySignals[signalIndex]
            switch displaySignal {
            case .phase(let phaseSignal, let cardType):
                cell.configurePhase(phase: phaseSignal, cardType: cardType)
            case .symptom(let symptomSignal):
                cell.configure(with: symptomSignal)
            }
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "quick_actions_cell",
                for: indexPath
            ) as! QuickActionsCollectionViewCell
            cell.delegate = self  // ← key line
            cell.configure()
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "recommendation_cell",
                for: indexPath
            ) as! HomeRecommendationCollectionViewCell
            let recommendation = recommendationCards[indexPath.item]
            cell.configure(with: recommendation)
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_card_cell",
                for: indexPath
            ) as! SleepCardCollectionViewCell
            return cell
            
        case 5:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "cycle_pattern_cell",
                for: indexPath
            ) as! CyclePatternCollectionViewCell
            return cell
            
        case 6:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "symptom_patterns_cell",
                for: indexPath
            ) as! SymptomPatternsCollectionViewCell
            let symptom = allSymptoms[indexPath.item]
            let cycles = CycleDataStore.shared.loadRecentCycles()
            cell.configure(cycles: cycles, symptom: symptom)
            return cell
            
        case 7:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "about_pcos_cell",
                for: indexPath
            ) as! AboutPCOSCollectionViewCell
            let article = aboutPCOSArticles[indexPath.item]
            cell.configure(with: article)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "header_cell",
            for: indexPath
        ) as! HeaderCollectionReusableView
        
        switch indexPath.section {
        case 1: headerView.configureHeader(with: "Today's PCOS Signals")
        case 2: headerView.configureHeader(with: "Quick Actions")
        case 3: headerView.configureHeader(with: "What May Happen Next")
        case 4: headerView.configureHeader(with: "Sleep Patterns")
        case 5: headerView.configureHeader(with: "Cycle Trends")
        case 6: headerView.configureHeader(with: "Symptom Patterns")
        case 7: headerView.configureHeader(with: "About PCOS")
        default: headerView.configureHeader(with: "")
        }
        return headerView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch indexPath.section {
            
        case 1:
            if indexPath.item == 0 {
                performSegue(withIdentifier: "showSymptomLogger", sender: self)
                return
            }
            let signalIndex = indexPath.item - 1
            let displaySignal = displaySignals[signalIndex]
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            switch displaySignal {
            case .symptom(let signal):
                let navController = storyboard.instantiateViewController(
                    withIdentifier: "SymptomStoryNavigationController"
                ) as! UINavigationController
                let storyVC = navController.viewControllers.first
                    as! SymptomStoryPageViewController
                storyVC.signal = signal
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true)
            case .phase(let phaseSignal, let cardType):
                let navController = storyboard.instantiateViewController(
                    withIdentifier: "PhaseStoryNavigationController"
                ) as! UINavigationController
                let storyVC = navController.viewControllers.first
                    as! PhaseStoryPageViewController
                storyVC.phaseSignal = phaseSignal
                storyVC.startIndex = phaseSignal.cards.firstIndex(of: cardType) ?? 0
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true)
            }
            
        case 3:
            if indexPath.item == 0 {
                performSegue(withIdentifier: "showProtein", sender: self)
            } else if indexPath.item == 1 {
                performSegue(withIdentifier: "showInsulin", sender: self)
            } else if indexPath.item == 2 {
                performSegue(withIdentifier: "showWorkoutPush", sender: self)
            }
            
        case 5:
            performSegue(withIdentifier: "showCycleReport", sender: nil)
            
        case 7:
            let article = aboutPCOSArticles[indexPath.item]
            let vc = storyboard?.instantiateViewController(
                withIdentifier: "AboutPCOSViewController"
            ) as! AboutPCOSViewController
            vc.section = article
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
}
