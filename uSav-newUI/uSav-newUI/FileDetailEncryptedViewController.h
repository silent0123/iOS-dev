//
//  FileDetailEncryptedViewController.h
//  uSav-newUI
//
//  Created by Luca on 12/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"
#import "PermissionTableViewController.h"
#import "FileAuditTableViewController.h"
#import "FileDecryptionTableViewController.h"
#import "NYOBetterZoomViewController.h"
//server connect
#import "API.h"
#import "USAVClient.h"
#import "GDataXMLNode.h"
#import "TYDotIndicatorView.h"
//file operation
#import "UsavFileHeader.h"
#import "FileHeader.h"
#import "NSData+Base64.h"
#import "UsavCipher.h"
#import "UsavStreamCipher.h"

@class FileDecryptionTableViewController;

@interface FileDetailEncryptedViewController : UIViewController

@property (strong, nonatomic) NSString *segueTransFilePath;
@property (strong, nonatomic) NSString *segueTransFileName;
@property (strong, nonatomic) NSString *segueTransBytes;
@property (strong, nonatomic) NSString *segueTransColor;
@property (strong, nonatomic) NSString *segueTransKeyId;
@property (strong, nonatomic) FileDecryptionTableViewController *fileDecryptionTableViewController;

@property (strong, nonatomic) TYDotIndicatorView *loadingAlert;

@property (weak, nonatomic) IBOutlet UIImageView *CenterPicture;
@property (weak, nonatomic) IBOutlet UILabel *FileName;
@property (weak, nonatomic) IBOutlet UILabel *Bytes;
@property (weak, nonatomic) IBOutlet UIButton *DecryptionButton;
@property (weak, nonatomic) IBOutlet UIButton *PermissionButton;
@property (weak, nonatomic) IBOutlet UIButton *ShareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *OtherButton;

- (IBAction)DecryptButtonPressed:(id)sender;


@end
