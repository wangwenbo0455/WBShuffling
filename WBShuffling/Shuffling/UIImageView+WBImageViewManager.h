//
//  UIImageView+WBImageViewManager.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBImageDownloader.h"


@interface UIImageView (WBImageViewManager)

@property (nonatomic, assign) NSInteger reloadTimesForFailedURL;
@property (nonatomic, weak) WBImageDownloader *imageDownLoader;

@property (nonatomic, copy) WBCompletionImageBlock completion;

- (void)wb_setImageWithURLString:(NSString *)url placeholderImage:(NSString *)placeholderImage;
- (void)wb_setImageWithURLString:(NSString *)url placeholder:(UIImage *)placeholderImage;
- (void)wb_setImageWithURLString:(NSString *)url
                  placeholder:(UIImage *)placeholderImage
                   completion:(void (^)(UIImage *image))completion;
- (void)wb_setImageWithURLString:(NSString *)url
             placeholderImage:(NSString *)placeholderImage
                   completion:(void (^)(UIImage *image))completion;


@end
