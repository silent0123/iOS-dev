//
//  FileTableViewCell.h
//  TabBarTest
//
//  Created by Luca on 1/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//  FILES页面
//  这个类用来管理cell，连接也连进这里

#import <UIKit/UIKit.h>

@interface FileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Bytes;
@property (weak, nonatomic) IBOutlet UILabel *FileName;
@property (weak, nonatomic) IBOutlet UILabel *TableColor;
@property (weak, nonatomic) IBOutlet UILabel *ReceiveTime;
@property (weak, nonatomic) IBOutlet UIImageView *TableImage;

@end
