//
//  DemoCellTableViewCell.h
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface DemoCellTableViewCell : UITableViewCell
-(void)creatShuffling:(NSInteger)index;
@end
