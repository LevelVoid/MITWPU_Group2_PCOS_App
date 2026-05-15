//
//  DOBViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class DOBViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.tintColor = UIColor(hex: "FE7A96")
        setupDatePicker()
    }

    private func setupDatePicker() {
        // Set to Wheels style
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date

        // Set maximum date to today (can't select future dates)
        datePicker.maximumDate = Date()

        // Set minimum date (e.g., 100 years ago)
        let calendar = Calendar.current
        if let minDate = calendar.date(byAdding: .year, value: -100, to: Date()) {
            datePicker.minimumDate = minDate
        }

        // Set default date to 25 years ago (or whatever makes sense)
        if let defaultDate = calendar.date(byAdding: .year, value: -25, to: Date()) {
            datePicker.date = defaultDate
        }
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let selectedDate = datePicker.date

        // Format the date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: selectedDate)

        print("Date of Birth: \(dateString)")

        // Save to UserDefaults
        UserDefaults.standard.set(selectedDate, forKey: "userDOB")

        // Calculate age
        let age = Calendar.current.dateComponents([.year], from: selectedDate, to: Date()).year ?? 0
        print("Age: \(age)")

       performSegue(withIdentifier: "showHeight", sender: nil)
    }
}
