//
//  ContactGroupDetailTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 13/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitiateWithData.h"
#import "ColorFromHex.h"
#import "ContactDetailTableViewController.h"

@interface ContactGroupDetailTableViewController : UITableViewController

@property (strong, nonatomic) NSString *segueTransGroup;

@property (strong, nonatomic) NSMutableArray *CellData;

@end
