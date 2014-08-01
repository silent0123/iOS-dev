//
//  RecentTableViewCell.h
//  TabBarTest
//
//  Created by Luca on 31/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//  FILES页面
//  这个类用来管理cell，连接也连进这里

#import <UIKit/UIKit.h>

@interface RecentTableViewCell : UITableViewCell

#pragma mark RecentTable相关
@property (weak, nonatomic) IBOutlet UIImageView *CellPic;
@property (weak, nonatomic) IBOutlet UILabel *CellFileName;
@property (weak, nonatomic) IBOutlet UILabel *CellDateTime;
@property (weak, nonatomic) IBOutlet UILabel *CellVisitor;
@property (weak, nonatomic) IBOutlet UIButton *CellButton;
@property (weak, nonatomic) IBOutlet UIImageView *CellButtonBack;


@end
