//
//  SlideDownTransitionAnimator.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/16/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//


import UIKit

class SlideDownTransitionAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var animDuration = 0.3
    var isPresenting = false
    
    var interactive = false;
    
    var enterPanGesture: UIPanGestureRecognizer! {
        didSet {
            print("Did Set gesture")
            self.enterPanGesture.addTarget(self, action: #selector(handleOnstagePan(pan:)))
        }
    }
    
    var dismissPanGesture: UIPanGestureRecognizer! {
        didSet {
            print("Did Set gesture")
            self.dismissPanGesture.addTarget(self, action: #selector(handleOffstagePan(pan:)))
        }
    }
    
    var sourceViewController: UIViewController!
    var destinationViewController: NPViewController!
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animDuration
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        print("ANIMATE TRANSITION")
        
        guard let fromView = transitionContext.view(forKey: .from) else{
            return
        }
        guard let toView = transitionContext.view(forKey: .to) else{
            return
        }
        
        let container = transitionContext.containerView
        
        let offScreenUp = CGAffineTransform(translationX: 0, y: -container.frame.height)
        let offScreenDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        
        if(isPresenting){
            toView.transform = offScreenUp
        }
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        UIView.animate(withDuration: animDuration, delay: 0.0, animations: {
            if self.isPresenting {
                fromView.transform = offScreenDown
                fromView.alpha = 0.5
                toView.transform = CGAffineTransform.identity
                toView.alpha = 1.0
            }else{
                fromView.transform = offScreenUp
                fromView.alpha = 1.0
                toView.transform = CGAffineTransform.identity
                toView.alpha = 1.0
            }
            
        }) { (finished) in
            transitionContext.completeTransition(true)
        }
        
    }
    
    // TODO: We need to complete this method to do something useful
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        print("Todo: handle onstage gesture...")
        
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translation(in: pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.y / pan.view!.bounds.height * 0.1
        print("D: ", d)
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            // set our interactive flag to true
            self.interactive = true
            print("GESTURE BEGAN")
            
            // trigger the start of the transition
            self.sourceViewController.performSegue(withIdentifier: "showNowPlaying", sender: self)
            break
            
        case UIGestureRecognizerState.changed:
            
            // update progress of the transition
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            
            //To-Do: Finish Cancel Transition
            /*
             if(d > 0.2){
             // threshold crossed: finish
             self.finish()
             }
             else {
             // threshold not met: cancel
             self.cancel()
             }*/
            
            self.finish()
        }
    }
    
    // TODO: We need to complete this method to do something useful
    func handleOffstagePan(pan: UIPanGestureRecognizer){
        print("Todo: handle onstage gesture...")
        
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translation(in: pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.y / pan.view!.bounds.height * -0.1
        print("D: ", d)
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            // set our interactive flag to true
            self.interactive = true
            print("GESTURE BEGAN")
            
            // trigger the start of the transition
            self.destinationViewController.dismiss(animated: true, completion: nil)
            //self.destinationViewController.performSegue(withIdentifier: "showNowPlaying", sender: self)
            break
            
        case UIGestureRecognizerState.changed:
            
            // update progress of the transition
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            
            //To-Do: Finish Cancel Transition
            /*
             if(d > 0.2){
             // threshold crossed: finish
             self.finish()
             }
             else {
             // threshold not met: cancel
             self.cancel()
             }*/
            
            self.finish()
        }
    }
    
    
}


