//
//  PopUpMenu.m
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "PopUpMenu.h"

@implementation PopUpMenu


+ (UIView *)PopUpMenuFromAddButton:(UIView *)view {

    UIView *menu = [[UIView alloc] initWithFrame:CGRectMake(198, 30, 120, 140)];
    menu.backgroundColor = [ColorFromHex getColorFromHex:@"#929292"];
    menu.alpha = 0.95;
    menu.contentMode = UIViewContentModeCenter;
    
    UILabel *Photo = [[UILabel alloc] initWithFrame:CGRectMake(220, 55, 100, 40)];
    Photo.text = @"Take a Photo";
    Photo.textColor = [UIColor colorWithWhite:1 alpha:1];
    Photo.font = [UIFont systemFontOfSize:13];
    Photo.textAlignment = NSTextAlignmentLeft;
    Photo.userInteractionEnabled = YES;
    
    UILabel *Album = [[UILabel alloc] initWithFrame:CGRectMake(220, 105, 100, 35)];
    Album.text = @"View in Album";
    Album.textColor = [UIColor colorWithWhite:1 alpha:1];
    Album.font = [UIFont systemFontOfSize:13];
    Album.textAlignment = NSTextAlignmentLeft;
    Album.userInteractionEnabled = YES;
    
    [view addSubview:menu];
    [menu addSubview:Photo];
    [menu addSubview:Album];
    
    return menu;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
