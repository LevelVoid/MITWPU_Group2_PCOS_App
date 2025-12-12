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
    
    @IBOutlet weak var exerciseLevelLabel: UILabel!
    @IBOutlet weak var exerciseMuscleNameLabel: UILabel!
    @IBOutlet weak var exerciseTempoLabel: UILabel!
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
        guard exercise != nil else {
                fatalError("InfoModalViewController: exercise must be set before presenting")
            }
        let level:String=exercise.level
        exerciseLevelLabel.text=level
        let tempo:String=exercise.tempo
        exerciseTempoLabel.text=tempo
        let muscle:String="\(exercise.muscleGroup)"
        exerciseMuscleNameLabel.text=muscle
        
        buildSections()

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
                   titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {

        guard let header = view as? UITableViewHeaderFooterView else { return }

        header.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .label
        header.contentView.backgroundColor = .systemBackground
    }
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    

}
