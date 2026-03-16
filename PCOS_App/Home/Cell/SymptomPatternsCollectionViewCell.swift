//
//  SymtomPatternsCollectionViewCell.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 06/02/26.
//

import UIKit

class SymptomPatternsCollectionViewCell:
    UICollectionViewCell,
    
    UICollectionViewDelegate {

        
    @IBOutlet weak var collectionView: UICollectionView!
    //private var days: [CycleDay] = []
    @IBOutlet weak var  NameLabel: UILabel!
@IBOutlet weak var  SymptomImage: UIImageView!
        @IBOutlet  var  StartDateLabels: [UILabel]!
        @IBOutlet  var  LengthLabels: [UILabel]!
        @IBOutlet var ovulationView:UIView!
        @IBOutlet var follicularView:UIView!
        @IBOutlet var leutalView:UIView!
        @IBOutlet var menstrualView:UIView!
    private var symptom: SymptomItem?

    private var cycles: [CycleData] = []


        
        
        override func awakeFromNib() {
            super.awakeFromNib()

            contentView.layer.cornerRadius = 20
            contentView.backgroundColor = UIColor.systemGray6
            contentView.layer.masksToBounds = true

            // Legend colors
            menstrualView.backgroundColor = Phase.menstrual.backgroundColor.withAlphaComponent(0.5)
            follicularView.backgroundColor = Phase.follicular.backgroundColor.withAlphaComponent(0.5)
            ovulationView.backgroundColor = Phase.ovulation.backgroundColor.withAlphaComponent(0.5)
            leutalView.backgroundColor = Phase.luteal.backgroundColor.withAlphaComponent(0.5)

            [menstrualView, follicularView, ovulationView, leutalView].forEach {
                $0?.layer.cornerRadius = ($0?.bounds.width ?? 0) / 2
            }
            
            setupCollectionView()
        }

    // Height constraint outlet wired up programmatically – updated in configure()
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    private func setupCollectionView() {
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
                UINib(nibName: "DayCircleCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "DayCircleCollectionViewCell"
            )
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.isDirectionalLockEnabled = true
       
    }


        func configure(cycles: [CycleData], symptom: SymptomItem) {
            self.symptom = symptom
            
            // Keep the 3 most recent cycles (newest-first input)
            self.cycles = Array(cycles.prefix(3))
            
            NameLabel.text = symptom.name
            SymptomImage.image = UIImage(named: symptom.icon)

            for i in 0..<StartDateLabels.count {
                if i < self.cycles.count {
                    let cycle = self.cycles[i]

                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d"
                    StartDateLabels[i].text = formatter.string(from: cycle.startDate)
                    LengthLabels[i].text = "\(cycle.days.count) days"
                } else {
                    StartDateLabels[i].text = ""
                    LengthLabels[i].text = ""
                }
            }

            // Dynamically resize collection view so legend is always visible
            let rows = self.cycles.count + 1   // header row + one row per cycle
            let gridHeight = CGFloat(rows) * 44
            if let existing = collectionViewHeightConstraint {
                existing.constant = gridHeight
            } else {
                // Find and cache the XIB-defined height constraint, then update it
                if let constraint = collectionView.constraints.first(where: { $0.firstAttribute == .height }) {
                    constraint.constant = gridHeight
                    collectionViewHeightConstraint = constraint
                }
            }

            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }




        private func makeLayout() -> UICollectionViewLayout {
            UICollectionViewCompositionalLayout { [weak self] _, _ in
                guard let self = self else { return nil }

                let rows = self.cycles.count + 1   // day numbers + cycles
                let columns = self.maxDayCount()

                // One day cell
//                let itemSize = NSCollectionLayoutSize(
//                    widthDimension: .absolute(44),
//                    heightDimension: .absolute(45)
//                )
//                
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//                // One ROW = days laid out horizontally
//                let rowGroupSize = NSCollectionLayoutSize(
//                    widthDimension: .estimated(CGFloat(columns) * 68),
//                    heightDimension: .absolute(64)
                //)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(26),
                    heightDimension: .absolute(26)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let rowGroupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(CGFloat(columns) * 30),
                    heightDimension: .absolute(30)
                )

                let rowGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: rowGroupSize,
                    subitem: item,
                    count: columns
                )
                rowGroup.interItemSpacing = .fixed(4)

                // Stack rows vertically
                let gridGroupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(CGFloat(columns) * 30),
                    heightDimension: .absolute(CGFloat(rows) * 42)
                )
                let gridGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: gridGroupSize,
                    subitem: rowGroup,
                    count: rows
                )

                let section = NSCollectionLayoutSection(group: gridGroup)
                section.interGroupSpacing = 0

                return section
            }
        }
}

extension SymptomPatternsCollectionViewCell: UICollectionViewDataSource {


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
        //cycles.count+1//+1 for day number
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return (cycles.count + 1) * maxDayCount()
    }
    private func maxDayCount() -> Int {
        cycles.map { $0.days.count }.max() ?? 0
    }


}
extension SymptomPatternsCollectionViewCell {

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DayCircleCollectionViewCell",
            for: indexPath
        ) as! DayCircleCollectionViewCell

        let totalColumns = maxDayCount()
        let row = indexPath.item / totalColumns
        let column = indexPath.item % totalColumns

        if row == 0 {
            // Day numbers header row
            cell.configureAsDayNumber(day: column + 1)
        } else {
            let cycleIndex = row - 1
            let cycle = cycles[cycleIndex]

            if column < cycle.days.count {
                let day = cycle.days[column]

                // Compute the actual calendar date for this cycle day
                // and look up symptoms LIVE so changes logged after the
                // cycle was built are picked up immediately.
                let actualDate = Calendar.current.date(
                    byAdding: .day,
                    value: column,
                    to: cycle.startDate
                ) ?? cycle.startDate

                let liveSymptoms = SymptomDataStore.loadSymptoms(for: actualDate)
                let matchedSymptom = liveSymptoms.first { $0.name == symptom?.name }

                cell.configure(
                    day: day,
                    symptom: matchedSymptom,
                    focusedSymptom: symptom
                )
            } else {
                // Beyond this cycle's length — render nothing (invisible spacer)
                cell.prepareForReuse()
                cell.circleView.isHidden = true
                cell.circleView.backgroundColor = .clear
            }
        }

        return cell
    }



       
}

