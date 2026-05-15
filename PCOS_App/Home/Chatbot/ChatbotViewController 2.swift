//
//  ChatbotViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/03/26.
//

import UIKit

final class ChatbotViewController: UIViewController {

    
    // MARK: - Properties
    private var messages: [ChatMessage] = []
    private var isAITyping = false
    private let inputBar = ChatInputBar()
    private let brain = AIBrain.shared

    // Quick prompt suggestions shown on empty state
    private let quickPrompts = [
        "What should I eat today? ",
        "Why do I have cramps? ",
        "Help me understand my cycle ",
        "I'm craving sugar badly "
    ]

    // MARK: - TableView (programmatic, no IBOutlet needed)
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.identifier)
        tv.register(TypingIndicatorCell.self, forCellReuseIdentifier: TypingIndicatorCell.identifier)
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor(hex:"fceeed")
        tv.keyboardDismissMode = .interactive
        tv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - inputAccessoryView (the iMessage magic)
    override var inputAccessoryView: UIView? { inputBar }
    override var canBecomeFirstResponder: Bool { true }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex:"fceeed")
        setupNavigationBar()
        setupTableView()
        setupInputBar()
        setupKeyboardObservers()   // ← add this
        loadPersistedMessages()
    }

    // Add this new method:
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    private func loadPersistedMessages() {
        let saved = ChatPersistenceManager.shared.loadTodaysMessages()

        if saved.isEmpty {
            // First launch today or after clear — show welcome and persist it
            let welcome = ChatMessage(
                text: "Hi! I'm Adira, your PCOS health coach.\n\nI can help with meal ideas, understanding your symptoms, cycle questions, or anything PCOS-related. \n\nWhat's on your mind today?",
                sender: .ai
            )
            messages.append(welcome)
            ChatPersistenceManager.shared.saveMessage(text: welcome.text, sender: .ai)
        } else {
            messages = saved
        }

        tableView.reloadData()
        scrollToBottom(animated: false)
    }


    @objc private func keyboardWillChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight = max(0, view.bounds.height - keyboardFrame.origin.y)
        let bottomInset = keyboardHeight > 0 ? keyboardHeight + 8 : 12

        UIView.animate(withDuration: duration) {
            self.tableView.contentInset.bottom = bottomInset
            self.tableView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
        // Scroll to bottom so last message stays visible
        scrollToBottom()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()

        // Walkthrough: if user arrives here during the chatbot step, show final congrats
        if WalkthroughManager.shared.isActive,
           WalkthroughManager.shared.currentStep == .chatbotPrompt {
            WalkthroughManager.shared.addDelegate(self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.showWalkthroughCompletionCongrats()
            }
        }
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Adira"
        navigationController?.navigationBar.prefersLargeTitles = false

        // Subtitle "PCOS Coach" via attributed title workaround
        let titleLabel = UILabel()
        titleLabel.text = "Adira"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "PCOS Coach • Online"
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = UIColor(hex:"#fe7a96")

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 0
        navigationItem.titleView = stack

        // Clear button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.counterclockwise"),
            style: .plain,
            target: self,
            action: #selector(clearChatTapped)
        )
        //navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.52, green: 0.24, blue: 0.76, alpha: 1)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }

    private func setupInputBar() {
        inputBar.delegate = self
    }

    // MARK: - Welcome
    private func sendWelcomeMessage() {
        let welcome = ChatMessage(
            text: "Hi! I'm Adira, your PCOS health coach.\n\nI can help with meal ideas, understanding your symptoms, cycle questions, or anything PCOS-related. \n\nWhat's on your mind today?",
            sender: .ai
        )
        messages.append(welcome)
        tableView.reloadData()
    }

    // MARK: - Message Flow
    private func addUserMessage(_ text: String) {
        let msg = ChatMessage(text: text, sender: .user)
        messages.append(msg)
        insertLastRow(animated: true)
        ChatPersistenceManager.shared.saveMessage(text: text, sender: .user)
    }

    private func showTypingIndicator() {
        isAITyping = true
        let indexPath = IndexPath(row: messages.count, section: 0)
        tableView.insertRows(at: [indexPath], with: .fade)
        scrollToBottom()

        if let cell = tableView.cellForRow(at: indexPath) as? TypingIndicatorCell {
            cell.startAnimating()
        }
    }

    private func hideTypingIndicator(then completion: @escaping () -> Void) {
        guard isAITyping else { return }
        isAITyping = false
        let indexPath = IndexPath(row: messages.count, section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
        completion()
    }

    private func addAIMessage(_ text: String) {
        hideTypingIndicator {
            let msg = ChatMessage(text: text, sender: .ai)
            self.messages.append(msg)
            self.insertLastRow(animated: true)
            ChatPersistenceManager.shared.saveMessage(text: text, sender: .ai)
        }
    }

    private func insertLastRow(animated: Bool) {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: animated ? .bottom : .none)
        scrollToBottom()
    }

    private func scrollToBottom(animated: Bool = true) {
        DispatchQueue.main.async {
            let totalRows = self.messages.count + (self.isAITyping ? 1 : 0)
            guard totalRows > 0 else { return }
            let indexPath = IndexPath(row: totalRows - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }

    // MARK: - AI Call
    private func sendToAI(_ text: String) {
        showTypingIndicator()

        Task {
            do {
                let context = await SharedContextEngine.shared.buildContext()
                // Re-inject earlier conversation summary if AI session was reset
                let chatSummary = ChatPersistenceManager.shared.buildChatSummary()
                let fullContext = chatSummary.isEmpty ? context : "\(context)\n\n\(chatSummary)"
                
                let response = try await brain.sendChatMessage(text, context: fullContext)

                await MainActor.run {
                    self.addAIMessage(response)
                }
            } catch {
                await MainActor.run {
                    self.addAIMessage("I'm having trouble connecting right now. Please check your internet connection and try again.")
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func clearChatTapped() {
        let alert = UIAlertController(title: "Clear Chat", message: "Start a new conversation with Adira?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.brain.resetChat()
            ChatPersistenceManager.shared.clearAllMessages()
            self.messages.removeAll()
            self.isAITyping = false
            self.tableView.reloadData()
            self.loadPersistedMessages()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func dismissKeyboard() {
        inputBar.textView.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource
extension ChatbotViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + (isAITyping ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Typing indicator is the last row when AI is responding
        if isAITyping && indexPath.row == messages.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: TypingIndicatorCell.identifier, for: indexPath) as! TypingIndicatorCell
            cell.startAnimating()
            return cell
        }

        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleCell.identifier, for: indexPath) as! ChatBubbleCell
        cell.configure(with: message)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatbotViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // Long press to copy
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row < messages.count else { return nil }
        let message = messages[indexPath.row]
        return UIContextMenuConfiguration(actionProvider: { _ in
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = message.text
            }
            return UIMenu(children: [copy])
        })
    }
}

// MARK: - ChatInputBarDelegate
extension ChatbotViewController: ChatInputBarDelegate {
    func inputBar(_ bar: ChatInputBar, didSend text: String) {
        addUserMessage(text)
        sendToAI(text)
    }
}

// MARK: - WalkthroughManagerDelegate
extension ChatbotViewController: WalkthroughManagerDelegate {

    func walkthroughDidReachStep(_ step: WalkthroughStep) { }

    func walkthroughDidComplete() { }

    // Called from viewDidAppear when the walkthrough is at .chatbotPrompt
    private func showWalkthroughCompletionCongrats() {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        WalkthroughCongratsView.present(
            in: keyWindow,
            title: "You're All Set!",
            body: "Welcome to your PCOS journey with Adira!\nAsk me anything — I'm here to help every step of the way.",
            continueTitle: "Start Exploring"
        ) {
            WalkthroughManager.shared.completeWalkthrough()
        }
    }
}
