//
//  RecentTableViewCell.m
//  TabBarTest
//
//  Created by Luca on 31/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "RecentTableViewCell.h"

@implementation RecentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
