//
//  UIColor-Extention.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/15.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
}
