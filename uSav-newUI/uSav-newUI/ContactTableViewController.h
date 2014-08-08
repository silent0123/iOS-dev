//
//  ContactTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactTableViewCell.h"
#import "ContactDataBase.h"
#import "InitiateWithData.h"
#import "ColorFromHex.h"
#import "ContactGroupTableViewController.h"

@interface ContactTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *CellData;
@property (strong, nonatomic) IBOutlet UITableView *ContactTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ContactSegment;

- (IBAction)SegmentChange:(id)sender;

@end
