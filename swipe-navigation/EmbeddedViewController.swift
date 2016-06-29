//
//  EmbeddedViewController.swift
//  swipe-navigation
//
//  Created by Donald Lee on 28/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

protocol EmbeddedViewControllerDelegate: class {
    
    func isCenterContainerActive() -> Bool
    func isTopContainerActive() -> Bool
    func isBottomContainerActive() -> Bool
    func isLeftContainerActive() -> Bool
    func isRightContainerActive() -> Bool
    
    func onDone(sender: AnyObject)
    
    func onShowCenterContainer(sender: AnyObject)
    func onShowTopContainer(sender: AnyObject)
    func onShowBottomContainer(sender: AnyObject)
    func onShowLeftContainer(sender: AnyObject)
    func onShowRightContainer(sender: AnyObject)
}

class EmbeddedViewController: UIViewController {
    
    weak var delegate: EmbeddedViewControllerDelegate?
    
    @IBAction private func onDone(sender: AnyObject) {
        self.delegate?.onDone(sender)
    }
}
