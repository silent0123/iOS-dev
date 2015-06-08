//
//  COPeoplePickerViewController.h
//  COPeoplePickerViewController
//
//  Created by Erik Aigner on 08.10.11.
//  Copyright (c) 2011 chocomoko.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "USAVPassTimeValueProtocol.h"
#import "USAVTimeArrangeViewController.h"
#import "USAVFileViewController.h"
//#import "USAVTextMessageViewController.h"
#import "USAVSecureChatViewController.h"

@class USAVSecureChatViewController;

@protocol COPeoplePickerViewControllerDelegate;

@interface COPeoplePickerViewController:UIViewController<UIActionSheetDelegate, TimeArrangeDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) id<COPeoplePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) USAVSecureChatViewController *textMessageDelegate;
@property (nonatomic, weak) USAVFileViewController *fileControllerDelegate;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviBar;
@property (strong, nonatomic) UIButton *DoneBtn;  //从bar移到了下面
@property (strong, nonatomic) UIButton *confirmShareBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *CancelBtn;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *keyId;
@property (nonatomic) BOOL editPermission;

@property (assign, nonatomic) BOOL isChangedSetting;
@property (assign, nonatomic) BOOL isFromMessage;
@property (assign, nonatomic) BOOL isFromFileViewer;
@property (strong, nonatomic) UIButton *timeArrangeButton;

//---- Decrypt Copy
@property (assign, nonatomic) NSInteger allowSaveDecryptCopy;
/*!
 @property
 @abstract Returns the address book used by the view controller
 */
@property (nonatomic, readonly) ABAddressBookRef addressBookRef;

/*!
 @property displayedProperties
 @discussion An array of ABPropertyID listing the properties that should be visible when viewing a person.
 If you are interested in one particular type of data (for example a phone number), displayedProperties
 should be an array with a single NSNumber instance (representing kABPersonPhoneProperty).
 Note that name information will always be shown if available.
 
 DEVNOTE: currently only supports email (extend if you need more)
*/
@property (nonatomic, copy) NSArray *displayedProperties;

/*!
 @property selectedRecords
 @abstract Returns an array of CORecord.
 */
@property (nonatomic, readonly) NSArray *selectedRecords;

/*!
 @method resetTokenFieldWithRecords:
 @abstract Resets the token field if controller was initialized previously.
 */
- (void)resetTokenFieldWithRecords:(NSArray *)records;

@end

@interface COPerson : NSObject
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSString *namePrefix;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *middleName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *nameSuffix;
@property (nonatomic, readonly) NSArray *emailAddresses;
@property (nonatomic, readonly) ABRecordRef record;

- (id)initWithABRecordRef:(ABRecordRef)record;

@end

@interface CORecord : NSObject
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) COPerson *person;

- (id)initWithTitle:(NSString *)title person:(COPerson *)person;

@end

@protocol COPeoplePickerViewControllerDelegate <NSObject>
@optional

- (void)peoplePickerViewControllerDidFinishPicking:(COPeoplePickerViewController *)controller;

@end
