//
//  TabBarView.m
//  uSav3
//
//  Created by Luca on 28/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "TabBarView.h"

@implementation TabBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFrame:frame];
        [self layoutView];
    }
    return self;
}

- (void) layoutView {
    
    //绘制tab bar, 初始状态
    _tabBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_0"]];
    [_tabBarView setFrame:CGRectMake(0, 9, _tabBarView.bounds.size.width, 51)];
    [_tabBarView setUserInteractionEnabled:YES];
    
    //绘制中心按钮的背景和大小
    _tabBarViewCenter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_mainbtn_bg"]];
    _tabBarViewCenter.center = CGPointMake(self.center.x, self.bounds.size.height/2.0);
    [_tabBarViewCenter setUserInteractionEnabled:YES];
    
    //绘制中心按钮的图片
    _button_center = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_center.adjustsImageWhenHighlighted = YES;
    [_button_center setBackgroundImage:[UIImage imageNamed:@"tabbar_mainbtn"] forState:UIControlStateNormal];
    [_button_center setFrame:CGRectMake(0, 0, 46, 46)];
    _button_center.center = CGPointMake(_tabBarViewCenter.bounds.size.width/2.0, _tabBarViewCenter.bounds.size.height/2.0 + 5);
    
    //添加
    [self addSubview:_tabBarView];
    [self addSubview:_tabBarViewCenter];
    [self addSubview:_button_center];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
