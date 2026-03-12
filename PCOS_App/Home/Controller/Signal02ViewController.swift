//
//  Signal02ViewController.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 18/02/26.
//

import UIKit

final class Signal02ViewController: UIViewController {

    var signal: PCOSSignal!

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doctorDisclaimerLabel: UILabel!
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var card2View: UIView!
    
    // Colors for the cards matching the design
    private let cardColors: [UIColor] = [
        UIColor(hex: "#fce4e8")
    ]
    
    // Store the maximum card height so all pills have the same height
    private var maxCardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        card1View.layer.cornerRadius = 16
        card2View.layer.cornerRadius = 16
        
//        card2View.layer.borderWidth = 1
//        card2View.layer.borderColor = UIColor(hex:"FE7A96").withAlphaComponent(0.5).cgColor
        
        setupTableView()
        bindData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update table view height to fit content without scrolling
        tableView.layoutIfNeeded()
        let contentHeight = tableView.contentSize.height
        
        // Remove old height constraint if exists
        if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height }) {
            tableView.removeConstraint(heightConstraint)
        }
        
        // Add new height constraint matching content
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: contentHeight)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AppearanceCell")
        
        // Remove any height constraints on the table view itself to avoid conflicts
        tableView.constraints.filter { $0.firstAttribute == .height }.forEach {
            tableView.removeConstraint($0)
        }
    }
    
    private func bindData() {
        headingLabel.text = signal.appearanceHeading
        doctorDisclaimerLabel.text = signal.doctorDisclaimer
        
        // Calculate max height for all cards before reloading
        calculateMaxCardHeight()
        
        // Reload table to display cards
        tableView.reloadData()
    }
    
    private func calculateMaxCardHeight() {
        // Calculate the height needed for each description text
        let cardWidth = tableView.bounds.width  // Full width
        let labelWidth = cardWidth - 40  // 20pt padding inside card on each side
        
        var heights: [CGFloat] = []
        
        for description in signal.appearanceDescriptions {
            let label = UILabel()
            label.text = description
            label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            label.numberOfLines = 0
            
            let size = label.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
            let cardHeight = size.height + 32 + 12  // 16pt top + 16pt bottom padding + 12pt for cell spacing (6+6)
            heights.append(cardHeight)
        }
        
        // Store the maximum height
        maxCardHeight = heights.max() ?? 80
    }
}

// MARK: - UITableViewDataSource
extension Signal02ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signal.appearanceDescriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppearanceCell", for: indexPath)
        
        // Remove any existing views
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Create card view
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = cardColors[indexPath.row % cardColors.count]
        // Use half the card height as corner radius for proper pill shape
        cardView.layer.cornerRadius = (maxCardHeight - 12) / 2  // Subtract spacing (6+6), then divide by 2
        cardView.layer.masksToBounds = true
        cell.contentView.addSubview(cardView)
        
        // Create label for description
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = signal.appearanceDescriptions[indexPath.row]
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        cardView.addSubview(descriptionLabel)
        
        // Setup constraints - center text vertically in the pill
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
            
            descriptionLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            descriptionLabel.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension Signal02ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Return the maximum card height so all pills are the same size
        return maxCardHeight > 0 ? maxCardHeight : 80
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
