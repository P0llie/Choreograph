//
//  Utilities.swift
//  Choreograph
//
//  Created by Karen McCarthy on 24/01/2018.
//  Copyright © 2018 Karen McCarthy. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}

extension UIView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        drawHierarchy(in: bounds, afterScreenUpdates: true )
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
extension String {
        func attributedString(withTextStyle style: UIFontTextStyle, ofSize size: CGFloat) -> NSAttributedString {
            let font = UIFont.preferredFont(forTextStyle: style).withSize(size)
            return NSAttributedString(string: self, attributes: [.font:font])
        }
}
    
extension NSMutableAttributedString {
        func setFont(_ newValue: UIFont?) {
            if newValue != nil { addAttributes([.font:newValue!], range: NSMakeRange(0, length)) }
        }
}
