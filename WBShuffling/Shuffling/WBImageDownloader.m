//
//  WBImageDownloader.m
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import "WBImageDownloader.h"


@interface WBImageDownloader ()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic, assign) unsigned long long currentLength;
@property (nonatomic, copy) WBDownloadProgressBlock progressBlock;
@property (nonatomic, copy) WBDownLoadDataFinshedBlock callbackOnFinished;

@end

@implementation WBImageDownloader

+ (WBImageDownloader *)sharedDownloader {
    static WBImageDownloader *instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}


- (void)startDownloadImageWithUrl:(NSString *)url
                         progress:(WBDownloadProgressBlock)progress
                         finished:(WBDownLoadDataFinshedBlock)finished {
    self.progressBlock = progress;
    self.callbackOnFinished = finished;
    
    if ([NSURL URLWithString:url] == nil) {
        if (finished) {
            finished(nil, [NSError errorWithDomain:@"Dely"
                                              code:101
                                          userInfo:@{@"errorMessage": @"URL不正确"}]);
        }
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:60];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    self.session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:queue];
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
    [task resume];
    self.task = task;
}


#pragma mark ------------NSURLSessionDownloadDelegate--------------

//完成下载
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
    
    if (self.callbackOnFinished) {
        self.callbackOnFinished(data, nil);
        
        // 防止重复调用
        self.callbackOnFinished = nil;
    }
}

//正在下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

//下载失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ([error code] != NSURLErrorCancelled) {
        if (self.callbackOnFinished) {
            self.callbackOnFinished(nil, error);
        }
        
        self.callbackOnFinished = nil;
    }
}



@end
