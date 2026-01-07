//
//  WorkCardCell.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit

class WorkCardCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.secondaryBackgroundColor
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "weli_home_record_pause"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            playButton.widthAnchor.constraint(equalToConstant: 52),
            playButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with post: Post) {
        let fullPath = "weliacg/\(post.coverPath)"
        if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
            imageView.image = UIImage(contentsOfFile: imagePath)
        } else if let imagePath = Bundle.main.path(forResource: post.coverPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
            imageView.image = UIImage(contentsOfFile: imagePath)
        }
        // 重置按钮状态
        playButton.setImage(UIImage(named: "weli_home_record_pause"), for: .normal)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        if isPlaying {
            playButton.setImage(UIImage(named: "weli_home_record_play"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "weli_home_record_pause"), for: .normal)
        }
    }
}

