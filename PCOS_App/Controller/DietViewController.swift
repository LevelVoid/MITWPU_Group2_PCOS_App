//
//  DietViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class DietViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diet"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarTapped))
        navigationItem.rightBarButtonItem = calendar
        
//        // Create a custom UIButton
//        let calendarButton = UIButton(type: .system)
//        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
//        calendarButton.tintColor = .label
//        calendarButton.addTarget(self, action: #selector(calendarTapped), for: .touchUpInside)
//        
//        // Ensure a reasonable tappable size (min 44x44 recommended)
//        calendarButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
//        calendarButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
//        
//        // Wrap the button in a UIBarButtonItem
//        let calendarItem = UIBarButtonItem(customView: calendarButton)
//        navigationItem.rightBarButtonItem = calendarItem
    }
    
    @objc func calendarTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "dietLogs") as? DietLogsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
