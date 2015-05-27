//
//  MainViewController.h
//  uSav-NewMac
//
//  Created by Luca on 23/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USAVFileHandler.h"
#import "USAVLoginViewController.h"
#import "USAVContactHandler.h"

@class USAVPermissionViewController;

@interface MainViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSDraggingDestination>

//sideBar
@property (weak) IBOutlet NSButton *sideBarFilesBtn;
@property (weak) IBOutlet NSButton *sideBarContactsBtn;
@property (weak) IBOutlet NSButton *sideBarTrashBtn;
@property (weak) IBOutlet NSButton *sideBarSettingBtn;
@property (weak) IBOutlet NSTextField *sideBarFilesLabel;
@property (weak) IBOutlet NSTextField *sideBarContactsLabel;
@property (weak) IBOutlet NSTextField *sideBarShareLabel;
@property (weak) IBOutlet NSTextField *sideBarTrashLabel;
@property (weak) IBOutlet NSButton *sideBarAddFileBtn;
@property (weak) IBOutlet NSTableView *fileTable;

- (IBAction)newFileBtnPressed: (id)sender;

//file
@property (strong, nonatomic) NSMutableArray *selectedFileURLList;
@property (strong, nonatomic) NSMutableArray *selectedFilePathList;
@property (strong, nonatomic) NSFileManager *fileManager;
- (IBAction)cellTrashBtnPressed:(id)sender;

//table
@property (assign, nonatomic) NSInteger selectedRow;


//detail
@property (weak) IBOutlet NSTextField *DetailHeaderFilename;
@property (weak) IBOutlet NSTextField *detailBackground;
@property (weak) IBOutlet NSTextField *sourcePath;
@property (strong, nonatomic) NSString *sourceURL;
@property (strong, nonatomic) NSString *destinationURL;
@property (weak) IBOutlet NSTextField *destinationPath;
@property (weak) IBOutlet NSView *detailView;
@property (weak) IBOutlet NSTextField *hintLabel;
@property (weak) IBOutlet NSImageView *imageBanner;
@property (weak) IBOutlet NSButton *editPermissionBtn;
@property (weak) IBOutlet NSButton *fileHistoryBtn;
@property (weak) IBOutlet NSTextField *modificationTime;
- (IBAction)destinationBtnPressed:(id)sender;
- (IBAction)editPermissionBtnPressed:(id)sender;
- (IBAction)fileHistoryBtnPressed:(id)sender;

//Encryption/Decryption Progress
@property (weak) IBOutlet NSButton *enc_decBtn;
@property (assign, nonatomic) BOOL willEncryptFile;
@property (weak) IBOutlet NSView *activityView;
@property (weak) IBOutlet NSTextField *activityLabel;
@property (weak) IBOutlet NSProgressIndicator *activityCircle;
@property (strong, nonatomic) NSString *keyId;

//Permission
@property (strong, nonatomic) USAVPermissionViewController *permissionController;

- (IBAction)enc_decBtnPressed:(id)sender;

//Login
@property (strong, nonatomic) USAVLoginViewController *loginViewController;

//LogOut
- (IBAction)logoutButtonPressed:(id)sender;

@end
