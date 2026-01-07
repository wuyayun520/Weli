//
//  ProfileManager.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit

class ProfileManager {
    static let shared = ProfileManager()
    
    private let userDefaults = UserDefaults.standard
    private let usernameKey = "profile_username"
    private let bioKey = "profile_bio"
    private let avatarKey = "profile_avatar_filename"
    
    private init() {}
    
    // MARK: - Username
    func getUsername() -> String? {
        return userDefaults.string(forKey: usernameKey)
    }
    
    func saveUsername(_ username: String) {
        userDefaults.set(username, forKey: usernameKey)
    }
    
    // MARK: - Bio
    func getBio() -> String? {
        return userDefaults.string(forKey: bioKey)
    }
    
    func saveBio(_ bio: String) {
        userDefaults.set(bio, forKey: bioKey)
    }
    
    // MARK: - Avatar
    func getAvatarFilename() -> String? {
        return userDefaults.string(forKey: avatarKey)
    }
    
    func saveAvatarFilename(_ filename: String) {
        userDefaults.set(filename, forKey: avatarKey)
    }
    
    func getAvatarPath() -> String? {
        guard let filename = getAvatarFilename() else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(filename).path
    }
    
    func saveAvatarImage(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = "profile_avatar_\(UUID().uuidString).jpg"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: filePath)
            saveAvatarFilename(filename)
            return filePath.path
        } catch {
            print("Failed to save avatar: \(error)")
            return nil
        }
    }
    
    func loadAvatarImage() -> UIImage? {
        guard let path = getAvatarPath(),
              FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    func deleteAvatar() {
        if let path = getAvatarPath(), FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
        userDefaults.removeObject(forKey: avatarKey)
    }
}

