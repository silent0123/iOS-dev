//
//  CircleTableViewCell.h
//  TabBarTest
//
//  Created by Luca on 4/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *Header;
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Email;
@property (weak, nonatomic) IBOutlet UILabel *SharedNum;

@end
