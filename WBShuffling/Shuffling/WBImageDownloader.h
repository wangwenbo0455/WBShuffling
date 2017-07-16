//
//  WBImageDownloader.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^WBDownLoadDataFinshedBlock)(NSData *data, NSError *error);
typedef void (^WBDownloadProgressBlock)(unsigned long long total, unsigned long long current);
typedef void (^WBCompletionImageBlock)(UIImage *image);

@interface WBImageDownloader : NSObject

@property (nonatomic, strong) NSURLSessionDownloadTask *task;

+ (WBImageDownloader *)sharedDownloader;

- (void)startDownloadImageWithUrl:(NSString *)url
                         progress:(WBDownloadProgressBlock)progress
                         finished:(WBDownLoadDataFinshedBlock)finished;

@end
