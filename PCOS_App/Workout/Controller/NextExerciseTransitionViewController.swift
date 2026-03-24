import UIKit

class NextExerciseTransitionViewController: UIViewController {
    
    // Configurable properties
    var nextExerciseName: String = ""
    var nextExerciseGif: UIImage? = nil
    var currentExerciseIndex: Int = 0
    var totalExercises: Int = 0
    
    var onTransitionFinished: (() -> Void)?
    
    // Internal timer
    private var timer: Timer?
    private var secondsRemaining = 30
    
    // UI Elements
    private let backgroundImageView = UIImageView()
    private let overlayView = UIView()
    private let stackView = UIStackView()
    private let nextInLabel = UILabel()
    private let timerLabel = UILabel()
    private let progressLabel = UILabel()
    private let exerciseNameLabel = UILabel()
    private let startButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 1. Background GIF
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.clipsToBounds = true
        backgroundImageView.backgroundColor = .white
        backgroundImageView.image = nextExerciseGif
        view.addSubview(backgroundImageView)
        
        // 2. Dark Overlay for text readability
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.addSubview(overlayView)
        
        // Pin background and overlay to edges
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 3. Stack View
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
        
        // 4. "Next Exercise in"
        nextInLabel.text = "Next Exercise in"
        nextInLabel.textColor = .white
        nextInLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        stackView.addArrangedSubview(nextInLabel)
        
        // 5. Timer text (e.g. 9)
        timerLabel.text = "\(secondsRemaining)"
        timerLabel.textColor = .white
        timerLabel.font = .systemFont(ofSize: 96, weight: .heavy)
        stackView.addArrangedSubview(timerLabel)
        
        // Spacer for visual separation
        stackView.setCustomSpacing(24, after: timerLabel)
        
        // 6. Progress text (e.g. Exercise 3/7)
        progressLabel.text = "Exercise \(currentExerciseIndex)/\(totalExercises)"
        progressLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        progressLabel.font = .systemFont(ofSize: 15, weight: .medium)
        stackView.addArrangedSubview(progressLabel)
        
        // 7. Exercise Name
        exerciseNameLabel.text = nextExerciseName
        exerciseNameLabel.textColor = .white
        exerciseNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        exerciseNameLabel.numberOfLines = 0
        exerciseNameLabel.textAlignment = .center
        stackView.addArrangedSubview(exerciseNameLabel)
        
        // Spacer before button
        stackView.setCustomSpacing(32, after: exerciseNameLabel)
        
        // 8. Start Button
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .white
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.layer.cornerRadius = 24
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        // Button padding
        stackView.addArrangedSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.heightAnchor.constraint(equalToConstant: 48),
            startButton.widthAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsRemaining -= 1
            self.timerLabel.text = "\(self.secondsRemaining)"
            
            // Haptic tick
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            if self.secondsRemaining <= 0 {
                self.finishTransition()
            }
        }
    }
    
    @objc private func startTapped() {
        // Haptic feedback on manual start
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        finishTransition()
    }
    
    private func finishTransition() {
        timer?.invalidate()
        dismiss(animated: true) {
            self.onTransitionFinished?()
        }
    }
}
