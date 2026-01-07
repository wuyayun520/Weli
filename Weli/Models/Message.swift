//
//  Message.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import Foundation
import UIKit

enum MessageType: String, Codable {
    case text
    case image
}

struct Message: Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let type: MessageType
    let content: String // 文本内容或图片路径
    let timestamp: TimeInterval
    
    init(id: String = UUID().uuidString, senderId: String, receiverId: String, type: MessageType, content: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.type = type
        self.content = content
        self.timestamp = timestamp
    }
}

