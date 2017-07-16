//
//  UIImageView+WBImageViewManager.m
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import "UIImageView+WBImageViewManager.h"
#import <objc/runtime.h>
#import "WBImageCache.h"

@implementation UIImageView (WBImageViewManager)

//reloadTimesForFailedURL的set和get方法
- (void)setReloadTimesForFailedURL:(NSInteger)reloadTimesForFailedURL{
    SEL key = @selector(reloadTimesForFailedURL);
    objc_setAssociatedObject(self, key, @(reloadTimesForFailedURL), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)reloadTimesForFailedURL{
    NSInteger times = [objc_getAssociatedObject(self, _cmd) integerValue];
    
    return (times<=0)?2:times;
}
//imageDownLoader的set和get方法
- (void)setImageDownLoader:(WBImageDownloader *)imageDownLoader{
    SEL key = @selector(imageDownLoader);
    objc_setAssociatedObject(self, key, imageDownLoader, OBJC_ASSOCIATION_RETAIN);
}

- (WBImageDownloader *)imageDownLoader{
    return objc_getAssociatedObject(self, _cmd);
}

//completion的set和get方法
- (void)setCompletion:(WBCompletionImageBlock)completion{
    SEL key = @selector(completion);
    objc_setAssociatedObject(self, key, completion, OBJC_ASSOCIATION_COPY);
}

- (WBCompletionImageBlock)completion{
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setImage:(UIImage *)image isFromCache:(BOOL)isFromCache {
    self.image = image;
    
    if (!isFromCache) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.65f];
        [animation setType:kCATransitionFade];
        animation.removedOnCompletion = YES;
        [self.layer addAnimation:animation forKey:@"transition"];
    }
}

- (void)wb_setImageWithURLString:(NSString *)url placeholder:(UIImage *)placeholderImage{
    [self wb_setImageWithURLString:url placeholder:placeholderImage completion:nil];
    
}
- (void)wb_setImageWithURLString:(NSString *)url placeholderImage:(NSString *)placeholderImage{
    UIImage *image = [UIImage imageNamed:placeholderImage];
    [self wb_setImageWithURLString:url placeholder:image completion:nil];
}

- (void)wb_setImageWithURLString:(NSString *)url placeholderImage:(NSString *)placeholderImage completion:(void (^)(UIImage *))completion{
     UIImage *image = [UIImage imageNamed:placeholderImage];
    [self wb_setImageWithURLString:url placeholder:image completion:completion];
}

- (void)wb_setImageWithURLString:(NSString *)url
                  placeholder:(UIImage *)placeholderImage
                   completion:(void (^)(UIImage *image))completion {
    [self.layer removeAllAnimations];
    if (completion) {
        self.completion = completion;
    }
    
    if (url == nil
        || [url isKindOfClass:[NSNull class]]
        || (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"])) {
        [self setImage:placeholderImage isFromCache:YES];
        
        if (completion) {
            self.completion(self.image);
        }
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self downloadWithReqeust:request holder:placeholderImage];
}

- (void)downloadWithReqeust:(NSURLRequest *)theRequest holder:(UIImage *)holder {
    UIImage *cachedImage = [[WBImageCache sharedImageCache] wb_cacheImageForRequest:theRequest];
    
    if (cachedImage) {
        [self setImage:cachedImage isFromCache:YES];
        
        if (self.completion) {
            self.completion(cachedImage);
        }
        return;
    }
    
    [self setImage:holder isFromCache:YES];
    
    
    
    if ([[WBImageCache sharedImageCache] wb_failTimesForRequest:theRequest] >= self.reloadTimesForFailedURL) {
        return;
    }
    
    [self cancelRequest];
    self.imageDownLoader = nil;
    
    __weak __typeof(self) weakSelf = self;
    
    WBImageDownloader *downloader = [[WBImageDownloader alloc] init];
    self.imageDownLoader = downloader;
    [downloader startDownloadImageWithUrl:theRequest.URL.absoluteString progress:nil finished:^(NSData *data, NSError *error) {
        // 成功
        if (data != nil && error == nil) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *image = [UIImage imageWithData:data];
                UIImage *finalImage = image;
                
                if (image) {
                    [[WBImageCache sharedImageCache] wb_cacheImage:finalImage forRequest:theRequest];
                } else {

                    [[WBImageCache sharedImageCache] wb_cacheFailRequest:theRequest];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finalImage) {
                        [weakSelf setImage:finalImage isFromCache:NO];
                        
                        if (weakSelf.completion) {
                            weakSelf.completion(weakSelf.image);
                        }
                    } else {// error data
                        if (weakSelf.completion) {
                            weakSelf.completion(weakSelf.image);
                        }
                    }
                });
            });
        } else { // error
            [[WBImageCache sharedImageCache] wb_cacheFailRequest:theRequest];
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.image);
            }
        }
    }];
}
- (void)cancelRequest{
    [self.imageDownLoader.task cancel];
}


@end
