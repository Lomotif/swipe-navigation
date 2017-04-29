//
//  CenterViewController.swift
//  swipe-navigation
//
//  Created by Donald Lee on 29/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

class CenterViewController: EmbeddedViewController {
    
    @IBAction fileprivate func onTopButton(_ sender: UIButton) {
        delegate?.onShowContainer(.top, sender: sender)
    }
    
    @IBAction fileprivate func onBottomButton(_ sender: UIButton) {
        delegate?.onShowContainer(.bottom, sender: sender)
    }
    
    @IBAction fileprivate func onLeftButton(_ sender: UIButton) {
        delegate?.onShowContainer(.left, sender: sender)
    }
    
    @IBAction fileprivate func onRightButton(_ sender: UIButton) {
        delegate?.onShowContainer(.right, sender: sender)
    }
}
