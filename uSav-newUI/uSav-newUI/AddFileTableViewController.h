//
//  AddFileTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitiateWithData.h"
#import "AddFileTableViewCell.h"
#import "FileDataBase.h"
#import "FileTableViewController.h"
#import "FileDecryptionTableViewController.h"

@class FileDecryptionTableViewController;
@class FileTableViewController;

@interface AddFileTableViewController : UITableViewController <UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSMutableArray *CellData;
@property (strong, nonatomic) FileTableViewController *fileEncryptedTableViewController;
@property (strong, nonatomic) FileDecryptionTableViewController *fileDecryptedTableViewController;

@end
