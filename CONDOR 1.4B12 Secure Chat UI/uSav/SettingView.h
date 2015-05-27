//
//  SettingView.h
//  uSav
//
//  Created by NWHKOSX49 on 28/2/14.
//  Copyright (c) 2014 young dennis. All rights reserved.
//
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>
#import "USAVFileViewController.h"
#import "ICETutorialController.h"

@class USAVFileViewController;

@interface SettingView : UIViewController<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,USAVFileViewerViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *TabBarSetting;
@property (strong, nonatomic) XHHUDView *alert;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *homeBtn;

//在这个界面控制dashboard
@property (strong, nonatomic) USAVFileViewController *fileControllerDelegate;

@end
