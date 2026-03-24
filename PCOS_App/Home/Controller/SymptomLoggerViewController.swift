//
//  SymptomLoggerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//
protocol DataPassDelegate: AnyObject {
    func passData(symptoms: [SymptomItem]) -> [SymptomItem]
}

import UIKit

class SymptomLoggerViewController: UIViewController {
    //var viewModel: SymptomLoggerViewModel = SymptomLoggerViewModel()
    
    var logDate: Date = Date()  // defaults to today
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: DataPassDelegate?
    private var categories = SymptomCategory.allCategories
    private var selectedSymptoms: Set<IndexPath> = []
    
    var onSymptomsSelected: (([SymptomItem]) -> Void)?
    private var preSelectedSymptoms: [SymptomItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Today's Symptoms"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let doneButton = UIBarButtonItem(title: "Save", style: .prominent, target: self, action: #selector(doneButtonTapped(_:)))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.tintColor = .white
        
        setupCollectionView()
        preselectSymptoms()
        
        view.backgroundColor = UIColor(hex: "#FCEEED")
        collectionView.backgroundColor = .clear
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            UINib(nibName: "SymptomItemCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: SymptomItemCollectionViewCell.identifier
        )
        
        collectionView.register(
            UINib(nibName: "SymptomLogSectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SymptomLogSectionHeaderView"
        )
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout {
            layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: "SectionBackground")
        }
    }
    
    func setSelectedSymptoms(_ symptoms: [SymptomItem]) {
        self.preSelectedSymptoms = symptoms
    }
    
    private func preselectSymptoms() {
        // Clear existing selections first
        selectedSymptoms.removeAll()
        
        for symptom in preSelectedSymptoms {
            // Find matching symptom in categories
            for (sectionIndex, category) in categories.enumerated() {
                if let itemIndex = category.items.firstIndex(where: { $0.name == symptom.name }) {
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    selectedSymptoms.insert(indexPath)
                }
            }
        }
        collectionView.reloadData()
    }
    
    @objc private func doneButtonTapped(_ sender: Any) {
        let symptoms = getSelectedSymptoms()
        
        // Pass data through delegate
        if let delegate = self.delegate {
            _ = delegate.passData(symptoms: symptoms)
        } else {
            print("No delegate found")
        }
        
        // Check if we're in a navigation stack or presented modally
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
                }
    }
    
    private func getSelectedSymptoms() -> [SymptomItem] {
        var symptoms: [SymptomItem] = []
        for indexPath in selectedSymptoms {
            let symptom = categories[indexPath.section].items[indexPath.item]
            let logged = SymptomItem(
                name: symptom.name,
                icon: symptom.icon,
                isSelected: true,
                date: logDate,
                category: symptom.category
            )
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Try to dequeue
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: SymptomItemCollectionViewCell.identifier, for: indexPath)
        
        // In case the cell after unwrapping is nil then else
        guard let cell = dequeuedCell as? SymptomItemCollectionViewCell else {
            return dequeuedCell // returns dequeued cell if cast fails
        }
        
        let symptom = categories[indexPath.section].items[indexPath.item]
        let isSelected = selectedSymptoms.contains(indexPath)
        
        cell.configure(with: symptom, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Dequeue (reuse) a supplementary view header from collection view
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SymptomLogSectionHeaderView", for: indexPath) as! SymptomLogSectionHeaderView
        header.SymptomSectionLabel.text = categories[indexPath.section].title
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension SymptomLoggerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCategory = categories[indexPath.section].title
        
        // Handle deselection
        if selectedSymptoms.contains(indexPath) {
            selectedSymptoms.remove(indexPath)
            collectionView.reloadItems(at: [indexPath])
            return
        }
        
        // Handle mutually exclusive categories (Flow and Discharge)
        if selectedCategory == "Flow" || selectedCategory == "Discharge" {
            // Find and remove any previously selected symptom from the same category
            let previouslySelected = selectedSymptoms.filter { previousIndexPath in
                categories[previousIndexPath.section].title == selectedCategory
            }
            
            var cellsToReload = [indexPath]
            for previousIndexPath in previouslySelected {
                selectedSymptoms.remove(previousIndexPath)
                cellsToReload.append(previousIndexPath)
            }
            
            // Select the new symptom
            selectedSymptoms.insert(indexPath)
            
            // Reload all affected cells
            collectionView.reloadItems(at: cellsToReload)
        } else {
            // Normal multi-select for other categories
            selectedSymptoms.insert(indexPath)
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            return self.createGridSection()
        }
    }
    
    private func createGridSection() -> NSCollectionLayoutSection {
        // Item size - each takes 1/4 of the group width
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),  // 25% = 1/4
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        // Group size - 4 items horizontally
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),   // Full width
            heightDimension: .absolute(145)           // Fixed height per row
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 4  // Exactly 4 items per row
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 16,
            bottom: 24,
            trailing: 16
        )
        
        let sectionBackground = NSCollectionLayoutDecorationItem.background(elementKind: "SectionBackground")
        sectionBackground.contentInsets = NSDirectionalEdgeInsets(top: 44, leading: 8, bottom: 8, trailing: 8)
        section.decorationItems = [sectionBackground]
        
        // Add section header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

