//
//  CenterViewController.swift
//  swipe-navigation
//
//  Created by Donald Lee on 29/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

class CenterViewController: EmbeddedViewController {
    
    @IBAction func onTopButton(sender: UIButton) {
        delegate?.onShowTopContainer(sender)
    }
    
    @IBAction func onBottomButton(sender: UIButton) {
        delegate?.onShowBottomContainer(sender)
    }
    
    @IBAction func onLeftButton(sender: UIButton) {
        delegate?.onShowLeftContainer(sender)
    }
    
    @IBAction func onRightButton(sender: UIButton) {
        delegate?.onShowRightContainer(sender)
    }
}
