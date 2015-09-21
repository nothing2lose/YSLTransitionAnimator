//
//  UIViewController+YSLTransition.swift
//  YSLTransitionAnimatorDemo
//
//  Created by jeju on 2015. 9. 18..
//  Copyright © 2015년 h.yamaguchi. All rights reserved.
//

import Foundation
import UIKit

var AOPopTranstionHandle: UInt8 = 0
var AOScrollViewHandle: UInt8 = 0
var AOToViewControllerImagePointYHandle: UInt8 = 0
var AOCancelAnimationPointYHandle: UInt8 = 0
var AOAnimationDuration: UInt8 = 0
var isScrollView = false
extension UIViewController: UINavigationControllerDelegate {
    // MARK:- Properties
    var interactivePopTransition: UIPercentDrivenInteractiveTransition? {
        get {
            return objc_getAssociatedObject(self, &AOPopTranstionHandle) as? UIPercentDrivenInteractiveTransition
        }
        set {
            objc_setAssociatedObject(self, &AOPopTranstionHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var yslScrollView: UIScrollView? {
        get {
            return objc_getAssociatedObject(self, &AOScrollViewHandle) as! UIScrollView?
        }
        set {
            objc_setAssociatedObject(self, &AOScrollViewHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var toViewControllerImagePointY: NSNumber? {
        get {
            return objc_getAssociatedObject(self, &AOToViewControllerImagePointYHandle) as! NSNumber?
        }
        set {
            objc_setAssociatedObject(self, &AOToViewControllerImagePointYHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var cancelAnimationPointY: NSNumber? {
        get {
            return objc_getAssociatedObject(self, &AOCancelAnimationPointYHandle) as! NSNumber?
        }
        set {
            objc_setAssociatedObject(self, &AOCancelAnimationPointYHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var animationDuration: NSNumber? {
        get {
            return objc_getAssociatedObject(self , &AOAnimationDuration) as! NSNumber?
        }
        set {
            objc_setAssociatedObject(self, &AOAnimationDuration, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK:- P6ublic methods
    func ysl_pushTransitionAnimationWithToViewControllerImagePointY(toViewControllerImagePointY: CGFloat, animationDuration: CGFloat) -> Void{
        self.toViewControllerImagePointY = NSNumber(float: Float(toViewControllerImagePointY))
        self.animationDuration = NSNumber(float: Float(animationDuration))
    }
    
    func ysl_popTransitionAnimationWithCurrentScrollView(scrollView: UIScrollView?, cancelAnimationPointY: CGFloat, animationDuration: CGFloat, isInteractiveTransition: Bool) -> Void {
        if let sc = scrollView {
            self.yslScrollView = sc
            isScrollView = true
        }
        
        self.cancelAnimationPointY = NSNumber(float: Float(cancelAnimationPointY))
        self.animationDuration = NSNumber(float: Float(animationDuration))
        if true == isInteractiveTransition {
            let popRecognizer: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handlePopRecognizer:"))
            popRecognizer.edges = UIRectEdge.Left
            self.view.addGestureRecognizer(popRecognizer)
        }
    }
    
    func ysl_addTransitionDelegate(viewController: UIViewController?) {
        self.navigationController?.delegate = self as UINavigationControllerDelegate
        if let vc = viewController {
            if vc.isKindOfClass(UITableViewController) {
                let viewController = vc as! UITableViewController
                viewController.clearsSelectionOnViewWillAppear = false
            } else if vc.isKindOfClass(UICollectionViewController) {
                let viewController = vc as! UICollectionViewController
                viewController.clearsSelectionOnViewWillAppear = false
            }
        }
    }
    
    func ysl_removeTransitionDelegate() {
        if let delegate = self.navigationController?.delegate where delegate === self  {
            self.navigationController?.delegate = nil
        }
    }
    
    
    // MARK:- UINavigationControllerDelegate
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if nil == self.interactivePopTransition {
            return nil
        }
        return self.interactivePopTransition
    }
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = fromVC as? YSLTransitionAnimatorDataSource, _ = toVC as? YSLTransitionAnimatorDataSource {
            if operation == UINavigationControllerOperation.Push {
                if operation != UINavigationControllerOperation.Push { return nil }
                
                let animator: YSLTransitionAnimator = YSLTransitionAnimator()
                animator.isForward = (operation == UINavigationControllerOperation.Push)
                
                if let pointY = self.toViewControllerImagePointY {
                    animator.toViewControllerImagePointY = CGFloat(pointY)
                }
                if let animDuration = self.animationDuration {
                    animator.animationDuration = animDuration.doubleValue as NSTimeInterval
                }
                return animator                
            } else if (operation == UINavigationControllerOperation.Pop) {
                if operation != UINavigationControllerOperation.Pop { return nil }
                
                if let cancelAnimPointY = self.cancelAnimationPointY, scrollView = self.yslScrollView where cancelAnimPointY.floatValue != 0 &&  true == isScrollView {
                    if Double(scrollView.contentOffset.y) > cancelAnimPointY.doubleValue {
                        return nil
                    }
                }
                
                let animator: YSLTransitionAnimator = YSLTransitionAnimator()
                animator.isForward = (operation == UINavigationControllerOperation.Push)
                if let animDuration = self.animationDuration {
                    animator.animationDuration = animDuration.doubleValue as NSTimeInterval
                }
                return animator
                
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK:- UIGestureRecognizer handlers
    func handlePopRecognizer(recognizer: UIScreenEdgePanGestureRecognizer) {
        var progress: CGFloat = recognizer .translationInView(self.view).x / (self.view.bounds.size.width)
        progress =  min(1.0, max(0.0, progress))
        
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            self.interactivePopTransition = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewControllerAnimated(true)
            break
        case UIGestureRecognizerState.Changed:
            self.interactivePopTransition?.updateInteractiveTransition(progress)
            break
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            if progress > 0.5 {
                self.interactivePopTransition?.finishInteractiveTransition()
            } else {
                self.interactivePopTransition?.cancelInteractiveTransition()
            }
            self.interactivePopTransition = nil
            break
        default: ()
        }
        
    }
    
}