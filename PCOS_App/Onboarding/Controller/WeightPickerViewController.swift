//
//  WeightPickerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class WeightPickerViewController: UIViewController {
    
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    private var picker: CircularArcWeightPickerView!
    //private var valueContainer: UIView!
    private var currentValue: Int = 70
    private var isMetric: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize based on segmented control
        isMetric = unitSegmentedControl.selectedSegmentIndex == 1
        currentValue = isMetric ? 70 : 154 // 70kg ≈ 154lbs
        nextButton.tintColor = UIColor(hex:"FE7A96")
        
        setupUI()
        setupPicker()
        
    }
    
    private func setupUI() {
        //containerView.backgroundColor = .clear
                
                // Create value container (pill-shaped background)
                //valueContainer = UIView()
                //valueContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
//                valueContainer.layer.cornerRadius = 30
//                valueContainer.translatesAutoresizingMaskIntoConstraints = false
//                containerView.addSubview(valueContainer)
                
        containerView.layer.cornerRadius = 30
        
        // Value Label
        valueLabel.text = "\(currentValue)"
        valueLabel.font = .systemFont(ofSize: 72, weight: .bold)
        valueLabel.textAlignment = .center
        
        // Unit Label
        unitLabel.text = isMetric ? "kg" : "lbs"
        unitLabel.font = .systemFont(ofSize: 14, weight: .regular)
        unitLabel.textColor = .secondaryLabel
        unitLabel.textAlignment = .center
                
                
               
        }

    private func setupPicker() {
        let minValue = isMetric ? 30 : 66
        let maxValue = isMetric ? 150 : 330
        
        picker = CircularArcWeightPickerView(
            frame: containerView.bounds,
            minValue: minValue,
            maxValue: maxValue
        )
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .clear
        picker.delegate = self
        containerView.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            picker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            picker.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        picker.setValue(currentValue)
        }
    
    @IBAction func unitChanged(_ sender: UISegmentedControl) {
        let wasMetric = isMetric
        isMetric = sender.selectedSegmentIndex == 1
        
        // Convert value only if the unit actually changed
        if wasMetric != isMetric {
            if isMetric {
                // Converting from lbs to kg
                currentValue = Int(round(Double(currentValue) / 2.205))
                unitLabel.text = "kg"
            } else {
                // Converting from kg to lbs
                currentValue = Int(round(Double(currentValue) * 2.205))
                unitLabel.text = "lbs"
            }
            
            // Recreate picker with new range
            picker.removeFromSuperview()
            setupPicker()
            updateValueDisplay()
        }
    }
    
    
    @IBAction func nextTapped(_ sender: UIButton) {
    // Save the weight value and move to next screen
            UserDefaults.standard.set(currentValue, forKey: "userWeight")
            UserDefaults.standard.set(isMetric, forKey: "weightIsMetric")
            
            print("Weight saved: \(currentValue) \(isMetric ? "kg" : "lbs")")
            performSegue(withIdentifier: "showPhenotype", sender: nil)
        }
        
        private func updateValueDisplay() {
            valueLabel.text = "\(currentValue)"
        }

}

// MARK: - CircularArcWeightPickerDelegate
extension WeightPickerViewController: CircularArcWeightPickerDelegate {
    func weightValueChanged(_ value: Int) {
        currentValue = value
        updateValueDisplay()
    }
}

// MARK: - Circular Arc Weight Picker Protocol
protocol CircularArcWeightPickerDelegate: AnyObject {
    func weightValueChanged(_ value: Int)
}

class CircularArcWeightPickerView: UIView, UIScrollViewDelegate {
    
    weak var delegate: CircularArcWeightPickerDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let centerIndicator = UIView()
    
    private var minValue: Int
    private var maxValue: Int
    private var currentValue: Int
    private let spacing: CGFloat = 8
    private let majorTickHeight: CGFloat = 30
    private let minorTickHeight: CGFloat = 15
    
    init(frame: CGRect, minValue: Int, maxValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = minValue
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.minValue = 100
        self.maxValue = 220
        self.currentValue = 170
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
                label.text = "\(value)"
                label.font = .systemFont(ofSize: 14, weight: .regular)
                label.textColor = .secondaryLabel
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: tick.centerXAnchor),
                    label.bottomAnchor.constraint(equalTo: tick.topAnchor, constant: -4),
                    label.widthAnchor.constraint(equalToConstant: 40)
                ])
            }
        }
        
        // Force layout
        contentView.layoutIfNeeded()
    }
    
    func setValue(_ value: Int) {
        guard value >= minValue && value <= maxValue else { return }
        currentValue = value
        
        let padding = bounds.width / 2
        let offset = CGFloat(value - minValue) * spacing
        
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
    }
}

// MARK: - ScrollView Delegate
extension CircularArcWeightPickerView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let value = minValue + Int(round(offset / spacing))
        
        let clampedValue = max(minValue, min(maxValue, value))
        
        if clampedValue != currentValue {
            currentValue = clampedValue
            delegate?.weightValueChanged(clampedValue)
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
