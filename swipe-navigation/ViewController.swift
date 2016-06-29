//
//  ViewController.swift
//  swipe-navigation
//
//  Created by Donald Lee on 28/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

enum ActivePanDirection {
    case Undefined
    case Horizontal
    case Vertical
}

class ViewController: UIViewController, EmbeddedViewControllerDelegate, UIGestureRecognizerDelegate {
    
    /*
     * The whole magic to this implementation:
     * manipulation of the x & y constraints of the center container view wrt the BaseViewController's
     *
     * The other (top, bottom, left, right) simply constrain themselves wrt to the center container
     */
    @IBOutlet weak private var currentXOffset: NSLayoutConstraint!
    @IBOutlet weak private var currentYOffset: NSLayoutConstraint!
    
    // pan gesture recognizer related
    @IBOutlet private var mainPanGesture: UIPanGestureRecognizer!
    private var previousNonZeroDirectionChange = CGVectorMake(0.0, 0.0)
    private var activePanDirection = ActivePanDirection.Undefined
    private let verticalSnapThresholdFraction: CGFloat = 0.15
    private let horizontalSnapThresholdFraction: CGFloat = 0.15
    
    // do not modify them, unfortunately they can't be declared with let due to value available only in viewDidLoad
    // implicitly unwrapped because they WILL be initialized during viewDidLoad
    private var centerContainerOffset: CGVector!
    private var topContainerOffset: CGVector!
    private var bottomContainerOffset: CGVector!
    private var leftContainerOffset: CGVector!
    private var rightContainerOffset: CGVector!
    
    weak private var centerViewController: EmbeddedViewController?
    weak private var topViewController: EmbeddedViewController?
    weak private var bottomViewController: EmbeddedViewController?
    weak private var leftViewController: EmbeddedViewController?
    weak private var rightViewController: EmbeddedViewController?
    
    // setting them to NO disables swiping to the view controller, try it!
    private var shouldshowTopViewController = true
    private var shouldShowBottomViewController = true
    private var shouldShowLeftViewController = true
    private var shouldShowRightviewController = true
    
    override func viewDidLoad() {
        // embedded containers offset
        let frameWidth = view.frame.size.width;
        let frameHeight = view.frame.size.height;
        
        // bookmark the offsets to specific positions
        centerContainerOffset = CGVectorMake(currentXOffset.constant, currentYOffset.constant)
        topContainerOffset = CGVectorMake(centerContainerOffset.dx, centerContainerOffset.dy + frameHeight)
        bottomContainerOffset = CGVectorMake(centerContainerOffset.dx, centerContainerOffset.dy - frameHeight)
        leftContainerOffset = CGVectorMake(centerContainerOffset.dx + frameWidth, centerContainerOffset.dy)
        rightContainerOffset = CGVectorMake(centerContainerOffset.dx - frameWidth, centerContainerOffset.dy)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar when navigating into this view controller
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Disable "Back" title on the navigation bar in child view controller.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar when navigating away from this view controller.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        // required for full screen, apparently
        return true;
    }
    
    // MARK: - Containers
    private func showCenterContainer() {
        currentXOffset.constant = centerContainerOffset.dx
        currentYOffset.constant = centerContainerOffset.dy
        UIView.animateWithDuration(0.2) { 
            self.view.layoutIfNeeded()
        }
    }
    
    private func showTopContainer() {
        currentXOffset.constant = topContainerOffset.dx
        currentYOffset.constant = topContainerOffset.dy
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showBottomContainer() {
        currentXOffset.constant = bottomContainerOffset.dx
        currentYOffset.constant = bottomContainerOffset.dy
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showLeftContainer() {
        currentXOffset.constant = leftContainerOffset.dx
        currentYOffset.constant = leftContainerOffset.dy
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showRightContainer() {
        currentXOffset.constant = rightContainerOffset.dx
        currentYOffset.constant = rightContainerOffset.dy
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    // MARK: - EmbeddedViewcontrollerDelegate Conformance
    func isCenterContainerActive() -> Bool {
        let currentOffset = (currentXOffset.constant, currentYOffset.constant)
        let targetOffset = (centerContainerOffset.dx, centerContainerOffset.dy)
        
        return currentOffset == targetOffset
    }
    
    func isTopContainerActive() -> Bool {
        let currentOffset = (currentXOffset.constant, currentYOffset.constant)
        let targetOffset = (topContainerOffset.dx, topContainerOffset.dy)
        
        return currentOffset == targetOffset
    }
    
    func isBottomContainerActive() -> Bool {
        let currentOffset = (currentXOffset.constant, currentYOffset.constant)
        let targetOffset = (bottomContainerOffset.dx, bottomContainerOffset.dy)
        
        return currentOffset == targetOffset
    }
    
    func isLeftContainerActive() -> Bool {
        let currentOffset = (currentXOffset.constant, currentYOffset.constant)
        let targetOffset = (leftContainerOffset.dx, leftContainerOffset.dy)
        
        return currentOffset == targetOffset
    }
    
    func isRightContainerActive() -> Bool {
        let currentOffset = (currentXOffset.constant, currentYOffset.constant)
        let targetOffset = (leftContainerOffset.dx, leftContainerOffset.dy)
        
        return currentOffset == targetOffset
    }
    
    func onDone(sender: AnyObject) {
        showCenterContainer()
    }
    
    func onShowCenterContainer(sender: AnyObject) {
        showCenterContainer()
    }
    
    func onShowTopContainer(sender: AnyObject) {
        showTopContainer()
    }
    
    func onShowBottomContainer(sender: AnyObject) {
        showBottomContainer()
    }
    
    func onShowLeftContainer(sender: AnyObject) {
        showLeftContainer()
    }
    
    func onShowRightContainer(sender: AnyObject) {
        showRightContainer()
    }
    
    // MARK: - Pan Gestures
    // called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    @IBAction private func onPanGestureTriggered(sender: UIPanGestureRecognizer) {
        switch sender.state {
            
        case .Began:
            /* Restrict pan movement
             * - top/bottom not allowed to pan horizontally
             * - left/right not allowed to pan vertically
             
             * Buttons may cause other containers to become active (don't rely on UIGestureRecognizerStateBegan to set direction)
             * - either set _activePanDirection in showXXXContainers or set it here
             */
            
            if isBottomContainerActive() || isTopContainerActive() {
                activePanDirection = .Vertical
            } else if isLeftContainerActive() || isRightContainerActive() {
                activePanDirection = .Horizontal
            } else {
                activePanDirection = .Undefined
            }
            
        case .Changed:
            /* Determine active direction if undefined
             * let horizontal take precedence in the case of equality
             * let direction be the more travelled one regardless of direction
             */
            
            // Update translation details
            let translationInMainView = sender.translationInView(view)
            
            // NOTE: x and y should be isolated
            if translationInMainView.x != 0 {
                previousNonZeroDirectionChange.dx = translationInMainView.x
            }
            
            if translationInMainView.y != 0 {
                previousNonZeroDirectionChange.dy = translationInMainView.y
            }
            
            switch activePanDirection {
            case .Undefined:
                activePanDirection = fabs(translationInMainView.x) > fabs(translationInMainView.y) ? .Horizontal : .Vertical
                
            case .Horizontal:
                // restraint accordingly to state
                // show container according to state OR if it's already showing through some other means (eg. button, etc)
                let isCurrentlyShowingRightViewController = currentXOffset.constant < centerContainerOffset.dx
                let isCurrentlyShowingLeftViewController = currentXOffset.constant > centerContainerOffset.dx
                let minX = isCurrentlyShowingRightViewController || shouldShowRightviewController ? rightContainerOffset.dx : centerContainerOffset.dx
                let maxX = isCurrentlyShowingLeftViewController || shouldShowLeftViewController ? leftContainerOffset.dx : centerContainerOffset.dx
                
                currentXOffset.constant = min(max(minX, currentXOffset.constant + translationInMainView.x), maxX)
                
            case .Vertical:
                // restraint accordingly to state
                // show container according to state OR if it's already showing through some other means (eg. button, etc)
                let isCurrentlyShowingBottomViewController = currentYOffset.constant < centerContainerOffset.dy
                let isCurrentlyShowingTopViewController = currentYOffset.constant > centerContainerOffset.dy
                let minY = isCurrentlyShowingBottomViewController || shouldShowBottomViewController ? bottomContainerOffset.dy : centerContainerOffset.dy
                let maxY = isCurrentlyShowingTopViewController || shouldshowTopViewController ? topContainerOffset.dy : centerContainerOffset.dy
                
                currentYOffset.constant = min(max(minY, currentYOffset.constant + translationInMainView.y), maxY)
            }
            
            // reset translation for next iteration
            sender.setTranslation(CGPointZero, inView: view)
            
        case .Ended:
            
            /*
             * Handle snapping here
             */
            switch activePanDirection {
            case .Horizontal:
                /* Snap to LEFT container  (positive x offset)
                 *
                 *      x0       x1
                 * 0----+--------+---->1
                 *  xxxx|        |xxx
                 *
                 * snap to 0 when < x0, snap to 1 when > x1
                 * center region: check previous pan vector's direction
                 *
                 */
                if currentXOffset.constant > 0.0 {
                    
                    // within range of center container
                    if currentXOffset.constant < (horizontalSnapThresholdFraction * view.frame.size.width) {
                        showCenterContainer()
                    }
                    
                    // within range of left container
                    else if currentXOffset.constant > ((1.0 - horizontalSnapThresholdFraction) * view.frame.size.width) {
                        showLeftContainer()
                    }
                    
                    // center region: depends on inertia direction
                    else {
                        // pulled right
                        if previousNonZeroDirectionChange.dx > 0.0 {
                            showLeftContainer()
                        }
                        
                        // pulled left
                        else {
                            showCenterContainer()
                        }
                    }
                }
                
                /* Snap to RIGHT container (negative x offset)
                 *
                 *        x1       x0
                 * -1<----+--------+----0
                 *    xxxx|        |xxx
                 *
                 * snap to 0 when > x0, snap to 1 when < x1
                 * center region: check previous pan vector's direction
                 *
                 */
                else if currentXOffset.constant < 0.0 {
                    
                    // within range of center container
                    if currentXOffset.constant > (horizontalSnapThresholdFraction * -view.frame.size.width) {
                        showCenterContainer()
                    }
                        
                    // within range of right container
                    else if currentXOffset.constant < ((1.0 - horizontalSnapThresholdFraction) * -view.frame.size.width) {
                        showRightContainer()
                    }
                        
                    // center region: depends on inertia direction
                    else {
                        // pulled left
                        if previousNonZeroDirectionChange.dx < 0.0 {
                            showRightContainer()
                        }
                            
                        // pulled left
                        else {
                            showCenterContainer()
                        }
                    }
                }
                
                
            case .Vertical:
                /* Snap to TOP container (positive y offset)
                 *
                 *      y0       y1
                 * 0----+--------+---->1
                 *  xxxx|        |xxx
                 *
                 * snap to 0 when < y0, snap to 1 when > y1
                 * center region: check previous pan vector's direction
                 *
                 */
                if currentYOffset.constant > 0.0 {
                    
                    // within range of center container
                    if currentYOffset.constant < (verticalSnapThresholdFraction * view.frame.size.height) {
                        showCenterContainer()
                    }
                        
                    // within range of top container
                    else if currentYOffset.constant > ((1.0 - verticalSnapThresholdFraction) * view.frame.size.height) {
                        showTopContainer()
                    }
                        
                    // center region: depends on inertia direction
                    else {
                        // pulled down
                        if previousNonZeroDirectionChange.dy > 0.0 {
                            showTopContainer()
                        }
                            
                        // pulled up
                        else {
                            showCenterContainer()
                        }
                    }
                }
                
                /* Snap to BOTTOM container (negative y offset)
                 *
                 *        y1       y0
                 * -1<----+--------+----0
                 *    xxxx|        |xxx
                 *
                 * snap to 0 when > y0, snap to 1 when < y1
                 * center region: check previous pan vector's direction
                 *
                 */
                else if currentYOffset.constant < 0.0 {
                    
                    // within range of center container
                    if currentYOffset.constant > (verticalSnapThresholdFraction * -view.frame.size.height) {
                        showCenterContainer()
                    }
                        
                    // within range of bottom container
                    else if currentYOffset.constant < ((1.0 - verticalSnapThresholdFraction) * -view.frame.size.height) {
                        showBottomContainer()
                    }
                        
                    // center region: depends on inertia direction
                    else {
                        // pulled up
                        if previousNonZeroDirectionChange.dy < 0.0 {
                            showBottomContainer()
                        }
                            
                        // pulled down
                        else {
                            showCenterContainer()
                        }
                    }
                }
                
            case .Undefined:
                // do nothing
                break
            }
        default:
            break
        }
    }
    
    /*
     * MARK: - Navigation
     *
     * - in a storyboard-based application, you will often want to do a little preparation before navigation
     * - in this case, prepareForSegue will be triggered on load due to embedded segues
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // for EmbeddedViewControllers are embedded in UINavigationControllers
        if let
            navController = segue.destinationViewController as? UINavigationController,
            embeddedViewController = navController.topViewController as? EmbeddedViewController {
                embeddedViewController.delegate = self
        }
        
        // for EmbeddedViewControllers are NOT embedded in UINavigationControllers
        else if let embeddedViewController = segue.destinationViewController as? EmbeddedViewController {
            embeddedViewController.delegate = self
        }
    }
}
