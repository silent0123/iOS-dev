//
//  USAVTextMessageViewController.h
//  uSav
//
//  Created by Luca on 10/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAVFileViewController.h"
#import "COPeoplePickerViewController.h"
#import "USAVVoiceRecoding.h"

@interface USAVTextMessageViewController : UIViewController <UITextFieldDelegate, UIDocumentInteractionControllerDelegate, UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) USAVFileViewController *fileControllerDelegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *receiverTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *CancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *messageBackgroundLabel;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UILabel *placeHolderLabel;
//keyboard
@property (assign, nonatomic) CGRect keyboardRect;


@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) NSTimer *alertTimer;

@property (strong, nonatomic) NSString *encryptPath;
@property (strong, nonatomic) NSString *decryptPath;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *encryptedFilePath;
@property (strong, nonatomic) NSFileManager *fileManager;

//share
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;

@property (strong, nonatomic) NSString *keyId;

//Detail
- (IBAction)detailButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailBackground;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UILabel *splitor;


//For Permission
@property (strong, nonatomic) NSMutableArray *receiverList;
@property (strong, nonatomic) NSMutableArray *usavContactList;
@property (assign, nonatomic) NSInteger tf_numLimit;
@property (assign, nonatomic) NSInteger tf_duration;

//search
@property (strong, nonatomic) UITableView *searchTableView;
@property (strong, nonatomic) NSMutableArray *contactList;
@property (strong, nonatomic) NSMutableArray *searchResult;

//progress
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *progressLabel;

- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

//voice
@property (weak, nonatomic) IBOutlet UIButton *voiceRecordingSwitchBtn;
- (IBAction)voiceRecordingSwitchBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *textMessageSwitchBtn;
- (IBAction)textMessageSwitchBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *voiceRecordingCustomView;
@property (weak, nonatomic) IBOutlet UIButton *voiceRecordingBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *voiceRecordingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *voiceRecordingTimeLabel;
@property (strong, nonatomic) NSTimer *voiceRecordingTimer;
@property (strong, nonatomic) USAVVoiceRecoding *voiceRecoding;
@property (strong, nonatomic) NSURL *recordedTmpFile;
@property (assign, nonatomic) NSInteger voiceRecordingTimerCount;
@property (weak, nonatomic) IBOutlet UILabel *voiceRecordingHintLabel;

- (IBAction)voiceRecordingBtnPressedDown:(id)sender;    //begin
- (IBAction)voiceRecordingPressedUp:(id)sender; //succeess
- (IBAction)voiceRecordingPressedDragOutside:(id)sender;    //will cancel
- (IBAction)voiceRecordingPressedUpOutside:(id)sender;  //cancel



@end
