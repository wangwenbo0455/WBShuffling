//
//  WBImageCache.m
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import "WBImageCache.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

#define Default_cachePath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/WBShufflingImages"]

NSString *const WBDidSettingTime = @"WBDidSettingTime";

#pragma mark --------NSString的分类方法-----------
@interface NSString (md5Hash)

+ (NSString *)wb_md5Hash:(NSString *)string;
+ (NSString *)wb_cachePath;
+ (NSString *)wb_keyForRequest:(NSURLRequest *)request;

@end

@implementation NSString (md5Hash)

+ (NSString *)wb_keyForRequest:(NSURLRequest *)request {
    return [NSString stringWithFormat:@"%@_WBShuffling",
            request.URL.absoluteString];
}

+ (NSString *)wb_cachePath {
    return Default_cachePath;
}

+ (NSString *)wb_md5Hash:(NSString *)string {
    if (string) {
        const char *cStr = [string UTF8String];
        unsigned char result[16];
        CC_MD5(cStr, (UInt32) strlen(cStr), result);
        NSString *md5Result = [NSString stringWithFormat:
                               @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                               result[0], result[1], result[2], result[3],
                               result[4], result[5], result[6], result[7],
                               result[8], result[9], result[10], result[11],
                               result[12], result[13], result[14], result[15]];
        return md5Result;
    }
    return nil;

}

@end

#pragma mark --------cache-----------

@implementation WBImageCache

+ (WBImageCache *)sharedImageCache {
    static WBImageCache *instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WBImageCache alloc] init];
    });
    return instance;
}


- (NSMutableDictionary *)wb_cacheFaileTimesDict{
    if (!_wb_cacheFaileTimesDict) {
        _wb_cacheFaileTimesDict = [NSMutableDictionary dictionary];
    }
    return _wb_cacheFaileTimesDict;
}

- (void)wb_clearCacheFaileTimesDict{
    [self.wb_cacheFaileTimesDict removeAllObjects];
    self.wb_cacheFaileTimesDict = nil;
}


- (void)wb_clearDiskCaches{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        NSString *directoryPath = [NSString wb_cachePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
        }
        [self wb_clearCacheFaileTimesDict];
    });
   

}

- (UIImage *)wb_cacheImageForRequest:(NSURLRequest *)request{
    if (request) {
        NSString *directoryPath = [NSString wb_cachePath];
        NSString *path = [NSString stringWithFormat:@"%@/%@",
                          directoryPath,
                          [NSString wb_md5Hash:[NSString wb_keyForRequest:request]]];
        return [UIImage imageWithContentsOfFile:path];
    }
    
    return nil;
    
}
- (void)wb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request{
    if (image == nil || request == nil) {
        return;
    }
    
    NSString *directoryPath = Default_cachePath;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];

        if (error) {
#ifdef kDebugLog
            NSLog(@"create cache dir error: %@", error);
#endif
            return;
        }

    }

    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      directoryPath,
                      [NSString wb_md5Hash:[NSString wb_keyForRequest:request]]];
    NSData *data = UIImagePNGRepresentation(image);
    if (data) {
        BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        
        if (isOk) {
#ifdef kDebugLog
            NSLog(@"save file ok for request: %@", [NSString wb_md5Hash:[NSString wb_keyForRequest:request]]);
#endif
        } else {
#ifdef kDebugLog
            NSLog(@"save file error for request: %@", [NSString wb_md5Hash:[NSString wb_keyForRequest:request]]);
#endif
        }
    }
}
- (void)wb_cacheFailRequest:(NSURLRequest *)request{
    
    NSNumber *faileTimes = [self.wb_cacheFaileTimesDict objectForKey:[NSString wb_md5Hash:[NSString wb_keyForRequest:request]]];
    NSInteger times = 0;
    if (faileTimes && [faileTimes respondsToSelector:@selector(integerValue)]) {
        times = [faileTimes integerValue];
    }
    times++;
    
    [self.wb_cacheFaileTimesDict setObject:@(times) forKey:[NSString wb_md5Hash:[NSString wb_keyForRequest:request]]];

}

- (NSUInteger)wb_failTimesForRequest:(NSURLRequest *)request{
    
    NSNumber *faileTimes = [self.wb_cacheFaileTimesDict objectForKey:[NSString wb_md5Hash:[NSString wb_keyForRequest:request]]];
    
    if (faileTimes && [faileTimes respondsToSelector:@selector(integerValue)]) {
        return [faileTimes integerValue];
    }
    
    return 0;
}


- (void)wb_clearDiskCachesWithTimeout:(NSTimeInterval)time{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *settingTime = [defaults objectForKey:WBDidSettingTime];
    
    if (!settingTime ||[settingTime isEqualToString:WBDidSettingTime] ) {
        NSTimeInterval  timeInterval = 60*60*time;
        NSDate *tmpDate = [nowDate initWithTimeIntervalSinceNow:timeInterval];
        NSString *string = [formatter stringFromDate:tmpDate];
        [defaults setObject:string forKey:WBDidSettingTime];
        [defaults synchronize];
    }else{
        NSString *nowDateString = [formatter stringFromDate:nowDate];
        if ([settingTime compare:nowDateString] == NSOrderedAscending) {
            //升序，说明时间到了 清除缓存
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(queue, ^{
                NSString *directoryPath = [NSString wb_cachePath];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
                }
                [self wb_clearCacheFaileTimesDict];
                [defaults setObject:WBDidSettingTime forKey:WBDidSettingTime];
                [defaults synchronize];
            });
        }
    }
}

- (void)wb_changeDiskCacheWithTimeout:(NSTimeInterval)time{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:WBDidSettingTime forKey:WBDidSettingTime];
    [defaults synchronize];
    [self wb_clearDiskCachesWithTimeout:time];
}



@end
