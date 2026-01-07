//
//  ChatManager.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import Foundation
import UIKit

class ChatManager {
    static let shared = ChatManager()
    
    private let messagesKeyPrefix = "ChatMessages_"
    private let imagesDirectory = "ChatImages"
    
    private init() {
        createImagesDirectoryIfNeeded()
    }
    
    private func createImagesDirectoryIfNeeded() {
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imagesPath = documentsPath.appendingPathComponent(imagesDirectory)
            if !fileManager.fileExists(atPath: imagesPath.path) {
                try? fileManager.createDirectory(at: imagesPath, withIntermediateDirectories: true)
            }
        }
    }
    
    private func chatKey(userId1: String, userId2: String) -> String {
        let sortedIds = [userId1, userId2].sorted()
        return "\(sortedIds[0])_\(sortedIds[1])"
    }
    
    func saveMessage(_ message: Message, between userId1: String, and userId2: String) {
        var messages = getMessages(between: userId1, and: userId2)
        messages.append(message)
        saveMessages(messages, between: userId1, and: userId2)
    }
    
    func getMessages(between userId1: String, and userId2: String) -> [Message] {
        let key = messagesKeyPrefix + chatKey(userId1: userId1, userId2: userId2)
        guard let data = UserDefaults.standard.data(forKey: key),
              let messages = try? JSONDecoder().decode([Message].self, from: data) else {
            return []
        }
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func saveMessages(_ messages: [Message], between userId1: String, and userId2: String) {
        let key = messagesKeyPrefix + chatKey(userId1: userId1, userId2: userId2)
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func saveImage(_ image: UIImage, for messageId: String) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let imagesPath = documentsPath.appendingPathComponent(imagesDirectory)
        let imageFileName = "\(messageId).jpg"
        let imagePath = imagesPath.appendingPathComponent(imageFileName)
        
        do {
            try imageData.write(to: imagePath)
            // 只返回图片名称，不返回完整路径
            return imageFileName
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    func loadImage(from imageName: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 每次读取时动态拼接沙盒路径+图片名称
        let imagesPath = documentsPath.appendingPathComponent(imagesDirectory)
        let imagePath = imagesPath.appendingPathComponent(imageName)
        
        return UIImage(contentsOfFile: imagePath.path)
    }
    
    func deleteImage(at imageName: String) {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        // 动态拼接沙盒路径+图片名称
        let imagesPath = documentsPath.appendingPathComponent(imagesDirectory)
        let imagePath = imagesPath.appendingPathComponent(imageName)
        
        try? fileManager.removeItem(atPath: imagePath.path)
    }
}

