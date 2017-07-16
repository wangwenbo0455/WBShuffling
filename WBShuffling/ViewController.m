//
//  ViewController.m
//  WBShuffling
//
//  Created by 王文博 on 2017/7/16.
//  Copyright © 2017年 王文博. All rights reserved.
//

#import "ViewController.h"
#import "DemoCellTableViewCell.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatTableView];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)creatTableView
{
    UITableView * demoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    demoTableView.backgroundColor = [UIColor clearColor];
    demoTableView.delegate = self;
    demoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    demoTableView.dataSource = self;
    [self.view addSubview:demoTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 208;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"DemoCellTableViewCell";
    
    DemoCellTableViewCell * cell = (DemoCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DemoCellTableViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellAccessoryNone;
    }
    
    [cell creatShuffling:indexPath.row];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
