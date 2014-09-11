//
//  PermissionTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"

@interface PermissionTableViewController : UITableViewController

@property (strong, nonatomic) NSString *segueTransFileName;
@property (strong, nonatomic) NSMutableArray *CellData;

@end
