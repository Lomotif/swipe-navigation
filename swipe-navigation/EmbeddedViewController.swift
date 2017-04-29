//
//  EmbeddedViewController.swift
//  swipe-navigation
//
//  Created by Donald Lee on 28/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

// add more cases if needed
enum Position {
    case center
    case top
    case bottom
    case left
    case right
}

protocol EmbeddedViewControllerDelegate: class {
    
    // delegate to provide information about other containers
    func isContainerActive(_ position: Position) -> Bool
    
    // delegate to handle containers events
    func onDone(_ sender: AnyObject)
    func onShowContainer(_ position: Position, sender: AnyObject)
}

class EmbeddedViewController: UIViewController {
    
    weak var delegate: EmbeddedViewControllerDelegate?
    
    @IBAction fileprivate func onDone(_ sender: AnyObject) {
        self.delegate?.onDone(sender)
    }
}
