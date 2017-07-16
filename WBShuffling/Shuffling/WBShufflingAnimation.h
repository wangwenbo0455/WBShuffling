//
//  WBShufflingAnimation.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBConfiguration.h"

@interface WBShufflingAnimation : NSObject

@property (nonatomic, assign) CarouselPushType pushAnimationType;

@property (nonatomic, strong) WBConfiguration *config;

- (void)updateDataWithConfiguration:(WBConfiguration *)config;

- (void)startAnimationInView:(UIView *)view;

@end
