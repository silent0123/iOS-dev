//
//  USAVAppDelegate.h
//  uSav
//
//  Created by young dennis on 3/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeLock.h"


@interface USAVAppDelegate : UIResponder <UIApplicationDelegate, KKPasscodeViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) IBOutlet UINavigationController *navigationController;
@property (nonatomic) IBOutlet UIViewController *viewController;
@property (strong, nonatomic) UIWebView *launchImageView;
@property (strong, nonatomic) UIView *blackView;
@property (assign, nonatomic) NSInteger *willShowLaunchImage;

@property (nonatomic, assign) BOOL touchIdShowed;
@end
