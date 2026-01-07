//
//  CommunityViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit

class CommunityViewController: BaseViewController {
    
    private let bannerView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weli_community_banner")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private let tabContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let popularButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Popular", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let newButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("New", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#57C5FF")
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var underlineLeadingConstraint: NSLayoutConstraint?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var popularUsers: [User] = []
    private var newUsers: [User] = []
    private var currentUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupUI()
        loadUsers()
    }
    
    private var underlineWidthConstraint: NSLayoutConstraint?
    
    private func setupUI() {
        view.addSubview(bannerView)
        view.addSubview(tabContainer)
        view.addSubview(collectionView)
        
        tabContainer.addSubview(popularButton)
        tabContainer.addSubview(newButton)
        tabContainer.addSubview(underlineView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserCardCell.self, forCellWithReuseIdentifier: "UserCardCell")
        
        popularButton.addTarget(self, action: #selector(popularButtonTapped), for: .touchUpInside)
        newButton.addTarget(self, action: #selector(newButtonTapped), for: .touchUpInside)
        
        // 给 banner 添加点击手势
        bannerView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bannerTapped))
        bannerView.addGestureRecognizer(tapGesture)
        
        let underlineLeading = underlineView.leadingAnchor.constraint(equalTo: popularButton.leadingAnchor)
        let underlineWidth = underlineView.widthAnchor.constraint(equalTo: popularButton.widthAnchor)
        underlineLeadingConstraint = underlineLeading
        underlineWidthConstraint = underlineWidth
        
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bannerView.heightAnchor.constraint(equalToConstant: 124),
            
            tabContainer.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 24),
            tabContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tabContainer.heightAnchor.constraint(equalToConstant: 40),
            
            popularButton.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            popularButton.centerYAnchor.constraint(equalTo: tabContainer.centerYAnchor),
            popularButton.heightAnchor.constraint(equalToConstant: 30),
            
            newButton.leadingAnchor.constraint(equalTo: popularButton.trailingAnchor, constant: 32),
            newButton.centerYAnchor.constraint(equalTo: tabContainer.centerYAnchor),
            newButton.heightAnchor.constraint(equalToConstant: 30),
            
            underlineView.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: -4),
            underlineLeading,
            underlineWidth,
            underlineView.heightAnchor.constraint(equalToConstant: 3),
            
            collectionView.topAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadUsers() {
        guard let usersData = DataManager.shared.loadUsersData() else { return }
        
        // 过滤掉被拉黑的用户
        let blockedUserIds = Set(BlockedUsersManager.shared.getBlockedUsers())
        let filteredUsers = usersData.users.filter { !blockedUserIds.contains($0.userId) }
        
        let allUsers = filteredUsers
        popularUsers = Array(allUsers.prefix(10))
        newUsers = Array(allUsers.suffix(10))
        
        currentUsers = popularUsers
        
        collectionView.reloadData()
    }
    
    @objc private func popularButtonTapped() {
        selectTab(isPopular: true)
        currentUsers = popularUsers
        collectionView.reloadData()
    }
    
    @objc private func newButtonTapped() {
        selectTab(isPopular: false)
        currentUsers = newUsers
        collectionView.reloadData()
    }
    
    private func selectTab(isPopular: Bool) {
        UIView.animate(withDuration: 0.3) {
            if isPopular {
                self.popularButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                self.popularButton.setTitleColor(.white, for: .normal)
                self.newButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                self.newButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
                
                self.underlineLeadingConstraint?.isActive = false
                self.underlineWidthConstraint?.isActive = false
                self.underlineLeadingConstraint = self.underlineView.leadingAnchor.constraint(equalTo: self.popularButton.leadingAnchor)
                self.underlineWidthConstraint = self.underlineView.widthAnchor.constraint(equalTo: self.popularButton.widthAnchor)
                self.underlineLeadingConstraint?.isActive = true
                self.underlineWidthConstraint?.isActive = true
            } else {
                self.newButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                self.newButton.setTitleColor(.white, for: .normal)
                self.popularButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                self.popularButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
                
                self.underlineLeadingConstraint?.isActive = false
                self.underlineWidthConstraint?.isActive = false
                self.underlineLeadingConstraint = self.underlineView.leadingAnchor.constraint(equalTo: self.newButton.leadingAnchor)
                self.underlineWidthConstraint = self.underlineView.widthAnchor.constraint(equalTo: self.newButton.widthAnchor)
                self.underlineLeadingConstraint?.isActive = true
                self.underlineWidthConstraint?.isActive = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func bannerTapped() {
        // 获取所有未被拉黑的用户
        guard let usersData = DataManager.shared.loadUsersData() else { return }
        let blockedUserIds = Set(BlockedUsersManager.shared.getBlockedUsers())
        let availableUsers = usersData.users.filter { !blockedUserIds.contains($0.userId) }
        
        // 随机选择一个用户
        guard let randomUser = availableUsers.randomElement() else { return }
        
        // 检查用户是否已解锁
        if UnlockedUsersManager.shared.isUserUnlocked(userId: randomUser.userId) {
            // 已解锁，直接跳转
            let detailVC = UserDetailViewController(user: randomUser)
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            // 未解锁，检查金币
            let unlockCost = UnlockedUsersManager.shared.getUnlockCost()
            var currentCoins = 0
            if #available(iOS 15.0, *) {
                currentCoins = WalletManager.shared.coins
            }
            
            if currentCoins >= unlockCost {
                // 金币足够，解锁并跳转
                if UnlockedUsersManager.shared.unlockUser(userId: randomUser.userId) {
                    let detailVC = UserDetailViewController(user: randomUser)
                    navigationController?.pushViewController(detailVC, animated: true)
                }
            } else {
                // 金币不足，提示并跳转到充值页面
                showInsufficientCoinsAlert(unlockCost: unlockCost, currentCoins: currentCoins)
            }
        }
    }
}

extension CommunityViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCardCell", for: indexPath) as! UserCardCell
        if indexPath.item < currentUsers.count {
            let user = currentUsers[indexPath.item]
            cell.configure(with: user)
            
            // 设置聊天按钮点击回调
            cell.chatButtonTapped = { [weak self] in
                let chatVC = ChatViewController(user: user)
                self?.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 44) / 2 // 减去左右边距和间距
        return CGSize(width: width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < currentUsers.count else { return }
        
        let selectedUser = currentUsers[indexPath.item]
        
        // 检查用户是否已解锁
        if UnlockedUsersManager.shared.isUserUnlocked(userId: selectedUser.userId) {
            // 已解锁，直接跳转
            let detailVC = UserDetailViewController(user: selectedUser)
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            // 未解锁，检查金币
            let unlockCost = UnlockedUsersManager.shared.getUnlockCost()
            var currentCoins = 0
            if #available(iOS 15.0, *) {
                currentCoins = WalletManager.shared.coins
            }
            
            if currentCoins >= unlockCost {
                // 金币足够，解锁并跳转
                if UnlockedUsersManager.shared.unlockUser(userId: selectedUser.userId) {
                    let detailVC = UserDetailViewController(user: selectedUser)
                    navigationController?.pushViewController(detailVC, animated: true)
                }
            } else {
                // 金币不足，提示并跳转到充值页面
                showInsufficientCoinsAlert(unlockCost: unlockCost, currentCoins: currentCoins)
            }
        }
    }
    
    private func showInsufficientCoinsAlert(unlockCost: Int, currentCoins: Int) {
        let alert = UIAlertController(
            title: "Insufficient Coins",
            message: "You need \(unlockCost) coins to unlock this user. You currently have \(currentCoins) coins.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Recharge", style: .default) { [weak self] _ in
            // 跳转到钱包页面
            if #available(iOS 15.0, *) {
                let walletVC = WalletViewController()
                self?.navigationController?.pushViewController(walletVC, animated: true)
            }
        })
        
        present(alert, animated: true)
    }
}

