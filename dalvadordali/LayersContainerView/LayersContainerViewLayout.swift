//
//  LayersContainerViewLayout
//  dalvadordali
//
//  Created by Maksim Danko on 05.11.2023
//  
// 

import UIKit

final class LayersContainerView: UIView {
    
    var onRemoveSampleLayer: ((SampleLayer) -> Void)?
    
    var onSelectSampleLayer: ((SampleLayer) -> Void)?
    
    var onPlaybackSampleLayer: ((SampleLayer) -> Void)?
    
    var onMuteSampleLayer: ((SampleLayer) -> Void)?
    
    private struct Constant {
        let layerHeight: CGFloat = 40
        let layerSpacing: CGFloat = 6
    }
    
    private(set) var sampleLayers: [SampleLayer] = []
    
    private let scrollView = UIScrollView()
    private var layers: [LayerRowView] = []
    
    private let constant = Constant()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        calculateLayout(width: size.width).size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    public func setMute(_ isMute: Bool, for sample: SampleLayer) {
        guard let index = sampleLayers.firstIndex(where: { $0.id == sample.id }) else { return }
        let layer = layers[index]
        layer.setMute(isMute)
    }
    
    public func setPlaying(_ isPlaying: Bool, for sample: SampleLayer) {
        guard let sampleLayerIndex = sampleLayers.firstIndex(where: { $0.id == sample.id }) else { return }
        for (index, layer) in layers.enumerated() {
            if index == sampleLayerIndex {
                layer.setPlayback(isPlaying)
            } else {
                layer.setPlayback(false)
            }
        }
    }
    
    func addSamples(_ samples: [SampleLayer]) {
        sampleLayers.append(contentsOf: samples)
        for sample in samples {
            let layerView = LayerRowView()
            layerView.sample = sample
            layerView.onTap = handleTap()
            layerView.onTapPlaybackButton = handlePlaybackSampleLayer()
            layerView.onTapMuteButton = handleTapMuteButton()
            layerView.onTapRemoveButton = handleRemoveLayer()
            scrollView.addSubview(layerView)
            layers.append(layerView)
        }
        setNeedsLayout()
    }
    
    func handleTap() -> (LayerRowView) -> Void {
        return { [weak self] layer in
            guard let self = self else { return }
            guard let index = self.layers.firstIndex(of: layer) else { return }
            let sample = self.sampleLayers[index]
            self.onSelectSampleLayer?(sample)
        }
    }
    
    func handleRemoveLayer() -> (LayerRowView) -> Void {
        return { [weak self] layer in
            guard let self = self else { return }
            guard let index = self.layers.firstIndex(of: layer) else { return }
            let sample = self.sampleLayers[index]
            self.removeSample(sample.id)
            onRemoveSampleLayer?(sample)
        }
    }
    
    func handleTapMuteButton() -> (LayerRowView) -> Void {
        return { [weak self] layer in
            guard let self = self else { return }
            guard let index = self.layers.firstIndex(of: layer) else { return }
            let sample = self.sampleLayers[index]
            self.onMuteSampleLayer?(sample)
        }
    }
    
    func handlePlaybackSampleLayer() -> (LayerRowView) -> Void {
        return { [weak self] layer in
            guard let self = self else { return }
            guard let index = self.layers.firstIndex(of: layer) else { return }
            let sample = self.sampleLayers[index]
            self.onPlaybackSampleLayer?(sample)
        }
    }

    func removeSample(_ sampleId: String) {
        guard let index = sampleLayers.firstIndex(where: { $0.id == sampleId }) else { return }
        sampleLayers.remove(at: index)
        layers[index].removeFromSuperview()
        layers.remove(at: index)
        superview?.setNeedsLayout()
    }
    
    private func setupView() {
        clipsToBounds = true
        addSubview(scrollView)
    }
    
    private func layout() {
        let layout = calculateLayout(width: bounds.width)
        scrollView.frame = layout.scrollFrame
        scrollView.contentSize = layout.contentSize
        for index in 0..<sampleLayers.count {
            layers[index].frame = layout.layersFrame[index]
        }
    }
    
    private func calculateLayout(width: CGFloat) -> LayersContainerViewLayout {
        let context = LayersContainerViewLayout.Context(width: width,
                                                        layerCount: sampleLayers.count,
                                                        layerHeight: constant.layerHeight,
                                                        layerSpacing: constant.layerSpacing)
        var layout = LayersContainerViewLayout(context: context)
        layout.calculate()
        return layout
    }
    
}

private struct LayersContainerViewLayout {
    
    struct Context {
        let width: CGFloat
        let layerCount: Int
        let layerHeight: CGFloat
        let layerSpacing: CGFloat
    }
    
    private(set) var size: CGSize = .zero
    private(set) var scrollFrame: CGRect = .zero
    private(set) var contentSize: CGSize = .zero
    private(set) var layersFrame: [CGRect] = []
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    mutating func calculate() {
        var y: CGFloat = 0
        for _ in 0..<context.layerCount {
            let layerFrame = CGRect(x: 0, y: y, width: context.width, height: context.layerHeight)
            layersFrame.append(layerFrame)
            y = layerFrame.maxY + context.layerSpacing
        }
        scrollFrame = CGRect(x: 0, y: 0, width: context.width, height: y)
        size = CGSize(width: context.width, height: y)
    }
    
}
