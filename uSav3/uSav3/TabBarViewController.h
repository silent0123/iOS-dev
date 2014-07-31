//
//  TabBarViewController.h
//  uSav3
//
//  Created by Luca on 28/7/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EncryptViewController.h"
#import "DecryptViewController.h"

#pragma mark 自动适配屏幕大小
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : 0)
#define addHeight 88

@class TabBarView;

@protocol tabbarDelegate <NSObject>

-(void) touchBarAtIndex:(NSInteger)index;

@end

@interface TabBarViewController : UIViewController <tabbarDelegate>

@property (nonatomic, strong) TabBarView *tabBar;
@property (nonatomic, strong) NSArray *arrayViewControllers;

@end

