//
//  FileDecryptionTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 7/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//  这类只是数据源，不用连接IBOutlet，在FileTableViewController这个主类中来调用它，实现segment切换数据源

#import <UIKit/UIKit.h>
#import "FileTableViewCell.h"
#import "FileDataBase.h"
#import "ColorFromHex.h"
#import "InitiateWithData.h"

@class FileTableViewController;

@interface FileDecryptionTableViewController : UITableViewController

//@property (strong, nonatomic) UITableViewCell *searchCell;
@property (strong, nonatomic) NSMutableArray *CellData;

@end
