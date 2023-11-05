//
//  ViewController
//  dalvadordali
//
//  Created by Maksim Danko on 31.10.2023
//  
// 

import UIKit

final class ViewController: UIViewController {
    
    private struct Constant {
        let workspaceSoundAdjustmentsInsets = UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)
        let waveformInsets = UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16)
        let waveformHeight: CGFloat = 30
        let layersContainerInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private let audioRecorder = AudioRecorder()
    private let audioSampleManager = AudioSampleManager()
    private let audioLayersManager = AudioLayersManager()
    
    private let waveformView = WaveformView()
    private let toolSelectionView = ToolSelectionView()
    private let bottomToolbarView = BottomToolbarView()
    private let workspaceSoundAdjustmentsView = WorkspaceSoundAdjustmentsView()
    private let layersContainerView = LayersContainerView()
    
    private var isOpenLayersContainer = false
    
    private let constant = Constant()
    
    private var currentSample: SampleLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomToolbarView()
        setupLayersContainerView()
        
        view.backgroundColor = .black
        view.addSubview(workspaceSoundAdjustmentsView)
        view.addSubview(toolSelectionView)
        view.addSubview(waveformView)
        view.addSubview(bottomToolbarView)
        view.addSubview(layersContainerView)
        
        waveformView.backgroundColor = .black
        
        workspaceSoundAdjustmentsView.verticalValue = 1
        workspaceSoundAdjustmentsView.horizontalValue = 0
        
        audioLayersManager.onShareURL = { [weak self] url in
            let activityViewController = UIActivityViewController(activityItems: [url] , applicationActivities: nil)
            self?.present(activityViewController, animated: true)
        }
        
        workspaceSoundAdjustmentsView.onChangeVerticalControl = { [weak self] progress in
            guard let self = self, let currentSample = self.currentSample else { return }
            self.audioLayersManager.setVolume(Float(progress), for: currentSample)
        }
        
        workspaceSoundAdjustmentsView.onChangeHorizontalControl = { [weak self] progress in
            guard let self = self, let currentSample = self.currentSample else { return }
            currentSample.delay = progress
        }
        
        audioLayersManager.onChangeBufferPointer = { [weak self] pointer in
            self?.waveformView.setBufferSamples(pointer)
        }
        
        audioRecorder.onChangeRecordingTime = { [weak self] in
            guard let self = self else { return }
            waveformView.addSamples([self.audioRecorder.averagePower])
        }
        
        audioRecorder.didFinishRecording = { [weak self] isSuccessfully, url in
            guard let self = self else { return }
            if isSuccessfully, let url = url {
                let id = UUID().uuidString
                let sampleLayer = SampleLayer(id: id, sampleId: id, sampleURL: url, type: .microphone)
                self.audioLayersManager.addSample(sampleLayer, completion: { buffer in
                    self.waveformView.setBufferSamples(buffer)
                    self.layersContainerView.addSamples([sampleLayer])
                    self.workspaceSoundAdjustmentsView.horizontalValue = sampleLayer.delay
                    self.workspaceSoundAdjustmentsView.verticalValue = CGFloat(sampleLayer.volume)
                    self.currentSample = sampleLayer
                    self.animateLayout()
                })
            }
        }
        
        toolSelectionView.onPlayAndSelectedSample = { [weak self] sample in
            guard let self = self else { return }
            self.audioSampleManager.playSample(sample, isOnce: true) { [weak self] in
                guard let self = self else { return }
                if let url = Bundle.main.url(forResource: sample.id, withExtension: sample.extension) {
                    let sampleLayer = SampleLayer(id: UUID().uuidString, sampleId: sample.id, sampleURL: url, type: sample.type)
                    self.audioLayersManager.addSample(sampleLayer, completion: { buffer in
                        self.waveformView.setBufferSamples(buffer)
                        self.layersContainerView.addSamples([sampleLayer])
                        self.animateLayout()
                    })
                    self.workspaceSoundAdjustmentsView.horizontalValue = sampleLayer.delay
                    self.workspaceSoundAdjustmentsView.verticalValue = CGFloat(sampleLayer.volume)
                    self.currentSample = sampleLayer
                }
            }
        }
        
        toolSelectionView.onSelectSample = { [weak self] sample in
            guard let self = self else { return }
            self.audioSampleManager.playSample(sample)
        }
        
        toolSelectionView.onSelectedSample = { [weak self] sample in
            guard let self = self else { return }
            self.audioSampleManager.stop()
            if let sample = sample, let url = Bundle.main.url(forResource: sample.id, withExtension: sample.extension) {
                let sampleLayer = SampleLayer(id: UUID().uuidString, sampleId: sample.id, sampleURL: url, type: sample.type)
                self.audioLayersManager.addSample(sampleLayer, completion: { buffer in
                    self.waveformView.setBufferSamples(buffer)
                    self.layersContainerView.addSamples([sampleLayer])
                    self.animateLayout()
                })
                self.workspaceSoundAdjustmentsView.horizontalValue = sampleLayer.delay
                self.workspaceSoundAdjustmentsView.verticalValue = CGFloat(sampleLayer.volume)
                self.currentSample = sampleLayer
            }
        }
        
        bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomToolbarView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomToolbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbarView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    
    private func setupLayersContainerView() {
        layersContainerView.onSelectSampleLayer = { [weak self] sample in
            guard let self = self else { return }
            self.currentSample = sample
            if let samplesBuffer = self.audioLayersManager.samplesBuffer[sample.id] {
                self.waveformView.setBufferSamples(samplesBuffer)
            }
            self.workspaceSoundAdjustmentsView.horizontalValue = sample.delay
            self.workspaceSoundAdjustmentsView.verticalValue = CGFloat(sample.volume)
            self.isOpenLayersContainer = false
            self.animateLayout()
        }
        
        layersContainerView.onPlaybackSampleLayer = { [weak self] sample in
            guard let self = self else { return }
            guard !self.audioLayersManager.isRecordingAudio else { return }
            
            audioLayersManager.stopAudio()
            self.bottomToolbarView.setPlay(self.audioLayersManager.isPlayingAudio)
            
            if !sample.isMute {
                audioLayersManager.playSample(sample)
            }
            
            if sample.id == audioLayersManager.playingSampleId {
                layersContainerView.setPlaying(true, for: sample)
            } else {
                layersContainerView.setPlaying(false, for: sample)
            }
        }
        
        layersContainerView.onMuteSampleLayer = { [weak self] sample in
            guard let self = self else { return }
            let isMute = self.audioLayersManager.changeMuteSample(sample)
            if sample.isMute {
                if sample.id == self.audioLayersManager.playingSampleId {
                    self.audioLayersManager.playSample(sample)
                }
            }
            self.layersContainerView.setMute(isMute, for: sample)
        }
        
        layersContainerView.onRemoveSampleLayer = { [weak self] sample in
            guard let self = self else { return }
            self.audioLayersManager.removeSample(sampleId: sample.id)
        }
        
    }
    
    private func setupBottomToolbarView() {
        bottomToolbarView.onTapRecordButton = { [weak self] in
            guard let self = self else { return }
            guard !self.audioLayersManager.isPlayingAudio else { return }
            if self.audioLayersManager.isRecordingAudio {
                self.audioLayersManager.stopRecordAudio()
            } else {
                self.audioLayersManager.startRecordAudio()
            }
            self.bottomToolbarView.setRecording(self.audioLayersManager.isRecordingAudio)
        }
        
        bottomToolbarView.onTapPlaybackButton = { [weak self] in
            guard let self = self else { return }
            guard !self.audioLayersManager.isRecordingAudio else { return }
            if self.audioLayersManager.isPlayingAudio {
                self.audioLayersManager.stopAudio()
            } else {
                self.audioLayersManager.playAudio()
            }
            self.bottomToolbarView.setPlay(self.audioLayersManager.isPlayingAudio)
        }

        bottomToolbarView.onTapLayersButton = { [weak self] in
            guard let self = self else { return }
            self.isOpenLayersContainer = !isOpenLayersContainer
            self.bottomToolbarView.setState(isOpen: self.isOpenLayersContainer)
            self.animateLayout()
        }
        
        bottomToolbarView.onTapMicrophone = { [weak self] in
            guard let self = self else { return }
            guard !self.audioLayersManager.isPlayingAudio && !self.audioLayersManager.isRecordingAudio else { return }
            
            if self.audioRecorder.isRecording {
                self.audioRecorder.stopRecording()
                self.bottomToolbarView.stopRecording()
            } else {
                self.audioRecorder.startRecording(name: UUID().uuidString) { [weak self] isStart in
                    if isStart {
                        self?.bottomToolbarView.startRecording()
                    } else {
                        let alertController = UIAlertController (title: "Дайте доступ к микрофону, пожалуйста", message: "Открыть настройки?", preferredStyle: .alert)
                        let settingsAction = UIAlertAction(title: "Настройки", style: .default) { (_) -> Void in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: {_ in })
                            }
                        }
                        
                        alertController.addAction(settingsAction)
                        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        self?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func animateLayout() {
        UIView.animate(withDuration: 0.3) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let toolSelectionSize = toolSelectionView.sizeThatFits(view.bounds.size)
        toolSelectionView.frame = CGRect(x: 0,
                                         y: view.safeAreaInsets.top,
                                         width: toolSelectionSize.width,
                                         height: toolSelectionSize.height)
        
        
        let workspaceSoundAdjustmentsY = toolSelectionView.frame.maxY + constant.workspaceSoundAdjustmentsInsets.top
        let workspaceSoundAdjustmentsWidth = view.bounds.width - constant.workspaceSoundAdjustmentsInsets.left - constant.workspaceSoundAdjustmentsInsets.right
        workspaceSoundAdjustmentsView.frame = CGRect(x: constant.workspaceSoundAdjustmentsInsets.left,
                                                     y: workspaceSoundAdjustmentsY,
                                                     width: workspaceSoundAdjustmentsWidth,
                                                     height: view.bounds.height - toolSelectionView.frame.maxY - bottomToolbarView.frame.height - view.safeAreaInsets.bottom - constant.workspaceSoundAdjustmentsInsets.bottom - 24 - 44)
        
        let waveformViewX = constant.waveformInsets.left
        let waveformViewY = bottomToolbarView.frame.minY - constant.waveformInsets.bottom - constant.waveformHeight
        let waveformViewWidth = view.bounds.width - constant.waveformInsets.left - constant.waveformInsets.right
        
        
        waveformView.frame = CGRect(x: waveformViewX, y: waveformViewY, width: waveformViewWidth, height: constant.waveformHeight)
        
        
        let layersContainerWidth = view.bounds.width - constant.layersContainerInsets.left - constant.layersContainerInsets.right
        if isOpenLayersContainer {
            let layersContainerSize = layersContainerView.sizeThatFits(CGSize(width: layersContainerWidth,
                                                                              height: .greatestFiniteMagnitude))
                        
            layersContainerView.frame = CGRect(x: constant.layersContainerInsets.left,
                                               y: bottomToolbarView.frame.minY - layersContainerSize.height,
                                               width: layersContainerSize.width,
                                               height: layersContainerSize.height)
        } else {
            layersContainerView.frame = CGRect(x: constant.layersContainerInsets.left,
                                               y: bottomToolbarView.frame.minY,
                                               width: layersContainerWidth,
                                               height: 0)
        }
        
    }

}
