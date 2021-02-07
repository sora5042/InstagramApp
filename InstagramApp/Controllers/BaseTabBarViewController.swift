//
//  BaseTabBarViewController.swift
//  InstagramApp
//
//  Created by 大谷空 on 2021/01/13.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers?.enumerated().forEach({ (index, viewController) in
            
            switch index {
            
            case 0:
                setTabBarInfo(viewController, selectedImage: "ホームアイコン", unselectedImage: "unホームアイコン")
            case 1:
                setTabBarInfo(viewController, selectedImage: "プラスのアイコン素材 (2)", unselectedImage: "プラスのアイコン素材 (1)")
            case 2:setTabBarInfo(viewController, selectedImage: "人物のアイコン素材 (1)", unselectedImage: "人物のアイコン素材")
                
            default:
                break
            }
        })
    }
    
    private func setTabBarInfo(_ viewController: UIViewController, selectedImage: String, unselectedImage: String) {
        
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImage)?.resize(size: .init(width: 25, height: 25))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unselectedImage)?.resize(size: .init(width: 25, height: 25))?.withRenderingMode(.alwaysOriginal)
    }
}
