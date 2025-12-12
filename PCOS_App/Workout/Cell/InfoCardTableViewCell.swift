//
//  InfoCardTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class InfoCardTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = false

        // shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
    }
//    func configure(text: String) {
//        infoLabel.text = "• " + text
//    }
//    func configure(list: [String]) {
//        infoLabel.text = list.map { "• \($0)" }.joined(separator: "\n")
//    }
    func configure(items: [String]) {
        infoLabel.text = items.map { "• \($0)" }.joined(separator: "\n")
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//
//    }
    
}
