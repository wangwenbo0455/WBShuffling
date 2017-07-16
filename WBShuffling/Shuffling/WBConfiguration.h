//
//  WBConfiguration.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WBConfiguration;

//#define kDebugLog (如果想看打印注释放开即可)

//imageView的个数
#define AllImageViewCount 3

//View的宽度
#define ViewWidth(view) CGRectGetWidth(view.frame)
//View的高度
#define ViewHeight(view) CGRectGetHeight(view.frame)

#define JYWeakSelf __weak typeof(self) weakSelf = self

//获取用户自定义属性
typedef WBConfiguration *(^CarouselConfigurationBlock)(WBConfiguration *carouselConfig);

//点击事件block
typedef void (^CarouselClickBlock)(NSInteger index);

//UIPageControl类型
typedef NS_ENUM(NSInteger, CarouselPageControllType) {
    MiddlePageControl = 0,
    LeftPageControl,
    RightPageControl,
    LabelPageControl,
    NonePageControl
};

typedef NS_ENUM(NSInteger ,CarouselPushType) {
    PushDefault = 0,    //默认平稳过渡
    PushCurlUp,         //向上翻一页
    PushCurlDown,       //向下翻一页
    PushFilpFromLeft,   //从左翻转
    PushFilpFromRight,  //从右翻转
    PushFade,           //交叉淡化过渡
    PushMoveIn,         //新视图移到旧视图上面 依靠animationSubtype方向
    PushReveal,         //将旧视图移开，显示下面的新视图 依靠animationSubtype方向
    PushPush,           //推挤
    PushCube,           //立方体效果 依靠animationSubtype方向
    PushPageCurl,       //翻页 依靠animationSubtype方向
    PushPageUnCurl,     //反翻页 依靠animationSubtype方向
    PushRippleEffect,   //滴水效果
    PushSuckEffect,      //收缩效果
    PushCameraIrisHollowOpen,  //镜头开
    PushCameraIrisHollowClose //镜头关
};

//定时器默认时间
static NSTimeInterval DefaultTime = 2.0;

@interface WBConfiguration : NSObject

/**
 占位图
 */
@property (nonatomic, strong) UIImage *placeholder;

/**
 轮播时间间隔（默认：3s，当设置为0s时,停止自动轮播）
 */
@property (assign, nonatomic) NSTimeInterval interValTime;

/**
 指示器类型（label和pageContoller样式）
 */
@property (nonatomic, assign) CarouselPageControllType pageContollType;

/**
 指示器填充颜色
 */
@property (strong, nonatomic) UIColor *currentPageTintColor;

/**
 指示器颜色
 */
@property (strong, nonatomic) UIColor *pageTintColor;


/**
 图片填充类型(默认是UIViewContentModeScaleToFill)
 */
@property (nonatomic, assign) UIViewContentMode contentMode;


/**
 轮播翻页类型
 */
@property (nonatomic, assign) CarouselPushType pushAnimationType;

#pragma mark - push翻页方向（只会在CarouselPushType为PushMoveIn、PushReveal、PushCube、PushPageCurl、PushPageUnCurl有效果）

/**
 *  kCATransitionFromRight
 *  kCATransitionFromLeft
 *  kCATransitionFromTop
 *  kCATransitionFromBottom
 */
@property (nonatomic, strong) NSString *animationSubtype;

#pragma mark - 轮播背景颜色或者背景图片(在PushCameraIrisHollowOpen,  PushCameraIrisHollowClose, PushPageUnCurl, PushPageCurl,PushCube能看到效果)
/**
 轮播背景颜色
 */
@property (nonatomic, strong) UIColor *backViewColor;

/**
 背景图片
 */
@property (nonatomic, strong) UIImage *backViewImage;


/**
 imageView加载图片失败重试次数(默认2次)
 */
@property (nonatomic, assign) NSInteger faileReloadTimes;


@end
