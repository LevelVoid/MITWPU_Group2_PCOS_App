import UIKit
import HealthKit

class SummaryViewController: UIViewController {
    
    
    var completedWorkout: CompletedWorkout!
    
    
    @IBOutlet weak var containerView: UIView!
    // Goals (you can fetch these from user settings)
    let caloriesGoal = 600.0
    let durationGoalSeconds = 120 * 60  // 2 hours
    
    @IBOutlet weak var caloriesValueLabel: UILabel!
    @IBOutlet weak var caloriesGoalLabel: UILabel!
    
    @IBOutlet weak var exercisesDoneLabel: UILabel!
    
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var durationGoalLabel: UILabel!
    
    @IBOutlet weak var caloriesTitleLabel: UILabel!
    @IBOutlet weak var exercisesTitleLabel: UILabel!
    @IBOutlet weak var durationTitleLabel: UILabel!
    
    @IBOutlet weak var caloriesCard: UIView!
    @IBOutlet weak var exercisesCard: UIView!
    @IBOutlet weak var durationCard: UIView!
    
    /// Small label below the calorie number to show data source ("via Apple Watch", "Estimated")
    private var caloriesSourceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(hex: "#FCEEED")
        
        navigationItem.hidesBackButton = true
        
        addCaloriesSourceLabel()
        setupUI()
        applyCardStyling()
        showConfetti()
        
        // Async: try to get better calorie estimate from HealthKit / Apple Watch
        fetchBestCalorieEstimate()
    }
    
    // MARK: - Calories Source Label

    /// Creates the source label but keeps it hidden — source is printed to console for debugging.
    private func addCaloriesSourceLabel() {
        guard caloriesCard != nil else { return }
        let label = UILabel()
        label.isHidden = true   // hidden — debug info goes to console instead
        label.translatesAutoresizingMaskIntoConstraints = false
        caloriesCard.addSubview(label)
        caloriesSourceLabel = label
    }
    
    func setupUI() {
        containerView.layer.cornerRadius = 24

        // ---- DURATION ----
        let totalSeconds = completedWorkout.durationSeconds
        durationValueLabel.text = formatDuration(totalSeconds)

        // ---- CALORIES — show placeholder until real data arrives ----
        // Do NOT show a duration-based estimate; wait for HealthKit / heart-rate data.
        caloriesValueLabel.text = "—"

        // ---- EXERCISES DONE ----
        let completedExercises = completedWorkout.exercises.filter {
            $0.sets.allSatisfy { $0.completionState == .completed }
        }.count
        exercisesDoneLabel.text = "\(completedExercises)"
    }

    /// Tracks how many times we have retried the HealthKit fetch (max 2).
    private var hkFetchRetries = 0

    // MARK: - HealthKit Calorie Calculation

    /// Attempts to get the best calorie estimate using the following priority:
    /// 1. Apple Watch activeEnergyBurned during this workout window (start → end)
    /// 2. Keytel formula from Apple Watch heart rate during this workout window
    /// 3. Shows 0 with "No Watch Data" if neither is available
    ///
    /// A 5-second delay is applied before the first fetch because Apple Watch
    /// takes several seconds (sometimes up to 30s) to sync data to HealthKit
    /// after a session ends. A second retry fires after 15 more seconds.
    private func fetchBestCalorieEstimate() {
        // Wait before first attempt to allow Watch → HealthKit sync
        let delay: TimeInterval = hkFetchRetries == 0 ? 5 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.runCalorieQuery()
        }
    }

    private func runCalorieQuery() {
        let start = completedWorkout.startTime
        let end = start.addingTimeInterval(TimeInterval(completedWorkout.durationSeconds))

        // First try: HealthKit active calories ONLY for this session's window
        HealthKitManager.shared.fetchActiveCalories(from: start, to: end) { [weak self] sessionCals in
            guard let self = self else { return }

            if sessionCals > 0 {
                print("[Calories] Source: via Apple Watch (direct HK calories) | Value: \(sessionCals) kcal")
                DispatchQueue.main.async {
                    self.caloriesValueLabel.text = String(format: "%.0f", sessionCals)
                    self.saveAndSyncCalories(sessionCals)
                }
            } else {
                print("[Calories] No direct HK calorie data found — trying heart rate...")
                self.fetchHeartRateBasedCalories()
            }
        }
    }

    private func fetchHeartRateBasedCalories() {
        let start = completedWorkout.startTime
        let end = start.addingTimeInterval(TimeInterval(completedWorkout.durationSeconds))

        HealthKitManager.shared.fetchHeartRate(from: start, to: end) { [weak self] avgHR in
            guard let self = self else { return }

            if let avgHR = avgHR, avgHR > 0 {
                let durationMin = Double(self.completedWorkout.durationSeconds) / 60.0
                let hkm = HealthKitManager.shared
                let calories = hkm.estimateCaloriesFromHeartRate(
                    avgHR: avgHR,
                    ageYears: hkm.userAge,
                    weightKg: hkm.userWeightKg,
                    durationMin: durationMin,
                    isFemale: true
                )
                print("[Calories] Source: Keytel formula | Avg HR: \(Int(avgHR)) bpm | Duration: \(String(format: "%.1f", durationMin)) min | Age: \(hkm.userAge) | Weight: \(hkm.userWeightKg) kg | Result: \(String(format: "%.1f", calories)) kcal")
                DispatchQueue.main.async {
                    self.caloriesValueLabel.text = String(format: "%.0f", calories)
                    self.saveAndSyncCalories(calories)
                }
            } else {
                // No data yet — retry up to 2 times (Watch can take up to ~30s to sync)
                if self.hkFetchRetries < 2 {
                    self.hkFetchRetries += 1
                    print("[Calories] No HR data yet — retry \(self.hkFetchRetries)/2 in 15s...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
                        self?.runCalorieQuery()
                    }
                } else {
                    print("[Calories] All retries exhausted — no Apple Watch or no HR recorded")
                    DispatchQueue.main.async {
                        self.caloriesValueLabel.text = "—"
                        self.saveAndSyncCalories(0)
                    }
                }
            }
        }
    }

    /// Saves the final calorie value to completedWorkout and syncs to DailyActivityDataStore.
    private func saveAndSyncCalories(_ calories: Double) {
        // Update the in-memory CompletedWorkout so WorkoutSessionManager has the value
        completedWorkout.caloriesBurned = calories

        // Update the persisted Core Data record with final calories
        CompletedWorkoutsDataStore.shared.save(completedWorkout)

        // Sync to DailyActivityDataStore so MetricsViewController graph shows session calories
        DailyActivityDataStore.shared.syncWorkout(completedWorkout)
    }

    
    func applyCardStyling() {
        let cards = [durationCard, caloriesCard, exercisesCard]
        cards.forEach { card in
            card?.layer.cornerRadius = 20
            card?.backgroundColor = .systemBackground
            card?.layer.masksToBounds = false
            
            // Add subtle shadow for premium look
            card?.layer.shadowColor = UIColor.black.cgColor
            card?.layer.shadowOffset = CGSize(width: 0, height: 4)
            card?.layer.shadowRadius = 8
            card?.layer.shadowOpacity = 0.05
        }
        
        setupStackViews()
    }
    
    private func setupStackViews() {
        // Calorie Card
        if let card = caloriesCard, let val = caloriesValueLabel, let unit = caloriesGoalLabel, let title = caloriesTitleLabel {
            configureCardStack(card: card, valueLabel: val, unitLabel: unit, titleLabel: title)
        }
        
        // Exercises Card
        if let card = exercisesCard, let val = exercisesDoneLabel, let title = exercisesTitleLabel {
            configureCardStack(card: card, valueLabel: val, unitLabel: nil, titleLabel: title)
        }
        
        // Duration Card
        if let card = durationCard, let val = durationValueLabel, let unit = durationGoalLabel, let title = durationTitleLabel {
            configureCardStack(card: card, valueLabel: val, unitLabel: unit, titleLabel: title)
        }
    }
    
    private func configureCardStack(card: UIView, valueLabel: UILabel, unitLabel: UILabel?, titleLabel: UILabel) {
        // Clear existing subviews to prevent duplicates if called multiple times
        card.subviews.forEach { $0.removeFromSuperview() }
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Horizontal stack for Value + Unit
        let valueStack = UIStackView()
        valueStack.axis = .horizontal
        valueStack.alignment = .firstBaseline
        valueStack.spacing = 4
        valueStack.translatesAutoresizingMaskIntoConstraints = false
        valueStack.addArrangedSubview(valueLabel)
        
        if let unit = unitLabel {
            unit.translatesAutoresizingMaskIntoConstraints = false
            valueStack.addArrangedSubview(unit)
        }
        
        // Vertical stack for everything
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        mainStack.addArrangedSubview(valueStack)
        mainStack.addArrangedSubview(titleLabel)
        
        card.addSubview(mainStack)
        
        // Center the main stack in the card
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            mainStack.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -8)
        ])
        
        // Ensure title label styling is consistent
        titleLabel.textColor = .secondaryLabel
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        
        if hrs > 0 {
            return "\(hrs)h \(mins)"
        } else {
            return "\(mins)"
        }
    }
    
    
    
    func showConfetti() {
        let confettiLayer = CAEmitterLayer()
        
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.size.width, height: 1)
        
        // Vibrant confetti colors
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),    // Gold
            UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0),    // Hot Pink
            UIColor(red: 0.5, green: 0.2, blue: 0.9, alpha: 1.0),    // Purple
            UIColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1.0),    // Green
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),    // Orange
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),    // Blue
            UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0),    // Red
            UIColor(red: 0.9, green: 0.9, blue: 0.2, alpha: 1.0)     // Yellow
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            for _ in 0..<1 {                              // 1 particle per color (was 2)
                let cell = CAEmitterCell()

                cell.birthRate = 3                         // was 6
                cell.lifetime = 6.0                        // was 10.0
                cell.lifetimeRange = 2                     // was 3

                cell.velocity = CGFloat.random(in: 150...250)   // was 200...350
                cell.velocityRange = 60                    // was 100
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4              // tighter spread (was .pi / 3)

                cell.spin = CGFloat.random(in: 1...3)     // was 2...5
                cell.spinRange = 2                         // was 3

                cell.scale = CGFloat.random(in: 0.2...0.4)  // was 0.3...0.6
                cell.scaleRange = 0.1                      // was 0.2
                cell.scaleSpeed = -0.05

                cell.yAcceleration = 150
                cell.xAcceleration = CGFloat.random(in: -20...20)

                cell.alphaSpeed = -0.15                    // fades faster (was -0.1)
                cell.color = color.cgColor

                let shapes = ["circle", "square", "triangle"]
                let randomShape = shapes.randomElement() ?? "circle"
                cell.contents = confettiImage(shape: randomShape, color: color)?.cgImage

                cells.append(cell)
            }
        }
        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        
        // Stop emitting new particles after 2 seconds, but let existing ones finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            confettiLayer.birthRate = 0
        }
        
        // Remove layer completely after animation finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            confettiLayer.removeFromSuperlayer()
        }
    }
    func confettiImage(shape: String, color: UIColor) -> UIImage? {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            
            switch shape {
            case "square":
                let rect = CGRect(x: 1, y: 1, width: 8, height: 8)
                context.cgContext.fill(rect)
                
            case "triangle":
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: 1))
                path.addLine(to: CGPoint(x: 1, y: size.height - 1))
                path.addLine(to: CGPoint(x: size.width - 1, y: size.height - 1))
                path.close()
                path.fill()
                
            case "circle":
                let rect = CGRect(x: 1, y: 1, width: 8, height: 8)
                context.cgContext.fillEllipse(in: rect)
                
            default:
                break
            }
        }
    }
        @IBAction func doneButtonTapped(_ sender: UIButton) {
            //NAVIGATION TO HOME VC-> but it comes embedded in a navigation bar,no tab bar
//            let homeVC = UIStoryboard(name: "Workout", bundle: nil)
//                .instantiateViewController(withIdentifier: "WorkoutHome") as! WorkoutViewController
//            navigationController?.pushViewController(homeVC, animated: true)
            
            //just uncomment to navigate to routine preview vc
            
            view.window?.rootViewController?.dismiss(animated: true)
           
            
            
        }
        
    }
