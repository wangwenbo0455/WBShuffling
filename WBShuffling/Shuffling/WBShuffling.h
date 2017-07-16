//
//  WBShuffling.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBConfiguration.h"
#import "WBPageControl.h"
@protocol WBShufflingDelegate <NSObject>

@optional
- (void)shufflingViewClick:(NSInteger)index;

@end

@interface WBShuffling : UIView
/**
 block方式回调初始化
 
 @param frame       frame
 @param configBlock 轮播属性配置（可以为nil，为nil时采用默认的配置）
 @param clickBlock  点击回调
 
 @return carousel
 */
- (instancetype)initWithFrame:(CGRect)frame
                  configBlock:(CarouselConfigurationBlock)configBlock
                   clickBlock:(CarouselClickBlock)clickBlock;


/**
 delegate方式回调初始化
 
 @param frame       frame
 @param configBlock 轮播属性配置（可以为nil，为nil时采用默认的配置）
 @param target      delegate
 
 @return carousel
 */
- (instancetype)initWithFrame:(CGRect)frame
                  configBlock:(CarouselConfigurationBlock)configBlock
                       target:(id<WBShufflingDelegate>)target;




#pragma mark - ==============开始轮播==============

/**
 start Carousel
 
 @param imageArray imageArray(里面可以存放UIImage对象、NSString对象【本地图片名】、NSURL对象【远程图片的URL】)
 */
- (void)startCarouselWithArray:(NSMutableArray *)imageArray;


/**
 start Carousel With new Config（更新轮播配置，新的样式轮播）
 
 @param configBlock 轮播属性配置（可以为nil，为nil时采用之前默认的配置）
 */
- (void)startCarouselWithNewConfig:(CarouselConfigurationBlock)configBlock array:(NSMutableArray *)imageArray;

@end
