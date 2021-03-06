//
//  LogsTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 11/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogsDataBase.h"
#import "LogTableViewCell.h"
#import "ColorFromHex.h"
#import "InitiateWithData.h"
#import "LogsOperationTableViewController.h"

@interface LogsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *CellData;
@property (strong, nonatomic) IBOutlet UITableView *LogsTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *LogsSegment;

- (IBAction)SegmentChange:(id)sender;


@end
