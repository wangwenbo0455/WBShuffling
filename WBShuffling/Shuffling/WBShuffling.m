//
//  WBShuffling.m
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import "WBShuffling.h"
#import "WBShufflingAnimation.h"
#import "WBWeakTimer.h"
#import "UIImageView+WBImageViewManager.h"

@interface WBShuffling ()<UIScrollViewDelegate>

//图片数据(里面可以存放UIImage对象、NSString对象【本地图片名】、NSURL对象【远程图片的URL】)
@property (strong, nonatomic) NSMutableArray *images;


@property (nonatomic, strong) UIScrollView  *scrollView;

//存放3个imageView的数值
@property (nonatomic, strong) NSMutableArray *imageViewArray;

//点击block
@property (nonatomic, copy) CarouselClickBlock clickBlock;

//当前显示视图索引
@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) WBConfiguration *config;

@property (nonatomic, strong) WBPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timer;

//是否自动轮播,默认是轮播的
@property (nonatomic, assign) BOOL isAutoPlay;

//动画
@property (nonatomic, strong) WBShufflingAnimation *animation;

@property (nonatomic, weak) id<WBShufflingDelegate>delegate;

//轮播背景图片
@property (nonatomic, strong) UIImageView *backImageView;

@end


@implementation WBShuffling

- (NSMutableArray *)imageViewArray{
    if (!_imageViewArray) {
        _imageViewArray =[[NSMutableArray alloc] init];
    }
    return _imageViewArray;
}


#pragma mark -----------初始化-------------------

- (instancetype)initWithFrame:(CGRect)frame configBlock:(CarouselConfigurationBlock)configBlock clickBlock:(CarouselClickBlock)clickBlock{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageIndex = 0;
        if (configBlock) {
            WBConfiguration *configurate = [[WBConfiguration alloc] init];
            configurate.interValTime = DefaultTime;
            self.config = configBlock(configurate);
        }else{
            self.config = [[WBConfiguration alloc] init];
            self.config.interValTime = DefaultTime;
        }
        if (clickBlock) {
            __weak __typeof__(clickBlock) weakClickBlock = clickBlock;
            self.clickBlock = weakClickBlock;
        }
        [self initSelfView];
        [self updateSelfView];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame configBlock:(CarouselConfigurationBlock)configBlock target:(id<WBShufflingDelegate>)target{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageIndex = 0;
        self.delegate = target;
        if (configBlock) {
            WBConfiguration *configurate = [[WBConfiguration alloc] init];
            configurate.interValTime = DefaultTime;
            self.config = configBlock(configurate);
        }else{
            self.config = [[WBConfiguration alloc] init];
            self.config.interValTime = DefaultTime;
        }
        [self initSelfView];
        [self updateSelfView];
    }
    return self;
}

- (void)initSelfView{
    
    if (!self.pageControl) {
        self.pageControl = [[WBPageControl alloc] init];
    }
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth(self), ViewHeight(self))];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.contentMode = self.config.contentMode;
        [self addSubview:_backImageView];
    }
    
    if (!self.animation) {
        self.animation = [[WBShufflingAnimation alloc] init];
    }
    
    [self addSubView];
}

- (void)updateSelfView{
    
    if (self.config.backViewColor) {
        self.backgroundColor = self.config.backViewColor;
    }
    
    if (self.config.backViewImage) {
        _backImageView.image = self.config.backViewImage;
    }
    
    [self.animation updateDataWithConfiguration:self.config];
    
    for (UIImageView *imageView in self.imageViewArray) {
        imageView.contentMode = self.config.contentMode;
        //        imageView.reloadTimesForFailedURL = self.config.faileReloadTimes;
    }
}

//添加scrollView和imageView
- (void)addSubView{
    
    if(_scrollView == nil) {
        UIView *firstView = [[UIView alloc] init];
        [self addSubview:firstView];
        //scrollView
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        _scrollView.contentSize = CGSizeMake(ViewWidth(_scrollView) *AllImageViewCount, 0);
        _scrollView.contentOffset = CGPointMake(ViewWidth(_scrollView), 0);
        
        //imageView
        for(NSInteger i = 0; i < AllImageViewCount; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * ViewWidth(_scrollView), 0, ViewWidth(_scrollView), ViewHeight(_scrollView))];
            imageView.userInteractionEnabled = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            //            imageView.reloadTimesForFailedURL = self.config.faileReloadTimes;
            [_scrollView addSubview:imageView];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)]];
            
            [self.imageViewArray addObject:imageView];
        }
    }
}

// 设置scrollView的contentSize
- (void)setupScrollViewContentSize{
    if(self.images.count > 3){
        self.scrollView.contentSize = CGSizeMake(ViewWidth(_scrollView) *AllImageViewCount, 0);
        self.scrollView.contentOffset = CGPointMake(ViewWidth(_scrollView), 0);
        
    }else{
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset =CGPointZero;
    }
}

- (void)updateConfigWithBlock:(CarouselConfigurationBlock)configBlock{
    WBConfiguration *configurate = self.config;
    if (configBlock) {
        self.config = configBlock(configurate);
        [self updateSelfView];
    }
}


//开始轮播
- (void)startCarouselWithArray:(NSMutableArray *)imageArray{
    self.images = imageArray;
}

//开始轮播（以新的轮播样式来运行）
- (void)startCarouselWithNewConfig:(CarouselConfigurationBlock)configBlock array:(NSMutableArray *)imageArray{
    if (!self.config) {
        self.config = [[WBConfiguration alloc] init];
    }
    WBConfiguration *configurate = self.config;
    if (configBlock) {
        self.config = configBlock(configurate);
        [self updateSelfView];
    }
    
    [self startCarouselWithArray:imageArray];
}

#pragma mark - -----------set方法-------------------
- (void)setImages:(NSMutableArray *)images{
    
    NSInteger num = images.count;
    if (images.count > 0) {
        id firstObj = [images firstObject];
        id lastObj = [images lastObject];
        [images insertObject:lastObj atIndex:0];
        [images insertObject:firstObj atIndex:images.count];
    }
    
    if (!_images) {
        _images = [NSMutableArray array];
    }
    _images = images;
    self.imageIndex = 1;
    [self.pageControl initViewWithNumberOfPages:num configuration:self.config addInView:self];
    [self updateImageViewContent];
    [self setupScrollViewContentSize];
    
    //销毁定时器
    [self stopTimer];
    if (num == 0) {
        self.isAutoPlay = NO;
    }else if (num == 1){
        self.isAutoPlay = NO;
    }else{
        self.isAutoPlay = YES;
        [self beginTimer];
    }
}

#pragma mark - -----------更新图片-------------------

- (void)updateImageViewContent{
    
    if (self.images.count > 2) {
        for (NSInteger i = 0; i < self.imageViewArray.count; i++) {
            UIImageView *imageView = [self.imageViewArray objectAtIndex:i];
            NSInteger imageIndex = 0;
            if (i == 0) { // 左边
                imageIndex = self.imageIndex - 1;
                if (imageIndex == -1) { // 显示最后面一张图片
                    imageIndex = self.images.count - 2;
                }
            } else if (i == 1) { // 中间
                imageIndex = self.imageIndex;
            } else if (i == 2) { // 右边
                imageIndex = self.imageIndex + 1;
                if (imageIndex == self.images.count) { // 显示最前面一张图片
                    imageIndex = 1;
                }
            }
            imageView.tag = imageIndex;
            [self loadImage:imageIndex withImageView:imageView];
        }
        //更新pageControll
        [self.pageControl updateCurrentPageWithIndex:(self.imageIndex-1)];
    }
}

- (void)loadImage:(NSInteger)imageIndex withImageView:(UIImageView *)imageView{
    
    id obj = [self.images objectAtIndex:imageIndex];
    
    if ([obj isKindOfClass:[NSString class]]) { // 本地图片名或者urlStr
        imageView.image = [UIImage imageNamed:obj];
        if (imageView.image == nil) {
                        [imageView wb_setImageWithURLString:obj placeholder:self.config.placeholder];
            
            
            
            // 图片展示和缓存
            
        }
        return;
    }else if ([obj isKindOfClass:[NSURL class]]) { // 远程图片URL
                [imageView wb_setImageWithURLString:obj placeholder:self.config.placeholder];
        
        // 图片展示和缓存

        
        return;
    }else if ([obj isKindOfClass:[UIImage class]]) { // UIImage对象
        imageView.image = obj;
        return;
    }
}


#pragma mark - -------------------视图点击事件-------------------
- (void)imageClick:(UITapGestureRecognizer *)sender{
    if (_imageViewArray.count == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (self.clickBlock) {
        [self changeImageIndex];
        weakSelf.clickBlock(weakSelf.imageIndex-1);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shufflingViewClick:)]) {
        [self.delegate shufflingViewClick:self.imageIndex-1];
    }
}

#pragma mark - -------------------定时器-------------------
//开始定时器
- (void)beginTimer{
    if ((self.config.interValTime >0) && (self.timer == nil) && self.isAutoPlay) {
        self.timer = [WBWeakTimer scheduledTimerWithTimeInterval:self.config.interValTime target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

//销毁定时器
- (void)stopTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

/// 暂停
- (void)pauseTimer {
    if (!self.timer.isValid) return;
    [self.timer setFireDate:[NSDate distantFuture]];
}
/// 恢复
- (void)resumeTimer {
    if (!self.timer.isValid) return;
    [self.timer setFireDate:[NSDate date]];
}
/// 多少秒后恢复
- (void)resumeWithTimeInterval:(NSTimeInterval)time {
    if (!self.timer.isValid) return;
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:time]];
}

- (void)timeAction{
    __weak typeof(self)weakSelf = self;
    if (self.config.pushAnimationType == PushDefault) {
        [UIView animateWithDuration:0.35 animations:^{
            weakSelf.scrollView.contentOffset = CGPointMake(2 *ViewWidth(self.scrollView), 0);
        } completion:^(BOOL finished) {
            [self changeImageIndex];
            [weakSelf updateImageViewContent];
            [weakSelf setupScrollViewContentSize];
        }];
    }else{
        [self.animation startAnimationInView:weakSelf.scrollView];
        self.scrollView.contentOffset = CGPointMake(2 *ViewWidth(self.scrollView), 0);
        [self changeImageIndex];
        [self updateImageViewContent];
        [self setupScrollViewContentSize];
    }
}

#pragma mark - -------------------UIScrollViewDelegate-------------------
//开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //暂停定时器
    [self pauseTimer];
}

//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //恢复定时器
    [self resumeWithTimeInterval:self.config.interValTime];
}

//位置发生变化
// 找出显示在最中间的imageView x值和偏移量x差值最小的imageView，就是显示在最中间的imageView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UIImageView *middleImageView = nil;
    CGFloat minOffset = MAXFLOAT;
    
    for (UIImageView *imageView in self.imageViewArray) {
        CGFloat currentOffset = ABS(CGRectGetMinX(imageView.frame) - _scrollView.contentOffset.x);
        if (currentOffset < minOffset){
            minOffset = currentOffset;
            middleImageView = imageView;
        }
        self.imageIndex = middleImageView.tag;
    }
}

//结束滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self changeImageIndex];
    [self updateImageViewContent];
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
}

- (void)changeImageIndex{
    if (self.imageIndex == 0) {
        self.imageIndex = self.images.count - 2;
    }else if(self.imageIndex == (self.images.count-1)){
        self.imageIndex = 1;
    }
}

- (void)dealloc{
    [self stopTimer];
#ifdef kDebugLog
    NSLog(@"销毁定时器");
#endif
}


@end
