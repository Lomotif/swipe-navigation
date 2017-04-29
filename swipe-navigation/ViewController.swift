//
//  ViewController.swift
//  swipe-navigation
//
//  Created by Donald Lee on 28/6/16.
//  Copyright © 2016 Donald Lee. All rights reserved.
//

import UIKit

enum ActivePanDirection {
	case undefined
	case horizontal
	case vertical
}

class ViewController: UIViewController, EmbeddedViewControllerDelegate, UIGestureRecognizerDelegate {
	
	// Mark: - Properties
	/*
	* The whole magic to this implementation:
	* manipulation of the x & y constraints of the center container view wrt the BaseViewController's
	*
	* The other (top, bottom, left, right) simply constrain themselves wrt to the center container
	*/
	@IBOutlet fileprivate var currentXOffset: NSLayoutConstraint!
	@IBOutlet fileprivate var currentYOffset: NSLayoutConstraint!
	
	// Mark: View controllers
	fileprivate(set) var centerViewController: UIViewController!
	
	// Append embedded view to container view's view hierachy
	var topViewController: UIViewController? {
		willSet(newValue) {
			self.shouldshowTopViewController = newValue != nil
			topViewController?.view.removeFromSuperview()
			guard let viewController = newValue else {
				return
			}
			addEmbeddedViewController(viewController, position: .top)
		}
	}
	var bottomViewController: UIViewController? {
		willSet(newValue) {
			self.shouldShowBottomViewController = newValue != nil
			bottomViewController?.view.removeFromSuperview()
			guard let viewController = newValue else {
				return
			}
			addEmbeddedViewController(viewController, position: .bottom)
		}
	}
	var leftViewController: UIViewController? {
		willSet(newValue) {
			self.shouldShowLeftViewController = newValue != nil
			leftViewController?.view.removeFromSuperview()
			guard let viewController = newValue else {
				return
			}
			addEmbeddedViewController(viewController, position: .left)
		}
	}
	var rightViewController: UIViewController? {
		willSet(newValue) {
			self.shouldShowRightviewController = newValue != nil
			rightViewController?.view.removeFromSuperview()
			guard let viewController = newValue else {
				return
			}
			addEmbeddedViewController(viewController, position: .right)
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
	var shouldshowTopViewController = true
	var shouldShowBottomViewController = true
	var shouldShowLeftViewController = true
	var shouldShowRightviewController = true
	
	fileprivate let swipeAnimateDuration = 0.2
	
	// Mark: - Initializers
	// Use this initializer if you are not using storyboard
	init(centerViewController: UIViewController) {
		super.init(nibName: nil, bundle: nil)
		shouldshowTopViewController = false
		shouldShowBottomViewController = false
		shouldShowLeftViewController = false
		shouldShowRightviewController = false
		self.centerViewController = centerViewController
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// Mark: - Functions
	override func viewDidLoad() {
		//
		if currentXOffset == nil || currentYOffset == nil {
			view.addSubview(centerViewController.view)
			centerViewController.view.translatesAutoresizingMaskIntoConstraints = false
			centerViewController.view.backgroundColor = UIColor.blue
			self.currentXOffset = alignCenterXConstraint(forItem: centerViewController.view, toItem: view, position: .center)
			self.currentYOffset = alignCenterYConstraint(forItem: centerViewController.view, toItem: view, position: .center)
			view.addConstraints([self.currentXOffset, self.currentYOffset])
			view.addConstraints(sizeConstraints(forItem: centerViewController.view, toItem: view))
		}
		
		if mainPanGesture == nil {
			mainPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGestureTriggered(_:)))
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
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hide navigation bar when navigating into this view controller
		navigationController?.setNavigationBarHidden(true, animated: animated)
		
		// Disable "Back" title on the navigation bar in child view controller.
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Show navigation bar when navigating away from this view controller.
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	// MARK: - Containers
	fileprivate func showContainer(_ position: Position) {
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
		
		currentXOffset.constant = targetOffset.dx
		currentYOffset.constant = targetOffset.dy
		UIView.animate(withDuration: swipeAnimateDuration, animations: {
			self.view.layoutIfNeeded()
		})
	}
	
	// MARK: - EmbeddedViewcontrollerDelegate Conformance
	func isContainerActive(_ position: Position) -> Bool {
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
	
	func onDone(_ sender: AnyObject) {
		showContainer(.center)
	}
	
	func onShowContainer(_ position: Position, sender: AnyObject) {
		showContainer(position)
	}
	
	// MARK: - Pan Gestures
	// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return true
	}
	
	@IBAction @objc fileprivate func onPanGestureTriggered(_ sender: UIPanGestureRecognizer) {
		switch sender.state {
		case .began:
			/* Restrict pan movement
			* - top/bottom not allowed to pan horizontally
			* - left/right not allowed to pan vertically
			
			* Buttons may cause other containers to become active (don't rely on UIGestureRecognizerStateBegan to set direction)
			* - either set _activePanDirection in showXXXContainers or set it here
			*/
			
			if isContainerActive(.top) || isContainerActive(.bottom) {
				activePanDirection = .vertical
			} else if isContainerActive(.left) || isContainerActive(.right) {
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
				let minX = isCurrentlyShowingRightViewController || shouldShowRightviewController ? rightContainerOffset.dx : centerContainerOffset.dx
				let maxX = isCurrentlyShowingLeftViewController || shouldShowLeftViewController ? leftContainerOffset.dx : centerContainerOffset.dx
				
				currentXOffset.constant = min(max(minX, currentXOffset.constant + translationInMainView.x), maxX)
				
			case .vertical:
				// restraint accordingly to state
				// show container according to state OR if it's already showing through some other means (eg. button, etc)
				let isCurrentlyShowingBottomViewController = currentYOffset.constant < centerContainerOffset.dy
				let isCurrentlyShowingTopViewController = currentYOffset.constant > centerContainerOffset.dy
				let minY = isCurrentlyShowingBottomViewController || shouldShowBottomViewController ? bottomContainerOffset.dy : centerContainerOffset.dy
				let maxY = isCurrentlyShowingTopViewController || shouldshowTopViewController ? topContainerOffset.dy : centerContainerOffset.dy
				
				currentYOffset.constant = min(max(minY, currentYOffset.constant + translationInMainView.y), maxY)
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
						showContainer(.center)
					}
						
						// within range of left container
					else if currentXOffset.constant > ((1.0 - horizontalSnapThresholdFraction) * view.frame.size.width) {
						showContainer(.left)
					}
						
						// center region: depends on inertia direction
					else {
						// pulled right
						if previousNonZeroDirectionChange.dx > 0.0 {
							showContainer(.left)
						}
							
							// pulled left
						else {
							showContainer(.center)
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
						showContainer(.center)
					}
						
						// within range of right container
					else if currentXOffset.constant < ((1.0 - horizontalSnapThresholdFraction) * -view.frame.size.width) {
						showContainer(.right)
					}
						
						// center region: depends on inertia direction
					else {
						// pulled left
						if previousNonZeroDirectionChange.dx < 0.0 {
							showContainer(.right)
						}
							
							// pulled right
						else {
							showContainer(.center)
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
						showContainer(.center)
					}
						
						// within range of top container
					else if currentYOffset.constant > ((1.0 - verticalSnapThresholdFraction) * view.frame.size.height) {
						showContainer(.top)
					}
						
						// center region: depends on inertia direction
					else {
						// pulled down
						if previousNonZeroDirectionChange.dy > 0.0 {
							showContainer(.top)
						}
							
							// pulled up
						else {
							showContainer(.center)
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
						showContainer(.center)
					}
						
						// within range of bottom container
					else if currentYOffset.constant < ((1.0 - verticalSnapThresholdFraction) * -view.frame.size.height) {
						showContainer(.bottom)
					}
						
						// center region: depends on inertia direction
					else {
						// pulled up
						if previousNonZeroDirectionChange.dy < 0.0 {
							showContainer(.bottom)
						}
							
							// pulled down
						else {
							showContainer(.center)
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
	func addEmbeddedViewController(_ viewController: UIViewController, position: Position) {
		(viewController as? EmbeddedViewController)?.delegate = self
		view.addSubview(viewController.view)
		viewController.view.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraint(alignCenterXConstraint(forItem: viewController.view, toItem: centerViewController.view, position: position))
		view.addConstraint(alignCenterYConstraint(forItem: viewController.view, toItem: centerViewController.view, position: position))
		view.addConstraints(sizeConstraints(forItem: viewController.view, toItem: centerViewController.view))
		view.layoutIfNeeded()
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
	
	/*
	* MARK: - Navigation
	*
	* - in a storyboard-based application, you will often want to do a little preparation before navigation
	* - in this case, prepareForSegue will be triggered on load due to embedded segues
	*/
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// for EmbeddedViewControllers are embedded in UINavigationControllers
		if let
			navController = segue.destination as? UINavigationController,
			let embeddedViewController = navController.topViewController as? EmbeddedViewController {
			embeddedViewController.delegate = self
		}
			
			// for EmbeddedViewControllers are NOT embedded in UINavigationControllers
		else if let embeddedViewController = segue.destination as? EmbeddedViewController {
			embeddedViewController.delegate = self
		}
	}
}
