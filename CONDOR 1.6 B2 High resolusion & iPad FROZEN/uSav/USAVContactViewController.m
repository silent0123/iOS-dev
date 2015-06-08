//
//  USAVContactViewController.m
//  uSav
//
//  Created by young dennis on 5/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//
//
// [self.navigationItem setTitle:NSLocalizedString(@"ContactHomeTitleKey", @"")];

#import "USAVContactViewController.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"
#import "KKPasscodeLock.h"
#import "DOPScrollableActionSheet.h"

#define GROUP_NAME_TAG 0
#define CONTACT_NAME_TAG 1

#define ALERT_TAG_DONE_BUTTON_PRESSED 0

#define ACTIONSHEET_TAG_RIGHTBARBTN_HOME_SELECT   0
#define ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_SELECT  1
#define ACTIONSHEET_TAG_RIGHTBARBTN_HOME_INITIAL  2
#define ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_INITIAL 3
#define ACTIONSHEET_TAG_RIGHTBARBTN_HOME_MANAGE   4
#define ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_MANAGE  5
#define ACTIONSHEET_TAG_PERROW_CONTACT_MANAGE     6
#define ACTIONSHEET_TAG_PERROW_GROUP_MANAGE       7
#define ACTIONSHEET_TAG_Click_On_Group            8
#define ACTIONSHEET_TAG_IN_CHECK_MEMBER           9
#define ACTIONSHEET_TAG_IN_GROUP                  10

#define TEXT_FIELD_TOTAL_HEIGHT 50.0

@interface USAVContactViewController (){
    
    ABPeoplePickerNavigationController *picker;
    
@private
    ABAddressBookRef addressBook_;
    CGRect           keyboardFrame_;
}

@property (nonatomic, strong) NSMutableArray *arrayOfGroupsUpToCurrentLayer; // top = index 0
@property (nonatomic, strong) NSMutableArray *arrayOfGroups;
@property (nonatomic, strong) NSMutableArray *arrayOfContacts;
@property (nonatomic, strong) NSMutableArray *groupMembers;
@property (nonatomic, strong) NSString *friendAliasFromAddressbook;

@property (nonatomic, strong) NSMutableArray *arrayOfSelectedContacts;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) UIAlertView *alertForBack;
@property (nonatomic, strong) NSString *groupStr;

@property (nonatomic, strong) NSString *aliasHolder;
@property (nonatomic, strong) NSString *groupHolder;

@property (nonatomic) BOOL selectAllContacts;
@property (strong, nonatomic) UIBarButtonItem *actionBarBtn;
@property (strong, nonatomic) UIBarButtonItem *doneBarBtn;
@property (strong, nonatomic) UIBarButtonItem *backBtn;
@property (strong, nonatomic) UIBarButtonItem *homeBtn;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (nonatomic) BOOL inEditAlias;
@property (nonatomic) BOOL inEditNote;
@property (nonatomic) BOOL renameGroup;
@property (nonatomic) BOOL inCheckMember;

@property (strong, nonatomic) UITextField *alertTextField;

// @property (strong, nonatomic) UIBarButtonItem *goBackHomeBtn;
@property (strong, nonatomic) UIBarButtonItem *selectDoneBtn;
@property (strong, nonatomic) USAVPickerView *pickerView;
@property (strong, nonatomic)  UIActionSheet *tmpSht;

// @property (strong,nonatomic) UIActionSheet *pickerActionSheet;

@property (strong, nonatomic) UITableViewCell *selectedCell;

//HintLable
@property (strong, nonatomic) UILabel *hintLabel;

@end

@implementation USAVContactViewController
@synthesize homeBtn = _homeBtn;
@synthesize navBarItem = _navBarItem;
@synthesize inCheckMember = _inCheckMember;
@synthesize actionBarBtn;
@synthesize doneBarBtn;
@synthesize naviBar;
@synthesize inEditAlias;
@synthesize inEditNote;
@synthesize alertTextField;
@synthesize aliasHolder = _aliasHolder;
@synthesize groupHolder = _groupHolder;
// @synthesize goBackHomeBtn;
@synthesize selectDoneBtn;
@synthesize currentIndexPath;
@synthesize addItemTextField;
@synthesize tblView;
@synthesize selectAllContacts;
@synthesize mode;
@synthesize pickerView;

@synthesize arrayOfGroupsUpToCurrentLayer;
@synthesize arrayOfGroups;
@synthesize arrayOfContacts;
@synthesize arrayOfSelectedContacts;

@synthesize backBtn = _backBtn;
@synthesize renameGroup = _renameGroup;
@synthesize tabBarContact = _tabBarContact;


- (void)freshBtnPressed {
    //[self listGroup];
    //[self listTrustedContactStatus];
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
    [self.fileControllerDelegate showDashBoard];
}

- (void)enableBackBtn
{
    self.navigationItem.leftBarButtonItem = self.backBtn;
}

- (void)disableBackBtn
{
    self.navigationItem.leftBarButtonItem = self.homeBtn;
}

// @synthesize pickerActionSheet;

int currentGroupIndex;
int currentContactIndex;
int currentMemberIndex;
int currentTbViewIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    //[self.tabBarContact setTitle:NSLocalizedString(@"TabBarContact", @"")];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)awakeFromNib {
    [self.tabBarContact setTitle:NSLocalizedString(@"TabBarContact", @"")];
}

-(void)addContactToSelectedList:(int)idx
{
    [self.arrayOfSelectedContacts addObject:[self.arrayOfContacts objectAtIndex:idx]];
}

-(void)removeContactFromSelectedList:(int)idx
{
    [self.arrayOfSelectedContacts removeObject:[self.arrayOfContacts objectAtIndex:idx]];
}

- (void)changeTextColorForUIActionSheetDeleteGroup:(UIActionSheet*)actionSheet {
    UIColor *tintColor = [UIColor redColor];
    
    NSArray *actionSheetButtons = actionSheet.subviews;
    for (int i = 0; [actionSheetButtons count] > i; i++) {
        if (i != 4) continue;
        UIView *view = (UIView*)[actionSheetButtons objectAtIndex:i];
        if([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton*)view;
            [btn setTitleColor:tintColor forState:UIControlStateNormal];
            
        }
    }
}

- (void)changeTextColorForUIActionSheetDeleteContact:(UIActionSheet*)actionSheet {
    UIColor *tintColor = [UIColor redColor];
    
    NSArray *actionSheetButtons = actionSheet.subviews;
    for (int i = 0; [actionSheetButtons count] > i; i++) {
        if (i != 4) continue;
        UIView *view = (UIView*)[actionSheetButtons objectAtIndex:i];
        if([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton*)view;
            [btn setTitleColor:tintColor forState:UIControlStateNormal];
            
        }
    }
}



-(void)listGroupResult:(NSDictionary*)obj {
    
    if ([self.alert isVisible]) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        
        return;
    }
    
    if (obj == nil) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        
        return;
    }
    
	if (obj != nil) {
        NSLog(@"%@ list group result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
         [self.arrayOfGroups removeAllObjects];
        if (([obj objectForKey:@"groupList"] != nil) && ([[obj objectForKey:@"groupList"] count] > 0)) {
            
            [self.arrayOfGroups addObjectsFromArray:[obj objectForKey:@"groupList"]];
            // [self.tblView reloadData];
            [self.arrayOfGroups sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            //成功提示
            //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
            
            [UIView transitionWithView: self.tblView
                              duration: 0.50f
                               options: UIViewAnimationOptionTransitionCrossDissolve
                            animations: ^(void)
             {
                 [self.tblView reloadData];
                 //localized contacts
                 [[NSUserDefaults standardUserDefaults] setObject:self.arrayOfGroups forKey:@"arrayOfGroups"];
             }
                            completion: ^(BOOL isFinished)
             {
                 /* TODO: Whatever you want here */
             }];

            
        } else {
            //localized contacts
            [[NSUserDefaults standardUserDefaults] setObject:self.arrayOfGroups forKey:@"arrayOfGroups"];
            [self.tblView reloadData];
        }
    }
    else {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListGroupKey", @"") inView:self.view];
    }
}

-(void) listTrustedContactStatusResult:(NSDictionary*)obj {
    
    if ([self.alert isVisible]) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        return;
    }
    
	if (obj != nil) {
        NSLog(@"%@ list trust contact result: %@", [self class], obj);
        [self.arrayOfContacts removeAllObjects];
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        if (([obj objectForKey:@"contactList"] != nil) && ([[obj objectForKey:@"contactList"] count] > 0)) {
            [self.arrayOfContacts addObjectsFromArray:[obj objectForKey:@"contactList"]];
            //[self.arrayOfContacts sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"friendEmail" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            [self.arrayOfContacts sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            //localized Contacts
            [[NSUserDefaults standardUserDefaults] setObject:self.arrayOfContacts forKey:@"arrayOfContacts"];
            
            //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
            [self.tblView reloadData];
        } else if ([[obj objectForKey:@"contactList"] count] == 0) {
            //localized Contacts
            [[NSUserDefaults standardUserDefaults] setObject:self.arrayOfContacts forKey:@"arrayOfContacts"];
            [self.tblView reloadData];
            //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
        }
        
        //成功提示
        //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
    }
}

-(void) listTrustedContactResult:(NSDictionary*)obj {
    
    if ([self.alert isVisible]) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        return;
    }

	if (obj != nil) {
        NSLog(@"%@ list trust contact result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        if (([obj objectForKey:@"friendList"] != nil) && ([[obj objectForKey:@"friendList"] count] > 0)) {
            [self.arrayOfContacts removeAllObjects];
            [self.arrayOfContacts addObjectsFromArray:[obj objectForKey:@"friendList"]];
            //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
            [self.tblView reloadData];
        } else if ([[obj objectForKey:@"friendList"] count] == 0) {
            //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
        }
        
        //成功提示
        //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
    }
}


-(void) listGroupMemberResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"memberList"] != nil)) {
        NSLog(@"%@ list group member result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        
        [self.arrayOfContacts removeAllObjects];
        [self.arrayOfContacts addObjectsFromArray:[obj objectForKey:@"memberList"]];
        
        // clear the group list
        [self.arrayOfGroups removeAllObjects];
        
        // update the title
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", [self getCurrentLayer]]];
        //self.navigationItem.leftBarButtonItem = self.homeBtn;
        // [self.tblView reloadData];
        
        [UIView transitionWithView: self.tblView
                          duration: 0.50f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void)
         {
             self.inCheckMember = true;
             [self.tblView reloadData];
         }
                        completion: ^(BOOL isFinished)
         {
             /* TODO: Whatever you want here */
         }];
        
        //成功提示
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
    }
}

-(void) listGroupMemberStatusResult:(NSDictionary*)obj {
    
    if ([self.alert isVisible]) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260){
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        [self.arrayOfGroupsUpToCurrentLayer removeAllObjects];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.arrayOfGroupsUpToCurrentLayer removeAllObjects];
        //[self.tblView reloadData];
    
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"contactList"] != nil)) {
        NSLog(@"%@ list group member result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        
        //[self.arrayOfGroupsUpToCurrentLayer addObject:self.groupStr];
        [self enableBackBtn];
        self.navigationItem.rightBarButtonItem = nil;
        [self.groupMembers removeAllObjects];
        [self.groupMembers addObjectsFromArray:[obj objectForKey:@"contactList"]];
        /*
        [self.arrayOfContacts removeAllObjects];
        [self.arrayOfContacts addObjectsFromArray:[obj objectForKey:@"contactList"]];
        
        // clear the group list
        [self.arrayOfGroups removeAllObjects];
        */
        // update the title
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", [self getCurrentLayer]]];
        

        self.inCheckMember = true;
        [self.tblView reloadData];

        
        //成功提示
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
              [self.arrayOfGroupsUpToCurrentLayer removeAllObjects];
    }
}

-(void)listGroup
{
    if (!self.refreshWithNoAlert) {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarGetContact", @"")
                                                      delegate:self];
    }

    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listGroup:encodedGetParam target:(id)self selector:@selector(listGroupResult:)];
}

-(void)listTrustedContact
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listTrustedContact:encodedGetParam target:(id)self selector:@selector(listTrustedContactResult:)];
}

-(void)listTrustedContactStatus
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listTrustedContactStatus:encodedGetParam target:(id)self selector:@selector(listTrustedContactStatusResult:)];
}

-(void)listGroupMember:(NSString *)groupId
{
    USAVClient *client = [USAVClient current];
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupId, @"\n"];
    NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    NSLog(@"signature: %@", signature);
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listGroupMember:encodedGetParam target:(id)self selector:@selector(listGroupMemberResult:)];
}

-(void)listGroupMemberStatus:(NSString *)groupId
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ListGroupMember", @"")
                                                  delegate:self];
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupId, @"\n"];
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];

    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listGroupMemberStatus:encodedGetParam target:(id)self selector:@selector(listGroupMemberStatusResult:)];
}

-(void) deleteCategoryResult:(NSDictionary*)obj{
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    
	if (obj != nil) {
        NSLog(@"PhraseView delete folder: %@", obj);
        if ([[obj objectForKey:@"success"] boolValue]) {
            /*
            [self.arrayOfGroups removeObject:[obj objectForKey:@"context"]];
            [self.tblView reloadData];
            
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"FolderDeletedKey", @"") inView:self.view];
             */
            
            //成功提示
            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
            return;
        }
    }
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"FolderDeleteFailedKey", @"") inView:self.view];
}

-(void) deletePhraseResult:(NSDictionary*)obj{
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }

    
	if (obj != nil) {
        NSLog(@"PhraseView delete phrase: %@", obj);
        if ([[obj objectForKey:@"success"] boolValue]) {
            /*
            [self.arrayOfContacts removeObject:[obj objectForKey:@"context"]];
            [self.tblView reloadData];
            
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"SubjectDeletedKey", @"") inView:self.view];
             */
            //成功提示
            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
            return;
        }
    }
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"SubjectDeleteFailedKey", @"") inView:self.view];
}

-(void) deleteGroupResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                
                // [self.arrayOfContacts addObject:friendDict];
                [self.arrayOfGroups removeObjectAtIndex:currentGroupIndex];
                [self.tblView reloadData];
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                
                return;
            }
                break;
            case GROUP_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"GroupNameNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"RemoveGroupUnknownErrorKey", @"") inView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.tmpSht dismissWithClickedButtonIndex:0 animated:NO];
    [self.tblView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    //[self dismissViewControllerAnimated:NO completion:nil];
    //[self.tmpSht dismissWithClickedButtonIndex:0 animated:NO];
}

-(void) deleteGroupBuildRequest:(NSString *)groupName {
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupName, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api removeGroup:encodedGetParam target:(id)self selector:@selector(deleteGroupResult:)];
}

-(void) deleteContactResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        [self.tblView reloadData];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }

	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteContactResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                
                // [self.arrayOfContacts addObject:friendDict];
                [self.arrayOfContacts removeObjectAtIndex:currentContactIndex];
                [self.tblView reloadData];
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            case FRIEND_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"ContactNameNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"DeleteTrustContactUnknownErrorKey", @"") inView:self.view];
}

-(void) editFriendAliasResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        [self.tblView reloadData];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        return;
    }
 
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteContactResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                UITableViewCell *cell = [self.tblView cellForRowAtIndexPath:self.currentIndexPath];
                //cell.detailTextLabel.text = @"Hi";
                
                //NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *oldDict = (NSMutableDictionary *)[self.arrayOfContacts objectAtIndex:currentContactIndex];
                //[newDict addEntriesFromDictionary:oldDict];
                //[newDict setObject:@"Donsdfsdf" forKey:@"email"];
                [oldDict setObject:self.aliasHolder forKey:@"friendAlias"];
                //[self.arrayOfContacts replaceObjectAtIndex:currentContactIndex withObject:newDict];
                [self.tblView reloadData];
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            default:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"EditNoteFault", @"") inView:self.view];
                [self.tblView reloadData];
            }
                return;
                break;
        }
    }
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"DeleteTrustContactUnknownErrorKey", @"") inView:self.view];
}

-(void) editFriendEmailResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
  
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteContactResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                UITableViewCell *cell = [self.tblView cellForRowAtIndexPath:self.currentIndexPath];
                //cell.detailTextLabel.text = @"Hi";
                
                //NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *oldDict = (NSMutableDictionary *)[self.arrayOfContacts objectAtIndex:currentContactIndex];
                //[newDict addEntriesFromDictionary:oldDict];
                //[newDict setObject:@"Donsdfsdf" forKey:@"email"];
                [oldDict setObject:self.alertTextField.text forKey:@"friendNote"];
                //[self.arrayOfContacts replaceObjectAtIndex:currentContactIndex withObject:newDict];
                [self.tblView reloadData];
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            default:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"EditNoteFault", @"") inView:self.view];
                [self.tblView reloadData];
            }
                return;
                break;
        }
    }
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"DeleteTrustContactUnknownErrorKey", @"") inView:self.view];
}

-(void) editGroupNameResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
              return;
    }

	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteContactResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                [self.arrayOfGroups replaceObjectAtIndex:currentGroupIndex withObject:self.alertTextField.text];
                [self.tblView reloadData];
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            default:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RenameGroupFault", @"") inView:self.view];
            }
                return;
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"DeleteTrustContactUnknownErrorKey", @"") inView:self.view];
}

-(void) deleteContactBuildRequest:(NSString *)friendName {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", friendName, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api deleteTrustContact:encodedGetParam target:(id)self selector:@selector(deleteContactResult:)];
}

-(void) editFriendAlias:(NSString *)friendName alias: (NSString *)alias{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEditAlias", @"")
                                                  delegate:self];

    USAVClient *client = [USAVClient current];
    
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@", alias, @"\n", friendName];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:alias];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api editFriendAlias:encodedGetParam target:(id)self selector:@selector(editFriendAliasResult:)];
}

-(void) editFriendEmail:(NSString *)friendName email: (NSString *)email{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEditAlias", @"")
                                                  delegate:self];
    
    USAVClient *client = [USAVClient current];
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@", email, @"\n", friendName];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:email];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    //[client.api editFriendNote:encodedGetParam target:(id)self selector:@selector(editFriendEmailResult:)];
    [client.api editFriendAlias:encodedGetParam target:(id)self selector:@selector(editFriendAliasResult:)];
}

-(void) editGroupNameFrom:(NSString *)oldname to: (NSString *)newname{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEditGroupName", @"")
                                                  delegate:self];
    USAVClient *client = [USAVClient current];
    
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@", newname, @"\n", oldname];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"oldname" stringValue:oldname];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"newname" stringValue:newname];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api editGroupName:encodedGetParam target:(id)self selector:@selector(editGroupNameResult:)];
}

-(void) deleteGroupMemberResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
 
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView deleteGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                
                // [self.arrayOfContacts addObject:friendDict];
                [self.groupMembers removeObjectAtIndex:currentMemberIndex];
                [self.tblView reloadData];
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            case GROUP_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"GroupNameNotFoundKey", @"") inView:self.view];
                return;
            }
            case MEMBER_NOT_EXIST:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"GroupMemberNotExistKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
        
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"RemoveGroupUnknownErrorKey", @"") inView:self.view];
}

-(void)deleteGroupMemberBuildRequest:(NSString *)friendName inGroup:(NSString *)groupName
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", friendName, @"\n", groupName, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api removeGroupMember:encodedGetParam target:(id)self selector:@selector(deleteGroupMemberResult:)];
}

- (void) backBtnPressed
{
    self.inCheckMember = false;
    [self goUpOneGroup];
    [self disableBackBtn];
}

- (void)receiveTestNotification:(NSNotification *) notification
{
    //DissmissSheet
    //[self dismissViewControllerAnimated:YES completion:nil];
    if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
        [self.alertForBack dismissWithClickedButtonIndex:-1 animated:NO];
    }    
    [self.tblView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if ([[self.view subviews] containsObject:self.pickerView]) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    //[self.navigationItem setTitle:NSLocalizedString(@"ContactHomeTitleKey", @"")];
    
    
    if([self.view.subviews containsObject: self.pickerView]){
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    
    
    
    [self.view.window setUserInteractionEnabled:YES];
}

- (void)changeAccount:(NSNotification *) notification
{
    self.refreshWithNoAlert = 1;
    [self listGroup];
    [self listTrustedContactStatus];
    self.refreshWithNoAlert = 0;
    
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self.fileControllerDelegate showDashBoard];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Inner_bg_lightgray"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    self.view.autoresizesSubviews = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:@"LoginSucceed"
                                               object:nil];
    [self.alertForBack setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"DismissSheet"
                                               object:nil];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    //[self.navigationItem setTitle:NSLocalizedString(@"ContactHomeTitleKey", @"")];
    [self.tabBarContact setTitle:NSLocalizedString(@"TabBarContact", @"")];
    
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    
    self.selectAllContacts = FALSE;
    self.friendAliasFromAddressbook = @"";
    
    //设置hintLabel
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.hintLabel.center = CGPointMake(self.tblView.center.x, self.tblView.center.y - 40);
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = [UIColor colorWithWhite:0.3 alpha:0.9];
    self.hintLabel.text = NSLocalizedString(@"No CONDOR Contact\nClick here to add from phone contact", nil);
    self.hintLabel.font = [UIFont boldSystemFontOfSize:13];
    self.hintLabel.numberOfLines = 2;
    //add tap recognizer to add from phone contact
    [self.hintLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *noContactAndAddFromPhoneContactRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFromAddressBookBtnPressed)];
    [self.hintLabel addGestureRecognizer:noContactAndAddFromPhoneContactRec];
    
    self.tblView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    //separator
    self.tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tblView.separatorColor = [UIColor lightGrayColor];
    self.tblView.separatorInset = UIEdgeInsetsZero;
    //use this to set frame when using autolayout
    self.tblView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.addItemTextField.delegate = self;
    
    self.actionBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionBarBtnPressed:)];
    
    self.doneBarBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DoneKey", @"") style:UIBarButtonItemStyleDone target:self action:@selector(doneBarBtnPressed:)];
    
    self.homeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(freshBtnPressed)];
    self.navigationItem.rightBarButtonItem = self.actionBarBtn;
    self.navigationItem.leftBarButtonItem = self.homeBtn;
    
    self.backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnPressed)];
    
    //self.navigationItem.rightBarButtonItem = self.homeBtn;
    
    if (self.mode == CONTACT_VIEW_MODE_SELECT) {
        self.selectDoneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveAndReturnKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(selectDoneBtnPressed:)];
        self.navigationItem.leftBarButtonItem = self.selectDoneBtn;
    }
    
    self.arrayOfGroups = [[NSMutableArray alloc] initWithCapacity:0];
    self.arrayOfContacts = [[NSMutableArray alloc] initWithCapacity:0];
    self.arrayOfGroupsUpToCurrentLayer = [[NSMutableArray alloc] initWithCapacity:0];
    self.groupMembers = [[NSMutableArray alloc] initWithCapacity:0];
    self.arrayOfSelectedContacts = [[NSMutableArray alloc] initWithCapacity:0];
        
    //[self listGroup];
    //[self listTrustedContactStatus];
    
    //localized Contacts
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfGroups"] count] > 0) {
        self.arrayOfGroups = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfGroups"] mutableCopy];
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfContacts"] count] > 0) {
        self.arrayOfContacts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfContacts"] mutableCopy];
    }
    
    self.refreshWithNoAlert = 1;
    
    if (self.refreshWithNoAlert || (![[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfGroups"] count] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfContacts"] count])) {
        [self listGroup];
        [self listTrustedContactStatus];
    }
    
    self.refreshWithNoAlert = 0;


    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    if ([self.arrayOfGroupsUpToCurrentLayer count] == 0) {

    [self listGroup];
    [self listTrustedContactStatus];
    }
    
    [refreshControl endRefreshing];
}

- (void)viewDidUnload
{
    
    [self setTblView:nil];
    [self setNaviBar:nil];
    [self setAddItemTextField:nil];
    [self setNavBarItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    NSInteger totalCnt;
    if (self.inCheckMember) {
        
        //显示hint提示
        if (![self.groupMembers count]) {
            self.tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            self.hintLabel.text = NSLocalizedString(@"No Group Member", nil);
            if (![[self.tblView subviews] containsObject:self.hintLabel]) {
                [self.tblView addSubview:self.hintLabel];
            }
            
        } else {
            self.tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            if ([[self.tblView subviews] containsObject:self.hintLabel]) {
                [self.hintLabel removeFromSuperview];
            }
            
        }
        
        return [self.groupMembers count];
        
    } else {
        
        totalCnt = [self.arrayOfGroups count] + [self.arrayOfContacts count];
        
        //显示hint提示
        if (!totalCnt) {
            self.tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            self.hintLabel.text = NSLocalizedString(@"No CONDOR Contact\nClick here to add from phone contact", nil);
            if (![[self.tblView subviews] containsObject:self.hintLabel]) {
                [self.tblView addSubview:self.hintLabel];
            }
            
        } else {
            self.tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            if ([[self.tblView subviews] containsObject:self.hintLabel]) {
                [self.hintLabel removeFromSuperview];
            }
            
        }
        
    }
    [self.navigationItem setTitle:NSLocalizedString(@"ContactHomeTitleKey", @"")];
    

    
    return totalCnt;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor clearColor];
    
    //选中颜色
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    NSInteger folderCount = [self.arrayOfGroups count];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    if (self.inCheckMember) {
        
        NSDictionary *contact = [self.groupMembers objectAtIndex:(indexPath.row)];
        NSString *friendAlias;
        if ([contact objectForKey:@"friendAlias"] == nil || [[contact objectForKey:@"friendAlias"]  isEqual: @""]) {
            //没有Alias的用户，取Email的名字段为Alias
            NSArray *EmailStringArray = [[contact objectForKey:@"friendEmail"] componentsSeparatedByString:@"@"];
            friendAlias = [EmailStringArray objectAtIndex:0];
        } else {
            friendAlias = [contact objectForKey:@"friendAlias"];
        }
        cell.textLabel.text = friendAlias;
        
        if ([[contact objectForKey:@"friendStatus"] isEqualToString:@"inactivated"]) {
            //cell.textLabel.textColor = [UIColor redColor];
            cell.imageView.image = [UIImage imageNamed:@"person24_gray"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"person"];
        }
        
        cell.detailTextLabel.text = [contact objectForKey:@"friendEmail"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.accessoryType =  UITableViewCellAccessoryNone;
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        
        if (([self.arrayOfSelectedContacts containsObject:contact]) &&
            (mode == CONTACT_VIEW_MODE_SELECT)) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            if (!self.inCheckMember) {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
                cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
            }
        }
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        if (indexPath.row < folderCount) {
            // display the folders first
            cell.textLabel.text = [self.arrayOfGroups objectAtIndex:indexPath.row];
            //cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.imageView.image = [UIImage imageNamed:@"group3"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
            cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            cell.detailTextLabel.text = nil;
            
        }
        else {
            // 联系人text为Alias，DetailText为邮件
            NSDictionary *contact = [self.arrayOfContacts objectAtIndex:(indexPath.row - folderCount)];
            NSString *friendAlias;
            if ([contact objectForKey:@"friendAlias"] == nil || [[contact objectForKey:@"friendAlias"]  isEqual: @""]) {
                //没有Alias的用户，取Email的名字段为Alias
                NSArray *EmailStringArray = [[contact objectForKey:@"friendEmail"] componentsSeparatedByString:@"@"];
                friendAlias = [EmailStringArray objectAtIndex:0];
            } else {
                friendAlias = [contact objectForKey:@"friendAlias"];
            }
            cell.textLabel.text = friendAlias;
            
            if ([[contact objectForKey:@"friendStatus"] isEqualToString:@"inactivated"]) {
                //cell.textLabel.textColor = [UIColor redColor];
                cell.imageView.image = [UIImage imageNamed:@"person24_gray"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"person"];
            }
            
            cell.detailTextLabel.text = [contact objectForKey:@"friendEmail"];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
            cell.accessoryType =  UITableViewCellAccessoryNone;
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            
            if (([self.arrayOfSelectedContacts containsObject:contact]) &&
                (mode == CONTACT_VIEW_MODE_SELECT)) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                if (!self.inCheckMember) {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
                    cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
                }
            }
        }
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = indexPath;
    int idx = indexPath.row;
    if ([self getCurrentLayer] == nil) {
//        if (idx < [self.arrayOfGroups count]) {  // handle group
//            self.groupStr = [self.arrayOfGroups objectAtIndex:idx];
//            [UIView animateWithDuration:.5 // 0.2 but slowed down to easily see difference
//                                  delay:0
//                                options:UIViewAnimationOptionCurveEaseOut
//                             animations:^{
//                                 self.tblView.frame =  CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.tblView.frame.size.width, self.tblView.frame.size.height);
//                             }
//                             completion:nil];
//            self.navigationItem.rightBarButtonItem = Nil;
//            [self listGroupMemberStatus: self.groupStr];
//            [self.arrayOfGroupsUpToCurrentLayer addObject:self.groupStr];/*
//            [self enableBackBtn];
//            self.navigationItem.rightBarButtonItem = nil;*/
//        }
//        else {
//            [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
//        }
        //点每一行，直接就弹出选择按钮，不要再点accessory了，这里把accessory函数放过来为了方便
        [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
    else { // in a group
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (self.mode == CONTACT_VIEW_MODE_MANAGE) {
            if ([self getCurrentLayer] == nil) {
                if (indexPath.row < [self.arrayOfGroups count]) {  // handle group
                    currentGroupIndex = indexPath.row;
                    NSString *groupStr = [self.arrayOfGroups objectAtIndex:currentGroupIndex];
                    [self deleteGroupBuildRequest:groupStr];
                }
                else {                                                  // handle contact
                    currentContactIndex = indexPath.row - [self.arrayOfGroups count];
                    NSDictionary *contactDict = [self.arrayOfContacts
                                                 objectAtIndex:currentContactIndex];
                    [self deleteContactBuildRequest:[contactDict objectForKey:@"friendEmail"]];
                }
            }
            else { // in a group
                
                currentMemberIndex = indexPath.row; 
                [self deleteGroupMemberBuildRequest:cell.detailTextLabel.text inGroup:[self getCurrentLayer]];
            }
        }
    }
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    self.currentIndexPath = indexPath;
    NSInteger idx = indexPath.row;
    
    
    //for new actionsheet
    //group
    DOPAction *action1 = [[DOPAction alloc] initWithName:NSLocalizedString(@"Check Member", @"") iconName:@"DOP_memberList" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        NSString *groupStr = [self.arrayOfGroups objectAtIndex:currentGroupIndex];
        
        [self listGroupMemberStatus:groupStr];
        [self.arrayOfGroupsUpToCurrentLayer addObject:groupStr];
        
        
    }];
    DOPAction *action2 = [[DOPAction alloc] initWithName:NSLocalizedString(@"Rename Group", @"") iconName:@"DOP_editName" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterGroupName", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"OkKey", @""),nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        self.alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeDefault;
        alertTextField.placeholder = NSLocalizedString(@"EnterGroupNamePlaceHolder", @"");
        alertTextField.text = self.groupHolder;
        self.groupHolder = nil;
        self.renameGroup = true;
        self.alertForBack = alert;
        [alert show];
        
    }];
    DOPAction *action3 = [[DOPAction alloc] initWithName:NSLocalizedString(@"Delete Group", @"")iconName:@"DOP_delete" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        NSString *groupStr = [self.arrayOfGroups objectAtIndex:currentGroupIndex];
        [self deleteGroupBuildRequest:groupStr];
        
    }];
    
    //friend
    DOPAction *action4 = [[DOPAction alloc] initWithName:NSLocalizedString(@"ContactChangeNotesKey", @"") iconName:@"DOP_editName" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        NSInteger rowIndex = [self.tblView indexPathForSelectedRow].row;
        NSInteger folderCount = [self.arrayOfGroups count];
        NSDictionary *contact = [self.arrayOfContacts objectAtIndex:(rowIndex - folderCount)];
        NSString *userEmail = [contact objectForKey:@"friendEmail"];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterFriendAlias2", @"") message:userEmail delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"OkKey", @""),nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        self.alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeDefault;
        alertTextField.placeholder = NSLocalizedString(@"EnterFriendAliasPlaceHolder", @"");
        alertTextField.text = self.aliasHolder;
        self.aliasHolder = nil;
        self.inEditNote = true;
        self.alertForBack = alert;
        [alert show];
        
    }];
    DOPAction *action5 = [[DOPAction alloc] initWithName:NSLocalizedString(@"ContactAddToGroupKey", @"") iconName:@"DOP_addToGroup" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        [self addContactToGroupBtnPressed];
        
    }];
    DOPAction *action6 = [[DOPAction alloc] initWithName:NSLocalizedString(@"ContactDeleteKey", @"") iconName:@"DOP_delete" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        [self contactDeleteBtnPressed];
        
    }];
    DOPAction *action7 = [[DOPAction alloc] initWithName:NSLocalizedString(@"ContactBlockKey", @"") iconName:@"DOP_blockContact" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        [self contactDeleteBtnPressed];
        
    }];
    DOPAction *action8 = [[DOPAction alloc] initWithName:NSLocalizedString(@"ContactUnblockKey", @"") iconName:@"DOP_unblockContact" handler:^{
        
        //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
        self.addItemTextField.text = @"";
        [self doneBarBtnPressed:self.doneBarBtn];
        
        [self contactDeleteBtnPressed];
        
    }];
    
    
    if ([self getCurrentLayer] == nil) {
        if (idx < [self.arrayOfGroups count]) {  // handle group
            
            
            currentGroupIndex = indexPath.row;
            NSString *oldDict = (NSString *)[self.arrayOfGroups objectAtIndex: currentGroupIndex];
            self.groupHolder  = [oldDict copy];
            
            
            //new actionsheet
            NSArray *actions;
            
            actions = @[self.groupHolder, @[action1, action2, action3]];
            
            DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
            [actionSheet show];
            
            /*
             UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:self.groupHolder delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Check Member", @""),
             NSLocalizedString(@"Rename Group", @""),
             NSLocalizedString(@"Delete Group", @""),
             nil];
             self.tmpSht = sheet;
             sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
             sheet.tag = ACTIONSHEET_TAG_Click_On_Group;
             [sheet showInView:[self.view window]];
             [self changeTextColorForUIActionSheetDeleteGroup:sheet];
             */
            
            return;
        }
        else {                                                  // handle contact
            
            
            // NSDictionary *item = [self.arrayOfContacts objectAtIndex:(idx - [self.arrayOfGroups count])];
            currentContactIndex = idx - [self.arrayOfGroups count];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (mode == CONTACT_VIEW_MODE_MANAGE) {
                
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
                cell.accessoryView.frame = CGRectMake(0, 0, 8, 8);
                
                //NSMutableDictionary *oldDict = (NSMutableDictionary*)[self.arrayOfContacts objectAtIndex:currentContactIndex];
                self.aliasHolder = cell.textLabel.text;
                
                //new actionsheet
                NSArray *actions;
                
                //this is the only way to judge whether two pics are same
                if ([UIImagePNGRepresentation(cell.imageView.image) isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:@"person_blocked"])]) {
                    //blocked user
                    //actions = @[cell.textLabel.text, @[action4, action5, action6, action8]];
                    actions = @[cell.textLabel.text, @[action4, action5, action6]];
                } else {
                    //actions = @[cell.textLabel.text, @[action4, action5, action6, action7]];
                    actions = @[cell.textLabel.text, @[action4, action5, action6]];
                }
                
                
                DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
                [actionSheet show];
                
                
                /*
                 UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:cell.textLabel.text delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") destructiveButtonTitle:nil otherButtonTitles://NSLocalizedString(@"ContactChangeAliasKey", @""),
                 NSLocalizedString(@"ContactChangeNotesKey", @""),
                 NSLocalizedString(@"ContactAddToGroupKey", @""),
                 NSLocalizedString(@"ContactDeleteKey", @""), nil];
                 self.tmpSht = sheet;
                 sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                 sheet.tag = ACTIONSHEET_TAG_PERROW_CONTACT_MANAGE;
                 [sheet showInView:[self.view window]];
                 [self changeTextColorForUIActionSheetDeleteContact:sheet];
                 */
                
            }
            return;
        }
        
        
    }
    
    
}
-(void)addGroupResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
     
        switch (rc) {
            case SUCCESS:
            {
                [self.arrayOfGroups addObject:self.addItemTextField.text];
                [self.arrayOfGroups sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                
                [self.tblView reloadData];
                self.addItemTextField.text = @"";
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            case INVALID_GROUP_NAME:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"GroupNameInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case GROUP_EXIST:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"GroupNameAlreadyExistKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"GroupNameUnknownErrorKey", @"") inView:self.view];
}

-(void) addGroupBuildRequest:(NSString *)groupName {
    USAVClient *client = [USAVClient current];
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupName, @"\n"];
    NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    NSLog(@"signature: %@", signature);

    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addGroup:encodedGetParam target:(id)self selector:@selector(addGroupResult:)];
}

-(void)addContactResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }

	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                
                // [self.arrayOfContacts addObject:self.addItemTextField.text];
                NSDictionary *friendDict = [NSDictionary
                                            dictionaryWithObjectsAndKeys:self.addItemTextField.text,
                                            @"friend", @"", @"alias", @"", @"email", nil];
                [self.arrayOfContacts addObject:friendDict];
                //[self.tblView reloadData];
                [self listGroup];
                [self listTrustedContactStatus];
                self.addItemTextField.text = @"";
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            case ACC_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"ContactNameNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_FD_ALIAS:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"AliasNameInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_EMAIL:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"EmailNameInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case FRIEND_EXIST:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"FriendNameAlreadyExistKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"AddTrustContactUnknownErrorKey", @"") inView:self.view];
}

-(void)addFriendRequest:(NSString *)friendName {
    
    NSString *friendAlias;
    //如果没有输入Alias，则以Email前半段作为Alias，如果是从Addressbook选的，则使用addressbook的名字
    if ([self.alertTextField.text isEqualToString:@""] || self.alertTextField.text == nil) {
        
        if (![self.friendAliasFromAddressbook isEqualToString:@""]){
            friendAlias = self.friendAliasFromAddressbook;
        } else {
            NSArray *EmailStringArray = [friendName componentsSeparatedByString:@"@"];
            friendAlias = [EmailStringArray objectAtIndex:0];
        }
        
    } else {
        friendAlias = self.alertTextField.text;
    }
    
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", friendAlias, @"\n", friendName, @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:friendAlias];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"note" stringValue:@""];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    /*
     paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:aliasName];
     [paramsElement addChild:paramElement];
     paramElement = [GDataXMLNode elementWithName:@"email" stringValue:emailAddress];
     [paramsElement addChild:paramElement];
     */
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    self.alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProcessAddFriend", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [self.alert show];
    [client.api addFriend:encodedGetParam target:(id)self selector:@selector(addFriendResult:)];
}

-(void) addFriendResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        [self.tblView reloadData];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
   
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                // [self.arrayOfContacts addObject:self.addItemTextField.text];
                
                NSMutableDictionary *friendDict = [NSMutableDictionary
                                            dictionaryWithObjectsAndKeys:self.addItemTextField.text,
                                            @"friendEmail", @"", @"friendAlias", @"", @"friendNote", @"inactivated", @"friendStatus",nil];
                
                [self.arrayOfContacts addObject:friendDict];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"friendEmail" ascending:YES];
                [self.arrayOfContacts sortUsingDescriptors:[NSArray arrayWithObject:sort]];

                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                
                [picker dismissViewControllerAnimated:YES completion:nil];
                
                [self.tblView reloadData];
                [self listGroup];
                [self listTrustedContactStatus];
                
                self.addItemTextField.text = @"";
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            case ACC_NOT_FOUND:
            {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"ContactNameNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_FD_ALIAS:
            {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"AliasNameInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_EMAIL:
            {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"EmailNameInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case FRIEND_EXIST:
            {
                [self.alert dismissWithClickedButtonIndex:0 animated:YES];
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"FriendNameAlreadyExistKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"AddTrustContactUnknownErrorKey", @"") inView:self.view];
}

-(void) addContactBuildRequest:(NSString *)friendName {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", friendName, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:@""];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"email" stringValue:@""];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    /*
     paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:aliasName];
     [paramsElement addChild:paramElement];
     paramElement = [GDataXMLNode elementWithName:@"email" stringValue:emailAddress];
     [paramsElement addChild:paramElement];
     */
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addTrustContact:encodedGetParam target:(id)self selector:@selector(addContactResult:)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //NSLog(@"%zi",[textField.text length]);
    /*switch (textField.tag) {
        case GROUP_NAME_TAG:
        {
            if ([textField.text length] > 0 || [textField.text length] <= 49) {
                [self addGroupBuildRequest:textField.text];
            } else {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"AddGroupFault", @"") inView:self.view];
            }
        }
            break;
        case CONTACT_NAME_TAG:
        {
            if ([textField.text length] > 4 || [textField.text length] <= 32) {
                //[self addContactBuildRequest:textField.text];
                //self.inEditNote = false;
                //self.inEditAlias = false;
                
                [self addFriendRequest:textField.text];
            } else {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"AddFriendFault", @"") inView:self.view];
            }
        }
            break;
        default:
            break;
    }
    */
    [self doneBarBtnPressed:self];
    [textField resignFirstResponder];
    return YES;
}

-(NSString *)getCurrentLayer
{
    if ([self.arrayOfGroupsUpToCurrentLayer count] == 0) {
        return nil;
    }
    else {
        return [self.arrayOfGroupsUpToCurrentLayer lastObject];
    }
}

-(void)selectAllSubjectsInCurrentFolder
{
}

-(void)deleteGroupOrContact {
    [self.tblView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = self.doneBarBtn;
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"DeleteItemMsgKey", @"") inView:self.view];
}

-(void)selectAllContactsBtnPressed {
    for (NSDictionary *phrase in self.arrayOfContacts) {
        if (![self.arrayOfSelectedContacts containsObject:phrase]) {
            [self.arrayOfSelectedContacts addObject:phrase];
        }
    }
    [self.tblView reloadData];
}

-(void)selectAllMembersBtnPressed {
    for (NSDictionary *phrase in self.arrayOfContacts) {
        if (![self.arrayOfSelectedContacts containsObject:phrase]) {
            [self.arrayOfSelectedContacts addObject:phrase];
        }
    }
    [self.tblView reloadData];
}

-(void)goUpOneGroup {
    if ([self.arrayOfGroupsUpToCurrentLayer count] == 0) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"PathAlreadyAtTopKey", @"") inView:self.view];
    }
    else {
        [self.arrayOfGroupsUpToCurrentLayer removeLastObject];
        if ([self.arrayOfGroupsUpToCurrentLayer count] == 0) {

            // update the title
            [self.navigationItem setTitle:NSLocalizedString(@"ContactHomeTitleKey", @"")];
            self.navigationItem.rightBarButtonItem = self.actionBarBtn;
            self.navigationItem.leftBarButtonItem = self.homeBtn;
            
            //[self listGroup];
            //[self listTrustedContactStatus];
            [self.tblView reloadData];
        }
        else {
            NSLog(@"Contact View: shouldn't get here, we only support one level of group");
        }
    }
}

-(void)addContactBtnPressed {
    
    [UIView animateWithDuration:.5 // 0.2 but slowed down to easily see difference
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.tblView.frame =  CGRectMake(0.0, TEXT_FIELD_TOTAL_HEIGHT, self.tblView.frame.size.width, self.tblView.frame.size.height);
                         
                     }
                     completion:nil];
    
    //self.tblView.frame =  CGRectMake(0.0, self.addItemTextField.frame.size.height, self.tblView.frame.size.width, self.tblView.frame.size.height);
    self.addItemTextField.placeholder = NSLocalizedString(@"EnterNewContactMsgKey", @"");
    //UIImageView *myView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"person.png"]];
    self.addItemTextField.tag = CONTACT_NAME_TAG;
    [self.addItemTextField setRightView:nil];
    [self.addItemTextField setRightViewMode:UITextFieldViewModeAlways];
    [self.addItemTextField becomeFirstResponder];
    
    self.navigationItem.rightBarButtonItem = self.doneBarBtn;
    
    // WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    // [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    // [wv show:NSLocalizedString(@"AddContactMsgKey", @"") inView:self.view];
}

-(void)addGroupBtnPressed {
    [UIView animateWithDuration:.5 // 0.2 but slowed down to easily see difference
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.tblView.frame =  CGRectMake(0.0, TEXT_FIELD_TOTAL_HEIGHT /* self.addItemTextField.frame.size.height */, self.tblView.frame.size.width, self.tblView.frame.size.height);
                     }
                     completion:nil];

    self.addItemTextField.placeholder = NSLocalizedString(@"EnterNewGroupMsgKey", @"");
    UIImageView *myView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"group3"]];
    self.addItemTextField.tag = GROUP_NAME_TAG;
    [self.addItemTextField setRightView:nil];
    [self.addItemTextField setRightViewMode:UITextFieldViewModeAlways];
    [self.addItemTextField becomeFirstResponder];
    self.navigationItem.rightBarButtonItem = self.doneBarBtn;
    
    // WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    // [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    // [wv show:NSLocalizedString(@"AddGroupMsgKey", @"") inView:self.view];
}

- (ABAddressBookRef)addressBookRef {
    return addressBook_;
}

#pragma mark 从通讯录添加
- (void) addFromAddressBookBtnPressed {
        //id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
        //[tokenFieldDelegate tokenFieldDidPressAddContactButton:self];
        
        picker = [ABPeoplePickerNavigationController new];
        picker.addressBook = self.addressBookRef;
        picker.peoplePickerDelegate = self;
        picker.displayedProperties = self.displayedProperties;
        
        // Set same tint color on picker navigation bar
        UIColor *tintColor = self.navigationController.navigationBar.tintColor;
        if (tintColor != nil) {
            picker.navigationBar.tintColor = tintColor;
        }
        [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
#pragma unused (peoplePicker, person)
    return YES;
}

//NEW FOR iOS8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        if (!multi) return;
        self.friendAliasFromAddressbook = @"";
        //得到选中的名字
        self.friendAliasFromAddressbook = [NSString stringWithFormat:@"%@", (ABRecordCopyCompositeName(person))];
        //NSLog(@"%@", self.friendAliasFromAddressbook);
        
        NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, identifier));
        CFRelease(multi);
        
        
        
        if (![self isValidEmail:email]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"Please Select a Valid Email Address", @"") inView:picker.view];
        } else {
            
            [self addFriendRequest:email];
        }
    } else {
        //compatible for iOS7
        [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
    }
    
    
}

//compatible for iOS7
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
     #pragma unused (peoplePicker)
     ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
     if (!multi) return NO;
    
     self.friendAliasFromAddressbook = @"";
     //得到选中的名字
     self.friendAliasFromAddressbook = [NSString stringWithFormat:@"%@", (ABRecordCopyCompositeName(person))];
    
     NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, identifier));
     CFRelease(multi);
    
     if (![self isValidEmail:email]) {
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"Please Select a Valid Email Address", @"") inView:picker.view];
     } else {
     [self addFriendRequest:email];
     }
     
     //[self.tokenField processToken:email associatedRecord:record];
     //[self dismissViewControllerAnimated:YES completion:nil];
     
     return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
#pragma unused (peoplePicker)
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
-(void) addMemberBtnPressed
{
}
*/
- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.inEditAlias && buttonIndex == 1) {
        [self editFriendAlias:[[self.arrayOfContacts objectAtIndex: currentContactIndex] objectForKey:@"friendEmail"] alias:self.alertTextField.text];
        self.inEditAlias = false;
    }else if (self.inEditNote && buttonIndex == 1) {
        [self editFriendEmail:[[self.arrayOfContacts objectAtIndex: currentContactIndex] objectForKey:@"friendEmail"] email: self.alertTextField.text];
        self.aliasHolder = self.alertTextField.text;
        self.inEditNote = false;
    }else if (self.renameGroup && buttonIndex == 1) {
        [self editGroupNameFrom:[self.arrayOfGroups objectAtIndex: currentGroupIndex] to:self.alertTextField.text];
        self.renameGroup = false;
    }else if (buttonIndex == 0) {  self.inEditNote = false;
        [self.tblView reloadData];
        return;
    }
    else if (alertView.tag == ALERT_TAG_DONE_BUTTON_PRESSED) {
        if (buttonIndex == 1)
        {
            // Yes, do something
            switch (self.addItemTextField.tag) {
                case GROUP_NAME_TAG:
                {
                    if ([self.addItemTextField.text length] > 0 || [self.addItemTextField.text length] <= 49) {
                        [self addGroupBuildRequest:self.addItemTextField.text];
                    } else {
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"AddGroupFault", @"") inView:self.view];
                    }
                }
                    break;
                case CONTACT_NAME_TAG:
                {
                    if ([self isValidEmail:self.addItemTextField.text]){
                        //[self addContactBuildRequest:self.addItemTextField.text];
                         if ([self.addItemTextField.text isEqualToString:[[USAVClient current] emailAddress]])
                         {
                             WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                             [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                             [wv show:NSLocalizedString(@"CantAddOwn", @"") inView:self.view];
                         }else {
                             
                             [self addFriendRequest:self.addItemTextField.text];
                         }
                    } else {
                        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                        [wv show:NSLocalizedString(@"InvalidEmail", @"") inView:self.view];
                    }
                }
                    break;
                default:
                    break;
            }
        }
        else if (buttonIndex == 0)
        {
            // No
            self.addItemTextField.text = @"";
        }
    }
}

-(void)addContactToGroupBtnPressed
{
    [self.navigationItem setTitle:NSLocalizedString(@"AddContactToGroupTitleKey", @"")];
    
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if ([self.arrayOfGroups count] == 0) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"NoGroupInContactList", @"") inView:self.view];
        [self.tblView reloadData];
        return;
    }
    self.pickerView = [[USAVPickerView alloc] initWithFrame:CGRectMake(-[[UIScreen mainScreen] bounds].size.width, 64.0f, [[UIScreen mainScreen] bounds].size.width, screenHeight - 64) withGroupList:self.arrayOfGroups forContact:[self.arrayOfContacts objectAtIndex:currentContactIndex]];
    
    UIGraphicsBeginImageContext(self.pickerView.frame.size);
    [[UIImage imageNamed:@"Inner_bg_lightgray"] drawInRect:self.pickerView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.pickerView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.pickerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    self.pickerView.delegate = self;
    
    [self.view addSubview:self.pickerView];
    [self.navigationController setNavigationBarHidden:YES];
    
    // self.navigationItem.leftBarButtonItem = self.actionBarBtn;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [UIView animateWithDuration:0.2 // 0.2 but slowed down to easily see difference
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [self.pickerView setFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, screenHeight)];
                         // [self.dimView setFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.widthf, 50.0f)];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)doneBarBtnPressed:(id)sender {
    
    if (self.tblView.editing) {
        [self.tblView setEditing:NO animated:YES];
        //self.navigationItem.rightBarButtonItem = self.homeBtn;
    }
    else if (self.tblView.frame.origin.y == (TEXT_FIELD_TOTAL_HEIGHT)) {
        // table has been shifted down to allow adding new category/phrase, now shift it back up
        
        if  (([self.addItemTextField.text length] > 0) && ([self getCurrentLayer] == nil)) {
            UIAlertView *alert = [[UIAlertView alloc] init];
            if (self.addItemTextField.tag == GROUP_NAME_TAG) {
                [alert setTitle:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"AddGroupWithNameKey", @""), self.addItemTextField.text]];
                // [alert setTitle:[NSString stringWithFormat:@"Add folder \"%@\"?", self.addItemTextField.text]];
            }
            else {
                //新增输入用户昵称
                [alert setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"AddContactWithNameKey", @"")]];
                [alert setMessage:NSLocalizedString(@"EnterFriendAlias2", @"")];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                self.alertTextField = [alert textFieldAtIndex:0];
                alertTextField.keyboardType = UIKeyboardTypeDefault;
                alertTextField.placeholder = NSLocalizedString(@"EnterFriendAliasPlaceHolder", @"");
                self.aliasHolder = nil;
                self.inEditNote = false;
            }
            //[alert setMessage:NSLocalizedString(@"PressYesOrNoKey", @"")];
            [alert setDelegate:self];
            [alert addButtonWithTitle:NSLocalizedString(@"CancelKey", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"ConfirmLabel", @"")];
            alert.tag = ALERT_TAG_DONE_BUTTON_PRESSED;
            self.alertForBack = alert;
            [alert show];
            
        }
        
        [UIView animateWithDuration:0.2 // 0.2 but slowed down to easily see difference
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.tblView.frame =  CGRectMake(0.0, 0, self.tblView.frame.size.width, self.tblView.frame.size.height);
                         }
                         completion:nil];
        
        //self.navigationItem.rightBarButtonItem = self.homeBtn;
        [self.addItemTextField resignFirstResponder];
        self.navigationItem.rightBarButtonItem = self.actionBarBtn;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.tblView reloadData];
        return;
    }
    
    //点击actionsheet的时候，自动隐藏输入框. (上面点击cancel则不用隐藏)
    self.addItemTextField.text = @"";
    [self doneBarBtnPressed:self.doneBarBtn];
    
    if (actionSheet.tag == ACTIONSHEET_TAG_Click_On_Group)
    {
        NSString *groupStr = [self.arrayOfGroups objectAtIndex:currentGroupIndex];
        switch (buttonIndex) {
            case 0: //check member
            {
                [self listGroupMemberStatus:groupStr];
                [self.arrayOfGroupsUpToCurrentLayer addObject:groupStr];/*
                [self enableBackBtn];
                self.navigationItem.rightBarButtonItem = nil;*/
            }
                break;
            case 1: //rename group
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterGroupName", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"OkKey", @""),nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                self.alertTextField = [alert textFieldAtIndex:0];
                alertTextField.keyboardType = UIKeyboardTypeDefault;
                alertTextField.placeholder = NSLocalizedString(@"EnterGroupNamePlaceHolder", @"");
                alertTextField.text = self.groupHolder;
                self.groupHolder = nil;
                self.renameGroup = true;
                self.alertForBack = alert;
                [alert show];
            }
                break;
            case 2: //delete group
            {
                [self deleteGroupBuildRequest:groupStr];
            }
                break;
            default:
                break;
        }
    }
    
    if ((actionSheet.tag == ACTIONSHEET_TAG_RIGHTBARBTN_HOME_INITIAL) ||
        (actionSheet.tag == ACTIONSHEET_TAG_RIGHTBARBTN_HOME_MANAGE))
    { // at home
        
        switch (buttonIndex) {
            case 0:
            {
                [self addGroupBtnPressed];
            }
                break;
            case 1:
            {
                [self addContactBtnPressed];
            }
                break;
            case 2:
            {
                [self addFromAddressBookBtnPressed];// Search
            }
                break;
            default:
                break;
        }
    }
    else if ((actionSheet.tag == ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_INITIAL) ||
             (actionSheet.tag == ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_MANAGE))
    {  // in a group
        switch (buttonIndex) {
            case 0: // go up one folder
            {
                [self goUpOneGroup];
            }
                break;
            case 1:
            {
                // Search
            }
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == ACTIONSHEET_TAG_RIGHTBARBTN_HOME_SELECT)
    {
        switch (buttonIndex) {
            case 0: // select all subjects
            {
                [self selectAllMembersBtnPressed];
            }
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_SELECT)
    {
        switch (buttonIndex) {
            case 0: // go up one folder
            {
                [self goUpOneGroup];
            }
                break;
            case 1: // select all subjects
            {
                [self selectAllMembersBtnPressed];
            }
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == ACTIONSHEET_TAG_PERROW_CONTACT_MANAGE)
    {
        switch (buttonIndex) { /*
                                case 0: // go up one folder
                                {
                                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterFriendAlias", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"OkKey", @""), nil];
                                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                                self.alertTextField = [alert textFieldAtIndex:0];
                                alertTextField.keyboardType = UIKeyboardTypeAlphabet;
                                alertTextField.placeholder = NSLocalizedString(@"EnterFriendAliasPlaceHolder", @"");
                                self.inEditAlias = true;
                                [alert show];
                                }
                                break;*/
            case 0: // go up one folder
            {
                // [self contactChangeNotesBtnPressed];
                NSInteger rowIndex = [self.tblView indexPathForSelectedRow].row;
                NSInteger folderCount = [self.arrayOfGroups count];
                NSDictionary *contact = [self.arrayOfContacts objectAtIndex:(rowIndex - folderCount)];
                NSString *userEmail = [contact objectForKey:@"friendEmail"];
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterFriendAlias2", @"") message:userEmail delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"OkKey", @""),nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                self.alertTextField = [alert textFieldAtIndex:0];
                alertTextField.keyboardType = UIKeyboardTypeDefault;
                alertTextField.placeholder = NSLocalizedString(@"EnterFriendAliasPlaceHolder", @"");
                alertTextField.text = self.aliasHolder;
                self.aliasHolder = nil;
                self.inEditNote = true;
                self.alertForBack = alert;
                [alert show];
            }
                break;
            case 1:
            {
                [self addContactToGroupBtnPressed];
            }
                break;
            case 2:
            {
                
                [self contactDeleteBtnPressed];
            }
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == ACTIONSHEET_TAG_IN_GROUP)
    {
        [self deleteContactBuildRequest:self.selectedCell.detailTextLabel.text];
    }
}

- (void)contactDeleteBtnPressed {
    [self deleteContactBuildRequest: [[self.arrayOfContacts objectAtIndex: currentContactIndex] objectForKey:@"friendEmail"]];
}

- (IBAction)actionBarBtnPressed:(id)sender {
    
    UIActionSheet *sheet;
    
    if (([self.arrayOfGroups count] == 0) &&
        ([self.arrayOfContacts count] == 0)) {
        if ([self.arrayOfGroupsUpToCurrentLayer count] == 0) {
            
            /*
            sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectActionKey", @"")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:NSLocalizedString(@"AddGroupKey", @""),
                     NSLocalizedString(@"AddContactKey", @""),
                     NSLocalizedString(@"AddContactFromAddressKey", nil), nil];
             
             self.tmpSht = sheet;
            sheet.tag = ACTIONSHEET_TAG_RIGHTBARBTN_HOME_INITIAL;
            */
            
            
            //for new actionsheet
            //group
            DOPAction *action1 = [[DOPAction alloc] initWithName:NSLocalizedString(@"AddGroupKey", @"") iconName:@"DOP_addGroup" handler:^{
                [self addGroupBtnPressed];
                
                
            }];
            DOPAction *action2 = [[DOPAction alloc] initWithName:NSLocalizedString(@"AddContactKey", @"") iconName:@"DOP_addFriend" handler:^{
                
                [self addContactBtnPressed];
                
            }];
            DOPAction *action3 = [[DOPAction alloc] initWithName:NSLocalizedString(@"AddContactFromAddressKey", nil) iconName:@"DOP_phoneContact" handler:^{
                
                [self addFromAddressBookBtnPressed];
                
            }];
            
            NSArray *actions = @[@"", @[action1, action2, action3]];
            
            DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
            
            [actionSheet show];
             
             
        }
        else { // in a group
            sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectActionKey", @"")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:
                     //NSLocalizedString(@"GoUpOneGroupKey", @""),
                     /* @"Show path", */ nil];
            self.tmpSht = sheet;
            sheet.tag = ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_INITIAL;
        }
    }
    else {
        if (mode == CONTACT_VIEW_MODE_MANAGE) {
            if ([self.arrayOfGroupsUpToCurrentLayer count] == 0) {
                /*
                sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectActionKey", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"AddGroupKey", @""),
                         NSLocalizedString(@"AddContactKey", @""),
                         NSLocalizedString(@"AddContactFromAddressKey", nil), nil];
                         //NSLocalizedString(@"SearchContactKey", @""),
                         
                self.tmpSht = sheet;
                sheet.tag = ACTIONSHEET_TAG_RIGHTBARBTN_HOME_MANAGE;
                */
                
                //for new actionsheet
                //group
                DOPAction *action1 = [[DOPAction alloc] initWithName:NSLocalizedString(@"AddGroupKey", @"") iconName:@"DOP_addGroup" handler:^{
                    [self addGroupBtnPressed];
                    
                    
                }];
                DOPAction *action2 = [[DOPAction alloc] initWithName:NSLocalizedString(@"AddContactKey", @"") iconName:@"DOP_addFriend" handler:^{
                    
                    [self addContactBtnPressed];
                    
                }];
                DOPAction *action3 = [[DOPAction alloc] initWithName:NSLocalizedString(@"AddContactFromAddressKey", nil) iconName:@"DOP_phoneContact" handler:^{
                    
                    [self addFromAddressBookBtnPressed];
                    
                }];
                
                NSArray *actions = @[@"", @[action1, action2, action3]];
                
                DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
                
                [actionSheet show];
                
            }
            else { // in a group
                sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectActionKey", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:
                         //NSLocalizedString(@"GoUpOneGroupKey", @""),
                         //NSLocalizedString(@"SearchContactKey", @""),
                         /* @"Show path", */ nil];
                self.tmpSht = sheet;
                sheet.tag = ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_MANAGE;
            }
        }
        else {  // select mode
            if ([self.arrayOfGroupsUpToCurrentLayer count] == 0) {
                sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectActionKey", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:
                         NSLocalizedString(@"SelectAllContactKey", @""),
                         /* @"Show path", */ nil];
                self.tmpSht = sheet;
                sheet.tag = ACTIONSHEET_TAG_RIGHTBARBTN_HOME_SELECT;                                                                                                   
            }
            else {
                sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectActionKey", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                      destructiveButtonTitle:nil
                                           otherButtonTitles://NSLocalizedString(@"GoUpOneGroupKey", @""),
                         NSLocalizedString(@"SelectAllMemberKey", @""),
                         /* @"Show path", */ nil];
                self.tmpSht = sheet;
                sheet.tag = ACTIONSHEET_TAG_RIGHTBARBTN_GROUP_SELECT;
            }
        }
    }
    [sheet showInView:[self.view window]];
}

- (void)goBackHomeBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectDoneBtnPressed:(id)sender {
    [self.delegate selectedContacts:self.arrayOfSelectedContacts target:self];
}

-(void) addGroupMemberResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
   
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupMemberResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                /*
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"AddMemberToGroupSuccessKey", @"") inView:self.view];
                 */
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                return;
            }
                break;
            case GROUP_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"GroupNameNotFoundKey", @"") inView:self.view];
                return;
            }
            case FRIEND_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"GroupMemberNotExistKey", @"") inView:self.view];
                return;
            }
                break;
            default:
                break;
        }
    }
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"RemoveGroupUnknownErrorKey", @"") inView:self.view];
}

-(void)pickerViewSaveCmd:(NSString *)groupStr forContact:(NSDictionary *)contactDict target:(USAVPickerView *)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.rightBarButtonItem = self.actionBarBtn;
    self.navigationItem.leftBarButtonItem = self.homeBtn;

    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", [contactDict objectForKey:@"friendEmail"], @"\n", groupStr, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupStr];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:[contactDict objectForKey:@"friendEmail"]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addGroupMember:encodedGetParam target:(id)self selector:@selector(addGroupMemberResult:)];
    
    [UIView animateWithDuration:0.2 // 0.2 but slowed down to easily see difference
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [self.tblView reloadData];
                         [self.pickerView setFrame:CGRectMake( -[[UIScreen mainScreen] bounds].size.width, 0.0f, [[UIScreen mainScreen] bounds].size.width, 420.0f)];
                         

                         [self.navigationItem setTitle:NSLocalizedString(@"ContactHomeTitleKey", @"")];
                         
                         
                     }
                     completion:^(BOOL finished) {
                        [self.pickerView removeFromSuperview];
                     }];
}

-(void)pickerViewCancelCmd:(USAVPickerView *)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:NSLocalizedString(@"ContactHomeTitleKey", @"")];
    
    self.navigationItem.rightBarButtonItem = self.actionBarBtn;
    self.navigationItem.leftBarButtonItem = self.homeBtn;

    [UIView animateWithDuration:0.2 // 0.2 but slowed down to easily see difference
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.tblView reloadData];
                         [self.pickerView setFrame:CGRectMake( -[[UIScreen mainScreen] bounds].size.width, 0.0f, [[UIScreen mainScreen] bounds].size.width, 420.0f)];

                     }
                     completion:^(BOOL finished) {
                         [self.pickerView removeFromSuperview];
                     }];
}

@end
