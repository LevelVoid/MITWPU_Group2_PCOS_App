import UIKit
import TipKit

class HomeViewController: UIViewController, DataPassDelegate, HomeHeaderCollectionViewCellDelegate, LogPeriodCalendarDelegate, SleepCardCollectionViewCellDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

        private var selectedSymptoms: [SymptomItem] = []
        private var displaySignals: [DisplaySignal] = []
        private var recommendationCards: [Recommendation] = recommendations
        private var allSymptoms: [SymptomItem] = []
        private var aboutPCOSArticles: [AboutPCOSSection] = []
        private var chatbotButton: UIButton!
        private var calendarBarButton: UIBarButtonItem? // used for TipKit tour anchor

        private var sleepData: SleepData? = nil
        private var todaySleepLog: SleepLog? = nil
        private var hkSteps: Int = 0
        private var hkCalories: Double = 0
        private var walkthroughOverlay: WalkthroughOverlayView?
    private weak var tipPopover: UIViewController?
    private var isShowingWalkthroughCongrats: Bool = false
        /// Set to true the moment the user saves symptoms during the walkthrough,
        /// so that viewWillAppear doesn't re-trigger the symptom overlay.
        private var walkthroughSymptomLogged: Bool = false
        private var pulseLayer: CALayer?


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
            calendarBarButton = calendar
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
            WalkthroughManager.shared.addDelegate(self)
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
            handleWalkthroughOnAppear()
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
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            walkthroughOverlay?.dismiss(animated: false)
            walkthroughOverlay = nil
            tipPopover?.dismiss(animated: false)
            stopChatbotPulse()
        }

        // MARK: - UIPopoverPresentationControllerDelegate
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
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

        // MARK: - Setup Logger

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
            chatbotButton = UIButton(type: .custom)
            chatbotButton.translatesAutoresizingMaskIntoConstraints = false
            
            // let icon = UIImage(named: "chat3")?.withRenderingMode(.alwaysOriginal)
            // chatbotButton.setImage(icon, for: .normal)
            // chatbotButton.imageView?.contentMode = .scaleAspectFill
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
            let sfIcon = UIImage(systemName: "message.badge.filled.fill", withConfiguration: symbolConfig)
            chatbotButton.setImage(sfIcon, for: .normal)
            chatbotButton.tintColor = .white
            
            chatbotButton.backgroundColor = UIColor(hex: "#fe7a96")
            chatbotButton.layer.cornerRadius = 30
            
            // Apply clipping to the imageView so the button's shadow isn't cut off
            // (Only needed for raster images — SF symbols don't need this)
            // chatbotButton.imageView?.layer.cornerRadius = 30
            // chatbotButton.imageView?.clipsToBounds = true
            
            chatbotButton.layer.shadowColor = UIColor.black.cgColor
            chatbotButton.layer.shadowOpacity = 0.15
            chatbotButton.layer.shadowOffset = CGSize(width: 0, height: 6)
            chatbotButton.layer.shadowRadius = 8
            
            chatbotButton.addTarget(self, action: #selector(ChatbotButtonTapped(_:)), for: .touchUpInside)
            view.addSubview(chatbotButton)

            NSLayoutConstraint.activate([
                chatbotButton.widthAnchor.constraint(equalToConstant: 60),
                chatbotButton.heightAnchor.constraint(equalToConstant: 60),
                chatbotButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                chatbotButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
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
                widthDimension: .absolute(110), heightDimension: .absolute(132))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(110), heightDimension: .absolute(132))
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
                widthDimension: .fractionalWidth(1), heightDimension: .absolute(220))
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
                heightDimension: .estimated(270))
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
            
            // Advance walkthrough after symptom save.
            // Set both flags FIRST so that viewWillAppear (triggered when this VC
            // is dismissed) does NOT re-show the symptom overlay.
            if WalkthroughManager.shared.isActive && WalkthroughManager.shared.currentStep == .logSymptom {
                self.walkthroughSymptomLogged = true   // ← prevent re-trigger
                self.isShowingWalkthroughCongrats = true
                self.walkthroughOverlay?.dismiss()
                self.walkthroughOverlay = nil
                // Wait for the sheet dismiss animation before showing congrats
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.showSymptomWalkthroughCongrats()
                }
            }
            
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

            // Advance walkthrough after period is saved
            if WalkthroughManager.shared.isActive && WalkthroughManager.shared.currentStep == .logPeriod {
                walkthroughOverlay?.dismiss()
                walkthroughOverlay = nil
                WalkthroughManager.shared.advanceToNextStep()  // → .logSymptom
            }
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showSymptomLogger",
               let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
                symptomLoggerVC.delegate = self
                symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
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
            case 3: headerView.configureHeader(with: "Today's Focus")
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

// MARK: - Walkthrough

extension HomeViewController: WalkthroughManagerDelegate {

    // MARK: Entry point (called from viewDidAppear)

    func handleWalkthroughOnAppear() {
        // First launch after onboarding: start walkthrough
        if WalkthroughManager.shared.shouldStartWalkthrough && !WalkthroughManager.shared.isActive {
            WalkthroughManager.shared.addDelegate(self)
            WalkthroughManager.shared.startWalkthrough()  // triggers walkthroughDidReachStep(.logPeriod)
            return
        }
        // Returning to Home tab while walkthrough is still active.
        // Guard: never re-show if congrats is up, an overlay is already visible,
        // or the user already saved symptoms this session.
        guard WalkthroughManager.shared.isActive,
              !isShowingWalkthroughCongrats,
              walkthroughOverlay == nil else { return }

        WalkthroughManager.shared.addDelegate(self)
        let step = WalkthroughManager.shared.currentStep
        switch step {
        case .logPeriod:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                self?.showPeriodWalkthroughOverlay()
            }
        case .logSymptom:
            // Only re-show if the user hasn't saved symptoms yet this session
            guard !walkthroughSymptomLogged else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                self?.showSymptomWalkthroughOverlay()
            }
        case .chatbotPrompt:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                self?.showChatbotWalkthroughOverlay()
            }
        default: break
        }
    }

    // MARK: WalkthroughManagerDelegate

    func walkthroughDidReachStep(_ step: WalkthroughStep) {
        guard isViewLoaded, view.window != nil else { return }
        switch step {
        case .logPeriod:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showPeriodWalkthroughOverlay()
            }
        case .logSymptom:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showSymptomWalkthroughOverlay()
            }
        case .logMeal:
            // Hand off to Diet tab
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.tabBarController?.selectedIndex = 1
            }
        case .workoutIntro:
            // Switch to Workout tab
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.tabBarController?.selectedIndex = 2
            }
        case .chatbotPrompt:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.tabBarController?.selectedIndex = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.showChatbotWalkthroughOverlay()
                }
            }
        default: break
        }
    }

    func walkthroughDidComplete() {
        walkthroughOverlay?.dismiss()
        walkthroughOverlay = nil
    }

    // MARK: Step 1 – Log Period overlay

    private func showPeriodWalkthroughOverlay() {
        guard WalkthroughManager.shared.isActive,
              WalkthroughManager.shared.currentStep == .logPeriod else { return }
              
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            guard let cell = self.collectionView.cellForItem(at: indexPath)
                    as? HomeHeaderCollectionViewCell,
                  let window = self.view.window else { return }

            let btn = cell.logPeriodButton!
            let btnFrame = btn.convert(btn.bounds, to: window)

            self.walkthroughOverlay?.dismiss(animated: false)
            self.walkthroughOverlay = WalkthroughOverlayView.install(
                in: window,
                targetFrame: btnFrame,
                onTargetTapped: { [weak self, weak cell] in
                    guard let self, let cell else { return }
                    self.tipPopover?.dismiss(animated: true)
                    self.walkthroughOverlay?.dismiss()
                    self.walkthroughOverlay = nil
                    self.homeHeaderCellDidTapLogPeriod(cell)
                }
            )
            
            if #available(iOS 17.0, *) {
                let tip = LogPeriodTip()
                if case .invalidated = tip.status {
                    WalkthroughManager.shared.handleWalkthroughAborted()
                    return
                }
                let popoverVC = TipUIPopoverViewController(tip, sourceItem: btn)
                popoverVC.view.tintColor = UIColor(hex: "#FE7A96")
                if let overlay = self.walkthroughOverlay {
                    popoverVC.popoverPresentationController?.passthroughViews = [overlay]
                    overlay.observeTip(tip, popover: popoverVC) { [weak self] in
                        self?.walkthroughOverlay = nil
                        WalkthroughManager.shared.handleWalkthroughAborted()
                    }
                }
                self.tipPopover = popoverVC
                self.present(popoverVC, animated: true)
            }
        }
    }

    // MARK: Step 2 – Log Symptom overlay

    private func showSymptomWalkthroughOverlay() {
        guard WalkthroughManager.shared.isActive,
              WalkthroughManager.shared.currentStep == .logSymptom else { return }
              
        let indexPath = IndexPath(item: 0, section: 1)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            guard let cell = self.collectionView.cellForItem(at: indexPath),
                  let window = self.view.window else {
                // Retry in case the layout is still updating from the period save reload
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.showSymptomWalkthroughOverlay()
                }
                return
            }

            let cellFrame = cell.convert(cell.bounds, to: window)

            self.walkthroughOverlay?.dismiss(animated: false)
            self.walkthroughOverlay = WalkthroughOverlayView.install(
                in: window,
                targetFrame: cellFrame,
                onTargetTapped: { [weak self] in
                    guard let self else { return }
                    self.tipPopover?.dismiss(animated: true)
                    self.walkthroughOverlay?.dismiss()
                    self.walkthroughOverlay = nil
                    self.performSegue(withIdentifier: "showSymptomLogger", sender: self)
                }
            )
            
            if #available(iOS 17.0, *) {
                let tip = LogSymptomTip()
                if case .invalidated = tip.status {
                    WalkthroughManager.shared.handleWalkthroughAborted()
                    return
                }
                let popoverVC = TipUIPopoverViewController(tip, sourceItem: cell)
                popoverVC.view.tintColor = UIColor(hex: "#FE7A96")
                if let overlay = self.walkthroughOverlay {
                    popoverVC.popoverPresentationController?.passthroughViews = [overlay]
                    overlay.observeTip(tip, popover: popoverVC) { [weak self] in
                        self?.walkthroughOverlay = nil
                        WalkthroughManager.shared.handleWalkthroughAborted()
                    }
                }
                self.tipPopover = popoverVC
                self.present(popoverVC, animated: true)
            }
        }
    }

    // MARK: Step 2 → Step 3 congrats

    func showSymptomWalkthroughCongrats() {
        // Prefer the key window so the card still shows even if the sheet is
        // mid-dismiss and view.window is temporarily nil.
        let window: UIWindow?
        if let w = view.window {
            window = w
        } else {
            window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
        }
        guard let window else { return }
        // isShowingWalkthroughCongrats is already true (set in onSymptomsSelected)
        WalkthroughCongratsView.present(
            in: window,
            title: "Amazing!",
            body: "You've logged your period and how you feel.\nNext, let's set up your nutrition!",
            continueTitle: "Go to Diet"
        ) { [weak self] in
            self?.isShowingWalkthroughCongrats = false
            WalkthroughManager.shared.advanceToStep(.logMeal)  // triggers tab switch to Diet
        }
    }

    // MARK: Step 7 – Chatbot Prompt
    private func showChatbotWalkthroughOverlay() {
        guard WalkthroughManager.shared.isActive,
              WalkthroughManager.shared.currentStep == .chatbotPrompt,
              let window = view.window else { return }

        // Start glowing pulse on the chatbot button to draw attention
        startChatbotPulse()

        let btnFrame = chatbotButton.convert(chatbotButton.bounds, to: window)

        walkthroughOverlay?.dismiss(animated: false)
        walkthroughOverlay = WalkthroughOverlayView.install(
            in: window,
            targetFrame: btnFrame,
            onTargetTapped: { [weak self] in
                guard let self else { return }
                self.tipPopover?.dismiss(animated: true)
                self.stopChatbotPulse()
                self.walkthroughOverlay?.dismiss()
                self.walkthroughOverlay = nil
                // Navigate to ChatbotVC — congrats will be shown from there
                self.ChatbotButtonTapped(self.chatbotButton)
            }
        )
        
        if #available(iOS 17.0, *) {
            let tip = ChatbotTip()
            if case .invalidated = tip.status {
                WalkthroughManager.shared.handleWalkthroughAborted()
                return
            }
            let popoverVC = TipUIPopoverViewController(tip, sourceItem: chatbotButton)
            popoverVC.view.tintColor = UIColor(hex: "#FE7A96")
            if let overlay = walkthroughOverlay {
                popoverVC.popoverPresentationController?.passthroughViews = [overlay]
                overlay.observeTip(tip, popover: popoverVC) { [weak self] in
                    self?.walkthroughOverlay = nil
                    WalkthroughManager.shared.handleWalkthroughAborted()
                }
            }
            self.tipPopover = popoverVC
            self.present(popoverVC, animated: true)
        }
    }

    // MARK: Chatbot button pulse animation

    private func startChatbotPulse() {
        stopChatbotPulse() // Clear any existing pulse

        let pulse = CALayer()
        pulse.frame = chatbotButton.bounds.insetBy(dx: -8, dy: -8)
        pulse.position = CGPoint(
            x: chatbotButton.bounds.midX,
            y: chatbotButton.bounds.midY
        )
        pulse.cornerRadius = (chatbotButton.bounds.width + 16) / 2
        pulse.backgroundColor = UIColor(hex: "FE7A96").withAlphaComponent(0.5).cgColor
        chatbotButton.layer.insertSublayer(pulse, below: chatbotButton.imageView?.layer)
        pulseLayer = pulse

        // Scale + fade pulse loop
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue   = 1.55

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = 0.7
        fadeAnim.toValue   = 0.0

        let group = CAAnimationGroup()
        group.animations  = [scaleAnim, fadeAnim]
        group.duration    = 1.2
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulse.add(group, forKey: "chatbotPulse")
    }

    private func stopChatbotPulse() {
        pulseLayer?.removeFromSuperlayer()
        pulseLayer = nil
    }

    // MARK: Step 8 – Final completion congrats (called from ChatbotViewController)

    /// Called by ChatbotViewController when it appears during the walkthrough.
    func showFinalCompletionCongrats() {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        WalkthroughCongratsView.present(
            in: keyWindow,
            title: "You're All Set!",
            body: "You've completed the setup!\nYou are now ready to use the app to manage your PCOS journey.",
            continueTitle: "Start Exploring"
        ) {
            WalkthroughManager.shared.completeWalkthrough()
        }
    }
}

