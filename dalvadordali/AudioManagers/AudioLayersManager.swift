//
//  AudioLayersManager
//  dalvadordali
//
//  Created by Maksim Danko on 05.11.2023
//  
// 

import Foundation
import AVFoundation

final class AudioLayersManager: NSObject {
    
    var onChangeBufferPointer: ((UnsafeBufferPointer<Float>) -> Void)?
    
    var onShareURL: ((URL) -> Void)?
    
    private var pianoCount: Int = 0
    private var gitarCount: Int = 0
    private var drumCount: Int = 0
    private var microphoneCount: Int = 0
    
    private(set) var isPlayingAudio = false
    private(set) var isRecordingAudio = false
    
    private(set) var samples: [SampleLayer] = []
    private(set) var samplesFlie: [String: AVAudioFile] = [:]
    private(set) var samplesPCMBuffer: [String: AVAudioPCMBuffer] = [:]
    private(set) var samplesBuffer: [String: UnsafeBufferPointer<Float>] = [:]
    private(set) var samplesPlayerNode: [String: AVAudioPlayerNode] = [:]
    private(set) var samplesPlayback: [String: Bool] = [:]
    
    private(set) var playingSampleId: String?
    
    private let engine = AVAudioEngine()
    
    func addSample(_ sample: SampleLayer, completion: @escaping (UnsafeBufferPointer<Float>) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            do {
                let file = try AVAudioFile(forReading: sample.sampleURL)
                let processingFormat = file.processingFormat
                let frameCount = AVAudioFrameCount(file.length)
                
                switch sample.type {
                case .piano:
                    sample.name = "Пианино \(pianoCount)"
                    pianoCount += 1
                case .gitar:
                    sample.name = "Гитара \(gitarCount)"
                    gitarCount += 1
                case .drum:
                    sample.name = "Ударные \(drumCount)"
                    drumCount += 1
                case .microphone:
                    sample.name = "Микрофон \(microphoneCount)"
                    microphoneCount += 1
                }
                
                if let pcmBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: frameCount) {
                    try file.read(into: pcmBuffer)
                    let buffer = UnsafeBufferPointer(start: pcmBuffer.floatChannelData![0], count: Int(pcmBuffer.frameLength))
                    
                    self.samplesPCMBuffer[sample.id] = pcmBuffer
                    self.samplesBuffer[sample.id] = buffer
                    self.samplesPlayback[sample.id] = false
                    
                    let playerNode = AVAudioPlayerNode()
                    samplesFlie[sample.id] = file
                    samplesPlayerNode[sample.id] = playerNode
                    samples.append(sample)
                    
                    engine.attach(playerNode)
                    engine.connect(playerNode, to: engine.mainMixerNode, format: file.processingFormat)
                    
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                    try? AVAudioSession.sharedInstance().setActive(true)
                    
                    engine.prepare()
                    
                    DispatchQueue.main.async {
                        completion(buffer)
                    }
                }
            } catch {
                
            }
        }
    }
    
    func playSample(_ sample: SampleLayer) {
        if let playingSampleId = playingSampleId,
           let node = samplesPlayerNode[playingSampleId] {
            samplesPlayback[playingSampleId] = false
            node.stop()
            
            if sample.id == playingSampleId {
                self.playingSampleId = nil
                return
            }
        }
        
        guard let buffer = samplesPCMBuffer[sample.id], let node = samplesPlayerNode[sample.id] else { return }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? engine.start()
        
        playingSampleId = sample.id
        samplesPlayback[sample.id] = true
        play(sample: sample, buffer: buffer, node: node)
    }
    
    private func play(sample: SampleLayer, buffer: AVAudioPCMBuffer, node: AVAudioPlayerNode, completion: (() -> Void)? = nil) {
        node.scheduleBuffer(buffer) {
            DispatchQueue.main.asyncAfter(deadline: .now() + (1 - sample.delay) * 2, execute: { [weak self] in
                guard let self = self, self.samplesPlayback[sample.id] == true else { return }
                self.play(sample: sample, buffer: buffer, node: node, completion: completion)
            })
        }
        node.play()
    }
    
    func removeSample(sampleId: String) {
        guard let index = samples.firstIndex(where: { $0.id == sampleId }) else { return }
        samples.remove(at: index)
        samplesFlie.removeValue(forKey: sampleId)
        samplesPCMBuffer.removeValue(forKey: sampleId)
        samplesBuffer.removeValue(forKey: sampleId)
        samplesPlayerNode.removeValue(forKey: sampleId)
        samplesFlie.removeValue(forKey: sampleId)
        samplesPlayback.removeValue(forKey: sampleId)
        
        if samples.isEmpty {
            stopAudio()
            stopRecordAudio()
        }
    }
    
    
    func setVolume(_ volume: Float, for sample: SampleLayer) {
        guard let node = samplesPlayerNode[sample.id] else { return }
        sample.volume = volume
        if !sample.isMute {
            node.volume = volume
        }
    }
    
    func playAudio() {
        guard !samples.isEmpty else { return }
        engine.prepare()
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? engine.start()
        isPlayingAudio = true
        for sample in samples {
            guard let buffer = samplesPCMBuffer[sample.id], let node = samplesPlayerNode[sample.id] else { return }
            samplesPlayback[sample.id] = true
            play(sample: sample, buffer: buffer, node: node, completion: nil)
        }
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: engine.mainMixerNode.outputFormat(forBus: 0)) { [weak self] buffer, time in
            guard let self = self else { return }
            let bufferPointer = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
            DispatchQueue.main.async {
                self.onChangeBufferPointer?(bufferPointer)
            }
        }
    }
    
    func stopAudio() {
        engine.stop()
        engine.mainMixerNode.removeTap(onBus: 0)
        isPlayingAudio = false
        for sample in samples {
            guard let node = samplesPlayerNode[sample.id] else { return }
            samplesPlayback[sample.id] = false
            node.stop()
        }
    }
    
    private var audioFile: AVAudioFile?
    
    func startRecordAudio() {
        guard !samples.isEmpty else { return }
        engine.prepare()
        try? engine.start()
        isRecordingAudio = true
        
        let url = URL(fileURLWithPath: "best_song.caf", isDirectory: false, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
                
        for sample in samples {
            guard let buffer = samplesPCMBuffer[sample.id], let node = samplesPlayerNode[sample.id] else { return }
            samplesPlayback[sample.id] = true
            play(sample: sample, buffer: buffer, node: node, completion: nil)
        }
        
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: engine.mainMixerNode.outputFormat(forBus: 0)) { [weak self] buffer, time in
            guard let self = self else { return }
            let bufferPointer = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
            
            if self.audioFile == nil {
                audioFile = try? AVAudioFile(forWriting: url, settings: self.engine.mainMixerNode.outputFormat(forBus: 0).settings)
            }
            
            do {
                try audioFile?.write(from: buffer)
            } catch {
                print(error)
            }
        
            DispatchQueue.main.async {
                self.onChangeBufferPointer?(bufferPointer)
            }
        }
    }
    
    func stopRecordAudio() {
        engine.stop()
        isRecordingAudio = false
        
        engine.mainMixerNode.removeTap(onBus: 0)
        
        if let url = audioFile?.url {
            onShareURL?(url)
        }
        
        for sample in samples {
            guard let node = samplesPlayerNode[sample.id] else { return }
            samplesPlayback[sample.id] = false
            node.stop()
        }
    }
    
    func changeMuteSample(_ sample: SampleLayer) -> Bool {
        sample.isMute = !sample.isMute
        if let node = samplesPlayerNode[sample.id] {
            if sample.isMute {
                node.volume = 0
            } else {
                node.volume = sample.volume
            }
        }
        return sample.isMute
    }
    
    
}

extension AVAudioPCMBuffer {
    
    var duration: TimeInterval {
        TimeInterval(Double(frameLength) / format.sampleRate)
    }
    
}
