//
//  SymptomLoggerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class SymptomLoggerViewController: UIViewController {
    //var viewModel: SymptomLoggerViewModel = SymptomLoggerViewModel()

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var categories = SymptomCategory.allCategories
    private var selectedSymptoms: Set<IndexPath> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Today's Symptoms"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add Done button to navigation bar
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
            navigationItem.rightBarButtonItem = doneButton
            
            /* #fe7a96
             #fe = 254 → 254/255 = 0.996
             #7a = 122 → 122/255 = 0.478
             #96 = 150 → 150/255 = 0.588
             */
        doneButton.tintColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 0.8)

        setupCollectionView()
        
    }
    
    private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    
//

    @objc private func doneButtonTapped(_ sender: Any) {
            let symptoms = getSelectedSymptoms()
            print("Selected symptoms: \(symptoms)")
            // TODO: Pass data back or save to DataStore
            navigationController?.popViewController(animated: true)
        }
        
        private func getSelectedSymptoms() -> [LoggedSymptoms] {
            var symptoms: [LoggedSymptoms] = []
            for indexPath in selectedSymptoms {
                let symptom = categories[indexPath.section].items[indexPath.item]
                let logged = LoggedSymptoms(date: Date(), name: symptom.name, icon: symptom.icon)
                symptoms.append(logged)
            }
            return symptoms
        }
    }
    
    // MARK: - UICollectionViewDataSource
    extension SymptomLoggerViewController: UICollectionViewDataSource {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return categories.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return categories[section].items.count
        }
        
        //erririn this func
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            
            // Try to dequeue
            let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: SymptomItemCollectionViewCell.identifier, for: indexPath)
            
            print("🔍 Dequeued cell type: \(type(of: dequeuedCell))")
            print("🔍 Is SymptomItemCollectionViewCell? \(dequeuedCell is SymptomItemCollectionViewCell)")
            
            guard let cell = dequeuedCell as? SymptomItemCollectionViewCell else {
                print("❌ FAILED TO CAST! Dequeued: \(type(of: dequeuedCell))")
                print("❌ Check Storyboard:")
                print("   1. Cell Class = SymptomItemCollectionViewCell")
                print("   2. Cell Identifier = SymptomItemCollectionViewCell")
                fatalError("Cell configuration error")
            }
          
            let symptom = categories[indexPath.section].items[indexPath.item]
            let isSelected = selectedSymptoms.contains(indexPath)
       
            cell.configure(with: symptom, isSelected: isSelected)
        
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            //deque(reuse) a supplementary view header from collection view
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SymptomLogSectionHeaderView", for: indexPath) as! SymptomLogSectionHeaderView
                header.SymptomSectionLabel.text = categories[indexPath.section].title
                return header
        }
    }

    // MARK: - UICollectionViewDelegate
    extension SymptomLoggerViewController: UICollectionViewDelegate {
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if selectedSymptoms.contains(indexPath) {
                selectedSymptoms.remove(indexPath)
            } else {
                selectedSymptoms.insert(indexPath)
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }

// MARK: - UICollectionViewDelegateFlowLayout
extension SymptomLoggerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 4 items per row
        let padding: CGFloat = 16 + 16 // left + right insets
        let spacing: CGFloat = 10 * 3 // 3 gaps between 4 items
        let availableWidth = collectionView.bounds.width - padding - spacing
        let itemWidth = availableWidth / 4
        return CGSize(width: itemWidth, height: itemWidth * 1.3) // height slightly more than width
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSection section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSection section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
}
