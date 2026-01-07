//
//  LoginViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weli_loginbg")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    
    private let enterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enter Weli", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#4177FF").cgColor,
            UIColor(hex: "#00E5FF").cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.cornerRadius = 25
        return layer
    }()
    
    private let termsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let agreementCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.cornerRadius = 10
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let privacyLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy Policy"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var agreementAccepted = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        updateAgreementCheckbox()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if gradientLayer.superlayer == nil {
            enterButton.layer.insertSublayer(gradientLayer, at: 0)
        }
        gradientLayer.frame = enterButton.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(enterButton)
        contentView.addSubview(termsContainerView)
        
        termsContainerView.addSubview(agreementCheckbox)
        termsContainerView.addSubview(termsLabel)
        termsContainerView.addSubview(privacyLabel)
        
        setupAgreementText()
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
          
            enterButton.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -240),
            enterButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            enterButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            enterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            enterButton.heightAnchor.constraint(equalToConstant: 50),
            
            termsContainerView.topAnchor.constraint(equalTo: enterButton.bottomAnchor, constant: 40),
            termsContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            termsContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            termsContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            termsContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
        
        setupTermsContainer()
    }
    
    private func setupAgreementText() {
        let fullText = "I have read and agree Terms of Service and"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: fullText.count))
        
        if let termsRange = fullText.range(of: "Terms of Service") {
            let nsRange = NSRange(termsRange, in: fullText)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }
        
        termsLabel.attributedText = attributedString
        
        let privacyText = "Privacy Policy"
        let privacyAttributedString = NSMutableAttributedString(string: privacyText)
        privacyAttributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: privacyText.count))
        privacyAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: privacyText.count))
        
        privacyLabel.attributedText = privacyAttributedString
    }
    
    private func setupTermsContainer() {
        NSLayoutConstraint.activate([
            agreementCheckbox.topAnchor.constraint(equalTo: termsContainerView.topAnchor),
            agreementCheckbox.leadingAnchor.constraint(equalTo: termsContainerView.leadingAnchor),
            agreementCheckbox.widthAnchor.constraint(equalToConstant: 20),
            agreementCheckbox.heightAnchor.constraint(equalToConstant: 20),
            
            termsLabel.topAnchor.constraint(equalTo: termsContainerView.topAnchor),
            termsLabel.leadingAnchor.constraint(equalTo: agreementCheckbox.trailingAnchor, constant: 8),
            termsLabel.trailingAnchor.constraint(equalTo: termsContainerView.trailingAnchor),
            
            privacyLabel.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 4),
            privacyLabel.leadingAnchor.constraint(equalTo: agreementCheckbox.trailingAnchor, constant: 8),
            privacyLabel.trailingAnchor.constraint(equalTo: termsContainerView.trailingAnchor),
            privacyLabel.bottomAnchor.constraint(equalTo: termsContainerView.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        enterButton.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        agreementCheckbox.addTarget(self, action: #selector(agreementCheckboxTapped), for: .touchUpInside)
        
        let termsTapGesture = UITapGestureRecognizer(target: self, action: #selector(termsLabelTapped))
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(termsTapGesture)
        
        let privacyTapGesture = UITapGestureRecognizer(target: self, action: #selector(privacyLabelTapped))
        privacyLabel.isUserInteractionEnabled = true
        privacyLabel.addGestureRecognizer(privacyTapGesture)
        
        let containerTapGesture = UITapGestureRecognizer(target: self, action: #selector(agreementCheckboxTapped))
        termsContainerView.isUserInteractionEnabled = true
        termsContainerView.addGestureRecognizer(containerTapGesture)
    }
    
    private func getTermsOfServiceRange(in text: String) -> NSRange? {
        if let range = text.range(of: "Terms of Service") {
            return NSRange(range, in: text)
        }
        return nil
    }
    
    private func handleTermsLabelTap(at point: CGPoint) {
        guard let attributedText = termsLabel.attributedText else { return }
        let text = attributedText.string
        
        if let termsRange = getTermsOfServiceRange(in: text) {
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: termsLabel.bounds.size)
            let textStorage = NSTextStorage(attributedString: attributedText)
            
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = termsLabel.numberOfLines
            textContainer.lineBreakMode = termsLabel.lineBreakMode
            
            let location = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            if location >= termsRange.location && location < termsRange.location + termsRange.length {
                showTermsOfService()
                return
            }
        }
        
        agreementCheckboxTapped()
    }
    
    @objc private func enterButtonTapped() {
        guard agreementAccepted else {
            showAlert(message: "Please accept Terms of Service and Privacy Policy")
            return
        }
        
        let homeViewController = HomeViewController()
        if let windowScene = view.window?.windowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = homeViewController
            window.makeKeyAndVisible()
            if let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window = window
            }
        }
    }
    
    @objc private func agreementCheckboxTapped() {
        agreementAccepted.toggle()
        updateAgreementCheckbox()
    }
    
    @objc private func termsLabelTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: termsLabel)
        handleTermsLabelTap(at: location)
    }
    
    @objc private func privacyLabelTapped() {
        showPrivacyPolicy()
    }
    
    private func showTermsOfService() {
        let termsVC = TermsOfServiceViewController()
        let navController = UINavigationController(rootViewController: termsVC)
        present(navController, animated: true)
    }
    
    private func showPrivacyPolicy() {
        let privacyVC = PrivacyPolicyViewController()
        let navController = UINavigationController(rootViewController: privacyVC)
        present(navController, animated: true)
    }
    
    private func updateAgreementCheckbox() {
        if agreementAccepted {
            agreementCheckbox.backgroundColor = Theme.primaryColor
            agreementCheckbox.setImage(UIImage(systemName: "checkmark"), for: .normal)
            agreementCheckbox.tintColor = .white
            agreementCheckbox.layer.borderColor = Theme.primaryColor.cgColor
        } else {
            agreementCheckbox.backgroundColor = .clear
            agreementCheckbox.setImage(nil, for: .normal)
            agreementCheckbox.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

