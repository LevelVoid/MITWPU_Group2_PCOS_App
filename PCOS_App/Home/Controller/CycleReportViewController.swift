//
//  CycleReportViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class CycleReportViewController: UIViewController {
    
    
    @IBOutlet weak var NextCycleCard: UIView!
    //@IBOutlet weak var warningNextCycleView: UIView!
    @IBOutlet weak var CycleOverview: UIView!
    @IBOutlet weak var cycleLengthCard: UIView!
    @IBOutlet weak var periodLengthCard: UIView!
    //@IBOutlet weak var cycleRegularityCard: UIView!
    
    @IBOutlet weak var periodCycleChartView: PeriodCycleChartView!
    
    @IBOutlet weak var OvulationCard: UIView!
    //@IBOutlet weak var ovulationWarningCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cycle Patterns"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        NextCycleCard.layer.cornerRadius = 20
        //warningNextCycleView.layer.cornerRadius = 10
        
        //        warningNextCycleView.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 0.1)
        //        ovulationWarningCard.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 0.1)
        
        CycleOverview.layer.cornerRadius = 20
        CycleOverview.clipsToBounds = true
        cycleLengthCard.layer.cornerRadius = 20
        periodLengthCard.layer.cornerRadius = 20
        
        //cycleRegularityCard.layer.cornerRadius = 20
        
        OvulationCard.layer.cornerRadius = 20
        //ovulationWarningCard.layer.cornerRadius = 10
        
        setupPeriodCycleChart()
    }
    
    
    private func setupPeriodCycleChart() {
        let cycles = CycleDataStore.shared.loadRecentCycles(count: 6)
        periodCycleChartView.configure(with: cycles)
    }
}
