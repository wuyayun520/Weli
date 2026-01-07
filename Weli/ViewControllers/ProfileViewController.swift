//
//  ProfileViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit
import PhotosUI

class ProfileViewController: BaseViewController {
    
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
    
    private let profileCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil.circle.fill")
        imageView.tintColor = UIColor.white.withAlphaComponent(0.6)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let walletButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_me_wallet"), for: .normal)
//        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let menuItems: [(icon: String, title: String)] = [
        ("doc.text", "User Contract"),
        ("lock", "Privacy Policy"),
        ("person", "About us")
    ]
    
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackButton()
        loadUserProfile()
    }
    
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileCardView)
        contentView.addSubview(walletButton)
        contentView.addSubview(menuTableView)
        
        profileCardView.addSubview(mainAvatarImageView)
        profileCardView.addSubview(usernameLabel)
        profileCardView.addSubview(bioLabel)
        profileCardView.addSubview(editIconImageView)
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.register(MenuItemCell.self, forCellReuseIdentifier: "MenuItemCell")
        
        if #available(iOS 15.0, *) {
            walletButton.addTarget(self, action: #selector(walletButtonTapped), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        
        // 添加点击手势
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        mainAvatarImageView.addGestureRecognizer(avatarTap)
        
        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        usernameLabel.addGestureRecognizer(usernameTap)
        
        let bioTap = UITapGestureRecognizer(target: self, action: #selector(bioTapped))
        bioLabel.addGestureRecognizer(bioTap)
        
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
            
            profileCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileCardView.heightAnchor.constraint(equalToConstant: 280),
            
            mainAvatarImageView.topAnchor.constraint(equalTo: profileCardView.topAnchor),
            mainAvatarImageView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor),
            mainAvatarImageView.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor),
            mainAvatarImageView.heightAnchor.constraint(equalToConstant: 200),
            
            usernameLabel.topAnchor.constraint(equalTo: mainAvatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editIconImageView.leadingAnchor, constant: -8),
            
            editIconImageView.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -16),
            editIconImageView.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            editIconImageView.widthAnchor.constraint(equalToConstant: 24),
            editIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -16),
            bioLabel.bottomAnchor.constraint(lessThanOrEqualTo: profileCardView.bottomAnchor, constant: -16),
            
            walletButton.topAnchor.constraint(equalTo: profileCardView.bottomAnchor, constant: 24),
            walletButton.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -8),
            walletButton.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 8),
            walletButton.heightAnchor.constraint(equalToConstant: 66),
            
            menuTableView.topAnchor.constraint(equalTo: walletButton.bottomAnchor, constant: 24),
            menuTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            menuTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            menuTableView.heightAnchor.constraint(equalToConstant: CGFloat(4 * 60)),
            menuTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadUserProfile() {
        // 优先加载本地保存的数据
        if let savedUsername = ProfileManager.shared.getUsername() {
            usernameLabel.text = savedUsername.hasPrefix("@") ? savedUsername : "@\(savedUsername)"
        } else {
            // 如果没有保存的数据，随机选择一个用户作为默认值
            guard let usersData = DataManager.shared.loadUsersData(),
                  let randomUser = usersData.users.randomElement() else { return }
            
            currentUser = randomUser
            let defaultUsername = "@\(randomUser.username)"
            usernameLabel.text = defaultUsername
            ProfileManager.shared.saveUsername(defaultUsername)
        }
        
        if let savedBio = ProfileManager.shared.getBio() {
            bioLabel.text = savedBio
        } else {
            // 如果没有保存的数据，使用随机用户的bio
            if currentUser == nil {
                guard let usersData = DataManager.shared.loadUsersData(),
                      let randomUser = usersData.users.randomElement() else { return }
                currentUser = randomUser
            }
            if let user = currentUser {
                bioLabel.text = user.bio
                ProfileManager.shared.saveBio(user.bio)
            }
        }
        
        // 加载头像（优先加载本地保存的）
        if let savedAvatar = ProfileManager.shared.loadAvatarImage() {
            mainAvatarImageView.image = savedAvatar
        } else {
            // 如果没有保存的头像，加载随机用户的头像
            if currentUser == nil {
                guard let usersData = DataManager.shared.loadUsersData(),
                      let randomUser = usersData.users.randomElement() else { return }
                currentUser = randomUser
            }
            if let user = currentUser {
                let fullPath = "weliacg/\(user.avatar)"
                if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
                    mainAvatarImageView.image = UIImage(contentsOfFile: imagePath)
                } else if let imagePath = Bundle.main.path(forResource: user.avatar.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
                    mainAvatarImageView.image = UIImage(contentsOfFile: imagePath)
                }
            }
        }
    }
    
    @available(iOS 15.0, *)
    @objc private func walletButtonTapped() {
        let walletVC = WalletViewController()
        navigationController?.pushViewController(walletVC, animated: true)
    }
    
    @objc private func avatarTapped() {
        let alert = UIAlertController(title: "Change Avatar", message: "Choose an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose from Photo Library", style: .default) { [weak self] _ in
            self?.presentImagePicker()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.sourceView = mainAvatarImageView
            popover.sourceRect = mainAvatarImageView.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func usernameTapped() {
        let alert = UIAlertController(title: "Edit Username", message: nil, preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Enter username"
            if let currentText = self?.usernameLabel.text {
                textField.text = currentText.hasPrefix("@") ? String(currentText.dropFirst()) : currentText
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let newUsername = textField.text?.trimmingCharacters(in: .whitespaces),
                  !newUsername.isEmpty else { return }
            
            let formattedUsername = newUsername.hasPrefix("@") ? newUsername : "@\(newUsername)"
            self?.usernameLabel.text = formattedUsername
            ProfileManager.shared.saveUsername(formattedUsername)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func bioTapped() {
        let alert = UIAlertController(title: "Edit Bio", message: nil, preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Enter bio"
            textField.text = self?.bioLabel.text
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let newBio = textField.text?.trimmingCharacters(in: .whitespaces) else { return }
            
            self?.bioLabel.text = newBio.isEmpty ? "No bio yet" : newBio
            ProfileManager.shared.saveBio(newBio)
        })
        
        present(alert, animated: true)
    }
    
    private func presentImagePicker() {
        if #available(iOS 14.0, *) {
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 1
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
}

extension ProfileViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.mainAvatarImageView.image = image
                _ = ProfileManager.shared.saveAvatarImage(image)
            }
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        if let image = image {
            mainAvatarImageView.image = image
            _ = ProfileManager.shared.saveAvatarImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        let item = menuItems[indexPath.row]
        cell.configure(icon: item.icon, title: item.title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = menuItems[indexPath.row]
        
        switch item.title {
        case "User Contract":
            let termsVC = TermsOfServiceViewController()
            navigationController?.pushViewController(termsVC, animated: true)
        case "Privacy Policy":
            let privacyVC = PrivacyPolicyViewController()
            navigationController?.pushViewController(privacyVC, animated: true)
        case "About us":
            let aboutUsVC = AboutUsViewController()
            navigationController?.pushViewController(aboutUsVC, animated: true)
        case "Black list":
            showBlacklist()
        default:
            break
        }
    }
    
    private func showBlacklist() {
        let blockedUserIds = BlockedUsersManager.shared.getBlockedUsers()
        guard let usersData = DataManager.shared.loadUsersData() else { return }
        
        let blockedUserObjects = usersData.users.filter { blockedUserIds.contains($0.userId) }
        
        if blockedUserObjects.isEmpty {
            let alert = UIAlertController(title: "Black list", message: "No blocked users", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Black list", message: "\(blockedUserObjects.count) user(s) blocked", preferredStyle: .actionSheet)
        
        for user in blockedUserObjects.prefix(10) {
            alert.addAction(UIAlertAction(title: "@\(user.username) - Unblock", style: .default) { _ in
                BlockedUsersManager.shared.unblockUser(userId: user.userId)
                // 刷新页面
                self.loadUserProfile()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}

class MenuItemCell: UITableViewCell {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(icon: String, title: String) {
        iconImageView.image = UIImage(systemName: icon)
        
        // 根据不同的菜单项设置不同的图标颜色
        switch title {
        case "User Contract":
            iconImageView.tintColor = UIColor.systemOrange
        case "Privacy Policy":
            iconImageView.tintColor = UIColor(hex: "#57C5FF")
        case "About us":
            iconImageView.tintColor = UIColor.systemPurple
        case "Black list":
            iconImageView.tintColor = UIColor.systemPurple
        default:
            iconImageView.tintColor = .white
        }
        
        titleLabel.text = title
    }
}

