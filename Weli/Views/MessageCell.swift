//
//  MessageCell.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit

class MessageCell: UITableViewCell {
    
    static let identifier = "MessageCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    private var messageLabelBottomConstraint: NSLayoutConstraint?
    private var messageImageViewBottomConstraint: NSLayoutConstraint?
    
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
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(timeLabel)
        
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        // 设置最大宽度，但允许根据内容自适应
        let widthConstraint = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 280)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleLeadingConstraint,
            bubbleTrailingConstraint,
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            widthConstraint,
            
            // 文本消息约束
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            // 图片消息约束
            messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // 时间标签约束
            timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            timeLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with message: Message, isFromCurrentUser: Bool) {
        let date = Date(timeIntervalSince1970: message.timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: date)
        
        // 调整气泡样式和位置
        if isFromCurrentUser {
            bubbleView.backgroundColor = Theme.primaryColor
            messageLabel.textColor = .white
            bubbleLeadingConstraint.isActive = false
            bubbleTrailingConstraint.isActive = true
            bubbleTrailingConstraint.constant = -16
        } else {
            bubbleView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            messageLabel.textColor = .white
            bubbleTrailingConstraint.isActive = false
            bubbleLeadingConstraint.isActive = true
            bubbleLeadingConstraint.constant = 16
        }
        
        // 先移除之前的约束
        messageLabelBottomConstraint?.isActive = false
        messageImageViewBottomConstraint?.isActive = false
        
        if message.type == .text {
            messageLabel.isHidden = false
            messageImageView.isHidden = true
            
            // 添加文本的 bottom 约束
            messageLabelBottomConstraint = messageLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -4)
            messageLabelBottomConstraint?.isActive = true
            
            messageLabel.text = message.content
            // 让标签根据文字内容自动调整大小
            messageLabel.preferredMaxLayoutWidth = 256 // 280 - 12*2 (左右padding)
        } else {
            messageLabel.isHidden = true
            messageImageView.isHidden = false
            
            // 添加图片的 bottom 约束
            messageImageViewBottomConstraint = messageImageView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -4)
            messageImageViewBottomConstraint?.isActive = true
            
            if let image = ChatManager.shared.loadImage(from: message.content) {
                messageImageView.image = image
            }
        }
        
        // 强制更新布局，让气泡框根据文字内容自适应
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
    }
}
