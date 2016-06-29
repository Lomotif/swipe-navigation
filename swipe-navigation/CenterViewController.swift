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
        delegate?.onShowContainer(.Top, sender: sender)
    }
    
    @IBAction func onBottomButton(sender: UIButton) {
        delegate?.onShowContainer(.Bottom, sender: sender)
    }
    
    @IBAction func onLeftButton(sender: UIButton) {
        delegate?.onShowContainer(.Left, sender: sender)
    }
    
    @IBAction func onRightButton(sender: UIButton) {
        delegate?.onShowContainer(.Right, sender: sender)
    }
}
