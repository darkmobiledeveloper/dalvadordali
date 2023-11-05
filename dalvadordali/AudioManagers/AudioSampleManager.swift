//
//  AudioSampleManager
//  dalvadordali
//
//  Created by Maksim Danko on 05.11.2023
//  
// 

import Foundation
import AVFoundation

final class AudioSampleManager {
    
    private let audioEngine = AVAudioEngine()
    private var audioPlayerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioPlayingNodes: [String: Bool] = [:]
    
    private var currentSample: Sample?
    
    func stop() {
        currentSample = nil
        for key in audioPlayerNodes.keys {
            audioPlayerNodes[key]?.stop()
            audioPlayingNodes[key] = false
        }
    }
    
    func playSample(_ sample: Sample, isOnce: Bool = false, completion: (() -> Void)? = nil) {
        if let currentSample = currentSample {
            if currentSample.id == sample.id { return }
            audioPlayerNodes[currentSample.id]?.stop()
            audioPlayingNodes[currentSample.id] = false
        }
        
        guard let url = Bundle.main.url(forResource: sample.id, withExtension: sample.extension) else { return }
        
        do {
            let file = try AVAudioFile(forReading: url)
            let processingFormat = file.processingFormat
                
            let audioPlayerNode = AVAudioPlayerNode()
                
            self.audioPlayerNodes[sample.id] = audioPlayerNode
            self.audioPlayingNodes[sample.id] = true
                
            self.audioEngine.attach(audioPlayerNode)
            self.audioEngine.connect(audioPlayerNode, to: self.audioEngine.mainMixerNode, format: processingFormat)
            self.audioEngine.prepare()
                            
            try? self.audioEngine.start()
            self.currentSample = sample
            audioPlayerNode.scheduleFile(file, at: nil) { [weak self] in
                if !isOnce {
                    self?.play(sampleId: sample.id, file: file)
                } else {
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
            audioPlayerNode.play()
        } catch {
            
        }
    }
    
    private func play(sampleId: String, file: AVAudioFile, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            guard let self = self, let node = audioPlayerNodes[sampleId]  else { return }
            if self.audioPlayingNodes[sampleId] == false { return }
            node.scheduleFile(file, at: nil) { [weak self] in
                self?.play(sampleId: sampleId, file: file, completion: completion)
            }
            if !audioEngine.isRunning {
                try? audioEngine.start()
            }
            node.play()
        }
    }
    
}
