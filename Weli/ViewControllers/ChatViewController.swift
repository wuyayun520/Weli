//
//  ChatViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit
import PhotosUI

class ChatViewController: BaseViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type a message..."
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        textField.textColor = .white
        textField.layer.cornerRadius = 20
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let imageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = Theme.primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var messages: [Message] = []
    private let currentUserId = "current_user" // 当前用户ID，可以从用户系统获取
    private let otherUser: User
    
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    init(user: User) {
        self.otherUser = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackButton()
        loadMessages()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(imageButton)
        inputContainerView.addSubview(sendButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        if #available(iOS 14.0, *) {
            imageButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        textField.delegate = self
        
        // 添加点击手势退下键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            imageButton.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            imageButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            imageButton.widthAnchor.constraint(equalToConstant: 40),
            imageButton.heightAnchor.constraint(equalToConstant: 40),
            
            textField.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        inputContainerBottomConstraint.constant = -keyboardHeight + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        inputContainerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func loadMessages() {
        messages = ChatManager.shared.getMessages(between: currentUserId, and: otherUser.userId)
        tableView.reloadData()
        scrollToBottom(animated: false)
    }
    
    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func sendButtonTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return
        }
        
        let message = Message(
            senderId: currentUserId,
            receiverId: otherUser.userId,
            type: .text,
            content: text
        )
        
        sendMessage(message)
        textField.text = ""
        dismissKeyboard()
    }
    
    @available(iOS 14.0, *)
    @objc private func imageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func sendMessage(_ message: Message) {
        ChatManager.shared.saveMessage(message, between: currentUserId, and: otherUser.userId)
        messages.append(message)
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .fade)
        scrollToBottom(animated: true)
    }
    
    private func sendImage(_ image: UIImage) {
        let messageId = UUID().uuidString
        guard let imagePath = ChatManager.shared.saveImage(image, for: messageId) else {
            return
        }
        
        let message = Message(
            id: messageId,
            senderId: currentUserId,
            receiverId: otherUser.userId,
            type: .image,
            content: imagePath
        )
        
        sendMessage(message)
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        let isFromCurrentUser = message.senderId == currentUserId
        cell.configure(with: message, isFromCurrentUser: isFromCurrentUser)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        if message.type == .text {
            // 根据文本长度估算高度
            let text = message.content
            let width: CGFloat = 256 // 最大文本宽度
            let font = UIFont.systemFont(ofSize: 16)
            let size = CGSize(width: width, height: .greatestFiniteMagnitude)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedRect = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
            // 加上 padding: 10 (top) + 4 (gap) + 16 (timeLabel) + 8 (bottom) + 8 (bubble bottom) = 46
            return estimatedRect.height + 46
        } else {
            // 图片消息固定高度: 10 (top) + 200 (image) + 4 (gap) + 16 (timeLabel) + 8 (bottom) + 8 (bubble bottom) = 246
            return 246
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}

extension ChatViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.sendImage(image)
            }
        }
    }
}

