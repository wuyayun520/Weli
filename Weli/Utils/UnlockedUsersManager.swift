//
//  UnlockedUsersManager.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import Foundation

class UnlockedUsersManager {
    static let shared = UnlockedUsersManager()
    
    private let userDefaults = UserDefaults.standard
    private let unlockedUsersKey = "unlockedUserIds"
    private let unlockCost = 12 // 解锁一个用户需要的金币数
    
    private init() {}
    
    func isUserUnlocked(userId: String) -> Bool {
        let unlockedIds = getUnlockedUserIds()
        return unlockedIds.contains(userId)
    }
    
    func unlockUser(userId: String) -> Bool {
        // 检查金币是否足够
        if #available(iOS 15.0, *) {
            guard WalletManager.shared.coins >= unlockCost else {
                return false
            }
            
            // 扣除金币
            WalletManager.shared.coins -= unlockCost
            
            // 标记用户为已解锁
            var unlockedIds = getUnlockedUserIds()
            if !unlockedIds.contains(userId) {
                unlockedIds.insert(userId)
                saveUnlockedUserIds(unlockedIds)
            }
            
            return true
        } else {
            return false
        }
    }
    
    func getUnlockCost() -> Int {
        return unlockCost
    }
    
    private func getUnlockedUserIds() -> Set<String> {
        if let data = userDefaults.data(forKey: unlockedUsersKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            return ids
        }
        return Set<String>()
    }
    
    private func saveUnlockedUserIds(_ ids: Set<String>) {
        if let data = try? JSONEncoder().encode(ids) {
            userDefaults.set(data, forKey: unlockedUsersKey)
        }
    }
}

