//
//  CenterViewController.swift
//  swipe-navigation
//
//  Created by Donald Lee on 29/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

class CenterViewController: EmbeddedViewController {
    
    @IBAction private func onTopButton(sender: UIButton) {
        delegate?.onShowContainer(.Top, sender: sender)
    }
    
    @IBAction private func onBottomButton(sender: UIButton) {
        delegate?.onShowContainer(.Bottom, sender: sender)
    }
    
    @IBAction private func onLeftButton(sender: UIButton) {
        delegate?.onShowContainer(.Left, sender: sender)
    }
    
    @IBAction private func onRightButton(sender: UIButton) {
        delegate?.onShowContainer(.Right, sender: sender)
    }
}
