//
//  LogsTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class LogsTableViewCell: UITableViewCell {

    @IBOutlet weak var outerCell: UIView!
    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var fats: UILabel!
    @IBOutlet weak var carbs: UILabel!
    @IBOutlet weak var protein: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodImg: UIImageView!
    
    @IBOutlet weak var innerCell: UIView!
    static var identifier = "LogsTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with log: Food) {
        foodName.text = log.name
        fats.text = "\(Int(log.fatsContent))g"
        carbs.text = "\(Int(log.carbsContent))g"
        protein.text = "\(Int(log.proteinContent))g"
        calories.text = "\(Int(log.calories))kcal"
        innerCell.layer.cornerRadius = 20
        foodImg.clipsToBounds = true
        foodImg.layer.cornerRadius = 12
        
        if let imageName = log.image, imageName.hasPrefix("http"),
           let url = URL(string: imageName) {
            foodImg.image = UIImage(named: "dietPlaceholder")
            loadImage(from: url)
        } else if let imageName = log.image, imageName.hasPrefix("/") {
            // Legacy File path
            foodImg.image = UIImage(contentsOfFile: imageName)
                ?? UIImage(named: "dietPlaceholder")
        } else if let imageName = log.image, !imageName.isEmpty {
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = docDir.appendingPathComponent("FoodImages").appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                foodImg.image = UIImage(contentsOfFile: fileURL.path)
            } else if let localImg = UIImage(named: imageName) {
                foodImg.image = localImg
            } else {
                foodImg.image = UIImage(named: "dietPlaceholder")
            }
        } else {
            foodImg.image = UIImage(named: "dietPlaceholder")
        }
    }


    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.foodImg.image = image
            }
        }.resume()
    }

    
}
