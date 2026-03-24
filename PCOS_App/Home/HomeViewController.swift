import UIKit

class HomeViewController: UIViewController, DataPassDelegate, HomeHeaderCollectionViewCellDelegate, LogPeriodCalendarDelegate,SleepCardCollectionViewCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

        private var selectedSymptoms: [SymptomItem] = []
        private var displaySignals: [DisplaySignal] = []
        private var recommendationCards: [Recommendation] = recommendations
        private var allSymptoms: [SymptomItem] = []
        private var aboutPCOSArticles: [AboutPCOSSection] = []
        private var chatbotButton: UIButton!
        private var sleepData: SleepData? = nil
        private var todaySleepLog: SleepLog? = nil
        private var hkSteps: Int = 0
        private var hkCalories: Double = 0

        // ── Daily Goals AI ────────────────────────────────────────────────────
        private var goalsOutput: DailyGoalsOutput?
        private var isGoalsLoading = false

        // MARK: - Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()

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
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
            collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)

            allSymptoms = SymptomDataStore.loadAllSymptomsLastNDays(365)
            loadTodaysSymptoms()
            buildDisplaySignals()
            loadTodaySleepLog()
            aboutPCOSArticles = AboutPCOSDataStore.shared.fetchSections()
            setupChatbotButton()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            #if DEBUG
            DebugInspector.printAll()
            #endif
            loadTodaysSymptoms()
            CycleDataStore.shared.loadCycles()

            if let currentCycle = CycleDataStore.shared.currentCycle {
                let limitSymptoms = SymptomDataStore.loadAllSymptomsBefore(
                    date: currentCycle.startDate, limitDays: 365)
                let previous3Cycles = CycleDataStore.shared.previousCycles(count: 3)
                var recentNames = Set<String>()
                for cycle in previous3Cycles {
                    for day in cycle.days {
                        for sym in day.symptoms { recentNames.insert(sym.name) }
                    }
                }
                allSymptoms = limitSymptoms.filter { recentNames.contains($0.name) }
                    .sorted { $0.name < $1.name }
            } else {
                allSymptoms = []
            }

            buildDisplaySignals()

            let savedOffset = collectionView.contentOffset
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.contentOffset = savedOffset

            loadTodaySleepLog()
            fetchSleepData()
            fetchWorkoutData()
            loadDailyGoals()   // ← trigger AI goals on every appear
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }

        // MARK: - Daily Goals AI

        private func loadDailyGoals() {
            guard !isGoalsLoading else { return }
            isGoalsLoading = true

            Task {
                let context = await SharedContextEngine.shared.buildContext()
                do {
                    let output = try await AIBrain.shared.generateDailyGoals(context: context)
                    await MainActor.run {
                        self.goalsOutput = output
                        self.isGoalsLoading = false
                        self.collectionView.reloadSections(IndexSet(integer: 3))
                    }
                } catch {
                    await MainActor.run {
                        self.isGoalsLoading = false
                        print("Goals error: \(error)")
                    }
                }
            }
        }

        // MARK: - HealthKit

        private func fetchSleepData() {
            HealthKitManager.shared.fetchSleepLastNight { [weak self] data in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.sleepData = data
                    self.collectionView.reloadSections(IndexSet(integer: 4))
                }
            }
        }

        private func fetchWorkoutData() {
            let group = DispatchGroup()
            var hkSteps = 0; var hkCalories = 0.0

            group.enter()
            HealthKitManager.shared.fetchTodaySteps { steps in hkSteps = steps; group.leave() }
            group.enter()
            HealthKitManager.shared.fetchTodayActiveCalories { cals in hkCalories = cals; group.leave() }

            group.notify(queue: .main) { [weak self] in
                guard let self else { return }
                DailyActivityDataStore.shared.mergeHealthKitData(
                    steps: hkSteps, healthKitDailyCalories: Int(hkCalories))
                self.collectionView.reloadSections(IndexSet(integer: 2))
            }
        }

        // MARK: - Sleep Logger

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
                withIdentifier: "SleepLoggerViewController") as? SleepLoggerViewController else {
                let loggerVC = SleepLoggerViewController()
                configureSleepLogger(loggerVC, isNotNowMode: isNotNowMode)
                present(loggerVC, animated: true)
                return
            }
            configureSleepLogger(loggerVC, isNotNowMode: isNotNowMode)
            present(loggerVC, animated: true)
        }

        private func configureSleepLogger(_ loggerVC: SleepLoggerViewController, isNotNowMode: Bool) {
            loggerVC.isNotNowMode = isNotNowMode
            loggerVC.modalPresentationStyle = .pageSheet
            if let sheet = loggerVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            loggerVC.onSleepSaved = { [weak self] in
                guard let self else { return }
                self.loadTodaySleepLog()
                self.collectionView.reloadSections(IndexSet(integer: 4))
            }
            loggerVC.onDismissedWithoutSaving = { [weak self] in
                self?.collectionView.reloadSections(IndexSet(integer: 4))
            }
        }

        private func todayDateString() -> String {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
            return f.string(from: Date())
        }

        // MARK: - Data

        private func loadTodaysSymptoms() {
            selectedSymptoms = SymptomDataStore.loadSymptoms(for: Date())
        }

        private func loadTodaySleepLog() {
            todaySleepLog = SleepDataStore.shared.loadTodaySleepLog()
        }

        private func buildDisplaySignals() {
            displaySignals.removeAll()
            for symptom in selectedSymptoms {
                if let signal = PCOSSignalStore.signal(for: symptom.name) {
                    displaySignals.append(.symptom(signal, symptom))
                }
            }
            if selectedSymptoms.isEmpty {
                let currentPhase = getCurrentPhase()
                let phaseSignals = PhaseSignalDataStore.shared.signals(for: currentPhase)
                displaySignals.append(contentsOf: phaseSignals)
            }
        }

        private func getCurrentPhase() -> Phase {
            return CycleDataStore.shared.currentPhaseInfo().phase
        }

        // MARK: - Chatbot Button

        private func setupChatbotButton() {
            chatbotButton = UIButton(type: .system)
            chatbotButton.translatesAutoresizingMaskIntoConstraints = false
            let icon = UIImage(named: "chat3")?.withRenderingMode(.alwaysOriginal)
                    chatbotButton.setImage(icon, for: .normal)
                    chatbotButton.imageView?.contentMode = .scaleAspectFill
                    chatbotButton.clipsToBounds = true
                    chatbotButton.backgroundColor = UIColor(hex: "#ffffff")
            chatbotButton.layer.cornerRadius = 28
            chatbotButton.layer.shadowColor = UIColor.black.cgColor
            chatbotButton.layer.shadowOpacity = 0.25
            chatbotButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            chatbotButton.layer.shadowRadius = 6
            chatbotButton.addTarget(self, action: #selector(ChatbotButtonTapped(_:)), for: .touchUpInside)
            view.addSubview(chatbotButton)

            let tabBarHeight: CGFloat = tabBarController?.tabBar.frame.height ?? 83
            NSLayoutConstraint.activate([
                chatbotButton.widthAnchor.constraint(equalToConstant: 56),
                chatbotButton.heightAnchor.constraint(equalToConstant: 56),
                chatbotButton.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                chatbotButton.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor, constant: -(tabBarHeight + 16))
            ])
        }

        @objc private func ChatbotButtonTapped(_ sender: UIButton) {
            let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
            guard let chatbotVC = homeStoryboard.instantiateViewController(
                withIdentifier: "ChatbotViewController") as? ChatbotViewController else { return }
            navigationController?.pushViewController(chatbotVC, animated: true)
        }

        // MARK: - Register Cells

        func registerCells() {
            collectionView.register(
                UINib(nibName: "HomeHeaderCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "home_header")
            collectionView.register(
                UINib(nibName: "AddSymptomCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "AddSymptomCollectionViewCell")
            collectionView.register(
                UINib(nibName: "SignalsCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "signals_cell")
            collectionView.register(
                UINib(nibName: "QuickActionsCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "quick_actions_cell")
            collectionView.register(
                DailyGoalsCollectionViewCell.nib(),                          // ← NEW
                forCellWithReuseIdentifier: DailyGoalsCollectionViewCell.identifier)
            collectionView.register(
                UINib(nibName: "CyclePatternCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "cycle_pattern_cell")
            collectionView.register(
                UINib(nibName: "SleepCardCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "sleep_card_cell")
            collectionView.register(
                UINib(nibName: "SymptomPatternsCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "symptom_patterns_cell")
            collectionView.register(
                UINib(nibName: "AboutPCOSCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "about_pcos_cell")
            collectionView.register(
                UINib(nibName: "HeaderCollectionReusableView", bundle: nil),
                forSupplementaryViewOfKind: "header",
                withReuseIdentifier: "header_cell")
        }

        // MARK: - Actions

        @objc func addTapped() {
            if let vc = storyboard?.instantiateViewController(
                withIdentifier: "ProfileTableViewController") as? ProfileTableViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        }

        @objc func leftBarButtonTapped() {
            if let vc = storyboard?.instantiateViewController(
                withIdentifier: "FullCalendarViewController") as? FullCalendarViewController {
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
                case 3: return self.createDailyGoalsSection()    // ← NEW
                case 4: return self.createSleepCardSection()
                case 5: return self.createCycleSection()
                case 6: return self.createSymptomPatternsSection()
                //case 7: return self.createAboutPCOSSection()
                default: return nil
                }
            }
        }

        func createHomeHeaderSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(370))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .zero
            return section
        }

        func createSignalsSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(105), heightDimension: .absolute(120))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(105), heightDimension: .absolute(120))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 16, bottom: 16, trailing: 16)
            section.orthogonalScrollingBehavior = .continuous
            addHeader(to: section)
            return section
        }

        func createQuickActionsSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1), heightDimension: .absolute(230))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 16, bottom: 16, trailing: 16)
            addHeader(to: section)
            return section
        }

        // ← NEW section layout for Daily Goals
        func createDailyGoalsSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 16, bottom: 16, trailing: 16)
            addHeader(to: section)
            return section
        }

        func createSleepCardSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(170))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 16, bottom: 16, trailing: 16)
            addHeader(to: section)
            return section
        }

        func createCycleSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1), heightDimension: .estimated(540))
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1), heightDimension: .estimated(540))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 16, bottom: 16, trailing: 16)
            addHeader(to: section)
            return section
        }

        func createSymptomPatternsSection() -> NSCollectionLayoutSection {
            let hasData = CycleDataStore.shared.hasTwoCycles && allSymptoms.count > 0
            let cycleCount = min(CycleDataStore.shared.previousCycles(count: 3).count, 3)
            let cellHeight: CGFloat
            if hasData {
                switch cycleCount {
                case 1:  cellHeight = 265
                case 2:  cellHeight = 305
                default: cellHeight = 365
                }
            } else {
                cellHeight = 300
            }

            if !hasData || allSymptoms.count <= 1 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(cellHeight))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(cellHeight))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 4, leading: 16, bottom: 16, trailing: 16)
                addHeader(to: section)
                return section
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(340), heightDimension: .absolute(cellHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(340), heightDimension: .absolute(cellHeight))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 0, bottom: 16, trailing: 0)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            addHeader(to: section, leadingInset: 16, trailingInset: 16)
            return section
        }

        func createAboutPCOSSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(340), heightDimension: .absolute(180))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(340), heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4, leading: 16, bottom: 16, trailing: 16)
            section.orthogonalScrollingBehavior = .continuous
            addHeader(to: section)
            return section
        }

        func addHeader(
            to section: NSCollectionLayoutSection,
            leadingInset: CGFloat = 0,
            trailingInset: CGFloat = 0
        ) {
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize, elementKind: "header", alignment: .top)
            headerItem.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset)
            section.boundarySupplementaryItems = [headerItem]
        }

        // MARK: - Delegates

        func passData(symptoms: [SymptomItem]) -> [SymptomItem] {
            self.selectedSymptoms = symptoms
            SymptomDataStore.saveSymptoms(symptoms, for: Date())
            DispatchQueue.main.async { self.collectionView.reloadData() }
            return symptoms
        }

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

        func didSavePeriodDates(_ dates: [Date], cycleDay: Int) {
            CycleDataStore.shared.loadCycles()
            buildDisplaySignals()
            if let currentCycle = CycleDataStore.shared.currentCycle {
                let limitSymptoms = SymptomDataStore.loadAllSymptomsBefore(
                    date: currentCycle.startDate, limitDays: 365)
                let previous3Cycles = CycleDataStore.shared.previousCycles(count: 3)
                var recentNames = Set<String>()
                for cycle in previous3Cycles {
                    for day in cycle.days {
                        for sym in day.symptoms { recentNames.insert(sym.name) }
                    }
                }
                allSymptoms = limitSymptoms.filter { recentNames.contains($0.name) }
                    .sorted { $0.name < $1.name }
            } else {
                allSymptoms = []
            }
            let savedOffset = collectionView.contentOffset
            collectionView.collectionViewLayout = createCompositionalLayout()
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.contentOffset = savedOffset
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showSymptomLogger",
               let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
                symptomLoggerVC.delegate = self
                symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
                symptomLoggerVC.onSymptomsSelected = { [weak self] symptoms in
                    guard let self else { return }
                    self.selectedSymptoms = symptoms
                    SymptomDataStore.saveSymptoms(symptoms, for: Date())
                    DispatchQueue.main.async { self.collectionView.reloadData() }
                }
            }
            if segue.identifier == "showSignal01",
               let destination = segue.destination as? Signal01ViewController,
               let signal = sender as? PCOSSignal {
                destination.signal = signal
            }
        }

        func sleepCardDidTapLogSleep(_ cell: SleepCardCollectionViewCell) {
            presentSleepLogger(isNotNowMode: true)
        }
    }

    // MARK: - QuickActionsDelegate

    extension HomeViewController: QuickActionsDelegate {
        func quickActionsDidTapAddMeal() {
            let dietStoryboard = UIStoryboard(name: "Diet", bundle: nil)
            guard let addMealVC = dietStoryboard.instantiateViewController(
                withIdentifier: "AddMealViewController") as? AddMealViewController else { return }
            addMealVC.delegate = self
            addMealVC.dietDelegate = self
            navigationController?.pushViewController(addMealVC, animated: true)
        }

        func quickActionsDidTapStartWorkout() {
            let currentPhase = CycleDataStore.shared.currentPhaseInfo().phase
            let recommended = RoutineDataStore.shared.recommendedRoutine(for: currentPhase)
            let workoutStoryboard = UIStoryboard(name: "Workout", bundle: nil)
            guard let routinePreviewVC = workoutStoryboard.instantiateViewController(
                withIdentifier: "RoutinePreviewViewController") as? RoutinePreviewViewController else { return }
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
            return 8   // 0:header 1:signals 2:quickActions 3:dailyGoals 4:sleep 5:cycle 6:symptoms 7:about
        }

        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {
            switch section {
            case 0: return 1
            case 1: return 1 + displaySignals.count
            case 2: return 1
            case 3: return 1                              // ← Daily Goals
            case 4: return 1
            case 5: return 1
            case 6:
                return (CycleDataStore.shared.hasTwoCycles && allSymptoms.count > 0)
                    ? allSymptoms.count : 1
            //case 7: return aboutPCOSArticles.count
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
                    withReuseIdentifier: "home_header", for: indexPath
                ) as! HomeHeaderCollectionViewCell
                cell.delegate = self
                let info = CycleDataStore.shared.currentPhaseInfo()
                let prediction = PeriodPredictionEngine().predict(
                    from: CycleDataStore.shared.cycles)
                cell.configure(cycleDay: info.cycleDay, phase: info.phase, prediction: prediction)
                return cell

            case 1:
                if indexPath.item == 0 {
                    return collectionView.dequeueReusableCell(
                        withReuseIdentifier: "AddSymptomCollectionViewCell", for: indexPath
                    ) as! AddSymptomCollectionViewCell
                }
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "signals_cell", for: indexPath
                ) as! SignalsCollectionViewCell
                let signal = displaySignals[indexPath.item - 1]
                switch signal {
                case .phase(let p, let t): cell.configurePhase(phase: p, cardType: t)
                case .symptom(let s, let sym): cell.configure(with: s, symptom: sym)
                }
                return cell

            case 2:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "quick_actions_cell", for: indexPath
                ) as! QuickActionsCollectionViewCell
                cell.delegate = self
                cell.configure()
                return cell

            case 3:
                // ── Daily Goals ──────────────────────────────────────────────
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DailyGoalsCollectionViewCell.identifier,
                    for: indexPath
                ) as! DailyGoalsCollectionViewCell
                if let output = goalsOutput {
                    cell.configure(with: output)
                } else {
                    cell.showLoadingState()
                }
                return cell

            case 4:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "sleep_card_cell", for: indexPath
                ) as! SleepCardCollectionViewCell
                cell.delegate = self
                cell.configure(with: sleepData, manualLog: todaySleepLog)
                return cell

            case 5:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cycle_pattern_cell", for: indexPath
                ) as! CyclePatternCollectionViewCell
                if CycleDataStore.shared.hasTwoCycles { cell.refreshChart() }
                else { cell.configureEmptyState() }
                return cell

            case 6:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "symptom_patterns_cell", for: indexPath
                ) as! SymptomPatternsCollectionViewCell
                if CycleDataStore.shared.hasTwoCycles && indexPath.item < allSymptoms.count {
                    cell.configure(
                        cycles: CycleDataStore.shared.previousCycles(count: 3),
                        symptom: allSymptoms[indexPath.item])
                } else {
                    cell.configureEmptyState()
                }
                return cell

//            case 7:
//                let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "about_pcos_cell", for: indexPath
//                ) as! AboutPCOSCollectionViewCell
//                cell.configure(with: aboutPCOSArticles[indexPath.item])
//                return cell

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
            case 3: headerView.configureHeader(with: "Daily Goals")        // ← NEW
            case 4: headerView.configureHeader(with: "Sleep Patterns")
            case 5: headerView.configureHeader(with: "Cycle Trends")
            case 6: headerView.configureHeader(with: "Symptom Patterns")
            //case 7: headerView.configureHeader(with: "About PCOS")
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
                let signal = displaySignals[indexPath.item - 1]
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                switch signal {
                case .symptom(let s, _):
                    let navController = storyboard.instantiateViewController(
                        withIdentifier: "SymptomStoryNavigationController"
                    ) as! UINavigationController
                    (navController.viewControllers.first as? SymptomStoryPageViewController)?.signal = s
                    navController.modalPresentationStyle = .fullScreen
                    present(navController, animated: true)
                case .phase(let p, let t):
                    let navController = storyboard.instantiateViewController(
                        withIdentifier: "PhaseStoryNavigationController"
                    ) as! UINavigationController
                    if let storyVC = navController.viewControllers.first
                        as? PhaseStoryPageViewController {
                        storyVC.phaseSignal = p
                        storyVC.startIndex = p.cards.firstIndex(of: t) ?? 0
                    }
                    navController.modalPresentationStyle = .fullScreen
                    present(navController, animated: true)
                }
            case 4:
                performSegue(withIdentifier: "showSleepReport", sender: nil)
//            case 7:
//                let article = aboutPCOSArticles[indexPath.item]
//                let vc = storyboard?.instantiateViewController(
//                    withIdentifier: "AboutPCOSViewController") as! AboutPCOSViewController
//                vc.section = article
//                navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
