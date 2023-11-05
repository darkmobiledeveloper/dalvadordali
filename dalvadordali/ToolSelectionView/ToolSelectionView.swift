//
//  ToolSelectionView
//  dalvadordali
//
//  Created by Maksim Danko on 01.11.2023
//  
// 

import UIKit

final class ToolSelectionView: UIView {
        
    var onPlayAndSelectedSample: ((Sample) -> Void)?
    
    var onSelectSample: ((Sample) -> Void)?
    
    var onSelectedSample: ((Sample?) -> Void)?
    
    private struct Constant {
        let controlSize = CGSize(width: 60, height: 60)
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
    }
    
    private let pianoControl = ToolSelectionControl()
    private let gitarControl = ToolSelectionControl()
    private let drumControl = ToolSelectionControl()
    
    private let constant = Constant()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return calculateLayout(width: size.width).size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func setupView() {
        addSubview(pianoControl)
        addSubview(gitarControl)
        addSubview(drumControl)
        
        pianoControl.backgroundColor = .white
        pianoControl.image = Images.piano
        pianoControl.imageSize = CGSize(width: 26, height: 26)
        
        gitarControl.backgroundColor = .white
        gitarControl.imageSize = CGSize(width: 26, height: 49)
        gitarControl.imagePosition = .bottom
        gitarControl.image = Images.guitar
        
        drumControl.backgroundColor = .white
        drumControl.image = Images.drum
        drumControl.imageSize = CGSize(width: 26, height: 26)
        
        [pianoControl, gitarControl, drumControl].forEach({
            $0.onSelectSample = { [weak self] sample in
                self?.onSelectSample?(sample)
            }
            $0.onSelectedSample = { [weak self] sample in
                self?.onSelectedSample?(sample)
            }
            $0.onPlayAndSelectedSample = { [weak self] sample in
                self?.onPlayAndSelectedSample?(sample)
            }
        })
        
        
        pianoControl.samples = pianoSamples
        gitarControl.samples = gitarSamples
        drumControl.samples = drumSamples
    }
    
    private func layout() {
        let layout = calculateLayout(width: bounds.width)
        pianoControl.frame = layout.pianoControlFrame
        gitarControl.frame = layout.gitarControlFrame
        drumControl.frame = layout.windControlFrame
    }
    
    private func calculateLayout(width: CGFloat) -> ToolSelectionViewLayout {
        let context = ToolSelectionViewLayout.Context(width: width,
                                                      controlSize: constant.controlSize,
                                                      insets: constant.insets,
                                                      pianoControl: pianoControl,
                                                      gitarControl: gitarControl,
                                                      windControl: drumControl)
        var layout = ToolSelectionViewLayout(context: context)
        layout.calculate()
        return layout
    }
    
    
}

private struct ToolSelectionViewLayout {
    
    struct Context {
        let width: CGFloat
        let controlSize: CGSize
        let insets: UIEdgeInsets
        let pianoControl: UIView
        let gitarControl: UIView
        let windControl: UIView
    }
    
    private(set) var size: CGSize = .zero
    private(set) var pianoControlFrame: CGRect = .zero
    private(set) var gitarControlFrame: CGRect = .zero
    private(set) var windControlFrame: CGRect = .zero
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    mutating func calculate() {
        let pianoControlSize = context.pianoControl.sizeThatFits(.zero)
        let gitarControlSize = context.gitarControl.sizeThatFits(.zero)
        let windControlSize = context.windControl.sizeThatFits(.zero)
        pianoControlFrame = CGRect(x: context.insets.left,
                                   y: context.insets.top,
                                   width: pianoControlSize.width,
                                   height: pianoControlSize.height)
        let gitarControlX = (context.width - gitarControlSize.width) / 2
        gitarControlFrame = CGRect(x: gitarControlX,
                                   y: context.insets.top,
                                   width: gitarControlSize.width,
                                   height: gitarControlSize.height)
        let windControlFrameX = context.width - context.insets.right - windControlSize.width
        windControlFrame = CGRect(x: windControlFrameX,
                                  y: context.insets.top,
                                  width: windControlSize.width,
                                  height: windControlSize.height)
        size = CGSize(width: context.width, height: context.controlSize.height + context.insets.top + context.insets.bottom)
    }
    
}


