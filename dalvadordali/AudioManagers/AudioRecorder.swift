//
//  AudioRecorder
//  dalvadordali
//
//  Created by Maksim Danko on 05.11.2023
//  
// 

import Foundation
import AVFoundation

final class AudioRecorder: NSObject {
    
    var onChangeRecordingTime: (() -> Void)?
    
    var didFinishRecording: ((Bool, URL?) -> Void)?
    
    private var recorder: AVAudioRecorder?
    
    private var timer: Timer?
    
    private let session = AVAudioSession.sharedInstance()
    
    lazy var documentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func startRecording(name: String, completion: @escaping (Bool) -> Void) {
        do {
            let url = documentDirectory.appendingPathComponent("\(name).m4a")
            
            self.recordingURL = url
            
            try session.setCategory(.record)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            
            session.requestRecordPermission { [weak self] isGranted in
                guard let self = self else { return }
                self.recorder?.prepareToRecord()
                if isGranted {
                    self.start()
                }
                DispatchQueue.main.async {
                    completion(isGranted)
                }
            }
        } catch {
            
        }
    }
    
    @discardableResult
    func start() -> Bool {
        guard let recorder = recorder, !recorder.isRecording else { return false }
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)
        recordingTime = 0
        let isRecording = recorder.record()
        if isRecording {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
        }
        return isRecording
    }
    
    func stopRecording() {
        guard let recorder = recorder, recorder.isRecording else { return }
        recorder.stop()
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false)
        timer?.invalidate()
    }
    
    private(set) var recordingURL: URL?
    
    private(set) var recordingTime: TimeInterval = 0
    
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    var averagePower: Float {
        return recorder?.averagePower(forChannel: 0) ?? 0
    }
    
    var peakPower: Float {
        return recorder?.peakPower(forChannel: 0) ?? 0
    }
    
    @objc
    private func handleTimer() {
        recordingTime = recorder?.currentTime ?? 0
        recorder?.updateMeters()
        onChangeRecordingTime?()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        timer?.invalidate()
        didFinishRecording?(flag, recordingURL)
    }
    
}
