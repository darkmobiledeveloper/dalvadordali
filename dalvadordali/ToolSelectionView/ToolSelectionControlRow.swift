//
//  ToolSelectionControlRow
//  dalvadordali
//
//  Created by Maksim Danko on 01.11.2023
//  
// 

import UIKit

final class ToolSelectionControlRow: UIView {
 
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    private let label = UILabel()
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    private func setupView() {
        addSubview(label)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [Colors.inchworm.cgColor, Colors.inchworm.cgColor]
    }
    
    func setSelected(_ isSelected: Bool, animated: Bool) {
        func update() {
            if isSelected {
                gradientLayer.colors = [Colors.inchworm.cgColor, UIColor.white.cgColor, Colors.inchworm.cgColor]
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            } else {
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
                gradientLayer.colors = [Colors.inchworm.cgColor, Colors.inchworm.cgColor]
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                update()
            }
        } else {
            update()
        }
    }
    
}
