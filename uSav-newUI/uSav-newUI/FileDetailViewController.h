//
//  FileDetailViewController.h
//  uSav-newUI
//
//  Created by Luca on 11/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"
#import "NYOBetterZoomViewController.h"
#import "FileTableViewController.h"
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

@class FileTableViewController;

@interface FileDetailViewController : UIViewController

@property (strong, nonatomic) TYDotIndicatorView *loadingAlert;

//公共变量，用于接收从上个页面传来的值
@property (strong, nonatomic) NSString *segueTransFilePath;
@property (strong, nonatomic) NSString *segueTransFileName;
@property (strong, nonatomic) NSString *segueTransBytes;
@property (strong, nonatomic) NSString *segueTransColor;
@property (assign, nonatomic) NSInteger encryptSourceType;
@property (strong, nonatomic) NSString *segueTransKeyId;
@property (strong, nonatomic) FileTableViewController *fileTableViewController;

@property (weak, nonatomic) IBOutlet UIImageView *CenterPicture;
@property (weak, nonatomic) IBOutlet UIButton *PreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *EncryptButton;
@property (weak, nonatomic) IBOutlet UIButton *OpenButton;
@property (weak, nonatomic) IBOutlet UILabel *FileName;
@property (weak, nonatomic) IBOutlet UILabel *Bytes;

//cache & buffer
@property (strong, nonatomic) NSData *currentDataBuffer;

- (IBAction)EncryptButtonPressed:(id)sender;

@end
