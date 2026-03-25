//
//  PeriodCycleChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class PeriodCycleChartView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let legendStackView = UIStackView()
    private let yAxisContainer = UIView()
    
    private var cycleData: [CycleData] = []
    private let barWidth: CGFloat = 40
    private let barSpacing: CGFloat = 20
    private let chartHeight: CGFloat = 200
    private let yAxisWidth: CGFloat = 30
    
    /// Builds Y-axis tick values in increments of 7, up to the maxValue
    private func yAxisTicks(for maxValue: Int) -> [Int] {
        var ticks: [Int] = []
        var v = 0
        while v <= maxValue {
            ticks.append(v)
            v += 7
        }
        return ticks
    }
    
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
        addSubview(yAxisContainer)
        addSubview(scrollView)
        addSubview(legendStackView)
        
        // Setup ScrollView internals
        scrollView.addSubview(contentView)
        
        // 2. Disable Autoresizing Masks
        yAxisContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        legendStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Configure Legend Stack View Spacing
        legendStackView.axis = .horizontal
        legendStackView.spacing = 20
        
        // 4. Clear and Re-populate Legend
        legendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for type in [PeriodCycleChartView.LineType.periodLength, .cycleLength] {
            let itemView = createLegendItem(color: type.color, name: type.name)
            legendStackView.addArrangedSubview(itemView)
        }
        
        // Hide scrollbar
        scrollView.showsHorizontalScrollIndicator = false
        
        // 5. Set Layout Constraints
        NSLayoutConstraint.activate([
            // Y-axis container on the left
            yAxisContainer.topAnchor.constraint(equalTo: topAnchor),
            yAxisContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            yAxisContainer.widthAnchor.constraint(equalToConstant: yAxisWidth),
            yAxisContainer.bottomAnchor.constraint(equalTo: legendStackView.topAnchor, constant: -12),
            
            // ScrollView starts after Y-axis
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: yAxisContainer.trailingAnchor),
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
        
        // Clear previous bars and gridlines
        contentView.subviews.forEach { $0.removeFromSuperview() }
        yAxisContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Remove old content width constraints
        contentView.constraints.filter { $0.firstAttribute == .width }.forEach { $0.isActive = false }
        
        layoutIfNeeded() // ensure scrollView frame is known
        let barsWidth = CGFloat(cycleData.count) * (barWidth + barSpacing) + 40
        let totalWidth = max(barsWidth, scrollView.bounds.width) // gridlines fill visible area
        contentView.widthAnchor.constraint(equalToConstant: totalWidth).isActive = true
        
        // Calculate max value for scaling
        let cycleLengths = cycleData.map{ $0.cycleLength }
        let maxCycleLength = cycleLengths.max() ?? 30
        let maxValue = max(maxCycleLength + 5, 35) // Ensure gridlines go at least to 35
        
        // The bottom of bars area = the area above month labels
        // Month labels take ~25pt from bottom of the container
        let monthLabelSpace: CGFloat = 25
        
        // Build dynamic tick values and draw Y-axis labels + gridlines
        let ticks = yAxisTicks(for: maxValue)
        addYAxisLabelsAndGridlines(ticks: ticks, maxValue: maxValue, monthLabelSpace: monthLabelSpace, totalContentWidth: totalWidth)
        
        // Draw bars
        for (index, cycle) in cycleData.enumerated() {
            let xPosition = 20 + CGFloat(index) * (barWidth + barSpacing)
            createBar(at: xPosition, cycleLength: cycle.cycleLength, periodLength: cycle.periodLength, month: cycle.month, maxCycle: maxValue)
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
    
    // MARK: - Y-Axis Labels & Gridlines
    
    private func addYAxisLabelsAndGridlines(ticks: [Int], maxValue: Int, monthLabelSpace: CGFloat, totalContentWidth: CGFloat) {
        // We need to wait for layout to know the actual height of the scroll area.
        // Use layoutIfNeeded to ensure frames are up-to-date.
        layoutIfNeeded()
        
        let availableHeight = scrollView.bounds.height
        guard availableHeight > 0 else {
            // If layout hasn't happened yet, defer
            DispatchQueue.main.async { [weak self] in
                self?.addYAxisLabelsAndGridlines(ticks: ticks, maxValue: maxValue, monthLabelSpace: monthLabelSpace, totalContentWidth: totalContentWidth)
            }
            return
        }
        
        // The chart area is the scrollView/contentView height minus month label space
        let chartAreaHeight = availableHeight - monthLabelSpace
        
        for value in ticks {
            guard value <= maxValue else { continue }
            
            // Calculate Y position (0 is at the bottom of the chart area, maxValue at top)
            let fraction = CGFloat(value) / CGFloat(maxValue)
            let yFromBottom = fraction * chartAreaHeight
            let yPosition = availableHeight - monthLabelSpace - yFromBottom
            
            // --- Y-axis label (fixed, in yAxisContainer) ---
            let label = UILabel()
            label.text = "\(value)"
            label.font = .systemFont(ofSize: 10, weight: .regular)
            label.textColor = UIColor.secondaryLabel
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            yAxisContainer.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: yAxisContainer.trailingAnchor, constant: -4),
                label.centerYAnchor.constraint(equalTo: yAxisContainer.topAnchor, constant: yPosition),
                label.widthAnchor.constraint(lessThanOrEqualToConstant: yAxisWidth - 4)
            ])
            
            // --- Horizontal gridline (in scrollable contentView) ---
            let line = UIView()
            line.backgroundColor = UIColor.systemGray5
            line.translatesAutoresizingMaskIntoConstraints = false
            contentView.insertSubview(line, at: 0) // Behind bars
            
            NSLayoutConstraint.activate([
                line.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                line.heightAnchor.constraint(equalToConstant: 0.5),
                line.topAnchor.constraint(equalTo: contentView.topAnchor, constant: yPosition)
            ])
        }
    }
    
    private func createBar(at x: CGFloat, cycleLength: Int, periodLength: Int, month: String, maxCycle: Int) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Calculate heights
        let cycleBarHeight = (CGFloat(cycleLength) / CGFloat(maxCycle)) * chartHeight
        let periodBarHeight = (CGFloat(periodLength) / CGFloat(maxCycle)) * chartHeight
        
        // Period bar (pink, bottom)
        let periodBar = UIView()
        periodBar.backgroundColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        periodBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        periodBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(periodBar)
        
        // Cycle bar (purple, top)
        let cycleBar = UIView()
        cycleBar.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
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
