//
//  USAVSecureChatBubbleTableViewCell.h
//  CONDOR
//
//  Created by Luca on 24/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAVSecureChatBubbleTableViewCell : UITableViewCell

//for reuse
//Cell components
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UIImageView *headerPhoto;
@property (weak, nonatomic) IBOutlet UIButton *voiceBubbleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImage;
@property (weak, nonatomic) IBOutlet UILabel *textBubbleLabel;
@end
