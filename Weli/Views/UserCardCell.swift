//
//  UserCardCell.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit

class UserCardCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
  
    
    private let onlineBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let onlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Online"
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let onlineContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_community_chat"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc var chatButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(onlineContainer)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(tagLabel)
        containerView.addSubview(actionButton)
        
        onlineContainer.addSubview(onlineBadge)
        onlineContainer.addSubview(onlineLabel)
        
        actionButton.addTarget(self, action: #selector(chatBtnTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            avatarImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7),
            
            onlineContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            onlineContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            onlineContainer.heightAnchor.constraint(equalToConstant: 20),
            
            onlineBadge.leadingAnchor.constraint(equalTo: onlineContainer.leadingAnchor, constant: 6),
            onlineBadge.centerYAnchor.constraint(equalTo: onlineContainer.centerYAnchor),
            onlineBadge.widthAnchor.constraint(equalToConstant: 8),
            onlineBadge.heightAnchor.constraint(equalToConstant: 8),
            
            onlineLabel.leadingAnchor.constraint(equalTo: onlineBadge.trailingAnchor, constant: 4),
            onlineLabel.trailingAnchor.constraint(equalTo: onlineContainer.trailingAnchor, constant: -6),
            onlineLabel.centerYAnchor.constraint(equalTo: onlineContainer.centerYAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),
            
            tagLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tagLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),
            tagLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),
            
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 40),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with user: User) {
        usernameLabel.text = "@\(user.username)"
        tagLabel.text = user.bio.components(separatedBy: "|").first?.trimmingCharacters(in: .whitespaces) ?? user.bio
        
        // 加载头像
        let fullPath = "weliacg/\(user.avatar)"
        if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
            avatarImageView.image = UIImage(contentsOfFile: imagePath)
        } else if let imagePath = Bundle.main.path(forResource: user.avatar.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
            avatarImageView.image = UIImage(contentsOfFile: imagePath)
        }
    }
    
    @objc private func chatBtnTapped() {
        chatButtonTapped?()
    }
}

