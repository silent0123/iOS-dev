//
//  ContactGroupTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactTableViewCell.h"
#import "ContactDataBase.h"
#import "ColorFromHex.h"
#import "InitiateWithData.h"

@class InitiateWithData;

@interface ContactGroupTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *CellData;
@property (strong, nonatomic) InitiateWithData *dataInitiator;
@property (strong, nonatomic) UITableView *contactTable;


- (void)editCellData;
@end
