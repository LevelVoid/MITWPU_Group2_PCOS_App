import UIKit

protocol QuickActionsDelegate: AnyObject {
    func quickActionsDidTapAddMeal()
    func quickActionsDidTapStartWorkout()
}

class QuickActionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dietActionCard: UIView!
    @IBOutlet weak var workoutActionCard: UIView!
    
    @IBOutlet weak var durationGoal: UILabel!
    @IBOutlet weak var stepsGoal: UILabel!
    @IBOutlet weak var fatsGoal: UILabel!
    @IBOutlet weak var carbsGoal: UILabel!
    @IBOutlet weak var proteinGoal: UILabel!
    
    @IBOutlet weak var durationCompleted: UILabel!
    @IBOutlet weak var stepsCompleted: UILabel!
    @IBOutlet weak var fatsCompleted: UILabel!
    @IBOutlet weak var carbsCompleted: UILabel!
    @IBOutlet weak var proteinCompleted: UILabel!
    
    // Missing duration labels in XIB
    @IBOutlet weak var workoutDurationCompleted: UILabel!
    @IBOutlet weak var workoutDurationGoal: UILabel!
    
    @IBOutlet weak var workoutButton: UIButton!
    
    weak var delegate: QuickActionsDelegate?
    
    private var strongRefs: [UIView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Retain outlets
        strongRefs = [durationGoal, stepsGoal, fatsGoal, carbsGoal, proteinGoal,
                      durationCompleted, stepsCompleted, fatsCompleted, carbsCompleted, proteinCompleted,
                      workoutDurationCompleted, workoutDurationGoal].compactMap { $0 }
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Setup Diet Card
        dietActionCard.subviews.forEach { $0.removeFromSuperview() }
        dietActionCard.backgroundColor = .systemBackground
        dietActionCard.layer.cornerRadius = 20
        dietActionCard.layer.shadowColor = UIColor.black.cgColor
        dietActionCard.layer.shadowOpacity = 0.05
        dietActionCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        dietActionCard.layer.shadowRadius = 8
        dietActionCard.translatesAutoresizingMaskIntoConstraints = false
        
        let dietHeader = makeCardHeader(
            icon: "fork.knife",
            label: "Diet",
            color: UIColor(red: 0.91, green: 0.38, blue: 0.29, alpha: 1)
        )
        
        let addMealBtn = UIButton(configuration: .filled())
        addMealBtn.setTitle("Add Meal", for: .normal)
        addMealBtn.tintColor = UIColor(red: 0.9, green: 0.37, blue: 0.47, alpha: 1)
        addMealBtn.setTitleColor(.white, for: .normal)
        addMealBtn.layer.cornerRadius = 22
        addMealBtn.clipsToBounds = true
        addMealBtn.addTarget(self, action: #selector(addMeal(_:)), for: .touchUpInside)
        
        let dietStats = UIStackView()
        dietStats.axis = .horizontal
        dietStats.distribution = .equalCentering
        dietStats.addArrangedSubview(createStatView(value: proteinCompleted, goal: proteinGoal, title: "Protein"))
        dietStats.addArrangedSubview(createStatView(value: carbsCompleted, goal: carbsGoal, title: "Carbs"))
        dietStats.addArrangedSubview(createStatView(value: fatsCompleted, goal: fatsGoal, title: "Fats"))
        
        let dietVStack = UIStackView(arrangedSubviews: [dietHeader, dietStats, addMealBtn])
        dietVStack.axis = .vertical
        dietVStack.spacing = 10
        dietVStack.distribution = .equalSpacing
        dietVStack.translatesAutoresizingMaskIntoConstraints = false
        dietActionCard.addSubview(dietVStack)
        
        // Setup Workout Card
        workoutActionCard.subviews.forEach { $0.removeFromSuperview() }
        workoutActionCard.backgroundColor = .systemBackground
        workoutActionCard.layer.cornerRadius = 20
        workoutActionCard.layer.shadowColor = UIColor.black.cgColor
        workoutActionCard.layer.shadowOpacity = 0.05
        workoutActionCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        workoutActionCard.layer.shadowRadius = 8
        workoutActionCard.translatesAutoresizingMaskIntoConstraints = false
        
        let workoutHeader = makeCardHeader(
            icon: "figure.strengthtraining.traditional",
            label: "Workout",
            color: UIColor(red: 0.95, green: 0.50, blue: 0.10, alpha: 1)
        )
        
        let startWorkoutBtn = UIButton(configuration: .filled())
        startWorkoutBtn.setTitle("Start Workout", for: .normal)
        startWorkoutBtn.tintColor = UIColor(red: 0.9, green: 0.37, blue: 0.47, alpha: 1)
        startWorkoutBtn.setTitleColor(.white, for: .normal)
        startWorkoutBtn.layer.cornerRadius = 22
        startWorkoutBtn.clipsToBounds = true
        startWorkoutBtn.addTarget(self, action: #selector(startWorkout(_:)), for: .touchUpInside)
        
        let workoutStats = UIStackView()
        workoutStats.axis = .horizontal
        workoutStats.distribution = .equalCentering
        workoutStats.addArrangedSubview(createStatView(value: durationCompleted, goal: durationGoal, title: "Minutes"))
        workoutStats.addArrangedSubview(createStatView(value: workoutDurationCompleted, goal: workoutDurationGoal, title: "Calories"))
        workoutStats.addArrangedSubview(createStatView(value: stepsCompleted, goal: stepsGoal, title: "Steps"))
        
        let workoutVStack = UIStackView(arrangedSubviews: [workoutHeader, workoutStats, startWorkoutBtn])
        workoutVStack.axis = .vertical
        workoutVStack.spacing = 10
        workoutVStack.distribution = .equalSpacing
        workoutVStack.translatesAutoresizingMaskIntoConstraints = false
        workoutActionCard.addSubview(workoutVStack)
        
        // Stack the cards vertically
        let mainStack = UIStackView(arrangedSubviews: [dietActionCard, workoutActionCard])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.distribution = .fillEqually
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            dietVStack.topAnchor.constraint(equalTo: dietActionCard.topAnchor, constant: 16),
            dietVStack.bottomAnchor.constraint(equalTo: dietActionCard.bottomAnchor, constant: -16),
            dietVStack.leadingAnchor.constraint(equalTo: dietActionCard.leadingAnchor, constant: 20),
            dietVStack.trailingAnchor.constraint(equalTo: dietActionCard.trailingAnchor, constant: -20),
            addMealBtn.heightAnchor.constraint(equalToConstant: 44),
            
            workoutVStack.topAnchor.constraint(equalTo: workoutActionCard.topAnchor, constant: 16),
            workoutVStack.bottomAnchor.constraint(equalTo: workoutActionCard.bottomAnchor, constant: -16),
            workoutVStack.leadingAnchor.constraint(equalTo: workoutActionCard.leadingAnchor, constant: 20),
            workoutVStack.trailingAnchor.constraint(equalTo: workoutActionCard.trailingAnchor, constant: -20),
            startWorkoutBtn.heightAnchor.constraint(equalToConstant: 44),
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }

    // MARK: - Card Header (matches Today's Focus style)
    private func makeCardHeader(icon: String, label: String, color: UIColor) -> UIView {
        // Rounded-square icon badge
        let badge = UIView()
        badge.backgroundColor = color
        badge.layer.cornerRadius = 8
        badge.layer.masksToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: symbolConfig))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(iconView)

        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 34),
            badge.heightAnchor.constraint(equalToConstant: 34),
            iconView.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        // Category label
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = color

        // Horizontal row: badge + label
        let hStack = UIStackView(arrangedSubviews: [badge, titleLabel])
        hStack.axis = .horizontal
        hStack.spacing = 10
        hStack.alignment = .center
        return hStack
    }

    private func createStatView(value: UILabel, goal: UILabel, title: String) -> UIView {
        value.font = .systemFont(ofSize: 16, weight: .bold)
        value.textColor = .label
        
        goal.font = .systemFont(ofSize: 12, weight: .semibold)
        goal.textColor = .secondaryLabel
        
        let valStack = UIStackView(arrangedSubviews: [value, goal])
        valStack.axis = .horizontal
        valStack.spacing = 2
        valStack.alignment = .firstBaseline
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        
        let vStack = UIStackView(arrangedSubviews: [valStack, titleLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .center
        return vStack
    }
    
    func configure() {
        // Diet Data from Core Data
        let totals = FoodLogDataStore.todaysMeal.reduce(into: (0.0, 0.0, 0.0)) { result, food in
            result.0 += food.proteinContent
            result.1 += food.carbsContent
            result.2 += food.fatsContent
        }
        proteinCompleted.text = "\(Int(totals.0))"
        carbsCompleted.text = "\(Int(totals.1))"
        fatsCompleted.text = "\(Int(totals.2))"
        
        // Workout Data from Core Data (CDDailyContext) — single source of truth
        let allActivities = DailyActivityDataStore.shared.loadAll()
        let calendar = Calendar.current
        let todayActivity = allActivities.first(where: { calendar.isDateInToday($0.date) })
        
        let todayMinutes = (todayActivity?.activeDurationSeconds ?? 0) / 60
        let todaySteps = todayActivity?.steps ?? 0
        let todayCalories = todayActivity?.totalCalories ?? 0
        
        durationCompleted.text = "\(todayMinutes)"
        stepsCompleted.text = "\(todaySteps)"
        workoutDurationCompleted.text = "\(todayCalories)"
        
        if let profile = ProfileService.shared.buildUserProfile() {
            let goals = GoalEngine.generateGoals(for: profile)
            let workoutGoals = goals.workout
            let dietGoals    = goals.diet

            // Use starting (ramp-adjusted) targets so home-screen cards reflect
            // the achievable day-1 goal for each user's lifestyle baseline.
            let goalProtein = Int(round(Double(dietGoals.startingProteinGrams) / 5.0)) * 5
            let goalCarbs   = Int(round(Double(dietGoals.startingCarbsGrams)   / 5.0)) * 5
            let goalFats    = Int(round(Double(dietGoals.startingFatsGrams)    / 5.0)) * 5

            proteinGoal.text = "/ \(goalProtein) g"
            carbsGoal.text   = "/ \(goalCarbs) g"
            fatsGoal.text    = "/ \(goalFats) g"

            let goalMinutes  = Int(round(Double(workoutGoals.startingMinutesPerDay) / 5.0)) * 5
            let goalCalories = Int(round(Double(workoutGoals.caloriesBurnedPerDay)  / 10.0)) * 10
            let goalSteps    = Int(round(Double(workoutGoals.startingStepsPerDay)   / 100.0)) * 100

            durationGoal.text        = "/ \(goalMinutes) min"
            workoutDurationGoal.text = "/ \(goalCalories) kcal"
            stepsGoal.text           = "/ \(goalSteps)"
        }
    }


    @IBAction func addMeal(_ sender: Any) {
        delegate?.quickActionsDidTapAddMeal()
    }
    
    @IBAction func startWorkout(_ sender: Any) {
        delegate?.quickActionsDidTapStartWorkout()
    }
}
