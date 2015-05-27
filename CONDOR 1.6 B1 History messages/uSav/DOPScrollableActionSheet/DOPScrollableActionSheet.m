//
//  DOPScrollableActionSheet.m
//  DOPScrollableActionSheet
//
//  Created by weizhou on 12/27/14.
//  Copyright (c) 2014 luca. All rights reserved.
//

#import "DOPScrollableActionSheet.h"

static CGFloat horizontalMargin = 20.0;
BOOL cancelButtonEnabled = NO;

@interface DOPScrollableActionSheet ()

@property (nonatomic, assign) CGRect         screenRect;
@property (nonatomic, strong) UIWindow       *window;
@property (nonatomic, strong) UIView         *dimBackground;
@property (nonatomic, copy  ) NSArray        *actions;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *handlers;
@property (nonatomic, copy) void(^dismissHandler)(void);

@end

@implementation DOPScrollableActionSheet

- (instancetype)initWithActionArray:(NSArray *)actions {
    self = [super init];
    if (self) {
        _screenRect = [UIScreen mainScreen].bounds;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.5 &&
            UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            _screenRect = CGRectMake(0, 0, _screenRect.size.height, _screenRect.size.width);
        }
        _actions = actions;
        _buttons = [NSMutableArray array];
        _handlers = [NSMutableArray array];
        _dimBackground = [[UIView alloc] initWithFrame:_screenRect];
        _dimBackground.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_dimBackground addGestureRecognizer:gr];
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.96];
    
        NSInteger rowCount = _actions.count;
    
        /*calculate action sheet frame begin*/
        //row title screenwidth*40 without row title margin screenwidth*20
        //60*60 icon 60*30 icon name
        CGFloat height = 0;

        for (int i = 0; i < rowCount; i++) {
            if ([_actions[i] isKindOfClass:[NSString class]]) {
                if ([_actions[i] isEqualToString:@""]) {
                    height += 20;
                } else {
                    height += 40;
                }
            } else {
                height = height+60+30;
            }
        }
        //cancel button screenwidth*45
        if (cancelButtonEnabled) {
            height += 45;
        } else {
            height += 10;
        }
        
        /*calculation end*/
        self.frame = CGRectMake(0, _screenRect.size.height, _screenRect.size.width, height);
        
        //add each row
        CGFloat y = 0.0;

       
        for (int i = 0; i < rowCount; i++) {
            if ([_actions[i] isKindOfClass:[NSString class]]) {
                //title
                if ([_actions[i] isEqualToString:@""]) {
                    UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, 20.0)];
                    [self addSubview:marginView];
                    y+=10;
                } else {
                    UILabel *rowTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, 40.0)];
                    rowTitle.font = [UIFont systemFontOfSize:12.0];
                    rowTitle.text = _actions[i];
                    rowTitle.textAlignment = NSTextAlignmentCenter;
                    rowTitle.textColor = [UIColor whiteColor];
                    [self addSubview:rowTitle];
                    y+=40;
                }
            } else {
                NSArray *items = _actions[i];
                //actions array
                UIScrollView *rowContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, 90)];
                rowContainer.directionalLockEnabled = YES;
                rowContainer.showsHorizontalScrollIndicator = NO;
                rowContainer.showsVerticalScrollIndicator = NO;
                rowContainer.contentSize = CGSizeMake(items.count*80+20, 90);
                [self addSubview:rowContainer];
                //add each item
                CGFloat x = horizontalMargin;
                for (int j = 0; j < items.count; j++) {
                    DOPAction *action = items[j];
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(x + 5, 10, 40, 40);  //微调图片位置
                    [button setImage:[UIImage imageNamed:action.iconName] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(handlePress:) forControlEvents:UIControlEventTouchUpInside];
                    [rowContainer addSubview:button];
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x - 5, 60, 60, 30)];
                    label.text = action.actionName;
                    label.font = [UIFont systemFontOfSize:11.0];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = [UIColor whiteColor];
                    label.lineBreakMode = NSLineBreakByWordWrapping;    //换行方案
                    label.numberOfLines = 0;    //自动行数
                    [rowContainer addSubview:label];
                    x = x + 60 + horizontalMargin;
                    
                    [_buttons addObject:button];
                    [_handlers addObject:action.handler];
                }
                y+=100;
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width,1)];
                separator.backgroundColor = [UIColor lightGrayColor];
                separator.alpha = 0.2;  //微调分界线
                [self addSubview:separator];
            }
        }
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
        cancel.frame = CGRectMake(0, y, _screenRect.size.width, 45);
        [cancel setTitle:NSLocalizedString(@"Cancel", @"cancel button name") forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancel.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        cancel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        [self addSubview:cancel];
        [cancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)handlePress:(UIButton *)button {
    NSInteger index = [self.buttons indexOfObject:button];
    
    if (index != self.buttons.count) {
        void(^handler)(void) = self.handlers[index];
        handler();
    }
    [self dismiss];
}

- (void)show {
    self.window = [[UIWindow alloc] initWithFrame:self.screenRect];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = [UIViewController new];
    self.window.rootViewController.view.backgroundColor = [UIColor clearColor];
    
    [self.window.rootViewController.view addSubview:self.dimBackground];
    
    [self.window.rootViewController.view addSubview:self];
    

    
    self.window.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.dimBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.frame = CGRectMake(0, self.screenRect.size.height-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        //进入后台自动隐藏
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"AppIntoBackground" object:nil];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.dimBackground.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, self.screenRect.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        self.window = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AppIntoBackground" object:nil];
    }];
    
}

@end

@implementation DOPAction

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName handler:(void(^)(void))handler {
    self = [super init];
    if (self) {
        _actionName = name;
        _iconName = iconName;
        _handler = handler;
    }
    return self;
}

@end
