//
//  BackgroundLabel
//  dalvadordali
//
//  Created by Maksim Danko on 04.11.2023
//  
// 

import UIKit

enum BackgroundLabelAxis {
    case horizontal
    case vertical
}

final class BackgroundLabel: UIView {
    
    var axis: BackgroundLabelAxis = .horizontal {
        didSet {
            switch axis {
            case .vertical:
                label.transform = CGAffineTransform(rotationAngle: -Double.pi / 2)
            case .horizontal:
                label.transform = .identity
            }
            setNeedsLayout()
        }
    }
    
    var insets = UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var text: String? {
        didSet {
            label.text = text
            setNeedsLayout()
        }
    }
    
    var font: UIFont = .systemFont(ofSize: 12, weight: .regular) {
        didSet {
            label.text = text
            setNeedsLayout()
        }
    }
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let text = text else { return .zero }
        return calculateLayout(text: text).size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func setupView() {
        addSubview(label)
        label.font = font
        label.textColor = .black
    }
    
    private func layout() {
        guard let text = text else { return }
        let layout = calculateLayout(text: text)
        label.frame = layout.labelFrame
    }
    
    private func calculateLayout(text: String) -> BackgroundLabelLayout {
        let context = BackgroundLabelLayout.Context(axis: axis, insets: insets, font: font, text: text)
        var layout = BackgroundLabelLayout(context: context)
        layout.calculate()
        return layout
    }
    
}

private struct BackgroundLabelLayout {
    
    struct Context {
        let axis: BackgroundLabelAxis
        let insets: UIEdgeInsets
        let font: UIFont
        let text: String
    }
    
    private(set) var size: CGSize = .zero
    private(set) var labelFrame: CGRect = .zero
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    mutating func calculate() {
        let textSize = context.text.size(font: context.font)
        
        switch context.axis {
        case .horizontal:
            labelFrame = CGRect(x: context.insets.left, y: context.insets.top, width: textSize.width, height: textSize.height)
            size = CGSize(width: textSize.width + context.insets.left + context.insets.right,
                          height: textSize.height + context.insets.top + context.insets.bottom)
        case .vertical:
            labelFrame = CGRect(x: context.insets.top, y:context.insets.left, width: textSize.height, height: textSize.width)
            size = CGSize(width: textSize.height + context.insets.top + context.insets.bottom,
                          height: textSize.width + context.insets.left + context.insets.right)
        }
    }
    
}
