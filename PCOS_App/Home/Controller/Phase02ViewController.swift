//
//  Phase02ViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 19/02/26.
//

import UIKit

class Phase02ViewController: UIViewController {
    @IBOutlet weak var TableView: UITableView!
//    @IBOutlet weak var ExpectedSymptomName: UILabel!
    @IBOutlet weak var Description: UILabel!
//    @IBOutlet weak var ExpectedSymptomImage: UIImageView!
    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var card1View:UIView!
    @IBOutlet weak var card2View:UIView!
    
    var phaseSignal: PhaseSignal!
    private var symptoms: [SymptomItem] {
            phaseSignal.symptoms.symptomItems
        }

    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTableView()
        }

        // MARK: - UI Setup
        private func setupUI() {
            card1View.layer.cornerRadius=16
            card2View.layer.cornerRadius=16
            headingLabel.text = phaseSignal.symptoms.heading
            Description.text = phaseSignal.symptoms.introText
        }

        private func setupTableView() {
            TableView.dataSource = self
            TableView.delegate = self

            TableView.separatorStyle = .none
            TableView.backgroundColor = .clear
            TableView.isScrollEnabled = false
        }
}
extension Phase02ViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return symptoms.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExpectedSymptomCell",
            for: indexPath
        )

        let symptom = symptoms[indexPath.row]

        // Prototype cell subviews via tags
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = UIImage(named: symptom.icon)
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
        }

        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = symptom.name
        }

        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        return cell
    }
}

extension Phase02ViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 72
    }
}

