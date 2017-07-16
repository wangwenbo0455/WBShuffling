//
//  WBPageControl.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WBConfiguration.h"

@interface WBPageControl : NSObject

- (void)initViewWithNumberOfPages:(NSInteger)numberOfPages configuration:(WBConfiguration *)config addInView:(UIView *)superView;

- (void)updateCurrentPageWithIndex:(NSInteger)index;

@end
