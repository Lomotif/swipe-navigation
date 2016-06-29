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
    case Center
    case Top
    case Bottom
    case Left
    case Right
}

protocol EmbeddedViewControllerDelegate: class {
    
    // delegate to provide information about other containers
    func isContainerActive(position: Position) -> Bool
    
    // delegate to handle containers events
    func onDone(sender: AnyObject)
    func onShowContainer(position: Position, sender: AnyObject)
}

class EmbeddedViewController: UIViewController {
    
    weak var delegate: EmbeddedViewControllerDelegate?
    
    @IBAction private func onDone(sender: AnyObject) {
        self.delegate?.onDone(sender)
    }
}
