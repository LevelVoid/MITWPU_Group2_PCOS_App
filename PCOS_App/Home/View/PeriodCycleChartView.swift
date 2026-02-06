//
//  PeriodCycleChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

struct CycleData {
    let month: String
    let cycleLength: Int
    let periodLength: Int
}

class PeriodCycleChartView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let legendStackView = UIStackView()
    //    private let averageLineView = UIView()
    //    private let averageLabel = UILabel()
    
    private var cycleData: [CycleData] = []
    private let barWidth: CGFloat = 40
    private let barSpacing: CGFloat = 20
    private let chartHeight: CGFloat = 200
    
    enum LineType {
        case periodLength
        case cycleLength
        
        var color: UIColor {
            switch self {
            case .periodLength: return UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
            case .cycleLength: return UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
            }
        }
        
        var name: String {
            switch self {
            case .periodLength: return "Period Length"
            case .cycleLength: return "Cycle Length"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    private func setupView() {
        // 1. Add subviews to the hierarchy
        addSubview(scrollView)
        addSubview(legendStackView)
        
        // Setup ScrollView internals
        scrollView.addSubview(contentView)
        
        // 2. Disable Autoresizing Masks
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        legendStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Configure Legend Stack View Spacing
        legendStackView.axis = .horizontal
        legendStackView.spacing = 20  // <--- This increases spacing between the two legend items
        //legendStackView.alignment = .center
        
        // 4. Clear and Re-populate Legend
        legendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for type in [PeriodCycleChartView.LineType.periodLength, .cycleLength] {
            let itemView = createLegendItem(color: type.color, name: type.name)
            legendStackView.addArrangedSubview(itemView)
        }
        
        // 5. Set Layout Constraints
        NSLayoutConstraint.activate([
            // ScrollView pinned to top, leading, trailing, and bottom to legendStackView top
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: legendStackView.topAnchor, constant: -12),
            
            // Legend pinned to leading and bottom
            legendStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            legendStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            legendStackView.heightAnchor.constraint(equalToConstant: 20),
            
            // Content View inside ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    
    func configure(with data: [CycleData]) {
        // Reverse the data so newest is first (right side)
        self.cycleData = data.reversed()
        
        // Clear previous bars
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let totalWidth = CGFloat(cycleData.count) * (barWidth + barSpacing) + 40
        contentView.widthAnchor.constraint(equalToConstant: totalWidth).isActive = true
        
        // Calculate average
        let avgCycleLength = cycleData.map { $0.cycleLength }.reduce(0, +) / cycleData.count
        let maxCycleLength = cycleData.map { $0.cycleLength }.max() ?? 30
        
        // Add average line
        //        averageLineView.removeFromSuperview()
        //        contentView.addSubview(averageLineView)
        
        let avgY = chartHeight - (CGFloat(avgCycleLength) / CGFloat(maxCycleLength + 5)) * chartHeight + 20
        
        // Draw bars
        for (index, cycle) in cycleData.enumerated() {
            let xPosition = 20 + CGFloat(index) * (barWidth + barSpacing)
            createBar(at: xPosition, cycleLength: cycle.cycleLength, periodLength: cycle.periodLength, month: cycle.month, maxCycle: maxCycleLength)
        }
        
        // IMPORTANT: Scroll to the right (newest data) after layout
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let maxOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.width
            if maxOffsetX > 0 {
                self.scrollView.setContentOffset(CGPoint(x: maxOffsetX, y: 0), animated: false)
            }
        }
    }
    
    private func createBar(at x: CGFloat, cycleLength: Int, periodLength: Int, month: String, maxCycle: Int) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Calculate heights
        let cycleBarHeight = (CGFloat(cycleLength) / CGFloat(maxCycle + 5)) * chartHeight
        let periodBarHeight = (CGFloat(periodLength) / CGFloat(maxCycle + 5)) * chartHeight
        
        // Period bar (pink, bottom)
        let periodBar = UIView()
        periodBar.backgroundColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        //periodBar.layer.cornerRadius = 4
        periodBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        periodBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(periodBar)
        
        // Cycle bar (purple, top)
        let cycleBar = UIView()
        cycleBar.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
        //cycleBar.layer.cornerRadius = 4
        cycleBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cycleBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cycleBar)
        
        // Cycle length label
        let cycleLengthLabel = UILabel()
        cycleLengthLabel.text = "\(cycleLength)"
        cycleLengthLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        cycleLengthLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.8, alpha: 1.0)
        cycleLengthLabel.textAlignment = .center
        cycleLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cycleLengthLabel)
        
        // Period length label (white, on pink bar)
        let periodLengthLabel = UILabel()
        periodLengthLabel.text = "\(periodLength)"
        periodLengthLabel.font = .systemFont(ofSize: 14, weight: .bold)
        periodLengthLabel.textColor = .white
        periodLengthLabel.textAlignment = .center
        periodLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(periodLengthLabel)
        
        // Month label
        let monthLabel = UILabel()
        monthLabel.text = month
        monthLabel.font = .systemFont(ofSize: 12)
        monthLabel.textColor = .gray
        monthLabel.textAlignment = .center
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(monthLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: x),
            containerView.widthAnchor.constraint(equalToConstant: barWidth),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Period bar (bottom)
            periodBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            periodBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            periodBar.bottomAnchor.constraint(equalTo: monthLabel.topAnchor, constant: -10),
            periodBar.heightAnchor.constraint(equalToConstant: periodBarHeight),
            
            // Cycle bar (on top of period)
            cycleBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cycleBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cycleBar.bottomAnchor.constraint(equalTo: periodBar.topAnchor),
            cycleBar.heightAnchor.constraint(equalToConstant: cycleBarHeight - periodBarHeight),
            
            // Cycle length label (above bar)
            cycleLengthLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cycleLengthLabel.bottomAnchor.constraint(equalTo: cycleBar.topAnchor, constant: -4),
            
            // Period length label (on pink bar)
            periodLengthLabel.centerXAnchor.constraint(equalTo: periodBar.centerXAnchor),
            periodLengthLabel.centerYAnchor.constraint(equalTo: periodBar.centerYAnchor),
            
            // Month label (below bar)
            monthLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            monthLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            monthLabel.widthAnchor.constraint(equalToConstant: barWidth + 20)
        ])
    }
    private func createLegendItem(color: UIColor, name: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(dot)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            
            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
}

