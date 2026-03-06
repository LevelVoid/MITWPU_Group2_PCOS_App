//
//  NameViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class NameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.layer.cornerRadius = 10
        nameField.delegate = self
        nextButton.tintColor = UIColor(hex: "FE7A96")

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // Fallback: always dismiss keyboard when touching the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    // Dismiss keyboard when user taps Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func NextButtonTapped(_ sender: UIButton) {
        guard let name = nameField.text, !name.isEmpty else {
            let alert = UIAlertController(title: "No name entered",
                                          message: "Please enter your name",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        UserDefaults.standard.set(name, forKey: "userName")
        performSegue(withIdentifier: "showDOB", sender: nil)
    }
}
