//
//  UIViewController+SwipeNavigationController.swift
//  SwipeNavigationController
//
//  Created by Kok Chung Law on 4/7/16.
//  Copyright © 2016 Lomotif Private Limited. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    public var containerSwipeNavigationController: SwipeNavigationController? {
        get {
            var parentViewController = self.parent
            while (parentViewController != nil) {
                if let swipeNavigationController = parentViewController as? SwipeNavigationController {
                    return swipeNavigationController
                }
                parentViewController = parentViewController?.parent
            }
            return nil
        }
    }
    
}
