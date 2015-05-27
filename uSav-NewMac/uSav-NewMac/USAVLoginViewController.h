//
//  USAVLoginViewController.h
//  uSav-NewMac
//
//  Created by Luca on 9/12/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USAVAccountHandler.h"

@class MainViewController;

@interface USAVLoginViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) USAVAccountHandler *accountHandler;
@property (strong, nonatomic) MainViewController *mainViewController;

@property (strong, nonatomic) NSMutableArray *historyAccountList;

@property (assign, nonatomic) BOOL isHistoryAccountTableShowed;
@property (assign, nonatomic) BOOL isLoginInProgress;

@property (weak) IBOutlet NSTextField *accountTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSTextField *errorMessageLabel;
@property (weak) IBOutlet NSProgressIndicator *loginActivityIndicator;
@property (weak) IBOutlet NSTableView *historyAccountTableView;
@property (weak) IBOutlet NSTextFieldCell *historyAccountTextField;
@property (weak) IBOutlet NSButton *historyAccountDeleteButton;

- (IBAction)historyAccountDeleteButtonPressed:(id)sender;
- (IBAction)signUpButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)forgetPasswordButtonPressed:(id)sender;
- (IBAction)historyAccountButtonPressed:(id)sender;



@end
