//
//  USAVSecureChatListTableViewCell.h
//  CONDOR
//
//  Created by Luca on 26/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAVSecureChatListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unreadMessageImageView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
