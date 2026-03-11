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
        
        backgroundColor = .clear
        selectionStyle = .none
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        containerView.backgroundColor = .white
    }

    func configure(items: [String]) {
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)
        let textColor = UIColor.black
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 8
        
        let fullString = items.joined(separator: "\n")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        infoLabel.attributedText = NSAttributedString(string: fullString, attributes: attributes)
    }
}
