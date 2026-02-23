//
//  AboutPCOSViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 23/02/26.
//
import UIKit

final class AboutPCOSViewController: UIViewController {

    @IBOutlet weak var headerImageView: UIImageView!
   // @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var ContentView:UIView!
    var section: AboutPCOSSection?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        guard let section = section else { return }

        //view.backgroundColor = UIColor(hex: "#FCEEED")

        // Title
        title = section.title
       // title.font = UIFont.boldSystemFont(ofSize: 28)
      //  titleLabel.numberOfLines = 0

        // Header Image
        headerImageView.image = UIImage(named: section.imageName)
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.clipsToBounds = true

       // stackView.bottom = ContentView.bottom - 20
        // Clear old content
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        section.contentBlocks.forEach { block in

            if let heading = block.heading {
                let headingLabel = UILabel()
                headingLabel.text = heading
                headingLabel.font = UIFont.boldSystemFont(ofSize: 22)
                headingLabel.numberOfLines = 0
                headingLabel.textColor = .label
                stackView.addArrangedSubview(headingLabel)
            }

            if let body = block.body {
                let bodyLabel = UILabel()
                bodyLabel.text = body
                bodyLabel.font = UIFont.systemFont(ofSize: 18)
                bodyLabel.textColor = .darkGray
                bodyLabel.numberOfLines = 0
                bodyLabel.lineBreakMode = .byWordWrapping
                stackView.addArrangedSubview(bodyLabel)
            }

            if let imageName = block.imageName {
                let imageView = UIImageView()
                imageView.image = UIImage(named: imageName)
                imageView.contentMode = .scaleAspectFit
                imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
                stackView.addArrangedSubview(imageView)
            }
        }
    }
}
