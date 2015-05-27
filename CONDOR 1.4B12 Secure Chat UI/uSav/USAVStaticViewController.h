//
//  USAVStaticViewController.h
//  uSav
//
//  Created by NWHKOSX49 on 15/10/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "USAVFileViewerViewController.h"

@interface USAVStaticViewController : UIViewController

<UITableViewDelegate, MFMailComposeViewControllerDelegate,
USAVFileViewerViewControllerDelegate,UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbView;


@property (weak, nonatomic) IBOutlet UITabBarItem *TabBarProfile;


@end
