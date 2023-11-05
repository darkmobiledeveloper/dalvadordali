//
//  LayerRowView
//  dalvadordali
//
//  Created by Maksim Danko on 31.10.2023
//  
// 

import UIKit

final class LayerRowView: UIView {
        
    var onTap: ((LayerRowView) -> Void)?
    
    var onTapPlaybackButton: ((LayerRowView) -> Void)?
    
    var onTapMuteButton: ((LayerRowView) -> Void)?
    
    var onTapRemoveButton: ((LayerRowView) -> Void)?
    
    var sample: SampleLayer? {
        didSet {
            guard let sample = sample else { return }
            titleLabel.text = sample.name
            setMute(sample.isMute)
            setPlayback(sample.isPlayback)
            setNeedsLayout()
        }
    }
    
    private struct Constant {
        let height: CGFloat = 40
        let cornerRadius: CGFloat = 4
        let titleLabelInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let removeButtonInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let removeButtonCornerRadius: CGFloat = 4
        let buttonRightInset: CGFloat = 12
        let muteButtonSize = CGSize(width: 18, height: 18)
        let playbackButtonWidth: CGFloat = 16
    }
    
    private let titleLabel = UILabel()
    private let playbackButton = UIButton(type: .system)
    private let muteButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)
    
    private let constant = Constant()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: constant.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
        roundCorners()
    }
    
    func setMute(_ isMute: Bool) {
        if isMute {
            backgroundColor = .white
            muteButton.setImage(Images.mute, for: .normal)
        } else {
            backgroundColor = Colors.inchworm
            muteButton.setImage(Images.unmute, for: .normal)
        }
    }
    
    func setPlayback(_ isPlayback: Bool) {
        if isPlayback {
            playbackButton.setImage(Images.pause, for: .normal)
        } else {
            playbackButton.setImage(Images.play, for: .normal)
        }
    }
    
    
    private func setupView() {
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(playbackButton)
        addSubview(muteButton)
        addSubview(removeButton)
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .black
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        
        removeButton.backgroundColor = Colors.mercury
        removeButton.setImage(Images.cross, for: .normal)
        removeButton.addTarget(self, action: #selector(tapRemoveButton), for: .touchUpInside)
        
        muteButton.setImage(Images.unmute, for: .normal)
        muteButton.addTarget(self, action: #selector(tapMuteButton), for: .touchUpInside)
        
        playbackButton.addTarget(self, action: #selector(tapPlaybackButton), for: .touchUpInside)
    }
    
    private func layout() {
        guard let sample = sample else { return }
        let titleSize = sample.name.size(font: .systemFont(ofSize: 12, weight: .regular))
        let titleY = (bounds.height - titleSize.height) / 2
        titleLabel.frame = CGRect(x: constant.titleLabelInsets.left, y: titleY, width: titleSize.width, height: titleSize.height)
        
        
        let removeButtonSide = bounds.height - constant.removeButtonInsets.top - constant.removeButtonInsets.bottom
        removeButton.frame = CGRect(x: bounds.width - constant.removeButtonInsets.right - removeButtonSide,
                                    y: constant.removeButtonInsets.top,
                                    width: removeButtonSide,
                                    height: removeButtonSide)
        let muteButtonX = removeButton.frame.minX - constant.buttonRightInset - constant.muteButtonSize.width
        muteButton.frame = CGRect(x: muteButtonX, y: 0, width: constant.muteButtonSize.width, height: bounds.height)
        
        let playbackButtonX = muteButton.frame.minX - constant.buttonRightInset - constant.playbackButtonWidth
        playbackButton.frame = CGRect(x: playbackButtonX, y: 0, width: constant.playbackButtonWidth, height: bounds.height)
        
    }
    
    private func roundCorners() {
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: constant.cornerRadius).cgPath
        layer.mask = mask
        
        let removeButtonMask = CAShapeLayer()
        removeButtonMask.path = UIBezierPath(roundedRect: removeButton.bounds, cornerRadius: constant.removeButtonCornerRadius).cgPath
        removeButton.layer.mask = removeButtonMask
    }
    
    @objc
    private func tapRemoveButton() {
        onTapRemoveButton?(self)
    }
        
    @objc
    private func tapMuteButton() {
        onTapMuteButton?(self)
    }
    
    @objc
    private func tapPlaybackButton() {
        onTapPlaybackButton?(self)
    }
    
    @objc
    private func tap() {
        onTap?(self)
    }
    
}
