//
//  LogsOperationTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitiateWithData.h"
#import "ColorFromHex.h"
#import "LogsDataBase.h"
#import "LogTableViewCell.h"

@interface LogsOperationTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *CellData;
@end
