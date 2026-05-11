import UIKit
import TipKit

/// Manages a sequential guided tour using native TipKit popovers.
@available(iOS 17.0, *)
final class GuidedTourManager {

    static let tourCompletedKey = "hasCompletedHomeGuidedTour"
    private let pink = UIColor(red: 0.88, green: 0.35, blue: 0.47, alpha: 1.0)

    var hasCompletedTour: Bool {
        get { UserDefaults.standard.bool(forKey: Self.tourCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.tourCompletedKey) }
    }

    private weak var presenter: UIViewController?
    private var queue: [() -> Void] = []

    /// Build the tour queue, then call `start()`.
    func setup(presenter: UIViewController) {
        self.presenter = presenter
        queue.removeAll()
    }

    /// Enqueue a tip anchored to a UIView.
    func enqueue<T: Tip>(_ tip: T, sourceView: UIView) {
        queue.append { [weak self] in
            self?.show(tip, sourceItem: sourceView)
        }
    }

    /// Enqueue a tip anchored to a UIBarButtonItem.
    func enqueue<T: Tip>(_ tip: T, barButtonItem: UIBarButtonItem) {
        queue.append { [weak self] in
            self?.show(tip, sourceItem: barButtonItem)
        }
    }

    func start() {
        advance()
    }

    func cancel() {
        queue.removeAll()
        if let p = presenter, p.presentedViewController is TipUIPopoverViewController {
            p.dismiss(animated: false)
        }
    }

    // MARK: - Private

    private func show<T: Tip>(_ tip: T, sourceItem: some UIPopoverPresentationControllerSourceItem) {
        guard let presenter = presenter, presenter.view.window != nil else {
            advance(); return
        }

        // Wait for any previous popover to fully dismiss
        if presenter.presentedViewController != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.show(tip, sourceItem: sourceItem)
            }
            return
        }

        if let view = sourceItem as? UIView, view.window == nil {
            advance(); return
        }

        let popoverVC = TipUIPopoverViewController(tip, sourceItem: sourceItem)
        popoverVC.view.tintColor = pink
        presenter.present(popoverVC, animated: true)

        // Poll until the user dismisses the popover (X button or tap outside).
        // This is more reliable than TipKit's shouldDisplayUpdates async stream.
        pollForDismissal()
    }

    /// Check every 0.5s if the popover is still on screen.
    /// Once dismissed, advance to the next tip.
    private func pollForDismissal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, let presenter = self.presenter else { return }

            if presenter.presentedViewController is TipUIPopoverViewController {
                // Still showing — keep polling
                self.pollForDismissal()
            } else {
                // User dismissed the tip — show the next one after a brief pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.advance()
                }
            }
        }
    }

    private func advance() {
        guard !queue.isEmpty else {
            hasCompletedTour = true
            return
        }
        let next = queue.removeFirst()
        next()
    }
}
