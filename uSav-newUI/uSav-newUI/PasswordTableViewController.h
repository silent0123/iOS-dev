//
//  PasswordTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 15/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"
#import "USAVClient.h"
#import "API.h"
#import "GDataXMLNode.h"
#import "TYDotIndicatorView.h"

@interface PasswordTableViewController : UITableViewController

@property (strong, nonatomic) TYDotIndicatorView *loadingAlert;

@end
