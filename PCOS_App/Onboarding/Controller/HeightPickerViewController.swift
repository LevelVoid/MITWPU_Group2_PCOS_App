//
//  HeightPickerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class HeightPickerViewController: UIViewController {

    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rulerContainerView: UIView!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    private var rulerView: HeightRulerPickerView!
    private var currentValue: Int = 170
    private var isMetric: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.tintColor = UIColor(hex:"FE7A96")
        setupUI()
        setupRulerView()

    }
    

    private func setupUI() {
        
    rulerContainerView.layer.cornerRadius = 30
    
    // Value Label
    valueLabel.text = "\(currentValue)"
    valueLabel.font = .systemFont(ofSize: 72, weight: .bold)
    valueLabel.textAlignment = .center
    
    // Unit Label
    unitLabel.text = "cm"
    unitLabel.font = .systemFont(ofSize: 14, weight: .regular)
    unitLabel.textColor = .secondaryLabel
    unitLabel.textAlignment = .center
    }
    
    private func setupRulerView() {
    let minValue = isMetric ? 100 : 40
    let maxValue = isMetric ? 220 : 87
    
    rulerView = HeightRulerPickerView(frame: rulerContainerView.bounds, minValue: minValue, maxValue: maxValue, isMetric: isMetric)
    rulerView.translatesAutoresizingMaskIntoConstraints = false
    rulerView.backgroundColor = .clear
    rulerView.delegate = self
    rulerContainerView.addSubview(rulerView)
    
        NSLayoutConstraint.activate([
                    rulerView.leadingAnchor.constraint(equalTo: rulerContainerView.leadingAnchor),
                    rulerView.trailingAnchor.constraint(equalTo: rulerContainerView.trailingAnchor),
                    rulerView.centerYAnchor.constraint(equalTo: rulerContainerView.centerYAnchor),
                    rulerView.heightAnchor.constraint(equalToConstant: 100)
                ])
    
    rulerView.setValue(currentValue)
        }
    
    @IBAction func unitChanged(_ sender: UISegmentedControl) {
            isMetric = sender.selectedSegmentIndex == 1
            
            // Convert value
            if isMetric {
                currentValue = Int(Double(currentValue) * 2.54)
                unitLabel.text = "cm"
            } else {
                currentValue = Int(Double(currentValue) / 2.54)
                unitLabel.text = "ft + in"
            }
            
            // Recreate ruler with new range
            rulerView.removeFromSuperview()
            setupRulerView()
            updateValueDisplay()
        }
    @IBAction func nextTapped(_ sender: UIButton) {
            // Save the height value and move to next screen
            UserDefaults.standard.set(currentValue, forKey: "userHeight")
            UserDefaults.standard.set(isMetric, forKey: "heightIsMetric")
            
            // Navigate to next onboarding screen
            //performSegue(withIdentifier: "toNextScreen", sender: nil)
            print("Height saved: \(currentValue) \(isMetric ? "cm" : "inches")")
        }
        
        private func updateValueDisplay() {
            valueLabel.textAlignment = .center
            if isMetric {
                valueLabel.font = .systemFont(ofSize: 72, weight: .bold)
                valueLabel.text = "\(currentValue)"
            } else {
                let feet = currentValue / 12
                let inches = currentValue % 12
                
                valueLabel.font = .systemFont(ofSize: 72, weight: .bold)
                valueLabel.text = "\(feet)' \(inches)\""
            }
        }
}

// MARK: - RulerPickerDelegate
extension HeightPickerViewController: HeightRulerPickerDelegate {
    func rulerValueChanged(_ value: Int) {
        currentValue = value
        updateValueDisplay()
    }
}

// MARK: - Ruler Picker View
protocol HeightRulerPickerDelegate: AnyObject {
    func rulerValueChanged(_ value: Int)
}

class HeightRulerPickerView: UIView, UIScrollViewDelegate {
    
    weak var delegate: HeightRulerPickerDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let centerIndicator = UIView()
    
    private var minValue: Int
    private var maxValue: Int
    private var currentValue: Int
    private var isMetric: Bool
    private let spacing: CGFloat = 8
    private let majorTickHeight: CGFloat = 30
    private let minorTickHeight: CGFloat = 15
    
    init(frame: CGRect, minValue: Int, maxValue: Int, isMetric: Bool = true) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = minValue
        self.isMetric = isMetric
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.minValue = 100
        self.maxValue = 220
        self.currentValue = 170
        self.isMetric = true
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // ScrollView
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Center Indicator
        centerIndicator.backgroundColor = .label
        centerIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            centerIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            centerIndicator.widthAnchor.constraint(equalToConstant: 2),
            centerIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Only draw ruler once when bounds are known
        if contentView.subviews.isEmpty && bounds.width > 0 {
            drawRuler()
            setValue(currentValue)
        }
    }
    
    private func drawRuler() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Remove any existing width constraints
        contentView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width {
                constraint.isActive = false
            }
        }
        
        let totalValues = maxValue - minValue + 1
        let contentWidth = CGFloat(totalValues) * spacing
        let padding = bounds.width / 2
        
        let widthConstraint = contentView.widthAnchor.constraint(equalToConstant: contentWidth + padding * 2)
        widthConstraint.isActive = true
        
        for i in 0..<totalValues {
            let value = minValue + i
            let x = padding + CGFloat(i) * spacing
            
            let isMajorTick = value % 10 == 0
            let tickHeight = isMajorTick ? majorTickHeight : minorTickHeight
            
            let tick = UIView()
            tick.backgroundColor = .systemGray3
            tick.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(tick)
            
            NSLayoutConstraint.activate([
                tick.widthAnchor.constraint(equalToConstant: 1),
                tick.heightAnchor.constraint(equalToConstant: tickHeight),
                tick.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: x),
                tick.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
            
            // Add label for major ticks
            if isMajorTick {
                let label = UILabel()
                if isMetric {
                    label.text = "\(value)"
                } else {
                    let feet = value / 12
                    let inches = value % 12
                    label.text = "\(feet)'\(inches)\""
                }
                label.font = .systemFont(ofSize: 11, weight: .regular)
                label.textColor = .secondaryLabel
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: tick.centerXAnchor),
                    label.bottomAnchor.constraint(equalTo: tick.topAnchor, constant: -4),
                    label.widthAnchor.constraint(equalToConstant: 44)
                ])
            }
        }
        
        // Force layout
        contentView.layoutIfNeeded()
    }
    
    func setValue(_ value: Int) {
        guard value >= minValue && value <= maxValue else { return }
        currentValue = value
        
      //  let padding = bounds.width / 2
        let offset = CGFloat(value - minValue) * spacing
        
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
    }
}

// MARK: - ScrollView Delegate
extension HeightRulerPickerView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let value = minValue + Int(round(offset / spacing))
        
        let clampedValue = max(minValue, min(maxValue, value))
        
        if clampedValue != currentValue {
            currentValue = clampedValue
            delegate?.rulerValueChanged(clampedValue)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.x
        let value = minValue + Int(round(targetOffset / spacing))
        let clampedValue = max(minValue, min(maxValue, value))
        
        let snappedOffset = CGFloat(clampedValue - minValue) * spacing
        targetContentOffset.pointee.x = snappedOffset
    }
}
