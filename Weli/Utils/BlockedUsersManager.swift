//
//  BlockedUsersManager.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import Foundation

class BlockedUsersManager {
    static let shared = BlockedUsersManager()
    
    private let blockedUsersKey = "BlockedUsers"
    
    private init() {}
    
    func blockUser(userId: String) {
        var blockedUsers = getBlockedUsers()
        if !blockedUsers.contains(userId) {
            blockedUsers.append(userId)
            saveBlockedUsers(blockedUsers)
        }
    }
    
    func unblockUser(userId: String) {
        var blockedUsers = getBlockedUsers()
        blockedUsers.removeAll { $0 == userId }
        saveBlockedUsers(blockedUsers)
    }
    
    func isUserBlocked(userId: String) -> Bool {
        return getBlockedUsers().contains(userId)
    }
    
    func getBlockedUsers() -> [String] {
        if let data = UserDefaults.standard.array(forKey: blockedUsersKey) as? [String] {
            return data
        }
        return []
    }
    
    private func saveBlockedUsers(_ users: [String]) {
        UserDefaults.standard.set(users, forKey: blockedUsersKey)
    }
}

