//
//  USAVPermissionViewController.h
//  uSav-NewMac
//
//  Created by Luca on 2/12/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USAVFileHandler.h"
#import "USAVContactHandler.h"

@interface USAVPermissionViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (strong, nonatomic) NSString *keyId;
- (instancetype)initWithKeyId: (NSString *)keyId;

@property (strong, nonatomic) NSMutableArray *permissionAliasList;
@property (strong, nonatomic) NSMutableArray *permissionEmailList;
@property (strong, nonatomic) NSMutableArray *deleteEmailPermissionList;
@property (strong, nonatomic) NSMutableArray *deleteAliasPermissionList;
@property (strong, nonatomic) NSMutableArray *selectedRows;

//Restrictions
@property (weak) IBOutlet NSTextField *limitTextField;
@property (weak) IBOutlet NSTextField *durationTextField;
@property (weak) IBOutlet NSDatePicker *startTimePicker;
@property (weak) IBOutlet NSDatePicker *endTimePicker;
//---Decrypt Copy
@property (assign, nonatomic) NSInteger allowDecryptCopy;

- (IBAction)saveAsDefaultPressed:(id)sender;

@property (weak) IBOutlet NSSegmentedControl *decryptCopySegmentController;
- (IBAction)decryptCopySegmentChanged:(NSSegmentedControl *)sender;


//PermissionList
@property (weak) IBOutlet NSTableView *permissionTableView;

- (IBAction)addFromCondorContactsPressed:(id)sender;
- (IBAction)addFromSystemContactsPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;
- (IBAction)removeButtonPressed:(id)sender;


- (IBAction)cancelPressed:(id)sender;
- (IBAction)confirmPressed:(id)sender;

//New Permission
@property (weak) IBOutlet NSView *addPermissionView;
@property (weak) IBOutlet NSTextField *addAliasTextField;
@property (weak) IBOutlet NSTextField *addEmailTextField;
- (IBAction)addConfirmButtonPressed:(id)sender;
- (IBAction)addCancelButtonPressed:(id)sender;
@property (weak) IBOutlet NSButton *invalidAliasIndicator;
@property (weak) IBOutlet NSButton *invalidEmailIndicator;


//Activity
@property (weak) IBOutlet NSProgressIndicator *activityCircle;
@property (weak) IBOutlet NSTextField *activityLabel;

//Add contact from CONDOR
@property (strong) IBOutlet NSPanel *addContactPanel;
@property (assign, nonatomic) BOOL panelIsShowed;
@property (weak) IBOutlet NSTableView *addContactPanelTableView;
@property (strong, nonatomic) NSMutableArray *contactsAliasList;
@property (strong, nonatomic) NSMutableArray *contactsEmailList;
@property (weak) IBOutlet NSProgressIndicator *contactActivityCircle;
@property (strong, nonatomic) NSMutableArray *contactsStatusList;
- (IBAction)addContactPanelCancel:(id)sender;
- (IBAction)addContactPanelConfirm:(id)sender;
- (IBAction)addContactPanelRefresh:(id)sender;

@end
