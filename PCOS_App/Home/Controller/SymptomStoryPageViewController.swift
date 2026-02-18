//
//  SymptomStoryPageViewController.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 18/02/26.
//

import UIKit

final class SymptomStoryPageViewController: UIPageViewController {

    var signal: PCOSSignal!

    private var pages: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []

        title = signal.signalTitle

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        configureNavBar()
        configurePages()
        disableSwipe()
        addTapNavigation()
    }
    private func configureNavBar() {

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(hex: "#FCEEED")
        appearance.shadowColor = .clear

        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }



    private func configurePages() {

        let storyboard = UIStoryboard(name: "Home", bundle: nil)

        let infoVC = storyboard.instantiateViewController(
            withIdentifier: "Signal01ViewController"
        ) as! Signal01ViewController

        let appearanceVC = storyboard.instantiateViewController(
            withIdentifier: "Signal02ViewController"
        ) as! Signal02ViewController

        let supportVC = storyboard.instantiateViewController(
            withIdentifier: "Signal03ViewController"
        ) as! Signal03ViewController

        infoVC.signal = signal
        appearanceVC.signal = signal
        supportVC.signal = signal

        pages = [infoVC, appearanceVC, supportVC]

        setViewControllers([pages[0]], direction: .forward, animated: false)
    }
    
    private func disableSwipe() {
        for gesture in view.gestureRecognizers ?? [] {
            if gesture is UIPanGestureRecognizer {
                gesture.isEnabled = false
            }
        }
    }
    
    private func addTapNavigation() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(_:))
        )
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {

        let location = gesture.location(in: view)
        let midpoint = view.bounds.width / 2

        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else { return }

        if location.x > midpoint {
            goToNext(from: currentIndex)
        } else {
            goToPrevious(from: currentIndex)
        }
    }

    private func goToNext(from index: Int) {
        guard index < pages.count - 1 else { return }
        setViewControllers([pages[index + 1]],
                           direction: .forward,
                           animated: true)
    }

    private func goToPrevious(from index: Int) {
        guard index > 0 else { return }
        setViewControllers([pages[index - 1]],
                           direction: .reverse,
                           animated: true)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }


}
