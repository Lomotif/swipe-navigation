# SwipeNavigationController
SwipeNavigationController is a Snapchat like 4-way swipe navigation in Swift for iOS

Feel free to contribute by submiting PRs!

# Installation
If install using cocoapods, include this in your pod file and run ```pod install```:
##Swift 3.0:
```ruby
pod 'SwipeNavigationController', '~> 2.0.0'
```
##Swift 2.3:
```ruby
pod 'SwipeNavigationController', '~> 1.1.0'
```

Carthage is currently not supported.


# Usage
In your code, ```import SwipeNavigationController```, and create a SwipeNavigationController that enables 4 directions swipe navigation: 
```swift
let swipeNavigationController = SwipeNavigationController(centerViewController: CenterViewController())
swipeNavigationController.topViewController = TopViewController()
swipeNavigationController.bottomViewController = BottomViewController()
swipeNavigationController.leftViewController = LeftViewController()
swipeNavigationController.rightViewController = RightViewController()
```
Setting of view controllers value for all directions are optional. View controller set for respective direction will enable swipe by default, to disable swipe for direction use:
```swift
swipeNavigationController.shouldShowTopViewController = false
swipeNavigationController.shouldShowBottomViewController = false
swipeNavigationController.shouldShowLeftViewController = false
swipeNavigationController.shouldShowRightViewController = false
```
To show embedded view controller manually without using the gesture, in your center view controller use:
```swift
self.containerSwipeNavigationController.showEmbeddedView(.top)
self.containerSwipeNavigationController.showEmbeddedView(.bottom)
self.containerSwipeNavigationController.showEmbeddedView(.left)
self.containerSwipeNavigationController.showEmbeddedView(.right)
```
To receive callback when the embedded view moves to new position, your view controller will need to conform to SwipeNavigationControllerDelegate and implement the following functions:
```swift
/// Callback when embedded view started moving to new position
func swipeNavigationController(_ controller: SwipeNavigationController, willShowEmbeddedViewForPosition position: Position) {
}

/// Callback when embedded view had moved to new position
func swipeNavigationController(_ controller: SwipeNavigationController, didShowEmbeddedViewForPosition position: Position) {
}
```

License
---
The MIT License (MIT)

Copyright (c) 2016

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
