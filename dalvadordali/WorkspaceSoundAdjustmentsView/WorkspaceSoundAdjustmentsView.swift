//
//  WorkspaceSoundAdjustmentsView
//  dalvadordali
//
//  Created by Maksim Danko on 04.11.2023
//  
// 

import UIKit

final class WorkspaceSoundAdjustmentsView: UIView {
    
    var onChangeVerticalControl: ((CGFloat) -> Void)?
    
    var onChangeHorizontalControl: ((CGFloat) -> Void)?
    
    var verticalValue: CGFloat = 0 {
        didSet {
            guard let verticalControlRange = verticalControlRange else { return }
            let y = (1 - verticalValue) * (verticalControlRange.upperBound - verticalControlRange.lowerBound) + verticalControlRange.lowerBound
            verticalControl.frame.origin.y = y
        }
    }
    
    var horizontalValue: CGFloat = 0 {
        didSet {
            guard let horizontalControlRange = horizontalControlRange else { return }
            let x = (horizontalValue * (horizontalControlRange.upperBound - horizontalControlRange.lowerBound)) + horizontalControlRange.lowerBound
            horizontalControl.frame.origin.x = x
        }
    }
    
    
    private struct Constant {
        let verticalAxisInsets = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        let horizontalAxisInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    private let verticalAxisView = VerticalAxisView()
    private let horizontalAxisView = HorizontalAxisView()
    private let verticalControl = BackgroundLabel()
    private let horizontalControl = BackgroundLabel()
    
    private var verticalControlRange: ClosedRange<CGFloat>?
    private var horizontalControlRange: ClosedRange<CGFloat>?
    private var horizontalX: CGFloat = 0
    private var wasInitialLayout = false
    
    private lazy var panGestureeRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureeRecognizer(_:)))
        return panGestureRecognizer
    }()
    
    private lazy var verticalPanGestureeRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleVerticalPanGestureeRecognizer(_:)))
        return panGestureRecognizer
    }()
    
    private lazy var horizontalPanGestureeRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHorizontalPanGestureeRecognizer(_:)))
        return panGestureRecognizer
    }()
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    private let constant = Constant()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func setupView() {
        addGestureRecognizer(panGestureeRecognizer)
        addSubview(verticalAxisView)
        addSubview(horizontalAxisView)
        addSubview(verticalControl)
        addSubview(horizontalControl)
        
        verticalControl.axis = .vertical
        verticalControl.text = "громкость"
        verticalControl.backgroundColor = Colors.inchworm
        verticalControl.layer.masksToBounds = true
        verticalControl.layer.cornerRadius = 4
        verticalControl.addGestureRecognizer(verticalPanGestureeRecognizer)
        
        horizontalControl.text = "скорость"
        horizontalControl.backgroundColor = Colors.inchworm
        horizontalControl.layer.masksToBounds = true
        horizontalControl.layer.cornerRadius = 4
        horizontalControl.addGestureRecognizer(horizontalPanGestureeRecognizer)
        
        gradientLayer.colors = [Colors.royalblue.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
    }
    
    private func layout() {
        guard !wasInitialLayout else { return }
        wasInitialLayout = true
        let verticalAxisHeight = bounds.height - constant.verticalAxisInsets.top - constant.verticalAxisInsets.bottom
        let verticalAxisSize = verticalAxisView.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: verticalAxisHeight))
        verticalAxisView.frame = CGRect(x: 0, y: 0, width: verticalAxisSize.width, height: verticalAxisSize.height)
        let horizontalAxisSize = horizontalAxisView.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        let horizontalAxisWidth = horizontalAxisSize.width - constant.horizontalAxisInsets.left - constant.horizontalAxisInsets.right
        horizontalAxisView.frame = CGRect(x: constant.horizontalAxisInsets.left, y: bounds.height - horizontalAxisSize.height, width: horizontalAxisWidth, height: horizontalAxisSize.height)
        let verticalControlSize = verticalControl.sizeThatFits(.zero)
        verticalControl.frame = CGRect(x: 0, y: bounds.height - constant.verticalAxisInsets.bottom - verticalControlSize.height, width: verticalControlSize.width, height: verticalControlSize.height)
        let horizontalControlSize = horizontalControl.sizeThatFits(.zero)
        horizontalControl.frame = CGRect(x: constant.horizontalAxisInsets.left, y: bounds.height - horizontalControlSize.height, width: horizontalControlSize.width, height: horizontalControlSize.height)
        
        verticalControlRange =  0...(verticalAxisSize.height - verticalControlSize.height)
        horizontalControlRange = horizontalControl.frame.minX...(horizontalAxisView.frame.maxX - horizontalControlSize.width)
    }
    
    @objc
    private func handlePanGestureeRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        handleHorizontalControlPosition(translation)
        handleVerticalControlPosition(translation)
        panGestureRecognizer.setTranslation(.zero, in: panGestureRecognizer.view)
    }
    
    @objc
    private func handleHorizontalPanGestureeRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let location = panGestureRecognizer.translation(in: panGestureRecognizer.view?.superview)
        handleHorizontalControlPosition(location)
        panGestureRecognizer.setTranslation(.zero, in: panGestureRecognizer.view?.superview)
    }
    
    @objc
    private func handleVerticalPanGestureeRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let location = panGestureRecognizer.translation(in: panGestureRecognizer.view?.superview)
        handleVerticalControlPosition(location)
        panGestureRecognizer.setTranslation(.zero, in: panGestureRecognizer.view?.superview)
    }
    
    private func handleHorizontalControlPosition(_ position: CGPoint) {
        guard let horizontalControlRange = horizontalControlRange else { return }
        let x = min(max(horizontalControl.frame.origin.x + position.x, horizontalControlRange.lowerBound), horizontalControlRange.upperBound)
        let progress = (x - horizontalControlRange.lowerBound) / (horizontalControlRange.upperBound - horizontalControlRange.lowerBound)
        horizontalValue = progress
        onChangeHorizontalControl?(progress)
    }
    
    private func handleVerticalControlPosition(_ position: CGPoint) {
        guard let verticalControlRange = verticalControlRange else { return }
        let y = min(max(verticalControl.frame.origin.y + position.y, verticalControlRange.lowerBound), verticalControlRange.upperBound)
        let progress = 1 - ((y - verticalControlRange.lowerBound) / (verticalControlRange.upperBound - verticalControlRange.lowerBound))
        verticalValue = progress
        onChangeVerticalControl?(progress)
    }
    
}
