//
//  WalletManager.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import Foundation
import StoreKit

struct WalletProduct {
    let amount: Int
    let productId: String
    let price: Double
    
    static let all: [WalletProduct] = [
        WalletProduct(amount: 32, productId: "Weli", price: 0.99),
        WalletProduct(amount: 60, productId: "Weli1", price: 1.99),
        WalletProduct(amount: 96, productId: "Weli2", price: 2.99),
        WalletProduct(amount: 155, productId: "Weli4", price: 4.99),
        WalletProduct(amount: 189, productId: "Weli5", price: 5.99),
        WalletProduct(amount: 359, productId: "Weli9", price: 9.99),
        WalletProduct(amount: 729, productId: "Weli19", price: 19.99),
        WalletProduct(amount: 1869, productId: "Weli49", price: 49.99),
        WalletProduct(amount: 3799, productId: "Weli99", price: 99.99),
    ]
}

@available(iOS 15.0, *)
class WalletManager: NSObject {
    static let shared = WalletManager()
    
    private let userDefaults = UserDefaults.standard
    private let coinsKey = "weliCoins"
    
    private var products: [Product] = []
    private var purchasedTransactionIDs: Set<String> = []
    
    var coins: Int {
        get {
            return userDefaults.integer(forKey: coinsKey)
        }
        set {
            userDefaults.set(newValue, forKey: coinsKey)
        }
    }
    
    private override init() {
        super.init()
        loadPurchasedTransactions()
    }
    
    private func loadPurchasedTransactions() {
        if let data = userDefaults.data(forKey: "purchasedTransactionIDs"),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            purchasedTransactionIDs = ids
        }
    }
    
    private func savePurchasedTransactions() {
        if let data = try? JSONEncoder().encode(purchasedTransactionIDs) {
            userDefaults.set(data, forKey: "purchasedTransactionIDs")
        }
    }
    
    func loadProducts() async throws -> [Product] {
        let productIds = WalletProduct.all.map { $0.productId }
        
        do {
            let storeProducts = try await Product.products(for: productIds)
            await MainActor.run {
                self.products = storeProducts
            }
            return storeProducts
        } catch {
            print("Failed to load products: \(error)")
            throw error
        }
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerificationResult(verification)
                await transaction.finish()
                
                // 找到对应的产品配置
                if let walletProduct = WalletProduct.all.first(where: { $0.productId == product.id }) {
                    let transactionKey = "\(transaction.id)_\(product.id)"
                    
                    // 检查是否已经处理过
                    if !purchasedTransactionIDs.contains(transactionKey) {
                        purchasedTransactionIDs.insert(transactionKey)
                        savePurchasedTransactions()
                        
                        // 添加金币
                        await MainActor.run {
                            self.coins += walletProduct.amount
                        }
                        
                        return true
                    }
                }
                return false
                
            case .userCancelled:
                return false
                
            case .pending:
                return false
                
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            throw error
        }
    }
    
    private func checkVerificationResult<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    func getProduct(for productId: String) -> Product? {
        return products.first { $0.id == productId }
    }
    
    func getWalletProduct(for productId: String) -> WalletProduct? {
        return WalletProduct.all.first { $0.productId == productId }
    }
}

