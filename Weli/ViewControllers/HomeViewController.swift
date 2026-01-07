//
//  HomeViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    private var currentUser: User?
    private var currentPost: Post?
    private var otherPosts: [Post] = []
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_home_pause"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func updatePlayButtonState() {
        if isPlaying {
            playButton.setImage(UIImage(named: "weli_home_play"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "weli_home_pause"), for: .normal)
        }
    }
    
    private let actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_community_nor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let micButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_record_nor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_me_nor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userInfoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let worksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRandomUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.backgroundColor
        
        view.addSubview(backgroundImageView)
        view.addSubview(playButton)
        view.addSubview(actionButtonsStackView)
        view.addSubview(userInfoContainer)
        view.addSubview(worksCollectionView)
        
        actionButtonsStackView.addArrangedSubview(likeButton)
        actionButtonsStackView.addArrangedSubview(micButton)
        actionButtonsStackView.addArrangedSubview(downloadButton)
        
        micButton.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        userInfoContainer.addSubview(avatarImageView)
        userInfoContainer.addSubview(usernameLabel)
        userInfoContainer.addSubview(descriptionLabel)
        
        worksCollectionView.delegate = self
        worksCollectionView.dataSource = self
        worksCollectionView.register(WorkCardCell.self, forCellWithReuseIdentifier: "WorkCardCell")
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 52),
            playButton.heightAnchor.constraint(equalToConstant: 52),
            
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButtonsStackView.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor, constant: -100),
            actionButtonsStackView.widthAnchor.constraint(equalToConstant: 68),
            actionButtonsStackView.heightAnchor.constraint(equalToConstant: 220),
            
            likeButton.widthAnchor.constraint(equalToConstant: 68),
            likeButton.heightAnchor.constraint(equalToConstant: 68),
            micButton.widthAnchor.constraint(equalToConstant: 68),
            micButton.heightAnchor.constraint(equalToConstant: 68),
            downloadButton.widthAnchor.constraint(equalToConstant: 68),
            downloadButton.heightAnchor.constraint(equalToConstant: 68),
            
            userInfoContainer.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 80),
            userInfoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userInfoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            avatarImageView.leadingAnchor.constraint(equalTo: userInfoContainer.leadingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: userInfoContainer.topAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            usernameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: userInfoContainer.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: userInfoContainer.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: userInfoContainer.bottomAnchor),
            
            worksCollectionView.topAnchor.constraint(equalTo: userInfoContainer.bottomAnchor, constant: 20),
            worksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            worksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            worksCollectionView.heightAnchor.constraint(equalToConstant: 160),
            worksCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(communityButtonTapped), for: .touchUpInside)
    }
    
    @objc private func communityButtonTapped() {
        let communityVC = CommunityViewController()
        navigationController?.pushViewController(communityVC, animated: true)
    }
    
    private func loadRandomUser() {
        // 停止当前播放
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        updatePlayButtonState()
        
        // 获取未被拉黑的随机用户
        guard let usersData = DataManager.shared.loadUsersData() else { return }
        let blockedUserIds = Set(BlockedUsersManager.shared.getBlockedUsers())
        let availableUsers = usersData.users.filter { !blockedUserIds.contains($0.userId) }
        guard let user = availableUsers.randomElement() else { return }
        
        currentUser = user
        
        if let firstPost = user.posts.first {
            currentPost = firstPost
            otherPosts = Array(user.posts.dropFirst())
            
            loadBackgroundImage(from: firstPost.coverPath)
            loadAvatar(from: user.avatar)
            usernameLabel.text = user.username
            descriptionLabel.text = firstPost.description
        }
        
        worksCollectionView.reloadData()
    }
    
    private func loadBackgroundImage(from path: String) {
        let fullPath = "weliacg/\(path)"
        if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
            backgroundImageView.image = UIImage(contentsOfFile: imagePath)
        } else if let imagePath = Bundle.main.path(forResource: path.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
            backgroundImageView.image = UIImage(contentsOfFile: imagePath)
        }
    }
    
    private func loadAvatar(from path: String) {
        let fullPath = "weliacg/\(path)"
        if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
            avatarImageView.image = UIImage(contentsOfFile: imagePath)
        } else if let imagePath = Bundle.main.path(forResource: path.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
            avatarImageView.image = UIImage(contentsOfFile: imagePath)
        }
    }
    
    @objc private func playButtonTapped() {
        guard let post = currentPost else { return }
        
        if isPlaying {
            // 暂停播放
            audioPlayer?.pause()
            isPlaying = false
            updatePlayButtonState()
        } else {
            // 开始播放
            if audioPlayer == nil {
                // 加载新的音频文件
                loadAudio(from: post.audioPath)
            }
            
            if let player = audioPlayer {
                if player.isPlaying {
                    player.pause()
                    isPlaying = false
                } else {
                    player.play()
                    isPlaying = true
                }
                updatePlayButtonState()
            }
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
            updatePlayButtonState()
        } catch {
            print("Failed to load audio: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止播放
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(otherPosts.count, 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkCardCell", for: indexPath) as! WorkCardCell
        if indexPath.item < otherPosts.count {
            let post = otherPosts[indexPath.item]
            cell.configure(with: post)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < otherPosts.count else { return }
        
        // 获取选中的 post
        let selectedPost = otherPosts[indexPath.item]
        
        // 停止当前播放
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        updatePlayButtonState()
        
        // 将当前 post 移到 otherPosts 列表末尾
        if let currentPost = currentPost {
            otherPosts.append(currentPost)
        }
        
        // 从 otherPosts 中移除选中的 post
        otherPosts.remove(at: indexPath.item)
        
        // 更新当前 post
        currentPost = selectedPost
        
        // 更新 UI
        loadBackgroundImage(from: selectedPost.coverPath)
        descriptionLabel.text = selectedPost.description
        
        // 刷新列表
        worksCollectionView.reloadData()
    }
}

extension HomeViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        updatePlayButtonState()
        audioPlayer = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        isPlaying = false
        updatePlayButtonState()
        audioPlayer = nil
    }
    
    @objc private func micButtonTapped() {
        let recordingVC = RecordingViewController()
        navigationController?.pushViewController(recordingVC, animated: true)
    }
    
    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
