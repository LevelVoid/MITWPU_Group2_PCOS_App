//
//  RestTimeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class RestTimeViewController: UIViewController {
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var ringContainerView: UIView!

    private let totalCount = 10
        private var currentCount = 10
        
        private let ringLayer = CAShapeLayer()
        private let trackLayer = CAShapeLayer()

        var onCountdownFinished: (() -> Void)?

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Setup ring after layout to ensure correct bounds
            if trackLayer.path == nil {
                setupRing()
            }
            
            // Make image circular
            RestTimeImageOutlet?.layer.cornerRadius = (RestTimeImageOutlet?.frame.width ?? 0) / 2
            RestTimeImageOutlet?.clipsToBounds = true
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            startCountdown()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: false)
            tabBarController?.tabBar.isHidden = true
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.setNavigationBarHidden(false, animated: false)
            tabBarController?.tabBar.isHidden = false
        }

        private func setupUI() {
            view.backgroundColor = .systemBackground
            isModalInPresentation = true

            // Configure label
            countLabel.textColor = .label
            countLabel.textAlignment = .center
            countLabel.font = .systemFont(ofSize: 60, weight: .heavy) // Bigger and bolder
            countLabel.text = "" // Removed emoji
            countLabel.alpha = 0
            
            // Set image
            RestTimeImageOutlet?.image = UIImage(named: "resttimerimage")
            RestTimeImageOutlet?.contentMode = .scaleAspectFit
            RestTimeImageOutlet?.alpha = 1
            
            // Ensure label is on top of circle animation 
            view.bringSubviewToFront(countLabel)
        }

        private func setupRing() {
            // Calculate radius based on container size
            let size = min(ringContainerView.bounds.width, ringContainerView.bounds.height)
            let radius = (size - 24) / 2 // Leave space for line width
            let center = CGPoint(x: ringContainerView.bounds.midX,
                                 y: ringContainerView.bounds.midY)

            let circularPath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: -.pi / 2,
                endAngle: 1.5 * .pi,
                clockwise: true
            )

            // Track layer (background)
            trackLayer.path = circularPath.cgPath
            trackLayer.strokeColor = UIColor.systemGray5.cgColor
            trackLayer.lineWidth = 20
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.lineCap = .round

            // Progress layer (animated)
            ringLayer.path = circularPath.cgPath
            //ringLayer.strokeColor = UIColor.systemGreen.cgColor
            ringLayer.strokeColor = UIColor(hex:"FE7A96").cgColor
            ringLayer.lineWidth = 20
            ringLayer.fillColor = UIColor.clear.cgColor
            ringLayer.lineCap = .round
            ringLayer.strokeEnd = 0

            ringContainerView.layer.addSublayer(trackLayer)
            ringContainerView.layer.addSublayer(ringLayer)
        }

        private func startCountdown() {
            // Show "READY" text
            //countLabel.text = "READY"
            
            // Fade in
            UIView.animate(withDuration: 0.5) {
                self.countLabel.alpha = 1
            } completion: { _ in
                // Wait 1 second then start number countdown
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.startNumberCountdown()
                }
            }
        }
        
        private func startNumberCountdown() {
            // Show first number
            currentCount = totalCount
            updateLabel(to: "\(currentCount)")
            
            // Reset ring to full
            ringLayer.strokeEnd = 1.0
            
            // Start countdown
            animateCountdownStep()
        }

        private func animateCountdownStep() {
            // Animate ring from full to empty over 1 second
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 1.0
            animation.toValue = 0
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            ringLayer.add(animation, forKey: "countdown")
            
            // Haptic feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            // Schedule next count or finish
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                
                self.currentCount -= 1
                
                if self.currentCount > 0 {
                    // Update label with animation
                    self.animateLabelChange(to: "\(self.currentCount)")
                    
                    // Reset ring to full and animate again
                    self.ringLayer.removeAllAnimations()
                    self.ringLayer.strokeEnd = 1.0
                    self.animateCountdownStep()
                    
                } else {
                    // Countdown finished
                    //self.finishCountdown()
                    self.finishRest()
                }
            }
        }
        
        private func updateLabel(to text: String) {
            countLabel.text = text
            countLabel.alpha = 1.0
        }
        
        private func animateLabelChange(to text: String) {
            // Scale down and fade
            UIView.animate(withDuration: 0.15, animations: {
                self.countLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.countLabel.alpha = 0.3
            }) { _ in
                // Update text
                self.countLabel.text = text
                
                // Scale back up and fade in with bounce
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                    self.countLabel.transform = .identity
                    self.countLabel.alpha = 1.0
                }
            }
        }

        private func finishCountdown() {
            // Final haptic
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            // Fade out everything
            UIView.animate(withDuration: 0.3, animations: {
                self.countLabel.alpha = 0
                self.ringContainerView.alpha = 0
            }) { _ in
                self.dismiss(animated: false) {
                    self.onCountdownFinished?()
                }
            }
        }
    //Rest TIME LOGIC
    @IBOutlet weak var RestTimeImageOutlet: UIImageView!
    var secondsRemaining: Int = 10
        var timer: Timer?

        var onRestFinished: (() -> Void)?


        private func updateLabel() {
            countLabel.text = "\(secondsRemaining)s"
        }

        @IBAction func skipTapped(_ sender: UIButton) {
            finishRest()
        }

        private func finishRest() {
            timer?.invalidate()
            dismiss(animated: true) {
                self.onRestFinished?()
            }
        }
    }
