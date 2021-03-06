//
//  FileTableViewController.h
//  uSav-newUI
//
//  Created by Luca on 6/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileTableViewCell.h"
#import "FileDataBase.h"
#import "ColorFromHex.h"
#import "InitiateWithData.h"
#import "FileDecryptionTableViewController.h" //segment切换的数据源
#import "FileDetailViewController.h"    //用于传值给详细页面
#import "FileDetailEncryptedViewController.h"   //用于传值给详细页面2
#import "AddFileTableViewController.h"  //用于传参给addFile
//#import "PopUpMenu.h"
#import "TYDotIndicatorView.h"

@interface FileTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSMutableArray *CellData;
@property (strong, nonatomic) NSMutableArray *SearchData;//search结果
@property (strong, nonatomic) UITableViewCell *searchCell;


@property (strong, nonatomic) IBOutlet UITableView *FileTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *FileSegent;

- (void)readDataFromInitateData;
- (IBAction)SegmentChange:(id)sender;
//- (IBAction)AddButtonClicked:(id)sender;


@end
