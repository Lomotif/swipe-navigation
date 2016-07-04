//
//  UIViewController+SwipeNavigationController.swift
//  SwipeNavigationController
//
//  Created by Kok Chung Law on 4/7/16.
//  Copyright © 2016 Lomotif Private Limited. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var containerSwipeNavigationController: SwipeNavigationController? {
        get {
            var parentViewController = self.parentViewController
            while (parentViewController != nil) {
                if let swipeNavigationController = parentViewController as? SwipeNavigationController {
                    return swipeNavigationController
                }
                parentViewController = parentViewController?.parentViewController
            }
            return nil
        }
    }
    
}
