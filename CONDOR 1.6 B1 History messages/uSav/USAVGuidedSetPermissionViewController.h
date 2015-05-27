//
//  USAVGuidedSetPermissionViewController.h
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//  Be used to select contact

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "USAVContactViewController.h"
//#import "USAVGuidedSharingViewController.h"

@class USAVGuidedSetPermissionViewController;
@protocol USAVContactListViewControllerDelegate
- (void) contactListViewControllerDidFinish:(USAVGuidedSetPermissionViewController *)controller;
@end

@interface USAVGuidedSetPermissionViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) id <USAVContactListViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *fileIcon;
@property (weak, nonatomic) IBOutlet UITableView *tbView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (weak, nonatomic) IBOutlet UILabel *fileNameTxt;

@property (weak, nonatomic) IBOutlet UITextField *friendTextField;

@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *keyId;
@property (nonatomic, strong) NSMutableArray *emails;

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *friends2;
- (IBAction)shareBtnPressed:(id)sender;
- (IBAction)cancelBtnpressed:(id)sender;

//HintLable
@property (strong, nonatomic) UILabel *hintLabel;

@end
