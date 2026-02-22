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
    
    private var symptom: SymptomItem?

    private var cycles: [CycleData] = []


        
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }

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
        

    }

//        func configure(cycles: [CycleData], symptom: SymptomItem) {
//            self.cycles = cycles
//            self.symptom = symptom
//            
////            print("SymptomPatterns cycles:", cycles.count)
//            NameLabel.text = symptom.name
//            SymptomImage.image = UIImage(named: symptom.icon)
//            collectionView.reloadData()
//        }
        func configure(cycles: [CycleData], symptom: SymptomItem) {
            self.cycles = cycles
            self.symptom = symptom

            NameLabel.text = symptom.name
            SymptomImage.image = UIImage(named: symptom.icon)

            // Fill left-side cycle info (max 3)
            for i in 0..<StartDateLabels.count {
                if i < cycles.count {
                    let cycle = cycles[i]
//                    StartDateLabels[i].text = cycle.startDateFormatted
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d"
                    StartDateLabels[i].text = formatter.string(from: cycle.startDate)

                    LengthLabels[i].text = "\(cycle.days.count) days"
                } else {
                    StartDateLabels[i].text = ""
                    LengthLabels[i].text = ""
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
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(48),
                    heightDimension: .absolute(64)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // One ROW = days laid out horizontally
                let rowGroupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(CGFloat(columns) * 68),
                    heightDimension: .absolute(64)
                )
                let rowGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: rowGroupSize,
                    subitem: item,
                    count: columns
                )
                rowGroup.interItemSpacing = .fixed(20)

                // Stack rows vertically
                let gridGroupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(CGFloat(columns) * 68),
                    heightDimension: .absolute(CGFloat(rows) * 64)
                )
                let gridGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: gridGroupSize,
                    subitems: [rowGroup]
                )

                let section = NSCollectionLayoutSection(group: gridGroup)
                section.interGroupSpacing = 0

                return section
            }
        }
}

extension SymptomPatternsCollectionViewCell: UICollectionViewDataSource {

//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        1 + cycles.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int
//    ) -> Int {
//
//        if section == 0 {
//            return maxDayCount()
//        } else {
//            return cycles[section - 1].days.count
//        }
//    }
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
            // Day numbers row
            cell.configureAsDayNumber(day: column + 1)
        } else {
            let cycleIndex = row - 1
            let cycle = cycles[cycleIndex]

            if column < cycle.days.count {
                let day = cycle.days[column]
                let matchedSymptom = day.symptoms.first { $0.name == symptom?.name }

                cell.configure(
                    day: day,
                    symptom: matchedSymptom,
                    focusedSymptom: symptom
                )
            } else {
                // Empty placeholder for days beyond cycle length
                cell.prepareForReuse()
                cell.circleView.backgroundColor = .systemGray4
            }
        }



        return cell
    }



       
}

