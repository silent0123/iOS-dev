//
//  USAVGuidedSharingViewController.h
//  uSav
//
//  Created by NWHKOSX49 on 28/1/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "USAVGuidedSetPermissionViewController.h"
//@class USAVGuidedSharingViewController;
@interface USAVGuidedSharingViewController : UIViewController
 <UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate,UITableViewDelegate, MFMailComposeViewControllerDelegate, USAVContactListViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *fileImg;
@property (weak, nonatomic) IBOutlet UITextField *emailTxt;
@property (weak, nonatomic) IBOutlet UILabel *fileNameTxt;
@property (weak, nonatomic) IBOutlet UITableView *tbView;

@property (strong, nonatomic) NSMutableArray *emailList;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *keyId;

@property (weak, nonatomic) IBOutlet UINavigationItem *barItem;
@property (weak, nonatomic) IBOutlet UILabel *InstructionOne;
@property (weak, nonatomic) IBOutlet UILabel *InstructionTwo;
@property (weak, nonatomic) IBOutlet UIButton *ContactListBtn;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBtn;


@end
