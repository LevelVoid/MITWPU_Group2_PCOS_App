//
//  SectionBackgroundDecorationView.swift
//  PCOS_App
//

import UIKit

class SectionBackgroundDecorationView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
}
