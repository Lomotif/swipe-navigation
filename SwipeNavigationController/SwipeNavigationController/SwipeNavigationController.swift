//
//  SwipeNavigationController.swift
//  SwipeNavigationController
//
//  Created by Donald Lee on 28/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

public enum Position {
    case center
    case top
    case bottom
    case left
    case right
}

enum ActivePanDirection {
    case undefined
    case horizontal
    case vertical
}

// MARK: - SwipeNavigationControllerDelegate
/// SwipeNavigationControllerDelegate
public protocol SwipeNavigationControllerDelegate: class {
    
    /// Inform delegate that the embedded view will navigation to new position
    ///
    /// - Parameters:
    ///   - controller: Swipe navigation controller
    ///   - position: New position
    func swipeNavigationController(_ controller: SwipeNavigationController, willShowEmbeddedViewForPosition position: Position)
    
    /// Inform delegate that the embedded view had already navigated to new position
    ///
    /// - Parameters:
    ///   - controller: Swipe navigation controller
    ///   - position: New position
    func swipeNavigationController(_ controller: SwipeNavigationController, didShowEmbeddedViewForPosition position: Position)
}

// MARK: - SwipeNavigationController
/// SwipeNavigationController Class
open class SwipeNavigationController: UIViewController {
    
    // Mark: - Properties
    /*
     * The whole magic to this implementation:
     * manipulation of the x & y constraints of the center container view wrt the BaseViewController's
     *
     * The other (top, bottom, left, right) simply constrain themselves wrt to the center container
     */
    @IBOutlet fileprivate var currentXOffset: NSLayoutConstraint!
    @IBOutlet fileprivate var currentYOffset: NSLayoutConstraint!
    
    open fileprivate(set) weak var activeViewController: UIViewController!
    
    public weak var delegate: SwipeNavigationControllerDelegate?
    
    // Mark: View controllers
    open fileprivate(set) var centerViewController: UIViewController!
    
    // Append embedded view to container view's view hierachy
    open var topViewController: UIViewController? {
        willSet(newValue) {
            self.shouldShowTopViewController = newValue != nil
            guard let viewController = newValue else {
                return
            }
            addEmbeddedViewController(viewController, previousViewController: topViewController, position: .top)
        }
    }
    open var bottomViewController: UIViewController? {
        willSet(newValue) {
            self.shouldShowBottomViewController = newValue != nil
            guard let viewController = newValue else {
                return
            }
            addEmbeddedViewController(viewController, previousViewController: bottomViewController, position: .bottom)
        }
    }
    open var leftViewController: UIViewController? {
        willSet(newValue) {
            self.shouldShowLeftViewController = newValue != nil
            guard let viewController = newValue else {
                return
            }
            addEmbeddedViewController(viewController, previousViewController: leftViewController, position: .left)
        }
    }
    open var rightViewController: UIViewController? {
        willSet(newValue) {
            self.shouldShowRightViewController = newValue != nil
            guard let viewController = newValue else {
                return
            }
            addEmbeddedViewController(viewController, previousViewController: rightViewController, position: .right)
        }
    }
    
    // Manually call viewWillAppear, viewDidAppear, viewWillDisappear, viewDidDisappear function
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        get {
            return false
        }
    }
    
    // pan gesture recognizer related
    @IBOutlet fileprivate var mainPanGesture: UIPanGestureRecognizer!
    fileprivate var previousNonZeroDirectionChange = CGVector(dx: 0.0, dy: 0.0)
    fileprivate var activePanDirection = ActivePanDirection.undefined
    fileprivate let verticalSnapThresholdFraction: CGFloat = 0.15
    fileprivate let horizontalSnapThresholdFraction: CGFloat = 0.15
    
    // do not modify them, unfortunately they can't be declared with let due to value available only in viewDidLoad
    // implicitly unwrapped because they WILL be initialized during viewDidLoad
    fileprivate var centerContainerOffset: CGVector!
    fileprivate var topContainerOffset: CGVector!
    fileprivate var bottomContainerOffset: CGVector!
    fileprivate var leftContainerOffset: CGVector!
    fileprivate var rightContainerOffset: CGVector!
    
    // setting them to NO disables swiping to the view controller, try it!
    open var shouldShowTopViewController = true
    open var shouldShowBottomViewController = true
    open var shouldShowLeftViewController = true
    open var shouldShowRightViewController = true
    open var shouldShowCenterViewController = true
    
    fileprivate let swipeAnimateDuration = 0.2
    
    // Mark: - Initializers
    // Use this initializer if you are not using storyboard
    public init(centerViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        shouldShowTopViewController = false
        shouldShowBottomViewController = false
        shouldShowLeftViewController = false
        shouldShowRightViewController = false
        self.centerViewController = centerViewController
        addChildViewController(centerViewController)
        centerViewController.didMove(toParentViewController: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Mark: - Functions
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // if currentXOffset or currentYOffset is not set
        if currentXOffset == nil && currentYOffset == nil {
            view.addSubview(centerViewController.view)
            centerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.currentXOffset = alignCenterXConstraint(forItem: centerViewController.view, toItem: view, position: .center)
            self.currentYOffset = alignCenterYConstraint(forItem: centerViewController.view, toItem: view, position: .center)
            view.addConstraints([self.currentXOffset, self.currentYOffset])
            view.addConstraints(sizeConstraints(forItem: centerViewController.view, toItem: view))
        }
        
        assert(currentXOffset != nil && currentYOffset != nil, "both currentXOffset and currentYOffset must be set")
        
        // create pan gesture recognizer if it's nil
        if mainPanGesture == nil {
            mainPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGestureTriggered(sender:)))
            view.addGestureRecognizer(mainPanGesture)
        }
        
        // embedded containers offset
        let frameWidth = view.frame.size.width
        let frameHeight = view.frame.size.height
        // bookmark the offsets to specific positions
        centerContainerOffset = CGVector(dx: currentXOffset.constant, dy: currentYOffset.constant)
        topContainerOffset = CGVector(dx: centerContainerOffset.dx, dy: centerContainerOffset.dy + frameHeight)
        bottomContainerOffset = CGVector(dx: centerContainerOffset.dx, dy: centerContainerOffset.dy - frameHeight)
        leftContainerOffset = CGVector(dx: centerContainerOffset.dx + frameWidth, dy: centerContainerOffset.dy)
        rightContainerOffset = CGVector(dx: centerContainerOffset.dx - frameWidth, dy: centerContainerOffset.dy)
        
        // set default active view to center view
        activeViewController = centerViewController
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activeViewController.beginAppearanceTransition(true, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activeViewController.endAppearanceTransition()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activeViewController.beginAppearanceTransition(false, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activeViewController.endAppearanceTransition()
    }
    
    // Let UIKit handle rotation forwarding calls
    open override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    // MARK: - Containers
    open func showEmbeddedView(position: Position) {
        weak var disappearingViewController: UIViewController?
        let targetOffset: CGVector
        
        switch position {
        case .center:
            // if active view is center view, we are just doing snapping without switching to other embedded view, therefore disappearingViewController should be nil. Else, previous activeViewController value will be the disappearingViewController
            if !activeViewController.isEqual(centerViewController) {
                disappearingViewController = activeViewController
            }
            activeViewController = centerViewController
            targetOffset = centerContainerOffset
        case .top:
            activeViewController = topViewController
            targetOffset = topContainerOffset
        case .bottom:
            activeViewController = bottomViewController
            targetOffset = bottomContainerOffset
        case .left:
            activeViewController = leftViewController
            targetOffset = leftContainerOffset
        case .right:
            activeViewController = rightViewController
            targetOffset = rightContainerOffset
        }
        
        // if activeViewController value has changed, disappearingViewController will be centerViewController
        if !activeViewController.isEqual(centerViewController) {
            disappearingViewController = centerViewController
        }
        
        currentXOffset.constant = targetOffset.dx
        currentYOffset.constant = targetOffset.dy
        disappearingViewController?.beginAppearanceTransition(false, animated: true)
        activeViewController.beginAppearanceTransition(true, animated: true)
        delegate?.swipeNavigationController(self, willShowEmbeddedViewForPosition: position)
        UIView.animate(withDuration: swipeAnimateDuration, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.delegate?.swipeNavigationController(self, didShowEmbeddedViewForPosition: position)
            self.activeViewController.endAppearanceTransition()
            disappearingViewController?.endAppearanceTransition()
        }
    }
    
    open func isContainerActive(position: Position) -> Bool {
        let targetOffset: CGVector
        switch position {
        case .center:
            targetOffset = centerContainerOffset
        case .top:
            targetOffset = topContainerOffset
        case .bottom:
            targetOffset = bottomContainerOffset
        case .left:
            targetOffset = leftContainerOffset
        case .right:
            targetOffset = rightContainerOffset
        }
        return (currentXOffset.constant, currentYOffset.constant) == (targetOffset.dx, targetOffset.dy)
    }
    
    // MARK: - Pan Gestures
    // called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    @IBAction fileprivate func onPanGestureTriggered(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            /* Restrict pan movement
             * - top/bottom not allowed to pan horizontally
             * - left/right not allowed to pan vertically
             
             * Buttons may cause other containers to become active (don't rely on UIGestureRecognizerStateBegan to set direction)
             * - either set _activePanDirection in showXXXContainers or set it here
             */
            
            if isContainerActive(position: .top) || isContainerActive(position: .bottom) {
                activePanDirection = .vertical
            } else if isContainerActive(position: .left) || isContainerActive(position: .right) {
                activePanDirection = .horizontal
            } else {
                activePanDirection = .undefined
            }
            
        case .changed:
            /* Determine active direction if undefined
             * let horizontal take precedence in the case of equality
             * let direction be the more travelled one regardless of direction
             */
            
            // Update translation details
            let translationInMainView = sender.translation(in: view)
            
            // NOTE: x and y should be isolated
            if translationInMainView.x != 0 {
                previousNonZeroDirectionChange.dx = translationInMainView.x
            }
            
            if translationInMainView.y != 0 {
                previousNonZeroDirectionChange.dy = translationInMainView.y
            }
            
            switch activePanDirection {
            case .undefined:
                activePanDirection = fabs(translationInMainView.x) > fabs(translationInMainView.y) ? .horizontal : .vertical
                
            case .horizontal:
                // restraint accordingly to state
                // show container according to state OR if it's already showing through some other means (eg. button, etc)
                let isCurrentlyShowingRightViewController = currentXOffset.constant < centerContainerOffset.dx
                let isCurrentlyShowingLeftViewController = currentXOffset.constant > centerContainerOffset.dx
                let minX = isCurrentlyShowingRightViewController || shouldShowRightViewController ? rightContainerOffset.dx : centerContainerOffset.dx
                let maxX = isCurrentlyShowingLeftViewController || shouldShowLeftViewController ? leftContainerOffset.dx : centerContainerOffset.dx
                
                if shouldShowCenterViewController {
                    currentXOffset.constant = min(max(minX, currentXOffset.constant + translationInMainView.x), maxX)
                }
            case .vertical:
                // restraint accordingly to state
                // show container according to state OR if it's already showing through some other means (eg. button, etc)
                let isCurrentlyShowingBottomViewController = currentYOffset.constant < centerContainerOffset.dy
                let isCurrentlyShowingTopViewController = currentYOffset.constant > centerContainerOffset.dy
                let minY = isCurrentlyShowingBottomViewController || shouldShowBottomViewController ? bottomContainerOffset.dy : centerContainerOffset.dy
                let maxY = isCurrentlyShowingTopViewController || shouldShowTopViewController ? topContainerOffset.dy : centerContainerOffset.dy
                
                if shouldShowCenterViewController {
                    currentYOffset.constant = min(max(minY, currentYOffset.constant + translationInMainView.y), maxY)
                }
            }
            
            // reset translation for next iteration
            sender.setTranslation(CGPoint.zero, in: view)
            
        case .ended:
            /*
             * Handle snapping here
             */
            switch activePanDirection {
            case .horizontal:
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
                        showEmbeddedView(position: .center)
                    }
                        
                        // within range of left container
                    else if currentXOffset.constant > ((1.0 - horizontalSnapThresholdFraction) * view.frame.size.width) {
                        showEmbeddedView(position: .left)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled right
                        if previousNonZeroDirectionChange.dx > 0.0 {
                            showEmbeddedView(position: .left)
                        }
                            
                            // pulled left
                        else {
                            showEmbeddedView(position: .center)
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
                        showEmbeddedView(position: .center)
                    }
                        
                        // within range of right container
                    else if currentXOffset.constant < ((1.0 - horizontalSnapThresholdFraction) * -view.frame.size.width) {
                        showEmbeddedView(position: .right)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled left
                        if previousNonZeroDirectionChange.dx < 0.0 {
                            showEmbeddedView(position: .right)
                        }
                            
                            // pulled right
                        else {
                            showEmbeddedView(position: .center)
                        }
                    }
                }
                
            case .vertical:
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
                        showEmbeddedView(position: .center)
                    }
                        
                        // within range of top container
                    else if currentYOffset.constant > ((1.0 - verticalSnapThresholdFraction) * view.frame.size.height) {
                        showEmbeddedView(position: .top)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled down
                        if previousNonZeroDirectionChange.dy > 0.0 {
                            showEmbeddedView(position: .top)
                        }
                            
                            // pulled up
                        else {
                            showEmbeddedView(position: .center)
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
                        showEmbeddedView(position: .center)
                    }
                        
                        // within range of bottom container
                    else if currentYOffset.constant < ((1.0 - verticalSnapThresholdFraction) * -view.frame.size.height) {
                        showEmbeddedView(position: .bottom)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled up
                        if previousNonZeroDirectionChange.dy < 0.0 {
                            
                            showEmbeddedView(position: .bottom)
                        }
                            
                            // pulled down
                        else {
                            showEmbeddedView(position: .center)
                        }
                    }
                }
                
            case .undefined:
                // do nothing
                break
            }
        default:
            break
        }
    }
    
    // Append embedded view to container view's view hierachy
    func addEmbeddedViewController(_ viewController: UIViewController, previousViewController: UIViewController?, position: Position) {
        if viewController.isEqual(previousViewController) {
            return
        }
        
        previousViewController?.beginAppearanceTransition(false, animated: false)
        previousViewController?.view.removeFromSuperview()
        previousViewController?.endAppearanceTransition()
        previousViewController?.willMove(toParentViewController: nil)
        previousViewController?.removeFromParentViewController()
        
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        view.sendSubview(toBack: viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.didMove(toParentViewController: self)
        view.addConstraint(alignCenterXConstraint(forItem: viewController.view, toItem: centerViewController.view, position: position))
        view.addConstraint(alignCenterYConstraint(forItem: viewController.view, toItem: centerViewController.view, position: position))
        view.addConstraints(sizeConstraints(forItem: viewController.view, toItem: centerViewController.view))
    }
    
    // MARK: - Layout Constraints
    // Create a layout constraint that make view item to align center x to the respective item with offset according to the position
    // For view item that is positioned on the left will offset by -toItem.width, and +toItem.width if it's positioned on the right
    func alignCenterXConstraint(forItem item: UIView, toItem: UIView, position: Position) -> NSLayoutConstraint {
        let offset = position == .left ? -self.view.frame.width : position == .right ? toItem.frame.width : 0
        return NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: toItem, attribute: .centerX, multiplier: 1, constant: offset)
    }
    
    // Create a layout constraint that make view item to align center y to the respective item height offset according to the position
    // For view item that is positioned on the top will offset by -toItem.height, and +toItem.height if it's positioned on the right
    func alignCenterYConstraint(forItem item: UIView, toItem: UIView, position: Position) -> NSLayoutConstraint {
        let offset = position == .top ? -self.view.frame.height : position == .bottom ? toItem.frame.height : 0
        return NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: toItem, attribute: .centerY, multiplier: 1, constant: offset)
    }
    
    // Create width and height layout constraints that make make the item.size same as the toItem.size
    func sizeConstraints(forItem item: UIView, toItem: UIView) -> [NSLayoutConstraint] {
        let widthConstraint = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: toItem, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: toItem, attribute: .height, multiplier: 1, constant: 0)
        return [widthConstraint, heightConstraint]
    }
    
}
