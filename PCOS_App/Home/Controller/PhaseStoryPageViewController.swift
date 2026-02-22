//
//  PhaseStoryPageViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 19/02/26.
//

import UIKit

final class PhaseStoryPageViewController: UIPageViewController {

    // MARK: - Data
    var phaseSignal: PhaseSignal!
    var startIndex: Int = 0

    private var pages: [UIViewController] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        configureNavBar()
        configurePages()
        disableSwipe()
        addTapNavigation()
    }

    // MARK: - Navigation Bar
    private func configureNavBar() {

        title = phaseSignal.understanding.heading

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(hex: "#FCEEED")
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    // MARK: - Pages
    private func configurePages() {

        let storyboard = UIStoryboard(name: "Home", bundle: nil)

        let phase01VC = storyboard.instantiateViewController(
            withIdentifier: "Phase01ViewController"
        ) as! Phase01ViewController

        let phase02VC = storyboard.instantiateViewController(
            withIdentifier: "Phase02ViewController"
        ) as! Phase02ViewController

        let phase03VC = storyboard.instantiateViewController(
            withIdentifier: "Phase03ViewController"
        ) as! Phase03ViewController

        phase01VC.phaseSignal = phaseSignal
        phase02VC.phaseSignal = phaseSignal
        phase03VC.phaseSignal = phaseSignal

        pages = [phase01VC, phase02VC, phase03VC]

        setViewControllers(
            [pages[startIndex]],
            direction: .forward,
            animated: false
        )

    }

    // MARK: - Navigation Behavior
    private func disableSwipe() {
        view.gestureRecognizers?
            .filter { $0 is UIPanGestureRecognizer }
            .forEach { $0.isEnabled = false }
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

        guard
            let currentVC = viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentVC)
        else { return }

        if location.x > midpoint {
            goToNext(from: currentIndex)
        } else {
            goToPrevious(from: currentIndex)
        }
    }

    private func goToNext(from index: Int) {
        guard index < pages.count - 1 else { return }
        setViewControllers(
            [pages[index + 1]],
            direction: .forward,
            animated: true
        )
    }

    private func goToPrevious(from index: Int) {
        guard index > 0 else { return }
        setViewControllers(
            [pages[index - 1]],
            direction: .reverse,
            animated: true
        )
    }

    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
