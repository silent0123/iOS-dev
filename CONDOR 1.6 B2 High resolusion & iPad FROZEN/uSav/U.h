//
//  USAVGuidedSetPermissionViewController.h
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *fileNameTxt;

@property (weak, nonatomic) IBOutlet UITextField *friendTextField;

@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *naviBtn;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *keyId;
@property (nonatomic, strong) NSMutableArray *emails;

- (IBAction)shareBtnPressed:(id)sender;

@end
