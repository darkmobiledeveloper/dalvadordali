//
//  String+Extension
//  dalvadordali
//
//  Created by Maksim Danko on 04.11.2023
//  
// 

import UIKit

extension String {
    
    func size(font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
    
}
