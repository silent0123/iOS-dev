//
//  USAVSecureChatViewController.h
//  CONDOR
//
//  Created by Luca on 24/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "USAVSecureChatBubbleTableViewCell.h"
#import "USAVSecureChatFileSendPanelViewController.h"
#import "USAVClient.h"
#import "WarningView.h"
#import "SGDUtilities.h"
#import "USAVSingleFileLog.h"
#import "USAVFileViewController.h"

@class USAVSecureChatListTableViewController;

@interface USAVSecureChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) USAVSecureChatListTableViewController *chatListDelegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *inputMessageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *inputVoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *inputFileBtn;
@property (strong, nonatomic) USAVSecureChatFileSendPanelViewController *fileSendPanel;
@property (strong, nonatomic) UIMenuController *contextMenu;

@property (strong, nonatomic) UIAlertView *alert;

@property (assign, nonatomic) CGRect keyboardRect;
@property (assign, nonatomic) float keyboardDuration;

@property (strong, nonatomic) UILongPressGestureRecognizer* longPressRecognizerForAccountOwner;
@property (strong, nonatomic) UILongPressGestureRecognizer* longPressRecognizerForFriend;

//data
@property (strong, nonatomic) NSMutableArray *resultArray;
//@property (strong, nonatomic) NSMutableArray *displayArray;

//file system
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSMutableArray *fileList;
@property (strong, nonatomic) NSMutableArray *keyInfoList;
@property (strong, nonatomic) NSString *messageFolder;
@property (strong, nonatomic) NSString *tempFileFolder;     //for voice/message cache
@property (strong, nonatomic) NSString *decryptedFolder;    //for decrypted document/image cache
@property (strong, nonatomic) NSString *encryptedFolder;    //for encrypted document
@property (strong, nonatomic) NSString *photoAlbumFolder;   //for encrypted image
@property (strong, nonatomic) NSString *decryptedCopyFolder;    //for decrypted copy (allowed)
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *encryptedFilePath;
@property (strong, nonatomic) NSString *keyId;
@property (strong, nonatomic) NSString *sendTo;

- (IBAction)backBtnpressed:(id)sender;
- (IBAction)inputFileBtnPressed:(id)sender;

//voice
- (IBAction)inputVoiceBtnPressedUp:(id)sender;
- (IBAction)inputVoiceBtnPressedDown:(id)sender;
- (IBAction)inputVoiceBtnDragOutside:(id)sender;
- (IBAction)inputVoiceBtnUpOutside:(id)sender;
- (IBAction)inputVoiceBtnDragIn:(id)sender;

//voice recording
@property (weak, nonatomic) IBOutlet UIView *voiceRecordingCustomView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *voiceRecordingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *voiceRecordingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel * voiceRecordingHintLabel;

@property (strong, nonatomic) NSTimer *voiceRecordingTimer;
@property (strong, nonatomic) USAVVoiceRecoding *voiceRecoding;
@property (strong, nonatomic) NSURL *recordedTmpFile;
@property (assign, nonatomic) NSInteger voiceRecordingTimerCount;

//refresh
@property (nonatomic, strong) UIRefreshControl* refreshControl;

//progress view
@property (strong, nonatomic) UIProgressView *progressViewOnNaviBar;

//open in
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;

@end
