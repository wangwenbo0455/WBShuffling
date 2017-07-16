//
//  DemoCellTableViewCell.m
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import "DemoCellTableViewCell.h"
#import "WBShuffling.h"

@interface DemoCellTableViewCell ()
@property (nonatomic, strong) WBShuffling * shuffling;

@end

@implementation DemoCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatShuffling:(NSInteger)index
{
    NSMutableArray *imageArray2 = [[NSMutableArray alloc] initWithArray: @[@"http://pic2.52pk.com/files/160719/2380130_112911_1_lit.jpg",@"http://npic7.edushi.com/cn/zixun/zh-chs/2017-05/30/3969765-jJYcViblrlujtym.jpg",@"http://pic.qiantucdn.com/58pic/15/67/62/82J58PICNH5_1024.jpg"]];
    if (!_shuffling) {
        _shuffling = [[WBShuffling alloc] initWithFrame:CGRectMake(0, 0,ScreenWidth, 208) configBlock:nil clickBlock:^(NSInteger index) {
            NSLog(@"你点击了第%ld张图片",index);
            
            
            //这个类定义协议回调到Viewcontroller
        }];
        [self.contentView addSubview:_shuffling];
    }
    
    [_shuffling startCarouselWithNewConfig:^WBConfiguration *(WBConfiguration *carouselConfig) {
        carouselConfig.pushAnimationType = [self getRandomNumber:0 to:16];
        carouselConfig.pageContollType = index;
        carouselConfig.pageTintColor = [UIColor redColor];
        carouselConfig.currentPageTintColor = [UIColor blueColor];
        carouselConfig.placeholder = nil;
        carouselConfig.faileReloadTimes = 5;
        carouselConfig.interValTime = 4;
        return carouselConfig;
    } array:imageArray2];
    

}

-(int)getRandomNumber:(int)from to:(int)to

{
    
    return (int)(from + (arc4random() % (to - from + 1)));
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
