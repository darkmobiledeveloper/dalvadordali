//
//  VerticalAxisView
//  dalvadordali
//
//  Created by Maksim Danko on 03.11.2023
//  
// 

import UIKit

final class VerticalAxisView: UIView {
    
    private struct Constant {
        let groupCount = 5
        let rowInGroupCount = 5
    }
    
    private let constant = Constant()
    private var rows: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        calculateLayout(height: size.height).size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func setupView() {
        let count = constant.groupCount * constant.rowInGroupCount
        for _ in 0..<count {
            let view = UIView()
            view.backgroundColor = .white
            addSubview(view)
            rows.append(view)
        }
    }
    
    private func layout() {
        let layout = calculateLayout(height: bounds.height)
        for (index, frame) in layout.rows.enumerated() {
            rows[index].frame = frame
        }
    }
    
    private func calculateLayout(height: CGFloat) -> VerticalAxisViewLayout {
        let context = VerticalAxisViewLayout.Context(height: height, groupCount: constant.groupCount, rowInGroupCount: constant.rowInGroupCount, groupWidth: 14, rowWidth: 8)
        var layout = VerticalAxisViewLayout(context: context)
        layout.calculate()
        return layout
    }
    
}

private struct VerticalAxisViewLayout {
    
    struct Context {
        let height: CGFloat
        let groupCount: Int
        let rowInGroupCount: Int
        let groupWidth: CGFloat
        let rowWidth: CGFloat
    }
    
    private(set) var size: CGSize = .zero
    private(set) var rows: [CGRect] = []
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    mutating func calculate() {
        var y: CGFloat = 0
        
        let count = context.groupCount * context.rowInGroupCount
        let spacing = (context.height - CGFloat(count)) / CGFloat(count)
        
        for index in 0..<count {
            let width = index % context.groupCount == 0 ? context.groupWidth : context.rowWidth
            let frame = CGRect(x: 0, y: y, width: width, height: 1)
            rows.append(frame)
            y = frame.maxY + spacing
        }
        
        size = CGSize(width: context.groupWidth, height: context.height)
        
    }
}
