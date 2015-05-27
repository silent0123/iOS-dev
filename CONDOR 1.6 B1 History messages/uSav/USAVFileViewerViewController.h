//
//  SGDPdfViewerViewController.h
//  SecuredGoogleDrive
//
//  Created by young dennis on 9/1/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
//copy from fileViewController

#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "UsavCipher.h"
#import "NSData+Base64.h"
#import "SGDUtilities.h"
#import "FileBriefCell.h"
#import "UsavStreamCipher.h"
#import "KKPasscodeLock.h"
#import "USAVLock.h"
#import "USAVVoiceRecoding.h"
#import <AssetsLibrary/AssetsLibrary.h>
#include <mach/mach_time.h>
#include <stdint.h>

@class USAVFileViewerViewController;


@protocol USAVFileViewerViewControllerDelegate <NSObject>
-(void)done:(USAVFileViewerViewController *)sender;
@end


@interface USAVFileViewerViewController : UIViewController
    <UIWebViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) id <USAVFileViewerViewControllerDelegate> delegate;

@property (strong, nonatomic) UIGestureRecognizer *gestureRecognizer;

@property (strong, nonatomic) NSString *fullFilePath;
@property (strong, nonatomic) NSString *noPrefixFilePath;

@property (strong, nonatomic) NSString *keyOwner;

//duration计时
@property (assign, nonatomic) NSInteger allowedLength;
@property (strong, nonatomic) NSTimer *durationTimer;
@property (strong, nonatomic) UILabel *timeLabel;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, assign) CGFloat keyboardDuration;
@property (nonatomic, assign) CGRect keyboardRect;

//reply
@property (strong, nonatomic) UIView *replyView;
@property (strong, nonatomic) UITextView *replyTextView;

//加密与permission
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *encryptPath;
@property (nonatomic, strong) NSString *decryptPath;
@property (nonatomic, strong) NSString *decryptCopyPath;
@property (nonatomic, strong) NSTimer *alertTimer;
@property (nonatomic, strong) NSString *encryptedFilePath;
@property (nonatomic, strong) NSMutableArray *receiverList;
@property (nonatomic, strong) NSString *keyId;
@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@property (nonatomic, strong) UIBarButtonItem *replyBtn;
@property (nonatomic, strong) UIBarButtonItem *sendBtn;
@property (nonatomic, strong) UIBarButtonItem *backBtn;

//Permission Detail区域
@property (strong, nonatomic) UIBarButtonItem *detailBtn;
@property (strong, nonatomic) UIBarButtonItem *hideBtn;
@property (weak, nonatomic) IBOutlet UIView *permissionDetailView;
@property (weak, nonatomic) IBOutlet UITextField *permissionDetailReceiver;
@property (weak, nonatomic) IBOutlet UIView *permissionDetailMoreView;
@property (weak, nonatomic) IBOutlet UITextField *permissionDetailLimit;
@property (weak, nonatomic) IBOutlet UITextField *permissionDetailDuration;
@property (weak, nonatomic) IBOutlet UILabel *permissionDetailReceiverLabel;
@property (weak, nonatomic) IBOutlet UILabel *permissionDetailLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *permissionDetailDurationLabel;

@property (strong, nonatomic) NSMutableArray *contactList;
@property (strong, nonatomic) NSMutableArray *contactNameList;
@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSMutableArray *searchNameResult;
@property (strong, nonatomic) UITableView *searchTableView;

- (IBAction)receiverBeginEdit:(id)sender;
- (IBAction)receiverEndEdit:(id)sender;
- (IBAction)PermissionDetailMorePressed:(id)sender;
- (IBAction)receiverTextChanged:(id)sender;

//voice message
@property (strong, nonatomic) USAVVoiceRecoding *voiceRecording;
@property (strong, nonatomic) UIButton *voiceRecordingSwitchBtn;
@property (strong, nonatomic) UIButton *voiceRecordingBtn;
@property (strong, nonatomic) NSTimer *voiceRecordingTimer;
@property (assign, nonatomic) NSInteger voiceRecordingTimerCount;
//其他类调用
- (void)backToFile;
@end
