//
//  InfoModalViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class InfoModalViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var exercise:Exercise!
    
    @IBOutlet weak var gifImageContainer: UIView!

    @IBOutlet weak var levelTag: UIView!
    @IBOutlet weak var muscleTag: UIView!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var exerciseLevelLabel: UILabel!
    @IBOutlet weak var exerciseMuscleNameLabel: UILabel!
   // @IBOutlet weak var exerciseTempoLabel: UILabel!
    enum ExerciseInfoSection{
        case form([String])
        case tempo(String)
        case variations([String])
        case commonMistakes([String])
        var title:String {
            switch self {
            case.form: return "Form"
            case .tempo: return "Tempo"
            case .commonMistakes: return "Common Mistakes"
            case .variations: return "Variations"
            }
        }
    }
    var sections: [ExerciseInfoSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title=exercise.name
        guard exercise != nil else {
                fatalError("InfoModalViewController: exercise must be set before presenting")
            }
        view.backgroundColor = .white
        gifImageContainer.layer.cornerRadius = 24
        gifImageContainer.backgroundColor = .white
        gifImageContainer.layer.borderWidth = 1
        gifImageContainer.layer.borderColor = UIColor.systemGray5.cgColor
        
        gifImageView.image = exercise.gifImage
        
        let recommendedBg = UIColor(red: 255/255, green: 245/255, blue: 245/255, alpha: 1.0)
        let recommendedText = UIColor(red: 255/255, green: 175/255, blue: 177/255, alpha: 1.0)
        
        styleTag(levelTag, label: exerciseLevelLabel, color: recommendedBg, textColor: recommendedText)
        styleTag(muscleTag, label: exerciseMuscleNameLabel, color: recommendedBg, textColor: recommendedText)
        
        tableView.backgroundColor = .clear
        
        let level:String=exercise.level
        exerciseLevelLabel.text=level
        //let tempo:String=exercise.tempo
        //exerciseTempoLabel.text=tempo
        let muscle:String="\(exercise.muscleGroup.displayName)"
        exerciseMuscleNameLabel.text=muscle
        
        buildSections()
        setupTableView()
    }
    
    private func styleTag(_ tagView: UIView, label: UILabel, color: UIColor, textColor: UIColor) {
        tagView.layer.cornerRadius = 10
        tagView.backgroundColor = color
        tagView.layer.borderWidth = 0
        
        label.textColor = textColor
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        
        // Find icon inside and update it
        if let icon = tagView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            icon.tintColor = textColor
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "InfoCardTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "InfoCardTableViewCell")
    }
    func buildSections() {
        sections = [
            .form(exercise.form),
            .tempo(exercise.tempo),
            .variations(exercise.variations),
            .commonMistakes(exercise.commonMistakes)
        ]
    }
    
    @IBAction func infoCloseButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1   // each card is one row
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCardTableViewCell",
                                                 for: indexPath) as! InfoCardTableViewCell

        let sectionData = sections[indexPath.section]

        switch sectionData {
        case .form(let list):
            cell.configure(items: list)

        case .tempo(let tempo):
            cell.configure(items: ["\(tempo)"])

        case .variations(let list),
             .commonMistakes(let list):
            cell.configure(items: list)
        }

        return cell
    }
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = sections[section].title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    

}
