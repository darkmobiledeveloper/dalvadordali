//
//  HorizontalAxisView
//  dalvadordali
//
//  Created by Maksim Danko on 04.11.2023
//  
// 

import UIKit

final class HorizontalAxisView: UIView {
 
    private struct Constant {
        let rowSize = CGSize(width: 1, height: 14)
        let maxSpacing = 9
        let minSpacing = 2
    }
    
    private let constant = Constant()
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return calculateLayout(width: size.width).size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = calculateLayout(width: bounds.width)
        for frame in layout.rows {
            let view = UIView()
            view.backgroundColor = .white
            addSubview(view)
            view.frame = frame
        }
    }
    
    private func calculateLayout(width: CGFloat) -> HorizontalAxisViewLayout {
        let context = HorizontalAxisViewLayout.Context(width: width, rowSize: constant.rowSize, maxSpacing: constant.maxSpacing, minSpacing: constant.minSpacing)
        var layout = HorizontalAxisViewLayout(context: context)
        layout.calculate()
        return layout
    }
        
}

private struct HorizontalAxisViewLayout {
    
    struct Context {
        let width: CGFloat
        let rowSize: CGSize
        let maxSpacing: Int
        let minSpacing: Int
    }
    
    private(set) var size: CGSize = .zero
    private(set) var rows: [CGRect] = []
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    mutating func calculate() {
        let countSpacing = context.maxSpacing - context.minSpacing
        let countGroupWidth = context.width / CGFloat(countSpacing)
        var x: CGFloat = 0
        for index in 0..<countSpacing {
            while(true) {
                let frame = CGRect(x: x, y: 0, width: context.rowSize.width, height: context.rowSize.height)
                guard frame.maxX < countGroupWidth * CGFloat(index + 1) else { break }
                x = frame.maxX + CGFloat(context.maxSpacing - index)
                rows.append(frame)
            }
        }
        size = CGSize(width: context.width, height: context.rowSize.height)
    }
    
}
