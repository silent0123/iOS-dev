//
//  USAVSecureChatListTableViewController.h
//  CONDOR
//
//  Created by Luca on 26/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAVSecureChatListTableViewCell.h"
#import "USAVFileViewController.h"
#import "USAVSecureChatViewController.h"
#import "USAVGuidedSetPermissionViewController.h" //contact selector

@interface USAVSecureChatListTableViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBtn;

- (IBAction)backBtnPressed:(id)sender;
- (IBAction)addBtnPressed:(id)sender;

- (void)getChattingDatabaseList;

@property (strong, nonatomic) NSMutableArray *chatArray;
@property (strong, nonatomic) NSMutableDictionary *chatDic;

@property (strong, nonatomic) USAVFileViewController *fileViewControllerDelegate;
@property (strong, nonatomic) USAVSecureChatViewController *secureChatViewController;

//directories
@property (strong, nonatomic) NSMutableArray *directoryList;

//files
@property (strong, nonatomic) NSMutableArray *filesInDirectory;

//file system
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSString *tempFileFolder;     //for voice/message cache
@property (strong, nonatomic) NSString *decryptedFolder;    //for decrypted document/image cache
@property (strong, nonatomic) NSString *encryptedFolder;    //for encrypted document
@property (strong, nonatomic) NSString *photoAlbumFolder;   //for encrypted image
@property (strong, nonatomic) NSString *decryptedCopyFolder;    //for decrypted copy (allowed)
@property (strong, nonatomic) NSString *chatDatabaseFolder; //for chat history database
@property (strong, nonatomic) NSString *messageFolder;

@property (strong, nonatomic) NSString *receivedFromKeyOwner;

//hintlabel
@property (strong, nonatomic) UILabel *hintLabel;
@end
