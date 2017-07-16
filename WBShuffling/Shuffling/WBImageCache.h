//
//  WBImageCache.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const WBDidSettingTime;

//#define kDebugLog

@interface WBImageCache : NSObject

+ (WBImageCache *)sharedImageCache;

@property (nonatomic, strong) NSMutableDictionary *wb_cacheFaileTimesDict;

- (UIImage *)wb_cacheImageForRequest:(NSURLRequest *)request;
- (void)wb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
- (void)wb_cacheFailRequest:(NSURLRequest *)request;
- (NSUInteger)wb_failTimesForRequest:(NSURLRequest *)request;

- (void)wb_clearCacheFaileTimesDict;
- (void)wb_clearDiskCaches;

/**
 超时清除缓存，可以在App启动时设置，以后就会定时清除轮播的缓存

 @param time 超时时间（单位为h）
 */
- (void)wb_clearDiskCachesWithTimeout:(NSTimeInterval)time;


/**
 修改超时清除缓存的时间

 @param time 重新设定的超时时间（单位为h）
 */
- (void)wb_changeDiskCacheWithTimeout:(NSTimeInterval)time;



@end
