//
//  CyclePatternCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

class CyclePatternCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cyclePatternView: UIView!
    
    @IBOutlet weak var avgCycleLength: UIView!
    
    @IBOutlet weak var avgPeriodLength: UIView!
    @IBOutlet weak var viewTooTiredToRemove: UIView!
    @IBOutlet weak var periodCycleChartView: PeriodCycleChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cyclePatternView.layer.cornerRadius = 20
        viewTooTiredToRemove.layer.cornerRadius = 20
        avgCycleLength.layer.cornerRadius = 10
        avgPeriodLength.layer.cornerRadius = 10
        
        setupPeriodCycleChart()
    }
    
    private func setupPeriodCycleChart() {
    let sampleData: [CycleData] = [
        CycleData(month: "Jan\n18", cycleLength: 28, periodLength: 5),
        CycleData(month: "Dec\n16", cycleLength: 29, periodLength: 5),
        CycleData(month: "Nov\n14", cycleLength: 24, periodLength: 5),
        CycleData(month: "Oct\n7", cycleLength: 26, periodLength: 5),
        CycleData(month: "Sept\n3", cycleLength: 30, periodLength: 5),
        CycleData(month: "Aug\n2", cycleLength: 30, periodLength: 5)
    ]
    
    periodCycleChartView.configure(with: sampleData)
    }

}
