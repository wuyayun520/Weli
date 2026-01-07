//
//  RecordingViewController.swift
//  Weli
//
//  Created by Charlotte on 2026/1/6.
//

import UIKit
import AVFoundation

class RecordingViewController: BaseViewController {
    
    private let contentCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(hex: "#57C5FF").cgColor
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .top
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dialogueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
 
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Click to start recording"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let controlContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 30
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(hex: "#57C5FF")
        button.layer.cornerRadius = 35
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 30
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var isRecording = false
    private var recordedAudioURL: URL?
    private var currentPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackButton()
        loadRandomDialogue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMicrophonePermission()
    }
    
    deinit {
        audioRecorder?.stop()
        audioPlayer?.stop()
    }
    
    private func setupUI() {
        view.addSubview(contentCardView)
        view.addSubview(instructionLabel)
        view.addSubview(controlContainerView)
        
        contentCardView.addSubview(characterImageView)
        contentCardView.addSubview(dialogueLabel)
        
        controlContainerView.addSubview(cancelButton)
        controlContainerView.addSubview(recordButton)
        controlContainerView.addSubview(confirmButton)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            contentCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            contentCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentCardView.heightAnchor.constraint(equalToConstant: 400),
            
            characterImageView.topAnchor.constraint(equalTo: contentCardView.topAnchor),
            characterImageView.leadingAnchor.constraint(equalTo: contentCardView.leadingAnchor),
            characterImageView.trailingAnchor.constraint(equalTo: contentCardView.trailingAnchor),
            characterImageView.heightAnchor.constraint(equalToConstant: 280),
            
            dialogueLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 16),
            dialogueLabel.leadingAnchor.constraint(equalTo: contentCardView.leadingAnchor, constant: 20),
            dialogueLabel.trailingAnchor.constraint(equalTo: contentCardView.trailingAnchor, constant: -20),
            dialogueLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentCardView.bottomAnchor, constant: -16),
            
           
            instructionLabel.topAnchor.constraint(equalTo: contentCardView.bottomAnchor, constant: 40),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            controlContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            controlContainerView.heightAnchor.constraint(equalToConstant: 70),
            
            cancelButton.leadingAnchor.constraint(equalTo: controlContainerView.leadingAnchor, constant: 60),
            cancelButton.centerYAnchor.constraint(equalTo: controlContainerView.centerYAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            recordButton.centerXAnchor.constraint(equalTo: controlContainerView.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: controlContainerView.centerYAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            confirmButton.trailingAnchor.constraint(equalTo: controlContainerView.trailingAnchor, constant: -60),
            confirmButton.centerYAnchor.constraint(equalTo: controlContainerView.centerYAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 60),
            confirmButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func loadRandomDialogue() {
        guard let usersData = DataManager.shared.loadUsersData() else { return }
        
        // 随机选择一个用户
        guard let randomUser = usersData.users.randomElement(),
              !randomUser.posts.isEmpty else { return }
        
        // 随机选择一个作品
        guard let randomPost = randomUser.posts.randomElement() else { return }
        
        currentPost = randomPost
        
        // 加载封面图片
        let fullPath = "weliacg/\(randomPost.coverPath)"
        if let imagePath = Bundle.main.path(forResource: fullPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp") {
            characterImageView.image = UIImage(contentsOfFile: imagePath)
        } else if let imagePath = Bundle.main.path(forResource: randomPost.coverPath.replacingOccurrences(of: ".webp", with: ""), ofType: "webp", inDirectory: "weliacg") {
            characterImageView.image = UIImage(contentsOfFile: imagePath)
        }
        
        // 显示台词（使用 description 作为台词）
        dialogueLabel.text = randomPost.description
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            if !granted {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Microphone Permission", message: "Please enable microphone access in Settings to record audio.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func setupAudioRecorder() -> URL? {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording_\(timestamp).m4a")
        
        // 使用更标准的音频格式设置
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000
        ]
        
        do {
            // 确保目录存在
            let directory = audioFilename.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            
            // 如果文件已存在，先删除
            if FileManager.default.fileExists(atPath: audioFilename.path) {
                try FileManager.default.removeItem(at: audioFilename)
            }
            
            // 先配置音频会话
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
            
            // 创建录音器
            let recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder.delegate = self
            
            // 准备录音
            guard recorder.prepareToRecord() else {
                print("Failed to prepare recorder")
                try audioSession.setActive(false)
                return nil
            }
            
            audioRecorder = recorder
            return audioFilename
        } catch {
            print("Failed to setup audio recorder: \(error.localizedDescription)")
            // 确保在错误时停用音频会话
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc private func cancelButtonTapped() {
        // 停止当前录音（如果有）
        if isRecording {
            stopRecording()
        }
        
        // 停止当前播放（如果有）
        audioPlayer?.stop()
        audioPlayer = nil
        
        // 清理录音文件
        recordedAudioURL = nil
        
        // 重置UI状态
        recordButton.backgroundColor = UIColor(hex: "#57C5FF")
        instructionLabel.text = "Click to start recording"
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.5
        
        // 加载新的随机配音内容
        loadRandomDialogue()
    }
    
    @objc private func recordButtonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @objc private func confirmButtonTapped() {
        if let audioURL = recordedAudioURL {
            playRecording(url: audioURL)
        } else {
            // 如果没有录音，显示提示
            let alert = UIAlertController(title: "No Recording", message: "Please record audio first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func startRecording() {
        // 先请求麦克风权限
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard granted else {
                    let alert = UIAlertController(title: "Microphone Permission", message: "Please enable microphone access in Settings to record audio.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
                guard let audioURL = self.setupAudioRecorder() else {
                    let alert = UIAlertController(title: "Error", message: "Failed to setup audio recorder.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
                // 开始录音
                guard let recorder = self.audioRecorder, recorder.record() else {
                    print("Failed to start recording")
                    let alert = UIAlertController(title: "Error", message: "Failed to start recording.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    
                    // 清理
                    do {
                        try AVAudioSession.sharedInstance().setActive(false)
                    } catch {
                        print("Failed to deactivate audio session: \(error)")
                    }
                    return
                }
                
                self.isRecording = true
                self.recordedAudioURL = audioURL
                
                // 更新UI
                self.recordButton.backgroundColor = UIColor.red
                self.instructionLabel.text = "Recording..."
                self.confirmButton.isEnabled = false
                self.confirmButton.alpha = 0.5
            }
        }
    }
    
    private func stopRecording() {
        guard let recorder = audioRecorder else { return }
        
        recorder.stop()
        isRecording = false
        
        // 等待录音完全停止
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // 验证文件是否存在
            if let audioURL = self.recordedAudioURL,
               FileManager.default.fileExists(atPath: audioURL.path) {
                // 文件存在，更新UI
                self.recordButton.backgroundColor = UIColor(hex: "#57C5FF")
                self.instructionLabel.text = "Recording completed. Click ✓ to play."
                self.confirmButton.isEnabled = true
                self.confirmButton.alpha = 1.0
            } else {
                // 文件不存在，显示错误
                self.recordButton.backgroundColor = UIColor(hex: "#57C5FF")
                self.instructionLabel.text = "Recording failed. Please try again."
                self.confirmButton.isEnabled = false
                self.confirmButton.alpha = 0.5
                self.recordedAudioURL = nil
            }
            
            // 延迟停用音频会话，确保文件完全写入
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
        }
    }
    
    private func playRecording(url: URL) {
        // 停止当前播放
        audioPlayer?.stop()
        audioPlayer = nil
        
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: url.path) else {
            let alert = UIAlertController(title: "Error", message: "Recording file not found.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 检查文件大小
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int64,
              fileSize > 0 else {
            let alert = UIAlertController(title: "Error", message: "Recording file is empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
            
            // 创建新的播放器实例
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            
            // 验证播放器是否准备就绪
            guard player.prepareToPlay() else {
                throw NSError(domain: "AudioPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare audio player"])
            }
            
            audioPlayer = player
            guard player.play() else {
                throw NSError(domain: "AudioPlayer", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to start playback"])
            }
            
            instructionLabel.text = "Playing recording..."
            recordButton.isEnabled = false
            recordButton.alpha = 0.5
            confirmButton.isEnabled = false
            confirmButton.alpha = 0.5
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: "Failed to play recording: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
            instructionLabel.text = "Click to start recording"
            recordButton.isEnabled = true
            recordButton.alpha = 1.0
            confirmButton.isEnabled = true
            confirmButton.alpha = 1.0
        }
    }
}

extension RecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            if flag {
                print("Recording finished successfully")
                // 验证文件
                if let url = self?.recordedAudioURL,
                   FileManager.default.fileExists(atPath: url.path) {
                    print("Recording file exists at: \(url.path)")
                } else {
                    print("Warning: Recording file not found after recording")
                }
            } else {
                print("Recording failed")
                self?.recordedAudioURL = nil
            }
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio recorder encode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async { [weak self] in
            self?.recordedAudioURL = nil
            self?.isRecording = false
            self?.recordButton.backgroundColor = UIColor(hex: "#57C5FF")
            self?.instructionLabel.text = "Recording error. Please try again."
        }
    }
}

extension RecordingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.instructionLabel.text = "Click to start recording"
            self?.recordButton.isEnabled = true
            self?.recordButton.alpha = 1.0
            self?.confirmButton.isEnabled = true
            self?.confirmButton.alpha = 1.0
            self?.audioPlayer = nil
            
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async { [weak self] in
            self?.instructionLabel.text = "Playback error. Please try recording again."
            self?.recordButton.isEnabled = true
            self?.recordButton.alpha = 1.0
            self?.confirmButton.isEnabled = true
            self?.confirmButton.alpha = 1.0
            self?.audioPlayer = nil
            
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
        }
    }
}

