//
//  WalletViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit
import StoreKit

@available(iOS 15.0, *)
class WalletViewController: BaseViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let balanceCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor(hex: "#57C5FF").withAlphaComponent(0.4).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Balance"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coinsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 42)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coinsUnitLabel: UILabel = {
        let label = UILabel()
        label.text = "Coins"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coinIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weli_wallet_gold")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Amount"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 14
        layout.minimumLineSpacing = 14
        layout.sectionInset = UIEdgeInsets.zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let rechargeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Recharge Now", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 29
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hex: "#57C5FF").cgColor,
            UIColor(hex: "#57C5FF").withAlphaComponent(0.85).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 29
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(hex: "#57C5FF")
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var selectedProductIndex: Int = 0
    private var isLoading = true
    private var purchasePending = false
    private var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackButton()
        loadProducts()
        updateBalance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变层大小
        if let gradientLayer = rechargeButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = rechargeButton.bounds
        }
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(balanceCardView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(productsCollectionView)
        contentView.addSubview(rechargeButton)
        view.addSubview(loadingIndicator)
        
        balanceCardView.addSubview(balanceLabel)
        balanceCardView.addSubview(coinsLabel)
        balanceCardView.addSubview(coinsUnitLabel)
        balanceCardView.addSubview(coinIconImageView)
        
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        productsCollectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        
        rechargeButton.addTarget(self, action: #selector(rechargeButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            balanceCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            balanceCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            balanceCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            balanceCardView.heightAnchor.constraint(equalToConstant: 120),
            
            balanceLabel.topAnchor.constraint(equalTo: balanceCardView.topAnchor, constant: 20),
            balanceLabel.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 20),
            
            coinsLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 12),
            coinsLabel.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 20),
            
            coinsUnitLabel.leadingAnchor.constraint(equalTo: coinsLabel.trailingAnchor, constant: 8),
            coinsUnitLabel.bottomAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: -6),
            
            coinIconImageView.trailingAnchor.constraint(equalTo: balanceCardView.trailingAnchor, constant: -20),
            coinIconImageView.centerYAnchor.constraint(equalTo: balanceCardView.centerYAnchor),
            coinIconImageView.widthAnchor.constraint(equalToConstant: 80),
            coinIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: 36),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            productsCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            productsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            productsCollectionView.heightAnchor.constraint(equalToConstant: calculateCollectionViewHeight()),
            
            rechargeButton.topAnchor.constraint(equalTo: productsCollectionView.bottomAnchor, constant: 36),
            rechargeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rechargeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rechargeButton.heightAnchor.constraint(equalToConstant: 58),
            rechargeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateBalance() {
        let coins = WalletManager.shared.coins
        coinsLabel.text = "\(coins)"
    }
    
    private func loadProducts() {
        loadingIndicator.startAnimating()
        isLoading = true
        
        Task {
            do {
                let loadedProducts = try await WalletManager.shared.loadProducts()
                await MainActor.run {
                    self.products = loadedProducts
                    self.isLoading = false
                    self.loadingIndicator.stopAnimating()
                    self.productsCollectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.loadingIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Failed to load products: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func rechargeButtonTapped() {
        guard !purchasePending else { return }
        guard selectedProductIndex < WalletProduct.all.count else { return }
        
        let selectedProduct = WalletProduct.all[selectedProductIndex]
        guard let product = WalletManager.shared.getProduct(for: selectedProduct.productId) else {
            showAlert(title: "Error", message: "Product not available")
            return
        }
        
        purchasePending = true
        updateRechargeButton()
        
        Task {
            do {
                let success = try await WalletManager.shared.purchase(product)
                await MainActor.run {
                    self.purchasePending = false
                    self.updateRechargeButton()
                    
                    if success {
                        self.updateBalance()
                        self.showAlert(title: "Success", message: "Purchase successful! +\(selectedProduct.amount) Coins")
                    } else {
                        self.showAlert(title: "Cancelled", message: "Purchase was cancelled")
                    }
                }
            } catch {
                await MainActor.run {
                    self.purchasePending = false
                    self.updateRechargeButton()
                    self.showAlert(title: "Error", message: "Purchase failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateRechargeButton() {
        if purchasePending {
            rechargeButton.setTitle("", for: .normal)
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = .white
            indicator.startAnimating()
            rechargeButton.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: rechargeButton.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: rechargeButton.centerYAnchor)
            ])
        } else {
            rechargeButton.subviews.forEach { if $0 is UIActivityIndicatorView { $0.removeFromSuperview() } }
            rechargeButton.setTitle("Recharge Now", for: .normal)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func calculateCollectionViewHeight() -> CGFloat {
        let itemCount = WalletProduct.all.count
        let rows = (itemCount + 1) / 2 // 每行2个，向上取整
        let itemHeight: CGFloat = 120
        let spacing: CGFloat = 14
        return CGFloat(rows) * itemHeight + CGFloat(max(0, rows - 1)) * spacing
    }
}

@available(iOS 15.0, *)
extension WalletViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WalletProduct.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let walletProduct = WalletProduct.all[indexPath.item]
        let product = WalletManager.shared.getProduct(for: walletProduct.productId)
        let priceString = product?.displayPrice ?? String(format: "$%.2f", walletProduct.price)
        let isSelected = indexPath.item == selectedProductIndex
        
        cell.configure(
            amount: walletProduct.amount,
            price: priceString,
            isSelected: isSelected
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 14
        let totalWidth = collectionView.bounds.width
        let itemWidth = (totalWidth - spacing) / 2
        return CGSize(width: itemWidth, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !purchasePending else { return }
        
        selectedProductIndex = indexPath.item
        collectionView.reloadData()
    }
}

class ProductCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coinIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weli_wallet_gold")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkmarkView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#57C5FF")
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkmarkIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        containerView.addSubview(coinIconImageView)
        containerView.addSubview(amountLabel)
        containerView.addSubview(priceContainerView)
        containerView.addSubview(checkmarkView)
        
        priceContainerView.addSubview(priceLabel)
        checkmarkView.addSubview(checkmarkIcon)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            coinIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            coinIconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            coinIconImageView.widthAnchor.constraint(equalToConstant: 40),
            coinIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            priceContainerView.leadingAnchor.constraint(equalTo: coinIconImageView.trailingAnchor, constant: 8),
            priceContainerView.centerYAnchor.constraint(equalTo: coinIconImageView.centerYAnchor),
            priceContainerView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8),
            priceContainerView.heightAnchor.constraint(equalToConstant: 28),
            
            priceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: priceContainerView.trailingAnchor, constant: -10),
            priceLabel.topAnchor.constraint(equalTo: priceContainerView.topAnchor, constant: 6),
            priceLabel.bottomAnchor.constraint(equalTo: priceContainerView.bottomAnchor, constant: -6),
            
            amountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            amountLabel.topAnchor.constraint(equalTo: coinIconImageView.bottomAnchor, constant: 20),
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkView.leadingAnchor, constant: -8),
            amountLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            
            checkmarkView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            checkmarkView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24),
            
            checkmarkIcon.centerXAnchor.constraint(equalTo: checkmarkView.centerXAnchor),
            checkmarkIcon.centerYAnchor.constraint(equalTo: checkmarkView.centerYAnchor),
            checkmarkIcon.widthAnchor.constraint(equalToConstant: 14),
            checkmarkIcon.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configure(amount: Int, price: String, isSelected: Bool) {
        amountLabel.text = "\(amount) Coins"
        priceLabel.text = price
        
        if isSelected {
            containerView.backgroundColor = UIColor(hex: "#57C5FF").withAlphaComponent(0.35)
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor(hex: "#57C5FF").withAlphaComponent(0.8).cgColor
            checkmarkView.isHidden = false
        } else {
            containerView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
            checkmarkView.isHidden = true
        }
        
        // 价格容器渐变
        priceContainerView.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hex: "#57C5FF").withAlphaComponent(0.6).cgColor,
            UIColor(hex: "#57C5FF").withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.cornerRadius = 12
        priceContainerView.layer.insertSublayer(gradientLayer, at: 0)
        DispatchQueue.main.async {
            gradientLayer.frame = self.priceContainerView.bounds
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = priceContainerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = priceContainerView.bounds
        }
    }
}

