//
//  UserData.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import Foundation

struct UsersData: Codable {
    let users: [User]
    let metadata: Metadata
}

struct User: Codable {
    let userId: String
    let username: String
    let avatar: String
    let bio: String
    let followers: Int
    let following: Int
    let totalLikes: Int
    let location: String
    let posts: [Post]
}

struct Post: Codable {
    let postId: String
    let title: String
    let description: String
    let audioPath: String
    let coverPath: String
    let plays: Int
    let likes: Int
    let comments: Int
    let timestamp: String
}

struct Metadata: Codable {
    let totalUsers: Int
    let totalPosts: Int
    let generatedDate: String
    let version: String
    let description: String
}

