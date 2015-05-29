//
//  USAVSecureChatBubbleTableViewCell.m
//  CONDOR
//
//  Created by Luca on 24/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureChatBubbleTableViewCell.h"

@implementation USAVSecureChatBubbleTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (BOOL)canBecomeFirstResponder {
    
    //re-write this function to enable long press
    return YES;
}
@end
