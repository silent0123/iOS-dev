//
//  USAVContactViewController.h
//  uSav
//
//  Created by young dennis on 5/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "USAVAddContactView.h"
#import "USAVPickerView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "USAVFileViewController.h"

@class USAVFileViewController;

@class USAVContactViewController;

@protocol USAVContactViewControllerDelegate <NSObject, UIAlertViewDelegate>
-(void)selectedContacts:(NSArray *)list
                 target:(USAVContactViewController *)sender;
@end

@interface USAVContactViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UIActionSheetDelegate, UITextFieldDelegate,
USAVPickerViewDelegate, UIAlertViewDelegate, ABPeoplePickerNavigationControllerDelegate> {}

@property (nonatomic, weak) id <USAVContactViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *addItemTextField;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarContact;

@property (strong, nonatomic) USAVFileViewController *fileControllerDelegate;

@property (nonatomic, copy) NSArray *displayedProperties;

@property (nonatomic) NSInteger mode;

@property (assign, nonatomic) NSInteger refreshWithNoAlert;

#define CONTACT_VIEW_MODE_MANAGE 0
#define CONTACT_VIEW_MODE_SELECT 1

@end