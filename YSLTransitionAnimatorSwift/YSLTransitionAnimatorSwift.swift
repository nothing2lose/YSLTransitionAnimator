//
//  YSLTransitionAnimatorSwift.swift
//  YSLTransitionAnimatorDemo
//
//  Created by jeju on 2015. 9. 18..
//  Copyright © 2015년 h.yamaguchi. All rights reserved.
//

import Foundation
import UIKit
//weak public var delegate: UITableViewDelegate?

@objc protocol YSLTransitionAnimatorDataSource: NSObjectProtocol  {
func pushTransitionImageView() -> UIImageView?
func popTransitionImageView() -> UIImageView?
}


@objc class YSLTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var isForward: Bool = false
    var animationDuration: NSTimeInterval = 0.3
    var toViewControllerImagePointY: CGFloat = 0
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.animationDuration;
    }

    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) -> Void {
        let fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        let duration = self.transitionDuration(transitionContext)
        
        let fromTransitionImage: UIImageView! = self.isForward ? (fromViewController as! YSLTransitionAnimatorDataSource).pushTransitionImageView() : (fromViewController as! YSLTransitionAnimatorDataSource).popTransitionImageView()
        let imageSnapshot: UIImageView = UIImageView(image: fromTransitionImage.image)
        imageSnapshot.layer.cornerRadius = fromTransitionImage.layer.cornerRadius
        
        imageSnapshot.frame = containerView!.convertRect(fromTransitionImage.frame, fromView: fromTransitionImage.superview)
        fromTransitionImage.hidden = true
        
        let toTransitionImage = self.isForward ? (toViewController as! YSLTransitionAnimatorDataSource).popTransitionImageView() : (toViewController as! YSLTransitionAnimatorDataSource).pushTransitionImageView()
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController as UIViewController)
        
        if true == self.isForward {
            toViewController.view.alpha = 0
            containerView?.addSubview(toViewController.view)
            toTransitionImage?.hidden = true
            toTransitionImage?.image = fromTransitionImage.image
            containerView?.addSubview(imageSnapshot)
            

            UIView.animateWithDuration(duration, animations: { () -> Void in
                toViewController.view.alpha = 1.0
                var frame: CGRect = (containerView?.convertRect((toTransitionImage?.frame)!, fromView: toViewController.view))!
                frame.origin.y = self.toViewControllerImagePointY
                imageSnapshot.frame = frame
                imageSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
                }, completion: { (completion: Bool) -> Void in
                
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        imageSnapshot.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        }, completion: { (completion: Bool) -> Void in
                        imageSnapshot.removeFromSuperview()
                            fromTransitionImage.hidden = false
                            toTransitionImage?.hidden = false
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                    })
                    
            });
        } else {
            // pop animation
            toTransitionImage?.hidden = true
            containerView?.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            containerView?.addSubview(imageSnapshot)
            UIView.animateWithDuration(duration, animations: { () -> Void in
                fromViewController.view.alpha = 0.0
                imageSnapshot.frame = (containerView?.convertRect((toTransitionImage?.frame)!, fromView: toTransitionImage!.superview))!
                
                }, completion: { (completion: Bool) -> Void in
                    imageSnapshot.removeFromSuperview()
                    fromTransitionImage.hidden = false
                    toTransitionImage?.hidden = false
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
        

    }
}
