//
//  ToolSelectionControl
//  dalvadordali
//
//  Created by Maksim Danko on 01.11.2023
//  
// 

import UIKit

enum ImagePosition {
    case center
    case bottom
}

final class ToolSelectionControl: UIView {
    
    var onSelectSample: ((Sample) -> Void)?
    
    var onSelectedSample: ((Sample?) -> Void)?
    
    var onPlayAndSelectedSample: ((Sample) -> Void)?
    
    var samples: [Sample] = [] {
        didSet {
            rows.forEach({ $0.removeFromSuperview() })
            rows.removeAll()
            for sample in samples {
                let row = ToolSelectionControlRow()
                row.title = sample.title
                addSubview(row)
                rows.append(row)
            }
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var imagePosition: ImagePosition = .center {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    var imageSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    private let size = CGSize(width: 60, height: 60)
    
    private let imageView = UIImageView()
    private var rows: [ToolSelectionControlRow] = []
    
    private(set) var isExpanded = false
    
    private lazy var longPress: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        return gestureRecognizer
    }()
    
    private lazy var tapPress: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        gestureRecognizer.require(toFail: longPress)
        return gestureRecognizer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return calculateLayout().size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = calculateLayout()
        imageView.frame = layout.imageFrame
        for (index, row) in rows.enumerated() {
            row.frame = layout.sampleFrames[index]
        }
    }
    
    private func setupView() {
        addGestureRecognizer(longPress)
        addGestureRecognizer(tapPress)
        
        addSubview(imageView)
        
        layer.masksToBounds = true
        layer.cornerRadius = 30
    }
    
    private func calculateLayout() -> ToolSelectionControlLayout {
        let context = ToolSelectionControlLayout.Context(size: size,
                                                         isExpanded: isExpanded,
                                                         imageSize: imageSize,
                                                         imagePosition: imagePosition,
                                                         sampleHeight: 40,
                                                         sampleCount: rows.count)
        var layout = ToolSelectionControlLayout(context: context)
        layout.calculate()
        return layout
    }
    
    @objc
    private func tapAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let sample = samples.first else { return }
        onPlayAndSelectedSample?(sample)
    }
    
    @objc
    private func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            isExpanded = true
            animate(isBegan: true)
        case .changed:
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            let selectedIndex = rows.firstIndex(where: { $0.frame.contains(location) })
            for (index, row) in rows.enumerated() {
                if selectedIndex == index {
                    onSelectSample?(samples[index])
                    row.setSelected(true, animated: true)
                } else {
                    row.setSelected(false, animated: false)
                }
            }
        case .ended:
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            if let selectedIndex = rows.firstIndex(where: { $0.frame.contains(location) }) {
                onSelectedSample?(samples[selectedIndex])
            } else {
                onSelectedSample?(nil)
            }
            isExpanded = false
            animate(isBegan: false)
        default:
            print("Default")
        }
    }
    
    private func animate(isBegan: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = isBegan ? Colors.inchworm : .white
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    
}

private struct ToolSelectionControlLayout {
    
    struct Context {
        let size: CGSize
        let isExpanded: Bool
        let imageSize: CGSize
        let imagePosition: ImagePosition
        let sampleHeight: CGFloat
        let sampleCount: Int
    }
    
    private(set) var size: CGSize = .zero
    private(set) var imageFrame: CGRect = .zero
    private(set) var sampleFrames: [CGRect] = []
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    mutating func calculate() {
        let imageX = (context.size.width - context.imageSize.width) / 2
        let imageY: CGFloat
        switch context.imagePosition {
        case .center:
            imageY = (context.size.height - context.imageSize.height) / 2
        case .bottom:
            imageY = context.size.height - context.imageSize.height
        }
        
        imageFrame = CGRect(x: imageX,
                            y: imageY,
                            width: context.imageSize.width,
                            height: context.imageSize.height)
        
        var sampleFrameY: CGFloat = context.size.height
        
        for _ in 0..<context.sampleCount {
            sampleFrames.append(CGRect(x: 0,
                                       y: sampleFrameY,
                                       width: context.size.width,
                                       height: context.sampleHeight))
            sampleFrameY += context.sampleHeight
        }
        
        let height = context.isExpanded ? sampleFrameY + 24 : context.size.height
        size = CGSize(width: context.size.width, height: height)
    }
    
}
