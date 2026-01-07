//
//  VideoCallViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit

class VideoCallViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_all_back"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let controlContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let muteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let hangupButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_call_nor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let videoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.setImage(UIImage(systemName: "video.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let otherUser: User
    private var countdownTimer: Timer?
    private var remainingSeconds = 20
    
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
        startCountdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(backButton)
        view.addSubview(userAvatarImageView)
        view.addSubview(usernameLabel)
        view.addSubview(statusLabel)
        view.addSubview(controlContainerView)
        
        controlContainerView.addSubview(muteButton)
        controlContainerView.addSubview(hangupButton)
        controlContainerView.addSubview(videoButton)
        
        // 加载用户头像作为背景
        let fullPath = "weliacg/\(otherUser.avatar)"
        if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
            backgroundImageView.image = UIImage(contentsOfFile: imagePath)
            userAvatarImageView.image = UIImage(contentsOfFile: imagePath)
        } else if let imagePath = Bundle.main.path(forResource: otherUser.avatar.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
            backgroundImageView.image = UIImage(contentsOfFile: imagePath)
            userAvatarImageView.image = UIImage(contentsOfFile: imagePath)
        }
        
        usernameLabel.text = otherUser.username
        statusLabel.text = "Calling...20s"
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        hangupButton.addTarget(self, action: #selector(hangupButtonTapped), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            userAvatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            userAvatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 60),
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.topAnchor.constraint(equalTo: userAvatarImageView.bottomAnchor, constant: 12),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            controlContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            controlContainerView.heightAnchor.constraint(equalToConstant: 70),
            
            muteButton.leadingAnchor.constraint(equalTo: controlContainerView.leadingAnchor, constant: 60),
            muteButton.centerYAnchor.constraint(equalTo: controlContainerView.centerYAnchor),
            muteButton.widthAnchor.constraint(equalToConstant: 60),
            muteButton.heightAnchor.constraint(equalToConstant: 60),
            
            hangupButton.centerXAnchor.constraint(equalTo: controlContainerView.centerXAnchor),
            hangupButton.centerYAnchor.constraint(equalTo: controlContainerView.centerYAnchor),
            hangupButton.widthAnchor.constraint(equalToConstant: 70),
            hangupButton.heightAnchor.constraint(equalToConstant: 70),
            
            videoButton.trailingAnchor.constraint(equalTo: controlContainerView.trailingAnchor, constant: -60),
            videoButton.centerYAnchor.constraint(equalTo: controlContainerView.centerYAnchor),
            videoButton.widthAnchor.constraint(equalToConstant: 60),
            videoButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func startCountdown() {
        remainingSeconds = 20
        updateStatusLabel()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.updateStatusLabel()
            
            if self.remainingSeconds <= 0 {
                self.countdownTimer?.invalidate()
                self.countdownTimer = nil
                self.hangupCall()
            }
        }
    }
    
    private func updateStatusLabel() {
        statusLabel.text = "Calling...\(remainingSeconds)s"
    }
    
    @objc private func backButtonTapped() {
        hangupCall()
    }
    
    @objc private func hangupButtonTapped() {
        hangupCall()
    }
    
    @objc private func muteButtonTapped() {
        // 切换静音状态
        let isMuted = muteButton.backgroundColor == .gray
        muteButton.backgroundColor = isMuted ? .white : .gray
        muteButton.tintColor = isMuted ? .black : .white
    }
    
    @objc private func videoButtonTapped() {
        // 切换视频开关
        let isVideoOff = videoButton.backgroundColor == .gray
        videoButton.backgroundColor = isVideoOff ? .white : .gray
        videoButton.tintColor = isVideoOff ? .black : .white
    }
    
    private func hangupCall() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        dismiss(animated: true) {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        }
    }
}

