//
//  DataManager.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private var usersData: UsersData?
    
    private init() {}
    
    func loadUsersData() -> UsersData? {
        if let usersData = usersData {
            return usersData
        }
        
        var path: String?
        if let bundlePath = Bundle.main.path(forResource: "weliusersdata", ofType: "json", inDirectory: "weliacg") {
            path = bundlePath
        } else if let bundlePath = Bundle.main.path(forResource: "weliacg/weliusersdata", ofType: "json") {
            path = bundlePath
        }
        
        guard let filePath = path,
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let decoded = try? JSONDecoder().decode(UsersData.self, from: data) else {
            return nil
        }
        
        usersData = decoded
        return decoded
    }
    
    func getRandomUser() -> User? {
        guard let data = loadUsersData() else { return nil }
        return data.users.randomElement()
    }
    
    func getImagePath(for path: String) -> String? {
        guard let bundlePath = Bundle.main.path(forResource: path, ofType: nil) else {
            return nil
        }
        return bundlePath
    }
}

