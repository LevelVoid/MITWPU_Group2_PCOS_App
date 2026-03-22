import UIKit

class HomeViewController: UIViewController, DataPassDelegate, HomeHeaderCollectionViewCellDelegate, LogPeriodCalendarDelegate,SleepCardCollectionViewCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedSymptoms: [SymptomItem] = []
    private var displaySignals: [DisplaySignal] = []
    private var recommendationCards: [Recommendation] = recommendations
    private var allSymptoms: [SymptomItem] = []
    private var aboutPCOSArticles: [AboutPCOSSection] = []
    /// Cached sleep data fetched from HealthKit — nil until first fetch or if not available
    private var sleepData: SleepData? = nil
    // MARK: - Sleep state
    private var todaySleepLog: SleepLog? = nil
    // Cached workout data from HealthKit for Quick Actions card
    private var hkSteps: Int = 0
    private var hkCalories: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

//        #if DEBUG
//        CycleLogicTests.runAll()   // ← DELETE before shipping
//        #endif

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
        
        // Prevent UIKit from re-adjusting content insets on viewWillAppear
        // (this was causing the header card to jump up after returning from sheets)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // Fix for content appearing behind floating tab bar
        // 1. Ensure content can be scrolled up above the tab bar
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        // 2. Ensure scroll indicators don't get covered either
        collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        
        // Scan up to ~1 year back so symptoms logged on past cycle days appear as cards
        allSymptoms = SymptomDataStore.loadAllSymptomsLastNDays(365)
        loadTodaysSymptoms()
        buildDisplaySignals()
        loadTodaySleepLog()
        aboutPCOSArticles = AboutPCOSDataStore.shared.fetchSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if DEBUG
        DebugInspector.printAll()
        #endif
        loadTodaysSymptoms()
        
        // Force a rebuild of cycles from CoreData to catch any newly logged historical symptoms
        CycleDataStore.shared.loadCycles()
        
        if let currentCycle = CycleDataStore.shared.currentCycle {
            let limitSymptoms = SymptomDataStore.loadAllSymptomsBefore(date: currentCycle.startDate, limitDays: 365)
            let previous3Cycles = CycleDataStore.shared.previousCycles(count: 3)
            
            var recentNames = Set<String>()
            for cycle in previous3Cycles {
                for day in cycle.days {
                    for sym in day.symptoms {
                        recentNames.insert(sym.name)
                    }
                }
            }
            allSymptoms = limitSymptoms.filter { recentNames.contains($0.name) }.sorted { $0.name < $1.name }
        } else {
            allSymptoms = []
        }
        
        buildDisplaySignals()
        
        // Preserve scroll position across reload so the header card doesn't jump
        let savedOffset = collectionView.contentOffset
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.contentOffset = savedOffset
        
        loadTodaySleepLog()
        // Fetch last night's sleep and today's workout data from HealthKit
        fetchSleepData()
        fetchWorkoutData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        showSleepLoggerIfNeeded()
    }

    // MARK: - HealthKit Sleep Fetch

    private func fetchSleepData() {
        HealthKitManager.shared.fetchSleepLastNight { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.sleepData = data
                // Reload only the sleep card section (4)
                self.collectionView.reloadSections(IndexSet(integer: 4))
//                self.showSleepLoggerIfNeeded()
            }
        }
    }

    private func fetchWorkoutData() {
        let group = DispatchGroup()
        var hkSteps = 0
        var hkCalories = 0.0
        
        group.enter()
        HealthKitManager.shared.fetchTodaySteps { steps in
            hkSteps = steps
            group.leave()
        }
        
        group.enter()
        HealthKitManager.shared.fetchTodayActiveCalories { cals in
            hkCalories = cals
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // Merge HealthKit data into CDDailyContext so the Quick Actions cell
            // reads up-to-date steps & calories from the single source of truth
            DailyActivityDataStore.shared.mergeHealthKitData(
                steps: hkSteps,
                healthKitDailyCalories: Int(hkCalories)
            )
            
            // Refresh Quick Actions section (index 2) to show updated data
            self.collectionView.reloadSections(IndexSet(integer: 2))
        }
    }
    // MARK: - Sleep Logger Presentation

    private func showSleepLoggerIfNeeded() {
        let todayString = todayDateString()
        let lastShown = UserDefaults.standard.string(forKey: "sleepLoggerLastShownDate")
        
        guard lastShown != todayString else { return }
        guard todaySleepLog == nil else { return }

        UserDefaults.standard.set(todayString, forKey: "sleepLoggerLastShownDate")
        presentSleepLogger(isNotNowMode: false)
    }
    private func presentSleepLogger(isNotNowMode: Bool) {

        guard let loggerVC = storyboard?.instantiateViewController(
            withIdentifier: "SleepLoggerViewController"
        ) as? SleepLoggerViewController else {

            let loggerVC = SleepLoggerViewController()
            configureSleepLogger(loggerVC, isNotNowMode: isNotNowMode)
            present(loggerVC, animated: true)
            return
        }

        configureSleepLogger(loggerVC, isNotNowMode: isNotNowMode)
        present(loggerVC, animated: true)
    }
    private func configureSleepLogger(
        _ loggerVC: SleepLoggerViewController,
        isNotNowMode: Bool
    ) {
        loggerVC.isNotNowMode = isNotNowMode
        loggerVC.modalPresentationStyle = .pageSheet

        if let sheet = loggerVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }

        loggerVC.onSleepSaved = { [weak self] in
            guard let self = self else { return }
            self.loadTodaySleepLog()
            self.collectionView.reloadSections(IndexSet(integer: 4))
        }

        loggerVC.onDismissedWithoutSaving = { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadSections(IndexSet(integer: 4))
        }
    }
    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    
    private func loadTodaysSymptoms() {
        selectedSymptoms = SymptomDataStore.loadSymptoms(for: Date())
    }
    private func loadTodaySleepLog() {
        todaySleepLog = SleepDataStore.shared.loadTodaySleepLog()
    }
    
    private func buildDisplaySignals() {
        displaySignals.removeAll()
        
        // 1. Logged Symptoms First
        for symptom in selectedSymptoms {
            if let signal = PCOSSignalStore.signal(for: symptom.name) {
                displaySignals.append(.symptom(signal, symptom))
            }
        }
        
        // 2. Phase Cards Second
        let currentPhase = getCurrentPhase()
        let phaseSignals = PhaseSignalDataStore.shared.signals(for: currentPhase)
        displaySignals.append(contentsOf: phaseSignals)
    }

    private func getCurrentPhase() -> Phase {
        return CycleDataStore.shared.currentPhaseInfo().phase
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
//            case 3: return self.createRecommendationSection()
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
            heightDimension: .estimated(370)
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
            widthDimension: .absolute(135),
            heightDimension: .absolute(155)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(135),
            heightDimension: .absolute(155)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4, leading: 16, bottom: 16, trailing: 16
        )
        section.orthogonalScrollingBehavior = .continuous
        addHeader(to: section)
        return section
    }
    
    func createQuickActionsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(230)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4, leading: 16, bottom: 16, trailing: 16
        )
        addHeader(to: section)
        return section
    }
    
    func createCycleSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(540)
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(540)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4, leading: 16, bottom: 16, trailing: 16
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
            top: 4, leading: 16, bottom: 16, trailing: 16
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
            heightDimension: .estimated(170)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4, leading: 16, bottom: 16, trailing: 16
        )
        addHeader(to: section)
        return section
    }
    
    func createSymptomPatternsSection() -> NSCollectionLayoutSection {
        let hasData = CycleDataStore.shared.hasTwoCycles && allSymptoms.count > 0
        
        // Dynamic height: header(~92pt) + grid(rows*34) + legend+padding(~39pt) + AI Insight(~65pt)
        let cycleCount = min(CycleDataStore.shared.previousCycles(count: 3).count, 3)
        let cellHeight: CGFloat
        if hasData {
            switch cycleCount {
            case 1:  cellHeight = 265
            case 2:  cellHeight = 305
            default: cellHeight = 365
            }
        } else {
            cellHeight = 300  // empty state
        }
        
        // Full-width when empty state OR only 1 symptom
        if !hasData || allSymptoms.count <= 1 {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 16, bottom: 16, trailing: 16
            )
            addHeader(to: section)
            return section
        }

        // Multiple symptoms → 340pt paging cards
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(340),
            heightDimension: .absolute(cellHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(340),
            heightDimension: .absolute(cellHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4, leading: 0, bottom: 16, trailing: 0
        )
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        addHeader(to: section, leadingInset: 16, trailingInset: 16)
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
            top: 4, leading: 16, bottom: 16, trailing: 16
        )
        section.orthogonalScrollingBehavior = .continuous
        addHeader(to: section)
        return section
    }
    
    func addHeader(to section: NSCollectionLayoutSection, leadingInset: CGFloat = 0, trailingInset: CGFloat = 0) {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "header",
            alignment: .top
        )
        headerItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset)
        section.boundarySupplementaryItems = [headerItem]
    }
    
    // MARK: - DataPassDelegate
    
    func passData(symptoms: [SymptomItem]) -> [SymptomItem] {
        self.selectedSymptoms = symptoms
        SymptomDataStore.saveSymptoms(symptoms, for: Date())
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
        CycleDataStore.shared.loadCycles()
        buildDisplaySignals()
        
        if let currentCycle = CycleDataStore.shared.currentCycle {
            let limitSymptoms = SymptomDataStore.loadAllSymptomsBefore(date: currentCycle.startDate, limitDays: 365)
            let previous3Cycles = CycleDataStore.shared.previousCycles(count: 3)
            
            var recentNames = Set<String>()
            for cycle in previous3Cycles {
                for day in cycle.days {
                    for sym in day.symptoms {
                        recentNames.insert(sym.name)
                    }
                }
            }
            allSymptoms = limitSymptoms.filter { recentNames.contains($0.name) }.sorted { $0.name < $1.name }
        } else {
            allSymptoms = []
        }
        
        // Recreate layout so sections 5 & 6 appear/disappear based on hasTwoCycles
        let savedOffset = collectionView.contentOffset
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.contentOffset = savedOffset
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
                SymptomDataStore.saveSymptoms(symptoms, for: Date())
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
    // MARK: - SleepCardCollectionViewCellDelegate

    func sleepCardDidTapLogSleep(_ cell: SleepCardCollectionViewCell) {
        presentSleepLogger(isNotNowMode: true)
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
        addMealVC.delegate = self      // ← was missing!
        addMealVC.dietDelegate = self
        navigationController?.pushViewController(addMealVC, animated: true)
    }

    
    func quickActionsDidTapStartWorkout() {
        let currentPhase = CycleDataStore.shared.currentPhaseInfo().phase
        let recommended = RoutineDataStore.shared.recommendedRoutine(for: currentPhase)

        let workoutStoryboard = UIStoryboard(name: "Workout", bundle: nil)
        guard let routinePreviewVC = workoutStoryboard.instantiateViewController(
            withIdentifier: "RoutinePreviewViewController"
        ) as? RoutinePreviewViewController else {
            print("Error: Could not instantiate RoutinePreviewViewController")
            return
        }
        routinePreviewVC.routine = recommended
        navigationController?.pushViewController(routinePreviewVC, animated: true)
    }
}

// MARK: - AddMealDelegate
extension HomeViewController: AddMealDelegate {
    func didAddMeal(_ food: Food) {
        FoodLogDataStore.addFoodBarCode(food)
        navigationController?.popToRootViewController(animated: true)
        collectionView.reloadSections(IndexSet(integer: 2))
    }
}


// MARK: - AddDescribedMealDelegate
extension HomeViewController: AddDescribedMealDelegate {
    func didConfirmMeal(_ food: Food) {
        FoodLogDataStore.addFoodBarCode(food)
        if presentedViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
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
//        case 3: return recommendationCards.count
        case 4: return 1
        case 5: return 1
        case 6:
            if CycleDataStore.shared.hasTwoCycles && allSymptoms.count > 0 {
                return allSymptoms.count
            }
            return 1  // empty state card
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
            let info = CycleDataStore.shared.currentPhaseInfo()
            let prediction = PeriodPredictionEngine().predict(from: CycleDataStore.shared.cycles)
            cell.configure(cycleDay: info.cycleDay, phase: info.phase, prediction: prediction)
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
            case .symptom(let symptomSignal, let symptomItem):
                cell.configure(with: symptomSignal, symptom: symptomItem)
            }
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "quick_actions_cell",
                for: indexPath
            ) as! QuickActionsCollectionViewCell
            cell.delegate = self

            // Cell reads directly from CDDailyContext — the single source of truth
            cell.configure()
            return cell
            
//        case 3:
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "recommendation_cell",
//                for: indexPath
//            ) as! HomeRecommendationCollectionViewCell
//            let recommendation = recommendationCards[indexPath.item]
//            cell.configure(with: recommendation)
//            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "sleep_card_cell",
                for: indexPath
            ) as! SleepCardCollectionViewCell
            cell.delegate = self
            cell.configure(with: sleepData, manualLog: todaySleepLog)
            return cell
            
        case 5:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "cycle_pattern_cell",
                for: indexPath
            ) as! CyclePatternCollectionViewCell
            if CycleDataStore.shared.hasTwoCycles {
                cell.refreshChart()
            } else {
                cell.configureEmptyState()
            }
            return cell
            
        case 6:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "symptom_patterns_cell",
                for: indexPath
            ) as! SymptomPatternsCollectionViewCell
            if CycleDataStore.shared.hasTwoCycles && indexPath.item < allSymptoms.count {
                let symptom = allSymptoms[indexPath.item]
                let cycles = CycleDataStore.shared.previousCycles(count: 3)
                cell.configure(cycles: cycles, symptom: symptom)
            } else {
                cell.configureEmptyState()
            }
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
//        case 3: headerView.configureHeader(with: "What May Happen Next")
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
            case .symptom(let signal, _):
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
            
//        case 3:
//            if indexPath.item == 0 {
//                performSegue(withIdentifier: "showProtein", sender: self)
//            } else if indexPath.item == 1 {
//                performSegue(withIdentifier: "showInsulin", sender: self)
//            } else if indexPath.item == 2 {
//                performSegue(withIdentifier: "showWorkoutPush", sender: self)
//            }
        case 4:
            performSegue(withIdentifier: "showSleepReport", sender: nil)
//        case 5:
//            performSegue(withIdentifier: "showCycleReport", sender: nil)
            
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
