//
// CyclePatternCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

class CyclePatternCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cyclePatternView: UIView!
    @IBOutlet weak var CycleLengthView: UIView!
    @IBOutlet weak var PeriodLengthView: UIView!
    @IBOutlet weak var viewTooTiredToRemove: UIView!
    @IBOutlet weak var periodCycleChartView: PeriodCycleChartView!
    
    // Labels to display the calculated averages
    @IBOutlet weak var avgCycleLengthLabel: UILabel!
    @IBOutlet weak var avgPeriodLengthLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cyclePatternView.layer.cornerRadius = 20
        viewTooTiredToRemove.layer.cornerRadius = 20
        CycleLengthView.layer.cornerRadius = 10
        PeriodLengthView.layer.cornerRadius = 10
    }

    /// Call from cellForItemAt to refresh chart data on every display
    func refreshChart() {
        let cycles = CycleDataStore.shared.previousCycles(count: 6)
        let prediction = CycleDataStore.shared.nextPeriodPrediction
        
        // Update chart
        periodCycleChartView.configure(with: cycles)
        
        // Use pre-calculated averages from prediction engine
        if let avgCycle = prediction.averageCycleLength {
            avgCycleLengthLabel?.text = "\(avgCycle)"
        } else {
            avgCycleLengthLabel?.text = "—"
        }
        
        if let avgPeriod = prediction.averagePeriodLength {
            avgPeriodLengthLabel?.text = "\(avgPeriod)"
        } else {
            avgPeriodLengthLabel?.text = "—"
        }
    }
}
