//
//  WBShufflingAnimation.m
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import "WBShufflingAnimation.h"

@implementation WBShufflingAnimation

- (void)updateDataWithConfiguration:(WBConfiguration *)config{
    self.config = config;
    self.pushAnimationType = config.pushAnimationType;
}

- (void)startAnimationInView:(UIView *)view{
    if (self.pushAnimationType < 5){
        //UIView Animation
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:1];
        
        switch (self.pushAnimationType) {
            case PushCurlUp:
                [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:view cache:YES];
                break;
            case PushCurlDown:
                [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:view cache:YES];
                break;
            case PushFilpFromLeft:
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:YES];
                break;
            case PushFilpFromRight:
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:view cache:YES];
                break;
            default:
                break;
        }
        
        [UIView commitAnimations];
    } else {
        
        //core animation
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        
        switch (self.pushAnimationType) {
            case PushFade:
                animation.type = kCATransitionFade;
                break;
            case PushMoveIn:
                animation.type = kCATransitionMoveIn;
                break;
            case PushReveal:
                animation.type = kCATransitionReveal;
                break;
            case PushPush:
                animation.type = kCATransitionPush;
                break;
            case PushCube:
                animation.type = @"cube";
                break;
            case PushPageCurl:
                animation.type = @"pageCurl";
                break;
            case PushPageUnCurl:
                animation.type = @"pageUnCurl";
                break;
            case PushSuckEffect:
                animation.type = @"suckEffect";
                break;
            case PushRippleEffect:
                animation.type = @"rippleEffect";
                break;
            case PushCameraIrisHollowOpen:
                animation.type = @"cameraIrisHollowOpen";
                break;
            case PushCameraIrisHollowClose:
                animation.type = @"cameraIrisHollowClose";
                break;
                
            default:
                break;
        }
        
        if (self.config.animationSubtype) {
            animation.subtype = self.config.animationSubtype;
        }else{
            animation.subtype = kCATransitionFromRight;
        }
        
        [view.layer addAnimation:animation forKey:@"animation"];
    }

}

@end
