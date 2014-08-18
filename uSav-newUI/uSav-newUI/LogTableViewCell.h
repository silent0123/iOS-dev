//
//  LogTableViewCell.h
//  uSav-newUI
//
//  Created by Luca on 18/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *LogTime;
@property (weak, nonatomic) IBOutlet UILabel *LogContent;
@property (weak, nonatomic) IBOutlet UILabel *LogType;
@property (weak, nonatomic) IBOutlet UIImageView *LogImage;
@property (weak, nonatomic) IBOutlet UILabel *LogSuccess;


@end
