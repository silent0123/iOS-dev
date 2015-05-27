//
//  USAVTableViewCell.m
//  uSav
//
//  Created by NWHKOSX49 on 12/12/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVTableViewCell.h"

@implementation USAVTableViewCell
@synthesize date = _date;
@synthesize operation = _operation;
@synthesize result = _result;
@synthesize content = _content;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
