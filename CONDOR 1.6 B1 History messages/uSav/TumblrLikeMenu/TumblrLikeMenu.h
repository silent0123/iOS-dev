//
//  TumblrLikeMenu.h
//  TumblrLikeMenu
//
//  Created by Tu You on 12/16/13.
//  Copyright (c) 2013 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TumblrLikeMenuItem.h"
#import "USAVFileViewController.h"

@class USAVFileViewController;

typedef void (^TumblrLikeMenuSelectBlock)(NSUInteger index);

@interface TumblrLikeMenu : UIView

@property (nonatomic, strong) NSArray *submenus;
@property (nonatomic, copy) TumblrLikeMenuSelectBlock selectBlock;
//自己添加，传输页面本体delegate
@property (nonatomic, strong) USAVFileViewController *fileControllerDelegate;
//自己添加，判断是否在显示
@property (nonatomic, assign) BOOL isShowing;

- (id)initWithFrame:(CGRect)frame subMenus:(NSArray *)menus;
- (id)initWithFrame:(CGRect)frame subMenus:(NSArray *)menus tip:(NSString *)tip;
- (void)disappear;

- (void)showAt:(UIView *)keyView;

@end
