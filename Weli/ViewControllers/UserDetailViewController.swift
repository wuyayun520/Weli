//
//  UserDetailViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit
import AVFoundation

class UserDetailViewController: BaseViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainContentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let videoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_me_video"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_me_chat"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let blockedOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let blockedLabel: UILabel = {
        let label = UILabel()
        label.text = "This user has been blocked"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unblockButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Unblock", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = Theme.primaryColor
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let popularLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popularUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#57C5FF")
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let worksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var user: User?
    private var posts: [Post] = []
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private var currentPlayingIndex: Int?
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackButton()
        setupMoreButton()
        loadUserData()
    }
    
    private func setupMoreButton() {
        NSLayoutConstraint.activate([
            moreButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 44),
            moreButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(mainContentContainer)
        
        mainContentContainer.addSubview(userCardView)
        mainContentContainer.addSubview(popularLabel)
        mainContentContainer.addSubview(popularUnderlineView)
        mainContentContainer.addSubview(worksCollectionView)
        
        userCardView.addSubview(userAvatarImageView)
        userCardView.addSubview(usernameLabel)
        userCardView.addSubview(bioLabel)
        userCardView.addSubview(actionButtonsStackView)
        userCardView.addSubview(blockedOverlayView)
        
        blockedOverlayView.addSubview(blockedLabel)
        blockedOverlayView.addSubview(unblockButton)
        
        view.addSubview(moreButton)
        view.bringSubviewToFront(moreButton)
        
        actionButtonsStackView.addArrangedSubview(videoButton)
        actionButtonsStackView.addArrangedSubview(messageButton)
        
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        unblockButton.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
        
        worksCollectionView.delegate = self
        worksCollectionView.dataSource = self
        worksCollectionView.register(WorkCardCell.self, forCellWithReuseIdentifier: "WorkCardCell")
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainContentContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainContentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainContentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainContentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            userCardView.topAnchor.constraint(equalTo: mainContentContainer.topAnchor),
            userCardView.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor),
            userCardView.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor),
            userCardView.heightAnchor.constraint(equalToConstant: 320),
            
            userAvatarImageView.topAnchor.constraint(equalTo: userCardView.topAnchor),
            userAvatarImageView.leadingAnchor.constraint(equalTo: userCardView.leadingAnchor),
            userAvatarImageView.trailingAnchor.constraint(equalTo: userCardView.trailingAnchor),
            userAvatarImageView.heightAnchor.constraint(equalTo: userCardView.heightAnchor, multiplier: 0.7),
            
            actionButtonsStackView.topAnchor.constraint(equalTo: userCardView.topAnchor, constant: 16),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: userCardView.trailingAnchor, constant: -16),
            
            videoButton.widthAnchor.constraint(equalToConstant: 40),
            videoButton.heightAnchor.constraint(equalToConstant: 40),
            messageButton.widthAnchor.constraint(equalToConstant: 40),
            messageButton.heightAnchor.constraint(equalToConstant: 40),
            
            blockedOverlayView.topAnchor.constraint(equalTo: userCardView.topAnchor),
            blockedOverlayView.leadingAnchor.constraint(equalTo: userCardView.leadingAnchor),
            blockedOverlayView.trailingAnchor.constraint(equalTo: userCardView.trailingAnchor),
            blockedOverlayView.bottomAnchor.constraint(equalTo: userCardView.bottomAnchor),
            
            blockedLabel.centerXAnchor.constraint(equalTo: blockedOverlayView.centerXAnchor),
            blockedLabel.centerYAnchor.constraint(equalTo: blockedOverlayView.centerYAnchor, constant: -20),
            
            unblockButton.topAnchor.constraint(equalTo: blockedLabel.bottomAnchor, constant: 20),
            unblockButton.centerXAnchor.constraint(equalTo: blockedOverlayView.centerXAnchor),
            unblockButton.widthAnchor.constraint(equalToConstant: 120),
            unblockButton.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.topAnchor.constraint(equalTo: userAvatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: userCardView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButtonsStackView.leadingAnchor, constant: -8),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: userCardView.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: userCardView.trailingAnchor, constant: -16),
            bioLabel.bottomAnchor.constraint(lessThanOrEqualTo: userCardView.bottomAnchor, constant: -16),
            
            popularLabel.topAnchor.constraint(equalTo: userCardView.bottomAnchor, constant: 24),
            popularLabel.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor),
            
            popularUnderlineView.topAnchor.constraint(equalTo: popularLabel.bottomAnchor, constant: 4),
            popularUnderlineView.leadingAnchor.constraint(equalTo: popularLabel.leadingAnchor),
            popularUnderlineView.widthAnchor.constraint(equalToConstant: 60),
            popularUnderlineView.heightAnchor.constraint(equalToConstant: 3),
            
            worksCollectionView.topAnchor.constraint(equalTo: popularUnderlineView.bottomAnchor, constant: 16),
            worksCollectionView.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor),
            worksCollectionView.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor),
            worksCollectionView.heightAnchor.constraint(equalToConstant: 600),
            worksCollectionView.bottomAnchor.constraint(equalTo: mainContentContainer.bottomAnchor)
        ])
    }
    
    private func loadUserData() {
        guard let user = user else { return }
        
        usernameLabel.text = "@\(user.username)"
        bioLabel.text = user.bio
        
        // 加载用户头像
        let fullPath = "weliacg/\(user.avatar)"
        if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
            userAvatarImageView.image = UIImage(contentsOfFile: imagePath)
        } else if let imagePath = Bundle.main.path(forResource: user.avatar.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
            userAvatarImageView.image = UIImage(contentsOfFile: imagePath)
        }
        
        // 加载用户作品
        posts = user.posts
        worksCollectionView.reloadData()
        
        // 检查用户是否被拉黑
        checkBlockedStatus()
    }
    
    private func checkBlockedStatus() {
        guard let user = user else { return }
        let isBlocked = BlockedUsersManager.shared.isUserBlocked(userId: user.userId)
        blockedOverlayView.isHidden = !isBlocked
        
        if isBlocked {
            // 隐藏用户信息
            userAvatarImageView.isHidden = true
            usernameLabel.isHidden = true
            bioLabel.isHidden = true
            actionButtonsStackView.isHidden = true
            worksCollectionView.isHidden = true
            popularLabel.isHidden = true
            popularUnderlineView.isHidden = true
        } else {
            userAvatarImageView.isHidden = false
            usernameLabel.isHidden = false
            bioLabel.isHidden = false
            actionButtonsStackView.isHidden = false
            worksCollectionView.isHidden = false
            popularLabel.isHidden = false
            popularUnderlineView.isHidden = false
        }
    }
    
    @objc private func moreButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let blockAction = UIAlertAction(title: "Block User", style: .destructive) { [weak self] _ in
            self?.blockUser()
        }
        
        let reportAction = UIAlertAction(title: "Report User", style: .default) { [weak self] _ in
            self?.reportUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(blockAction)
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.sourceView = moreButton
            popover.sourceRect = moreButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func blockUser() {
        guard let user = user else { return }
        
        BlockedUsersManager.shared.blockUser(userId: user.userId)
        
        let alert = UIAlertController(title: "User Blocked", message: "This user has been blocked. Their content will be hidden.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.checkBlockedStatus()
        })
        present(alert, animated: true)
    }
    
    private func reportUser() {
        guard let user = user else { return }
        
        let alert = UIAlertController(title: "Report User", message: "Report @\(user.username) for inappropriate content?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
            // 这里可以添加举报逻辑，比如发送到服务器
            let successAlert = UIAlertController(title: "Report Submitted", message: "Thank you for your report. We will review it shortly.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func unblockButtonTapped() {
        guard let user = user else { return }
        
        BlockedUsersManager.shared.unblockUser(userId: user.userId)
        checkBlockedStatus()
    }
    
    @objc private func messageButtonTapped() {
        guard let user = user else { return }
        let chatVC = ChatViewController(user: user)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func videoButtonTapped() {
        guard let user = user else { return }
        let videoCallVC = VideoCallViewController(user: user)
        videoCallVC.modalPresentationStyle = .fullScreen
        present(videoCallVC, animated: true)
    }
}

extension UserDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkCardCell", for: indexPath) as! WorkCardCell
        if indexPath.item < posts.count {
            cell.configure(with: posts[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 24) / 3 // 3列布局，减去间距
        return CGSize(width: width, height: width * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < posts.count else { return }
        
        let selectedPost = posts[indexPath.item]
        
        // 如果点击的是当前正在播放的作品，则暂停/继续
        if currentPlayingIndex == indexPath.item && isPlaying {
            audioPlayer?.pause()
            isPlaying = false
            updatePlayButtonState(for: indexPath.item, isPlaying: false)
            currentPlayingIndex = nil
        } else {
            // 停止当前播放
            if let currentIndex = currentPlayingIndex {
                updatePlayButtonState(for: currentIndex, isPlaying: false)
            }
            audioPlayer?.stop()
            audioPlayer = nil
            
            // 播放新选中的作品
            currentPlayingIndex = indexPath.item
            loadAudio(from: selectedPost.audioPath)
            updatePlayButtonState(for: indexPath.item, isPlaying: true)
        }
    }
    
    private func loadAudio(from path: String) {
        // 停止当前播放
        audioPlayer?.stop()
        audioPlayer = nil
        
        // 构建音频文件路径
        let fullPath = "weliacg/\(path)"
        var audioURL: URL?
        
        // 尝试多种路径方式
        if let audioPath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".mp3", with: ""), ofType: "mp3") {
            audioURL = URL(fileURLWithPath: audioPath)
        } else if let audioPath = Bundle.main.path(forResource: path.replacingOccurrences(of: ".mp3", with: ""), ofType: "mp3", inDirectory: "weliacg") {
            audioURL = URL(fileURLWithPath: audioPath)
        } else {
            // 尝试直接使用完整路径
            let components = path.components(separatedBy: "/")
            if components.count >= 2 {
                let directory = components[0]
                let filename = components[1].replacingOccurrences(of: ".mp3", with: "")
                if let audioPath = Bundle.main.path(forResource: filename, ofType: "mp3", inDirectory: "weliacg/\(directory)") {
                    audioURL = URL(fileURLWithPath: audioPath)
                }
            }
        }
        
        guard let url = audioURL else {
            print("Failed to find audio file: \(path)")
            return
        }
        
        do {
            // 配置音频会话
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 创建音频播放器
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            
            // 开始播放
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to load audio: \(error.localizedDescription)")
        }
    }
    
    private func updatePlayButtonState(for index: Int, isPlaying: Bool) {
        if let cell = worksCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? WorkCardCell {
            cell.updatePlayButtonState(isPlaying: isPlaying)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止播放
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentPlayingIndex = nil
    }
}

extension UserDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = currentPlayingIndex {
            updatePlayButtonState(for: index, isPlaying: false)
        }
        isPlaying = false
        audioPlayer = nil
        currentPlayingIndex = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        if let index = currentPlayingIndex {
            updatePlayButtonState(for: index, isPlaying: false)
        }
        isPlaying = false
        audioPlayer = nil
        currentPlayingIndex = nil
    }
}

