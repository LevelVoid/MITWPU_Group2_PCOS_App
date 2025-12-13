//
//  HeaderCollectionReusableView.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureHeader(with title: String) {
        headerLabel.text = title
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }
}
