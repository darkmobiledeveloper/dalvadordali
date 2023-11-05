//
//  WaveformView
//  dalvadordali
//
//  Created by Maksim Danko on 05.11.2023
//  
// 

import UIKit
import Accelerate

final class WaveformView: UIView {
    
    private struct Constant {
        let spacing: CGFloat = 2
        let lineWidth: CGFloat = 2
        let scale: CGFloat = 60
    }
    
    private var samples: [Float] = []
    
    private var bufferSamples: UnsafeBufferPointer<Float>?
    
    private let interval = 0.05
    
    private let constant = Constant()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if !samples.isEmpty {
            
            let maxValue = abs(CGFloat(samples.min() ?? 0))
            
            let middleY = rect.midY
            
            var x = rect.maxX
            
            for index in stride(from: samples.count - 1, through: 0, by: -1) {
                let sample = constant.scale + CGFloat(samples[index])
                let sampleHeight = rect.height * sample / maxValue
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: x, y: middleY - sampleHeight / 2))
                linePath.addLine(to: CGPoint(x: x, y: middleY + sampleHeight / 2))
                linePath.lineWidth = constant.lineWidth
                linePath.lineJoinStyle = .round
                linePath.lineCapStyle = .round
                UIColor.white.setStroke()
                linePath.stroke()
                x = x - constant.spacing - constant.lineWidth
                if x <= 0 { break }
            }
            return
        }
        
        if let bufferSamples = bufferSamples, !bufferSamples.isEmpty {
            
            let bufferSamplesCount = bufferSamples.count
            
            let maxSample: Float = vDSP.maximum(bufferSamples)
            let normalizationFactor = Float(rect.height) / maxSample / 2

            let middleY = rect.midY
            var x: CGFloat = 0
            var index = 0
            
            var sample = bufferSamples.item(at: index * bufferSamplesCount / Int(rect.width))
            
            while sample != nil {
                if let sample = sample {
                    let normalizedSample = sample * normalizationFactor
                    let waveHeight = CGFloat(normalizedSample) * middleY
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: x, y: middleY - waveHeight))
                    linePath.addLine(to: CGPoint(x: x, y: middleY + waveHeight))
                    linePath.lineWidth = constant.lineWidth
                    linePath.lineJoinStyle = .round
                    linePath.lineCapStyle = .round
                    UIColor.white.setStroke()
                    linePath.stroke()
                }
                
                x += constant.lineWidth + constant.spacing
                index += 1
                sample = bufferSamples.item(at: index * bufferSamplesCount / Int(rect.width))
            }
        }
    }
    
    func addSamples(_ samples: [Float]) {
        self.samples.append(contentsOf: samples)
        setNeedsDisplay()
    }
    
    func removeSamples() {
        self.samples.removeAll()
        self.bufferSamples = nil
    }
    
    func setBufferSamples(_ bufferSamples: UnsafeBufferPointer<Float>) {
        self.bufferSamples = bufferSamples
        self.samples.removeAll()
        setNeedsDisplay()
    }
    
}


extension UnsafeBufferPointer {
    
    func item(at index: Int) -> Element? {
        if index >= self.count {
            return nil
        }
        return self[index]
    }
    
}
