//
//  FileBriefCell.m
//
//  Created by young dennis on 10/1/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import "FileBriefCell.h"

@implementation FileBriefCell
@synthesize fileImage;
@synthesize fileName;
@synthesize fileSize;
@synthesize fileModTime;

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
