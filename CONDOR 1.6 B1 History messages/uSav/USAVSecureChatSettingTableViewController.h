//
//  USAVSecureChatSettingTableViewController.h
//  CONDOR
//
//  Created by Luca on 29/5/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAVSecureChatViewController.h"

@interface USAVSecureChatSettingTableViewController : UITableViewController <UIAlertViewDelegate>

- (IBAction)backBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;

@property (strong, nonatomic) NSString *messageFolder;
@property (strong, nonatomic) USAVSecureChatViewController *secureChatDelegate;

@end
