//
//  DietLogsViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit


class DietLogsViewController: UIViewController {
    var dummyData = DataStore.sampleFoods
    @IBOutlet weak var loggedMeal: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Diet Logs"
        navigationItem.largeTitleDisplayMode = .never
        loggedMeal.delegate = self
        loggedMeal.dataSource = self
    }
    
    
    

}


extension DietLogsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dummyData[indexPath.row].name
        cell.detailTextLabel?.text = "\(dummyData[indexPath.row].calories) kcal"
        return cell
    }
}



