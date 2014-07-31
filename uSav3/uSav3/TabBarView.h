//
//  TabBarView.h
//  uSav3
//
//  Created by Luca on 28/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//
//  这个文件是用来设计布局和按钮响应的

#import <UIKit/UIKit.h>
#import "TabBarViewController.h"

@interface TabBarView : UIView

@property (nonatomic, strong) UIImageView *tabBarView;
@property (nonatomic, strong) UIImageView *tabBarViewCenter;

@property (nonatomic, strong) UIButton *button_1;
@property (nonatomic, strong) UIButton *button_2;
@property (nonatomic, strong) UIButton *button_3;
@property (nonatomic, strong) UIButton *button_4;
@property (nonatomic, strong) UIButton *button_center;

@property (nonatomic, weak) id <tabbarDelegate> delegate;
@end
