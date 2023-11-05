//
//  BottomToolbarView
//  dalvadordali
//
//  Created by Maksim Danko on 31.10.2023
//  
// 

import UIKit

final class BottomToolbarView: UIView {
    
    var onTapRecordButton: (() -> Void)?
    
    var onTapMicrophone: (() -> Void)?
    
    var onTapLayersButton: (() -> Void)?
    
    var onTapPlaybackButton: (() -> Void)?
    
    private struct Constant {
        let buttonSize = CGSize(width: 34, height: 34)
        let buttonCornerRadius: CGFloat = 4
        let spacing: CGFloat = 5
    }
    
    private let constant = Constant()
    
    private let layersButton = UIButton(type: .system)
    private let playbackButton = UIButton(type: .system)
    private let recordButton = UIButton(type: .system)
    private let microphoneButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40)
    }
    
    func setPlay(_ isPlaying: Bool) {
        if isPlaying {
            playbackButton.setImage(Images.pause, for: .normal)
        } else {
            playbackButton.setImage(Images.play, for: .normal)
        }
    }
 
    func setRecording(_ isRecording: Bool) {
        if isRecording {
            recordButton.setImage(Images.recordActive, for: .normal)
        } else {
            recordButton.setImage(Images.record, for: .normal)
        }
    }
    
    func setState(isOpen: Bool) {
        if isOpen {
            layersButton.configuration?.background.backgroundColor = Colors.inchworm
        } else {
            layersButton.configuration?.background.backgroundColor = .white
        }
    }
    
    func stopRecording() {
        microphoneButton.setImage(Images.microphone, for: .normal)
    }
    
    func startRecording() {
        microphoneButton.setImage(Images.microphone, for: .normal)
    }
    
    private func setupView() {
        backgroundColor = .black
        addSubview(layersButton)
        addSubview(playbackButton)
        addSubview(recordButton)
        addSubview(microphoneButton)
        
        subviews.forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = constant.buttonCornerRadius
        })
        
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .white
        config.imagePlacement = .trailing
        config.image = Images.arrow
        config.imagePadding = 5
        config.titleAlignment = .leading
        config.attributedTitle = AttributedString("Слои", attributes: AttributeContainer([.foregroundColor: UIColor.black,
                                                                                          .font: UIFont.systemFont(ofSize: 12, weight: .regular)]))
        
        layersButton.configuration = config
        layersButton.addTarget(self, action: #selector(tapLayersButton), for: .touchUpInside)
        
        playbackButton.backgroundColor = .white
        playbackButton.setImage(Images.play, for: .normal)
        playbackButton.addTarget(self, action: #selector(tapPlaybackButton), for: .touchUpInside)
        recordButton.backgroundColor = .white
        recordButton.setImage(Images.record, for: .normal)
        recordButton.addTarget(self, action: #selector(tapRecordButton), for: .touchUpInside)
        microphoneButton.backgroundColor = .white
        microphoneButton.setImage(Images.microphone, for: .normal)
        microphoneButton.addTarget(self, action: #selector(tapMicrophoneButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            layersButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            layersButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            layersButton.heightAnchor.constraint(equalToConstant: constant.buttonSize.height),
            
            playbackButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            playbackButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playbackButton.widthAnchor.constraint(equalToConstant: constant.buttonSize.width),
            playbackButton.heightAnchor.constraint(equalToConstant: constant.buttonSize.height),
            recordButton.rightAnchor.constraint(equalTo: playbackButton.leftAnchor, constant: -constant.spacing),
            recordButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: constant.buttonSize.width),
            recordButton.heightAnchor.constraint(equalToConstant: constant.buttonSize.height),
            microphoneButton.rightAnchor.constraint(equalTo: recordButton.leftAnchor, constant: -constant.spacing),
            microphoneButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            microphoneButton.widthAnchor.constraint(equalToConstant: constant.buttonSize.width),
            microphoneButton.heightAnchor.constraint(equalToConstant: constant.buttonSize.height),
        ])
    }
    
    @objc
    private func tapPlaybackButton() {
        onTapPlaybackButton?()
    }
    
    @objc
    private func tapRecordButton() {
        onTapRecordButton?()
    }
    
    @objc
    private func tapMicrophoneButton() {
        onTapMicrophone?()
    }
    
    @objc
    private func tapLayersButton() {
        onTapLayersButton?()
    }
    
}

