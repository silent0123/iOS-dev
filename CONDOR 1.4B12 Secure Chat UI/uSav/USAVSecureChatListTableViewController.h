//
//  USAVSecureChatListTableViewController.h
//  CONDOR
//
//  Created by Luca on 26/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAVSecureChatListTableViewCell.h"
#import "USAVFileViewController.h"

@interface USAVSecureChatListTableViewController : UITableViewController

- (IBAction)backBtnPressed:(id)sender;
- (IBAction)addBtnPressed:(id)sender;

@property (strong, nonatomic) NSMutableArray *resultArray;
@property (strong, nonatomic) NSMutableDictionary *resultDic;

@property (strong, nonatomic) USAVFileViewController *fileViewControllerDelegate;

@end
