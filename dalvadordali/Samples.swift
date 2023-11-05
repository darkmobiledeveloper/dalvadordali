//
//  Samples
//  dalvadordali
//
//  Created by Maksim Danko on 05.11.2023
//  
// 

import Foundation

let pianoSamples = [
    Sample(id: SampleIdentifier.Piano.pinano_1.rawValue, title: "Сэмпл 1", extension: "wav", type: .piano),
    Sample(id: SampleIdentifier.Piano.pinano_2.rawValue, title: "Сэмпл 2", extension: "wav", type: .piano),
    Sample(id: SampleIdentifier.Piano.pinano_3.rawValue, title: "Сэмпл 3", extension: "wav", type: .piano)
]

let gitarSamples = [
    Sample(id: SampleIdentifier.Gitar.guitar_1.rawValue, title: "Сэмпл 1", extension: "wav", type: .gitar),
    Sample(id: SampleIdentifier.Gitar.guitar_2.rawValue, title: "Сэмпл 2", extension: "wav", type: .gitar)
]

let drumSamples = [
    Sample(id: SampleIdentifier.Drum.drum_1.rawValue, title: "Сэмпл 1", extension: "wav", type: .drum),
    Sample(id: SampleIdentifier.Drum.drum_2.rawValue, title: "Сэмпл 2", extension: "wav", type: .drum)
]

struct Sample {
    let id: String
    let title: String
    let `extension`: String
    let type: SampleLayerType
}

enum SampleIdentifier {
    
    enum Piano: String {
        case pinano_1
        case pinano_2
        case pinano_3
    }
    
    enum Gitar: String {
        case guitar_1
        case guitar_2
    }
    
    enum Drum: String {
        case drum_1
        case drum_2
    }
    
}

enum SampleLayerType {
    case piano
    case gitar
    case drum
    case microphone
}

final class SampleLayer {
    
    var name: String = ""
    
    var volume: Float = 1
    
    var delay: TimeInterval = 0
    
    var seconds: TimeInterval = 0
    
    var isMute = false
    
    var isPlayback = false
    
    let id: String
    
    let sampleId: String
    let sampleURL: URL
    let type: SampleLayerType
   
    init(id: String, sampleId: String, sampleURL: URL, type: SampleLayerType) {
        self.id = id
        self.sampleId = sampleId
        self.sampleURL = sampleURL
        self.type = type
    }
    
}




