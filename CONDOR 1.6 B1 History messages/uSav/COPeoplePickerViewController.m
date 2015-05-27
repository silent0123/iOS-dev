
//
//  COPeoplePickerViewController.m
//  COPeoplePickerViewController
//
//  Created by Erik Aigner on 08.10.11.
//  Copyright (c) 2011 chocomoko.com. All rights reserved.
//
groupIndex = 0;
#define ALERTVIEW_EMPTY_EMAIL_PERMISSION 0
#import "COPeoplePickerViewController.h"
#import "USAVGuidedSetPermissionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"
#import "USAVClient.h"
#import "API.h"
#import <Foundation/NSString.h>
#import "NSData+Base64.h"
#import "DOPScrollableActionSheet.h"
NSInteger confirmAndShare = 0;
#define COSynth(x) @synthesize x = x##_;
NSInteger butYLocation = 50;
NSInteger butYMax = 50 * 5 ;
NSInteger tokenHighlighted = FALSE;
//NSInteger alreadySelected = FALSE
NSInteger previouseY = 0;
NSInteger accY = 0;
NSInteger shareByEmail = 0;
// =============================================================================

@class COTokenField;

@interface COToken : UIButton
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id associatedObject;
@property (nonatomic, strong) COTokenField *container;
@property (nonatomic) BOOL highlighted2;


+ (COToken *)tokenWithTitle:(NSString *)title associatedObject:(id)obj container:(COTokenField *)container;

@end

// =============================================================================

@interface COEmailTableCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *emailLabelLabel;
@property (nonatomic, strong) UILabel *emailAddressLabel;
@property (nonatomic, strong) COPerson *associatedRecord;

- (void)adjustLabels;

@end

// =============================================================================

@protocol COTokenFieldDelegate <NSObject>
@required

- (void)tokenFieldDidPressAddContactButton:(COTokenField *)tokenField;
- (ABAddressBookRef)addressBookForTokenField:(COTokenField *)tokenField;
- (void)tokenField:(COTokenField *)tokenField updateAddressBookSearchResults:(NSArray *)records;
- (void)tokenField:(COTokenField *)tokenField updateAddressBookSearchResults2:(NSArray *)records withSearchText:(NSString *)text;

@end

#define kTokenFieldFontSize 13.0
#define kTokenFieldPaddingX 6.0
#define kTokenFieldPaddingY 6.0
#define kTokenFieldTokenHeight (kTokenFieldFontSize + 4.0)
#define kTokenFieldMaxTokenWidth 260.0
#define kTokenFieldFrameKeyPath @"frame"
#define kTokenFieldShadowHeight 14.0

@interface COTokenField : UIView <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<COTokenFieldDelegate> tokenFieldDelegate;
@property (nonatomic, strong) COPeoplePickerViewController *peoplePickerDelegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *addContactButton;
@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, strong) COToken *selectedToken;
@property (nonatomic, readonly) CGFloat computedRowHeight;
@property (nonatomic, readonly) NSString *textWithoutDetector;
@property (nonatomic, weak) NSArray*group;
@property (nonatomic, weak) UIView* scrollView;
@property (nonatomic, weak) UIButton *doneBtn;
@property (nonatomic, weak) UIButton *confirmShareBtn;
@property (nonatomic, strong) UILabel *placeholderLabel;

- (CGFloat)heightForNumberOfRows:(NSUInteger)rows;
- (void)selectToken:(COToken *)token;
- (void)removeAllTokens;
- (void)removeToken:(COToken *)token;
- (void)modifyToken:(COToken *)token;
- (void)modifySelectedToken;
- (NSInteger)processToken:(NSString *)tokenText associatedRecord:(COPerson *)record;
- (void)tokenInputChanged:(id)sender;
//- (void)tokenInputBegin: (id)sender;

@end

// =============================================================================

@interface CORecord ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) COPerson *person;
@end

@implementation CORecord
COSynth(title)
COSynth(person)

- (id)initWithTitle:(NSString *)title person:(COPerson *)person {
  self = [super init];
  if (self) {
    self.title = title;
    self.person = person;
  }
  return self;
}
/*
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ title: '%@'; person: '%@'>",
          NSStringFromClass(isa), self.title, self.person];
}
*/
@end

@interface CORecordEmail : NSObject {
@private
  ABMultiValueRef         emails_;
  ABMultiValueIdentifier  identifier_;
}
@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *address;

- (id)initWithEmails:(ABMultiValueRef)emails identifier:(ABMultiValueIdentifier)identifier;

@end

// =============================================================================

@interface COPeoplePickerViewController () <UITableViewDelegate, UITableViewDataSource, COTokenFieldDelegate, ABPeoplePickerNavigationControllerDelegate,USAVContactListViewControllerDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate> {
    
    BOOL isListed;  //记录是否已经获取过grouplist了
    
@private
  ABAddressBookRef addressBook_;
  CGRect           keyboardFrame_;
}

@property (nonatomic, strong) COTokenField *tokenField;
@property (nonatomic, strong) UIScrollView *tokenFieldScrollView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) NSMutableArray *discreteSearchResults;
@property (nonatomic, strong) CAGradientLayer *shadowLayer;
@property (nonatomic, strong) UIButton *uSavContact;
@property (nonatomic, strong) UIButton *btnAddBook;
@property (nonatomic, strong) UIButton *btnShare;

@property (strong, nonatomic) NSMutableArray *emailList;
@property (nonatomic) NSInteger numberOfSetPermissionSuccess;
@property (nonatomic) NSInteger numberOfTargetPermissions;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) NSMutableArray *group;
@property (nonatomic, strong) NSMutableArray *friend;
@property (nonatomic, strong) NSMutableArray *friendAlias;
@property (nonatomic, strong) NSMutableArray *groupMember;
@property (nonatomic, strong) NSMutableArray *groupFinal;
@property (nonatomic, strong) NSMutableArray *emailFinal;
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;
@property (strong, nonatomic)  UIActionSheet *tmpSht;
@property (nonatomic, strong) NSMutableArray *groupPermissions;
@property (nonatomic, strong) NSMutableArray *friendPermissions;
@property (nonatomic, strong) NSMutableArray *tempEmails;
@property (nonatomic, strong) NSMutableArray *tempGroups;
@property (nonatomic, strong) ABPeoplePickerNavigationController *picker;

//Time Arange相关
@property (nonatomic, strong) UITextField *Tf_NumLimit; //看的次数
@property (nonatomic, assign) NSInteger Tf_Duration;    //每次时间
@property (nonatomic, strong) NSString *Tf_StartTime;
@property (nonatomic, strong) NSString *Tf_EndTime;

//用来存放contactlist传过来的group和friend，来判断是否有新选择的permission
@property (nonatomic, strong) NSMutableArray *groupFromGuideController;
@property (nonatomic, strong) NSMutableArray *friendFromGuideController;

//用来存放阅后即焚的次数
@property (nonatomic, assign) NSInteger *burnAfterReadCount;

/*
@property (strong, nonatomic) NSString *encryptedFileName;
@property (strong, nonatomic) NSString *encryptedFilePath;
@property (strong, nonatomic) NSString *keyId;
*/
@end

@implementation COPeoplePickerViewController
COSynth(delegate)
COSynth(tokenField)
COSynth(tokenFieldScrollView)
COSynth(searchTableView)
COSynth(displayedProperties)
COSynth(discreteSearchResults)
COSynth(shadowLayer)
COSynth(uSavContact)
@synthesize group = _group;
@synthesize friend = _friend;

- (NSMutableArray *)emailList {
    if (!_emailList) {
        _emailList = [NSMutableArray arrayWithCapacity:0];
    }
    return _emailList;
}

- (NSMutableArray *)group {
    
    if (!_group) {
        _group = [NSMutableArray arrayWithCapacity:0];
    }
    return _group;
    
}

- (NSMutableArray *)friend {
    
    if (!_friend) {
        _friend = [NSMutableArray arrayWithCapacity:0];
    }
    return _friend;
    
}

- (void)dealloc {
  if (addressBook_ != NULL) {
    CFRelease(addressBook_);
    addressBook_ = NULL;
  }
}

#pragma mark 实现timearrange传参
- (void)passDuration:(NSInteger)duration {
    self.Tf_Duration = duration;
    //No limit 或者Allowcopy状态按钮提示修改
    if (self.allowSaveDecryptCopy || (self.Tf_Duration == 0 && [self.Tf_NumLimit.text integerValue] == 0)) {
        [self.timeArrangeButton setTitle:NSLocalizedString(@"Viewing Restrictions: No Limit", nil) forState:UIControlStateNormal];
    } else {
        [self.timeArrangeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Viewing Restrictions: %zi times | %zi seconds", nil), [self.Tf_NumLimit.text integerValue], self.Tf_Duration] forState:UIControlStateNormal];
    }
}

- (void)passLimit:(NSInteger)limit {
    
    self.Tf_NumLimit.text = [NSString stringWithFormat:@"%zi",limit];
    //No limit 或者Allowcopy状态按钮提示修改
    if (self.allowSaveDecryptCopy || (self.Tf_Duration == 0 && [self.Tf_NumLimit.text integerValue] == 0)) {
        [self.timeArrangeButton setTitle:NSLocalizedString(@"Viewing Restrictions: No Limit", nil) forState:UIControlStateNormal];
    } else {
        [self.timeArrangeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Viewing Restrictions: %zi times | %zi seconds", nil), [self.Tf_NumLimit.text integerValue], self.Tf_Duration] forState:UIControlStateNormal];
    }

}

//---- Decrypt Copy
- (void)passSaveDecryptCopy:(NSInteger)save {
    self.allowSaveDecryptCopy = save;
    NSLog(@"保存与否%zi",self.allowSaveDecryptCopy);
}

- (void)passTimeOfStart:(NSString *)startTime andEndTime:(NSString *)endTime  {
    
    self.Tf_StartTime = startTime;
    self.Tf_EndTime = endTime;
    
}

- (void)contactListViewControllerDidFinish:(USAVGuidedSetPermissionViewController *)controller {

    [self.navigationController popViewControllerAnimated:YES];
    /* [self addEmails:[controller.emails copy] toCurrentEmailList:self.emailList];[self.tbView reloadData];*/
    NSInteger limit = [self getNumLimit];
 
    for (id i in controller.groups) {
        //[self.tokenField processToken:i associatedRecord:nil];
        if (limit > 1000 || limit == 0) {
            [self.tokenField processToken:i associatedRecord:nil];
        } else{
            [self.tokenField processToken:[NSString stringWithFormat:@"%@", i] associatedRecord:nil];
        }
        
    }
    
    for (id i in controller.friends2) {
        //[self.tokenField processToken:i associatedRecord:nil];
        if (limit > 1000 || limit == 0) {
            [self.tokenField processToken:i associatedRecord:nil];
        } else{
            [self.tokenField processToken:[NSString stringWithFormat:@"%@", i] associatedRecord:nil];
        }
        
    }
    
    

    [self.groupFromGuideController addObjectsFromArray:controller.groups];
    [self.friendFromGuideController addObjectsFromArray:controller.friends2];
    //取消显示Group Token
    //[self.friendPermissions addObjectsFromArray:controller.emails];
    
    
    if ([self.groupFromGuideController count] != 0 || [self.friendFromGuideController count] != 0) {
        [self.DoneBtn setEnabled:YES];
        [self.DoneBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    }
    //[self.tokenField.textField becomeFirstResponder];
    
}

- (ABAddressBookRef)addressBookRef {
  return addressBook_;
}



- (void)addBookPressed:(id)sender {
    self.isChangedSetting = YES;
    [self performSegueWithIdentifier:@"EditPermission" sender:self];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EditPermission"]) {
        USAVGuidedSetPermissionViewController *usavContact = (USAVGuidedSetPermissionViewController  *)segue.destinationViewController;
        usavContact.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"TimeArrangeSegue"]) {
        USAVTimeArrangeViewController *timeArrangeController = segue.destinationViewController;
        timeArrangeController.COPeoplePickerTimeDelegate = self;
        //把服务器取回的参数传过去
        timeArrangeController.finalLimit = [self.Tf_NumLimit.text integerValue];    //因为旧代码，tf_NumLimit是个textfield，这里为了方便没去改它的类型，但是time那边是nsinteger，需要转换
        timeArrangeController.finalDuration = self.Tf_Duration;
        
        //---- Decrypt Copy
        timeArrangeController.allowSaveDecryptCopy = self.allowSaveDecryptCopy;
        
        //区分iOS8
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            if ([self.Tf_StartTime containsString:@"Z"]) {
                //不是第一次进入Time页面，不加Z
                timeArrangeController.finalStartTime = self.Tf_StartTime;
            } else {
                timeArrangeController.finalStartTime = [NSString stringWithFormat:@"%@Z",self.Tf_StartTime];    //服务器传回来的时间少了个Z，不修改下一个页面不识别
            }
            
            if ([self.Tf_EndTime containsString:@"Z"]) {
                //不是第一次进入Time页面，不加Z
                timeArrangeController.finalEndTime = self.Tf_EndTime;
            } else {
                timeArrangeController.finalEndTime = [NSString stringWithFormat:@"%@Z",self.Tf_EndTime];    //服务器传回来的时间少了个Z，不修改下一个页面不识别
            }
        } else {
            
            if ([self.Tf_StartTime rangeOfString:@"Z"].location != NSNotFound) {
                //不是第一次进入Time页面，不加Z
                timeArrangeController.finalStartTime = self.Tf_StartTime;
            } else {
                timeArrangeController.finalStartTime = [NSString stringWithFormat:@"%@Z",self.Tf_StartTime];    //服务器传回来的时间少了个Z，不修改下一个页面不识别
            }
            
            if ([self.Tf_EndTime rangeOfString:@"Z"].location != NSNotFound) {
                //不是第一次进入Time页面，不加Z
                timeArrangeController.finalEndTime = self.Tf_EndTime;
            } else {
                timeArrangeController.finalEndTime = [NSString stringWithFormat:@"%@Z",self.Tf_EndTime];    //服务器传回来的时间少了个Z，不修改下一个页面不识别
            }
        }

    }
}



- (void)addContactFromAddressBook:(id)sender {
#pragma unused (sender)
    //id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
    //[tokenFieldDelegate tokenFieldDidPressAddContactButton:self];
    self.isChangedSetting = YES;
    
    self.picker = [ABPeoplePickerNavigationController new];
    self.picker.addressBook = self.addressBookRef;
    self.picker.peoplePickerDelegate = self;
    self.picker.displayedProperties = self.displayedProperties;
    
    // Set same tint color on picker navigation bar
    UIColor *tintColor = self.navigationController.navigationBar.tintColor;
    if (tintColor != nil) {
        self.picker.navigationBar.tintColor = tintColor;
    }
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (void)done:(id)sender {
#pragma unused (sender)
  id<COPeoplePickerViewControllerDelegate> delegate = self.delegate;
  if ([delegate respondsToSelector:@selector(peoplePickerViewControllerDidFinishPicking:)]) {
    [delegate peoplePickerViewControllerDidFinishPicking:self];
  }
}

- (void)loadView {
  [super loadView];
    
  keyboardFrame_ = CGRectNull;
  // DEVNOTE: A workaround to force initialization of ABPropertyIDs.
  // If we don't create the address book here and try to set |displayedProperties| first
  // all ABPropertyIDs will default to '0'.
  //
  // Filed rdar://10526251
  //
  addressBook_ = ABAddressBookCreate();
  
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DoneKey", nil)
//                                                                style:UIBarButtonItemStyleDone
//                                                               target:self
//                                                               action:@selector(doneBtnPressed:)];
  //self.navigationItem.rightBarButtonItem = nil;
    
}

- (IBAction)doneBtnPressed:(id)sender {
    [self setPermissionFinal];
}

- (IBAction)sharePressed:(id)sender {
     confirmAndShare = 1;
    [self setPermissionFinal];
   
}

- (void)timeArrangePressed:(id)sender {
    self.isChangedSetting = YES;
    [self performSegueWithIdentifier:@"TimeArrangeSegue" sender:self];
}


- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.+@.+\\..+$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

- (BOOL)isGroup: (NSString *)name
{
    for (id g in self.group) {
        
        NSString *group= (NSString *)g;
        NSInteger i = [name length];
        NSInteger j = [group length];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([name isEqualToString:group])
            return YES;
    }
    return NO;
}

-(void)getMemberForGroup:(NSString *)group to:(NSMutableArray *)emailList {
    bool in = false;
    NSInteger index = -1;
    for(NSInteger i = 0; i < [self.group count]; i++) {
        if([group caseInsensitiveCompare:[self.group objectAtIndex:i]] == NSOrderedSame ) {
            in = true;
            index = i;
            [self.groupFinal addObject:group];
            break;
        }
    }
    if(in) {
        [emailList addObjectsFromArray:[self.groupMember objectAtIndex:index]];
    }
}

-(BOOL)isValidGroup:(NSString *)group
{
    for (id i in self.group) {
        if([group isEqualToString:i])
            return true;
    }
    return  false;
}

- (NSInteger)getNumLimit
{
    NSInteger time = [self.Tf_NumLimit.text integerValue];
    if([self.Tf_NumLimit.text length] == 0) time = 0;
    else if (time < 0) time = 1;
    return time;
}

- (NSInteger)setPermissionFinal
{
    self.emailFinal = [NSMutableArray arrayWithCapacity:0];
    self.groupFinal = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *tokenTextList = [NSMutableArray arrayWithCapacity:0];
    
    
    for(NSInteger i =0; i< [self.tokenField.tokens count]; i++)
    {
        NSArray *real= [((COToken *)[self.tokenField.tokens objectAtIndex:i]).title componentsSeparatedByString:@" "];
        
        NSString *tokenName = @"";
        //如果分组有空格，则需要拼接
        for (NSInteger j = 0; j < [real count]; j ++) {
             tokenName = [tokenName stringByAppendingString:[real objectAtIndex:j]];
            //除最后一个之外，加个空格
            if (j != [real count] - 1) {
                tokenName = [tokenName stringByAppendingString:@" "];
            }
        }
        
        
        [tokenTextList addObject:tokenName];
    }
    NSLog(@"TOKEN LIST:%@", tokenTextList);
    
    NSArray *tokenText= [[NSSet setWithArray:tokenTextList] allObjects];
    
    self.emailList = [NSMutableArray arrayWithCapacity:0];
    /*
    if([tokenText count] == 0)
    {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"InvalidGroupOrEmail", @"") inView:self.view];
        return 0;
    }
    */
    
    for (NSInteger i = 0; i < [tokenText count]; i++) {
        NSString *text = [tokenText objectAtIndex:i];
        if ([self isValidEmail:text]) {
            [self.emailList addObject:text];
            [self.emailFinal addObject:text];
        } else {
            if([self isValidGroup:text]){
                
                [self getMemberForGroup:text to:self.emailList];
            }
            else {
                /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"InvalidGroupOrEmail", @"") inView:self.view];
                [self.emailList removeAllObjects];
                [self.emailFinal removeAllObjects];
                return 0;*/
            }
        }
    }
    self.emailList = [[NSSet setWithArray:self.emailList] allObjects];
    
    NSInteger totalEmail = [self.emailList count];
    
    self.numberOfTargetPermissions = totalEmail;
    self.numberOfSetPermissionSuccess = 0;
    
    /*if (![self.emailList count]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Share List Empty", @"") message:NSLocalizedString(@"Share List Empty Alert", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
        [alert show];
        alert.alertViewStyle = UIAlertViewStyleDefault; // UIAlertViewStylePlainTextInput;
        alert.tag = ALERTVIEW_EMPTY_EMAIL_PERMISSION;
        [alert show];
        
        return;
    } else {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"FileEditPermissionKey", @"") delegate:self];
    }*/
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"FileEditPermissionKey", @"") delegate:self];
  
    
    NSMutableArray *groupP = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *friendP = [NSMutableArray arrayWithCapacity:100];
    
    NSInteger time = [self getNumLimit];
    
    for (NSInteger i = 0; i < [self.emailFinal count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[self.emailFinal objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%zi",1]];
        [root addObject:[NSString stringWithFormat:@"%zi", time]];
        [friendP addObject:root];
    }
    
    for (NSInteger i = 0; i < [self.groupFinal count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[self.groupFinal objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%zi",1]];
        [root addObject:[NSString stringWithFormat:@"%zi", time]];
        [groupP addObject:root];
    }
    
    if(self.editPermission) {
        for (id g in self.groupPermissions) {
            NSInteger deleted = YES;
            for (id g1 in self.groupFinal) {
                if ([g caseInsensitiveCompare:g1]== NSOrderedSame) {
                    deleted = NO;
                }
            }
            
            if(deleted) {
                NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
                [root addObject:[NSString stringWithFormat:@"%@",g]];
                [root addObject:[NSString stringWithFormat:@"%zi",0]];
                [root addObject:[NSString stringWithFormat:@"0"]];
                [groupP addObject:root];
            }
        }
        
        for (id f in self.friendPermissions) {
            NSInteger deleted = YES;
            for (id f1 in self.emailFinal) {
                if ([f caseInsensitiveCompare:f1]== NSOrderedSame) {
                    deleted = NO;
                }
            }
            
            if(deleted) {
                NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
                [root addObject:[NSString stringWithFormat:@"%@",f]];
                [root addObject:[NSString stringWithFormat:@"%zi",0]];
                [root addObject:[NSString stringWithFormat:@"0"]];
                [friendP addObject:root];
            }
        }
    }
    
    //NSLog(@"最终：%@, %@", groupP, friendP);
    NSLog(@"可以看的次数为%@, 时长%zi, 开始时间: %@, 结束时间: %@, 分组: %@, 好友: %@", self.Tf_NumLimit.text, self.Tf_Duration, self.Tf_StartTime, self.Tf_EndTime, groupP, friendP);
    
    [self setContactPermissionForKey:self.keyId group:groupP andFriends:friendP];
    
}

- (NSString *)md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

- (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSData *)CreateDataWithHexString:(NSString *)inputString
{
    NSUInteger inLength = [inputString length];
    
    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
    
    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
    
    NSInteger i, o = 0;
    UInt8 outByte = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 c = inCharacters[i];
        SInt8 value = -1;
        
        if      (c >= '0' && c <= '9') value =      (c - '0');
        else if (c >= 'A' && c <= 'F') value = 10 + (c - 'A');
        else if (c >= 'a' && c <= 'f') value = 10 + (c - 'a');
        
        if (value >= 0) {
            if (i % 2 == 1) {
                outBytes[o++] = (outByte << 4) | value;
                outByte = 0;
            } else {
                outByte = value;
            }
            
        } else {
            if (o != 0) break;
        }
    }
    
    return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}

-(NSString *)getAsciiFromBytes:(char *)b
{
    return [NSString stringWithCString:b encoding:NSASCIIStringEncoding];
}

-(char *)NSStringToBytes:(NSString *)s
{
    char *ans = malloc(2*[s length]);
    NSInteger i = 0;
    
    for (NSInteger j = 0; j < [s length]; j++) {
        unsigned short a = [s characterAtIndex:j];
        ans[i++] = (a >> 8) & 0xFF;
        ans[i++] = a & 0xFF;
    }
    return ans;
}

-(void)setContactPermissionForKey:(NSString *)kid group: (NSArray *)group andFriends: (NSArray *)friend {
    //NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.currentFullPath];
    //NSString *keyIdString = [keyId base64EncodedString];
    //NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", //keyIdString, @"\n"];
    
#pragma mark 这里增加了关于时间的新API
    //如果是旧API，则仍然使用原来这段，判断方式是几个参数是否存在，如果全部都为默认，则使用旧API
    if ([self.Tf_NumLimit.text isEqualToString:@""] && self.Tf_Duration == 0 && [self.Tf_StartTime isEqualToString:@""] && [self.Tf_EndTime isEqualToString:@""]) {
        
        GDataXMLElement * post= [GDataXMLNode elementWithName:@"params"];
        GDataXMLElement * keyId = [GDataXMLNode elementWithName:@"keyId" stringValue:kid];
        [post addChild:keyId];
        
        for (id g in group) {
            GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"GroupPermission"];
            NSString *gName = (NSString*)[g objectAtIndex:0];
            
            
            //char *s = [self NSStringToBytes:gName];
            //NSString *asccii = [self getAsciiFromBytes:s];
            
            
            GDataXMLElement * contact = [GDataXMLNode elementWithName:@"Contact" stringValue:gName];
            GDataXMLElement * permission = [GDataXMLNode elementWithName:@"Permission" stringValue:[g objectAtIndex:1]];
            
            [groupP addChild:contact];
            [groupP addChild:permission];
            [post addChild: groupP];
        }
        
        for (id f in friend) {
            GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"FriendPermission"];
            GDataXMLElement * contact = [GDataXMLNode elementWithName:@"Contact" stringValue:[f objectAtIndex:0]];
            GDataXMLElement * permission = [GDataXMLNode elementWithName:@"Permission" stringValue:[f objectAtIndex:1]];
            
            [groupP addChild:contact];
            [groupP addChild:permission];
            [post addChild: groupP];
        }
        
        NSString *md5 = [self md5:[post XMLString]];
        
        NSData *bits_128 = [self CreateDataWithHexString:md5];
        md5 = [bits_128 base64EncodedString];
        
        USAVClient *client = [USAVClient current];
        
        NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", md5, @"\n"];
        
        ////NSLog(@"stringToSign: %@", stringToSign);
        
        NSString *signature = [client generateSignature:stringToSign withKey:client.password];
        
        ////NSLog(@"signature: %@", signature);
        GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
        
        GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
        [requestElement addChild:paramElement];
        paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
        [requestElement addChild:paramElement];
        paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
        [requestElement addChild:paramElement];
        
        // add 'params' and the child parameters
        GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
        paramElement = [GDataXMLNode elementWithName:@"content-md5" stringValue:md5];
        [paramsElement addChild:paramElement];
        
        [requestElement addChild:paramsElement];
        
        paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", @"")];
        [requestElement addChild:paramElement];
        
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
        NSData *xmlData = document.XMLData;
        
        NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        
        NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
        
        ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
        //[client.api setcontactlistpermission:data target:(id)self selector:@selector(setPermissionCallBack:)];
        [client.api setcontactlistpermission:encodedGetParam P:[[post XMLString]  dataUsingEncoding:NSUTF8StringEncoding] target:(id)self selector:@selector(setPermissionCallBack:)];
    } else {
        
        //否则使用新API, 先进行默认值转换, 转为服务器识别的
        //注意这里没有启用新的API URL，只是参数修改了
        
        if ([self.Tf_NumLimit.text isEqualToString:@"-1"]) {
            self.Tf_NumLimit.text = 0;
        }
        if (self.Tf_Duration == 0 || self.Tf_Duration == -1) {
            self.Tf_Duration = NULL;
        }
        if ([self.Tf_StartTime isEqualToString:self.Tf_EndTime]) {
            self.Tf_StartTime = NULL;
            self.Tf_EndTime = NULL;
        }

        
        GDataXMLElement * post= [GDataXMLNode elementWithName:@"params"];
        GDataXMLElement * keyId = [GDataXMLNode elementWithName:@"keyId" stringValue:kid];
        [post addChild:keyId];
        
        for (id g in group) {
            GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"PermissionItem"];    //新的
            NSString *gName = (NSString*)[g objectAtIndex:0];
            
            
            //char *s = [self NSStringToBytes:gName];
            //NSString *asccii = [self getAsciiFromBytes:s];
            
            
            GDataXMLElement * contact = [GDataXMLNode elementWithName:@"contact" stringValue:gName];
            GDataXMLElement * permission = [GDataXMLNode elementWithName:@"permission" stringValue:[g objectAtIndex:1]];
            //新的
            GDataXMLElement * numLimit = [GDataXMLNode elementWithName:@"numLimit" stringValue:self.Tf_NumLimit.text];
            GDataXMLElement * isUser = [GDataXMLNode elementWithName:@"isUser" stringValue:@"FALSE"];
            GDataXMLElement * startTime = [GDataXMLNode elementWithName:@"startTime" stringValue:self.Tf_StartTime];
            GDataXMLElement * endTime = [GDataXMLNode elementWithName:@"endTime" stringValue:self.Tf_EndTime];
            GDataXMLElement * length = [GDataXMLNode elementWithName:@"length" stringValue:[NSString stringWithFormat:@"%zi", self.Tf_Duration]];
            GDataXMLElement * saveDecryptCopy = [GDataXMLNode elementWithName:@"allowCopy" stringValue:[NSString stringWithFormat:@"%zi", self.allowSaveDecryptCopy]];
            
            [groupP addChild:contact];
            [groupP addChild:permission];
            [groupP addChild:numLimit];
            [groupP addChild:isUser];
            [groupP addChild:startTime];
            [groupP addChild:endTime];
            [groupP addChild:length];
            [groupP addChild:saveDecryptCopy];
            [post addChild: groupP];
        }
        
        for (id f in friend) {
            GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"PermissionItem"];
            GDataXMLElement * contact = [GDataXMLNode elementWithName:@"contact" stringValue:[f objectAtIndex:0]];
            GDataXMLElement * permission = [GDataXMLNode elementWithName:@"permission" stringValue:[f objectAtIndex:1]];
            //新的
            GDataXMLElement * numLimit = [GDataXMLNode elementWithName:@"numLimit" stringValue:self.Tf_NumLimit.text];
            GDataXMLElement * isUser = [GDataXMLNode elementWithName:@"isUser" stringValue:@"TRUE"];
            GDataXMLElement * startTime = [GDataXMLNode elementWithName:@"startTime" stringValue:self.Tf_StartTime];
            GDataXMLElement * endTime = [GDataXMLNode elementWithName:@"endTime" stringValue:self.Tf_EndTime];
            GDataXMLElement * length = [GDataXMLNode elementWithName:@"length" stringValue:[NSString stringWithFormat:@"%zi", self.Tf_Duration]];
            GDataXMLElement * saveDecryptCopy = [GDataXMLNode elementWithName:@"allowCopy" stringValue:[NSString stringWithFormat:@"%zi", self.allowSaveDecryptCopy]];
            
            [groupP addChild:contact];
            [groupP addChild:permission];
            [groupP addChild:numLimit];
            [groupP addChild:isUser];
            [groupP addChild:startTime];
            [groupP addChild:endTime];
            [groupP addChild:length];
            [groupP addChild:saveDecryptCopy];
            [post addChild: groupP];

        }

        
        NSString *md5 = [self md5:[post XMLString]];
        
        NSData *bits_128 = [self CreateDataWithHexString:md5];
        md5 = [bits_128 base64EncodedString];
        
        USAVClient *client = [USAVClient current];
        
        NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", md5, @"\n"];
        
        ////NSLog(@"stringToSign: %@", stringToSign);
        
        NSString *signature = [client generateSignature:stringToSign withKey:client.password];
        
        ////NSLog(@"signature: %@", signature);
        GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
        
        GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
        [requestElement addChild:paramElement];
        paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
        [requestElement addChild:paramElement];
        paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
        [requestElement addChild:paramElement];
        
        paramElement  = [GDataXMLNode elementWithName:@"timeZ" stringValue:[NSString stringWithFormat:@"%@", [NSTimeZone systemTimeZone]]];
        [requestElement addChild:paramElement];
        
        // add 'params' and the child parameters
        GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
        paramElement = [GDataXMLNode elementWithName:@"content-md5" stringValue:md5];
        [paramsElement addChild:paramElement];
        
        [requestElement addChild:paramsElement];
        
        paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", @"")];
        [requestElement addChild:paramElement];
        
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
        NSData *xmlData = document.XMLData;
        
        NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", getParam);
        
        NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
        
        ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
        //[client.api setcontactlistpermission:data target:(id)self selector:@selector(setPermissionCallBack:)];
        [client.api setcontactlistpermission:encodedGetParam P:[[post XMLString]  dataUsingEncoding:NSUTF8StringEncoding] target:(id)self selector:@selector(setPermissionCallBack:)];
        
    }
    
    
    
}



- (void)setPermissionMono:(NSString *)keyId for:(NSString *)name isUser:(NSInteger)isUser withPermission:(NSInteger)permission
{
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",[[NSString alloc] initWithFormat:@"%zi",isUser], @"\n", keyId, @"\n",
                                name, @"\n", [[NSString alloc] initWithFormat:@"%zi", permission]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    ////NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"name" stringValue:name];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"isUser" stringValue:[[NSString alloc] initWithFormat:@"%zi", isUser]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"permission" stringValue:[[NSString alloc] initWithFormat:@"%zi",permission]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api setFriendListPermision:encodedGetParam target:(id)self selector:@selector(setPermissionCallBack:)];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            ////NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            ////NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
        {
            
            //成功提示
            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
            //隐藏MAILBOX
            [self dismissViewControllerAnimated:NO completion:nil];
            

            
            if (self.isFromMessage) {
                [self.navigationController popViewControllerAnimated:YES];
                //这里延迟0.5秒
                [self performSelector:@selector(sendNotificationWithDelay:) withObject:[[NSMutableArray alloc] initWithObjects:@"sentout", nil] afterDelay:1];
                
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            

        }
            return;
        case MFMailComposeResultFailed:
            ////NSLog(@"Result: failed");
            break;
        default:
            ////NSLog(@"Result: not sent");
            break;
    }
    
    if (self.isFromMessage) {
        [self.navigationController popViewControllerAnimated:YES];
        //这里延迟0.5秒
        [self performSelector:@selector(sendNotificationWithDelay) withObject:[[NSMutableArray alloc] initWithObjects:@"sentout", nil] afterDelay:1];
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
    // [self dismissModalViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendNotificationWithDelay: (id)obj {
    
    if ([[obj firstObject] isEqualToString:@"sentout"]) {
        [obj addObject:self.emailFinal];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagePermissionReady" object:obj];
}

- (void)sendNotificationWithDelayForFileViewer {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TextPermissionReadyForViewer" object:nil];
}

- (void)pushViewControllerWithDelay {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setPermissionCallBack:(NSDictionary*)obj
{
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"SetPermissionFailed", @"") inView:self.view];
        self.numberOfSetPermissionSuccess = 0;
        confirmAndShare = 0;
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        confirmAndShare = 0;
        return;
    }
    
    NSInteger result = [[obj objectForKey:@"rawStringStatus"] integerValue];
    if ((obj != nil && result == 0) || result == 2305) {
        //self.numberOfSetPermissionSuccess += 1;
        //if (self.numberOfSetPermissionSuccess == self.numberOfTargetPermissions) {
        //NSLog(@"object content is %@",obj);
        /*
        if(!self.editPermission) {
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
            [controller setToRecipients:self.emailList];
            [controller setMessageBody:NSLocalizedString(@"Hi , <br/>  Attached is the secured file.", @"") isHTML:YES];
            [controller addAttachmentData:[NSData dataWithContentsOfFile:self.filePath]
                                 mimeType:@"application/octet-stream"
                                 fileName:self.fileName];
            if (controller) {
                [self presentViewController:controller animated:YES completion:nil];
            }
        //}  
        }else {*/
        
        if(confirmAndShare) {
            /*
            UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                          initWithTitle:NSLocalizedString(@"ShareAfterEditPermissionSuccess", @"")
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:
                                          NSLocalizedString(@"FileTransferKey", @""),
                                          NSLocalizedString(@"FileEmailKey", @""), nil
                                          ];
            self.tmpSht = actionsheet;
            //actionsheet.tag = PROCESS_USAV_FILE_DECRYPT;
            [actionsheet showInView: [self.view window]];
             */
            
            DOPAction *action1 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileTransferKey", nil) iconName:@"DOP_share" handler:^{
                [self openDocumentIn];
            }];
            DOPAction *action2 = [[DOPAction alloc] initWithName:NSLocalizedString(@"FileEmailKey", nil) iconName:@"DOP_email" handler:^{
                [self getEmails:self.tokenField.tokens];
            }];
            
        
        
            NSArray *actions = @[NSLocalizedString(@"Send by", nil), @[action1, action2]];

            
            DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
            [actionSheet show];
     

        }else {
            
            //成功提示
            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
            
            if (self.isFromMessage) {

                [self.navigationController popViewControllerAnimated:YES];
                //这里延迟0.5秒
                [self performSelector:@selector(sendNotificationWithDelay:) withObject:nil afterDelay:1];
                
            } else if (self.isFromFileViewer){
                
                [self.navigationController popViewControllerAnimated:YES];
                
                [self performSelector:@selector(sendNotificationWithDelayForFileViewer) withObject:nil afterDelay:1];
            } else {
                [self performSelector:@selector(pushViewControllerWithDelay) withObject:nil afterDelay:0.5];
            }
            
            
            
            
        }
        
    } else {
        NSLog(@"ERROR INFO: %@",obj);
         confirmAndShare = 0;
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"EditPermissionFailedKey", @"") inView:self.view];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   switch (buttonIndex) {
    case 0: // Transfer
    {
        [self openDocumentIn];
        
    }
    break;

    case 1: // Email
    {
        //[self emailFile];
        [self getEmails:self.tokenField.tokens];
    }
    break;
           
    case 2:
    {
        if (self.isFromMessage) {
            //移除Message
            //[[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            //[self dismissViewControllerAnimated:NO completion:nil];
            [self.navigationController popViewControllerAnimated:NO];
            [self.navigationController popViewControllerAnimated:NO];
            //[self dismissViewControllerAnimated:NO completion:nil];
        }
        
        
    }
           break;
    default:
    break;
   }
}

-(void)openDocumentIn {
    
    // NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, self.currentFullPath];
    
    
    NSString *fullPath = [NSString stringWithFormat:@"%@", self.filePath];
    
	[self setupDocumentControllerWithURL:[NSURL fileURLWithPath:fullPath]];
    
    BOOL *isPresented =[self.docInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 200, 44)
                                                      inView:self.view
                                                    animated:YES];
    if (!isPresented) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoAppToOpen", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    
    //[self.docInteractionController pre]
}
- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    
//    //限制发送文件大小
//    long fileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:self.currentFullPath error:nil] objectForKey:@"NSFileSize"] longValue];
//    
//    if (fileSize >= 41943040) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Large File", nil) message:NSLocalizedString(@"Attachment should not be larger than 40Mb", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", nil) otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
    
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

-(void)emailFile
{
    
    //限制发送文件大小
    long fileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil] objectForKey:@"NSFileSize"] longValue];
    
    if (fileSize >= 26214400) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Large File", nil) message:NSLocalizedString(@"Email Attachment should not be larger than 25Mb", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSArray *components = [NSArray arrayWithArray:[self.filePath componentsSeparatedByString:@"/"]];
    NSString *filenameComponent = [components lastObject];
    
    //NSLog(@"EmailFile: fullPath:%@ filenameComponent:%@", self.currentFullPath, filenameComponent);
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
    [controller setMessageBody:NSLocalizedString(@"Attached is a secure file.", @"") isHTML:YES];
    NSArray *emails= [[NSSet setWithArray:self.tempEmails] allObjects];
    if ([emails count] > 0) {
        [controller setToRecipients:emails];
    }
    
    //[self getEmails:self.tokenField.tokens];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:self.filePath]
                         mimeType:@"application/octet-stream"
                         fileName:filenameComponent];
    if (controller) {
        //[self presentModalViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:NO];
    }
}

-(void)getEmails:(NSArray *)tokens
{
    for (id t in tokens) {
        COToken *l = (COToken *)t;
        if([self isValidEmail:l.title])
            [self.tempEmails addObject:l.title];
        else
            [self.tempGroups addObject:l.title];
    }
    
    if ([self.tempGroups count] > 0) {
        groupIndex = 0;
        shareByEmail = 1;
        NSString *first_group = [self.tempGroups objectAtIndex:0];
        isListed = NO;
        [self listGroupMemberStatus:first_group];
    } else {
        [self emailFile];
    }
}

/*
-(void)openDocumentIn {
    
    // NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.currentPath, self.currentFullPath];
    NSString *fullPath = [NSString stringWithFormat:@"%@", self.currentFullPath];
    
	[self setupDocumentControllerWithURL:[NSURL fileURLWithPath:fullPath]];
    
    [self.docInteractionController presentOpenInMenuFromRect:CGRectZero
                                                      inView:self.view
                                                    animated:YES];
}
*/

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    
    NSLog(@"Open document in :%@", application);
    
    if (self.isFromMessage) {
        [self.navigationController popViewControllerAnimated:YES];
        //这里延迟0.5秒
        [self performSelector:@selector(sendNotificationWithDelay:) withObject:[[NSMutableArray alloc] initWithObjects:@"sentout", nil] afterDelay:1];
        
    } else if (self.isFromFileViewer){
        [self.navigationController popViewControllerAnimated:YES];
        
        [self performSelector:@selector(sendNotificationWithDelayForFileViewer) withObject:nil afterDelay:1];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    
    if (self.isFromMessage) {
        //移除Message
        //[[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    }
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
    
    
}

/* deprecated
- (void)getcontactlistpermission:(NSString *)keyId
{
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    ////NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
        paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
   // NSString *real= [getParam componentsSeparatedByString:@"\n"][1];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    //NSLog(@"getParam encoding: raw:%@ encoded", getParam);
    
    [client.api getcontactlistpermission:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack2:)];
}
 */

- (void)getPermissionList:(NSString *)keyId
{
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    NSLog(@"Get Permission List for keyId: %@", keyId);
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    ////NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timeZ" stringValue:[NSString stringWithFormat:@"%@", [NSTimeZone systemTimeZone]]];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
        paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    //从listFriendList改为getcontactlistpermission, 返回值有时间参数
    [client.api getcontactlistpermission:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack:)];
}

- (void)getPermissionListCallBack:(NSDictionary*)obj
{
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    NSLog(@"Get Permission List Result: %@", obj);
    
    if ([[obj objectForKey:@"httpErrorCode"] integerValue] == 500) {
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        
        NSArray *permissionList = [obj objectForKey:@"permissionList"];

        
        if (!permissionList || [permissionList count] == 0)
        {
            return;
        }
        
        //取回服务器的时间设置（阅读次数，时间等），覆盖掉本地的。下一次本地的更新后会在confirm的时候上传到服务器
        //注意：因为目前的实现是所有用户和分组设定相同的时间安排，所以这里是取出任意一个contact的信息，来取时间数据
        NSDictionary *unit = [permissionList objectAtIndex:0];
        self.Tf_Duration = [[unit objectForKey:@"length"] integerValue];
        self.Tf_NumLimit.text = [NSString stringWithFormat:@"%zi", [[unit objectForKey:@"numLimit"] integerValue]];
        self.Tf_StartTime = [unit objectForKey:@"startTime"];
        self.Tf_EndTime = [unit objectForKey:@"endTime"];
        //---- Decrypt Copy
        self.allowSaveDecryptCopy = [[unit objectForKey:@"allowCopy"] integerValue];
        
        
        //修改Button上的字
        
        if (self.Tf_Duration != [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"] || ![self.Tf_NumLimit.text isEqualToString:[NSString stringWithFormat:@"%zi",[[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"]]]) {
            //No limit 或者Allowcopy状态按钮提示修改
            if (self.allowSaveDecryptCopy || (self.Tf_Duration == 0 && [self.Tf_NumLimit.text integerValue] == 0)) {
                [self.timeArrangeButton setTitle:NSLocalizedString(@"Viewing Restrictions: No Limit", nil) forState:UIControlStateNormal];
            } else {
                [self.timeArrangeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Viewing Restrictions: %zi times | %zi seconds", nil), [self.Tf_NumLimit.text integerValue], self.Tf_Duration] forState:UIControlStateNormal];
            }
        }
        
        NSLog(@"GetList:%zi", self.Tf_Duration);
        
        NSMutableArray *permissionForGroups = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *permissionForFriends = [NSMutableArray arrayWithCapacity:0];
        
        for (NSInteger i = 0; i < [permissionList count]; i++) {
            
            NSDictionary *unit = [permissionList objectAtIndex:i];
            //NSString *name = [unit objectForKey:@"contact"];
            NSString *name = [unit objectForKey:@"contact"];
            //NSString *limit = [unit objectForKey:@"numLimit"];
            //NSInteger lim = [limit integerValue];
            //if(!limit) lim = -1;
            if ([[unit objectForKey:@"permission"] integerValue] == 1) {
                if ([[unit objectForKey:@"isUser"] integerValue]== 0) {
                    [permissionForGroups addObject:name];
                    //if (lim > 1000 || lim == -1) {
                    [self.tokenField processToken:[NSString stringWithFormat:@"%@", name] associatedRecord:nil];
                    //} else{
                    //    [self.tokenField processToken:[NSString stringWithFormat:@"%@ %@", name, limit] associatedRecord:nil];
                    //}
                } else {
                    [permissionForFriends addObject:name];
                    //[self.tokenField processToken:[NSString stringWithFormat:@"%@ %@", name, limit] associatedRecord:nil];
                    /*if (lim > 1000 || lim == -1) {*/
                        [self.tokenField processToken:[NSString stringWithFormat:@"%@", name] associatedRecord:nil];
                    
                     /*} else{
                        [self.tokenField processToken:[NSString stringWithFormat:@"%@ %@", name, limit] associatedRecord:nil];
                    }*/

                }
            }
        }
        
        
        
        self.groupPermissions=permissionForGroups ;
        self.friendPermissions=permissionForFriends;
        
        //self.originPermissionGroups = permissionForGroups;
        //self.originPermissionFriends = permissionForFriends;
        //self.indexForOriginGroup = 0;
        //[self setOriginPermission];
        
        /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
         */
        
        //成功提示
        //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
    else {
        //[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
        /*
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"PermissionDenied", @"") inView:self.view];*/
        //[ dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
     // NSLog(@"Get Permission List END");
}

- (void)getPermissionListCallBack2:(NSDictionary*)obj
{
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    // NSLog(@"Get Permission List Result");
    
    if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        NSArray *permissionList = [obj objectForKey:@"permissionList"];
        

        
        if (!permissionList)
        {
            return;
        }
        
        NSMutableArray *permissionForGroups = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *permissionForFriends = [NSMutableArray arrayWithCapacity:0];
        
        for (NSInteger i = 0; i < [permissionList count]; i++) {
            NSDictionary *unit = [permissionList objectAtIndex:i];
            NSString *name = [unit objectForKey:@"contact"];
           
            NSString *limit = [unit objectForKey:@"numLimit"];
            NSInteger lim = [limit integerValue];
            if(!limit) lim = 0;
            if ([[unit objectForKey:@"permission"] integerValue] == 1) {
                if ([[unit objectForKey:@"isUser"] integerValue]== 0) {
                    [permissionForGroups addObject:name];
                    if (lim > 1000 || lim == 0) {
                    [self.tokenField processToken:[NSString stringWithFormat:@"%@", name] associatedRecord:nil];
                    } else{
                        [self.tokenField processToken:[NSString stringWithFormat:@"%@", name] associatedRecord:nil];
                    }
                } else {
                    [permissionForFriends addObject:name];
                    [self.tokenField processToken:[NSString stringWithFormat:@"%@", name] associatedRecord:nil];
                    if (lim > 1000 || lim == 0) {
                    [self.tokenField processToken:[NSString stringWithFormat:@"%@", name] associatedRecord:nil];
                    
                    } else{
                     [self.tokenField processToken:[NSString stringWithFormat:@"%@", name] associatedRecord:nil];
                     }
                    
                }
            }
        }
        
        
        
        self.groupPermissions=permissionForGroups ;
        self.friendPermissions=permissionForFriends;
        
        //self.originPermissionGroups = permissionForGroups;
        //self.originPermissionFriends = permissionForFriends;
        //self.indexForOriginGroup = 0;
        //[self setOriginPermission];
        
        /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
         */
        //成功提示
        //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
    else {
        //[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
        /*
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"PermissionDenied", @"") inView:self.view];*/
        //[ dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    // NSLog(@"Get Permission List END");
}

#pragma mark 点击back，提示保存
- (IBAction)cancelPressed:(id)sender {
    
    //处理没有保存的Token
    [self.tokenField textFieldShouldReturn:self.tokenField.textField];
    
    //提示保存
    if (self.isChangedSetting) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save", nil) message:NSLocalizedString(@"Do you want to save the current permission setting?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YesKey", nil) otherButtonTitles:NSLocalizedString(@"NoKey", nil), nil];
        alert.tag = 300;
        alert.delegate = self;  //这个alert会调用delegate
        [alert show];
    } else {
        if (self.isFromMessage) {
            //移除Message
            //[[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
            [self.navigationController popViewControllerAnimated:YES];
            [self.textMessageDelegate.messageTextView becomeFirstResponder];
            
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    
}

- (IBAction)donePressed:(id)sender {
    confirmAndShare = 0;
    [self setPermissionFinal];
    /*self.emailList = [NSMutableArray arrayWithCapacity:0];
    NSArray *tokenText= [[NSSet setWithArray:tokenTextList] allObjects];
    
    for (NSInteger i = 0; i < [tokenText count]; i++) {
        NSString *text = [tokenText objectAtIndex:i];
        if ([self isValidEmail:text]) {
            [self.emailList addObject:text];
            [self.emailFinal addObject:text];
        } else {
            [self getMemberForGroup:text to:self.emailList];
        }
    }
    self.emailList = [[NSSet setWithArray:self.emailList] allObjects];
    
    NSMutableArray *groupP = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *friendP = [NSMutableArray arrayWithCapacity:0];
    
    for (NSInteger i = 0; i < [self.emailFinal count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[self.emailFinal objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%zi",1]];
        
        [friendP addObject:root];
    }
    for (NSInteger i = 0; i < [self.groupFinal count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[self.groupFinal objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%zi",1]];
        
        [groupP addObject:root];
    }
    
    [self setContactPermissionForKey:self.keyId group:groupP andFriends:friendP];*/
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.navigationItem setTitle:NSLocalizedString(@"EditPermissionTitleBar", "")];
}

- (void)viewDidLoad {
    self.tempEmails = [NSMutableArray arrayWithCapacity:0];
    self.tempGroups = [NSMutableArray arrayWithCapacity:0];
    self.groupFromGuideController = [NSMutableArray arrayWithCapacity:0];
    self.friendFromGuideController = [NSMutableArray arrayWithCapacity:0];
    
    self.allowSaveDecryptCopy = [[NSUserDefaults standardUserDefaults] integerForKey:@"AllowDecryptCopy"];
    self.CancelBtn.image = [UIImage imageNamed:@"icon_back_blue"];

    
    shareByEmail = 0;
    isListed = NO;
    self.isChangedSetting = NO;
    
    //burnAfterRead计数器
    self.burnAfterReadCount = 1;
    
    //时间安排初始化
    self.Tf_Duration = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"];
    self.Tf_StartTime = @"";
    self.Tf_EndTime = @"";
    //这里不想改动太多，凑合用他的textfield
    self.Tf_NumLimit = [[UITextField alloc] init];
    self.Tf_NumLimit.text = [NSString stringWithFormat:@"%zi",[[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"]];
    
    
    confirmAndShare = 0;
    [self.CancelBtn setTitle:NSLocalizedString(@"BackKey", @"")];
    //[self.DoneBtn setTitle:NSLocalizedString(@"ConfirmLabel", @"")];
    [self.navigationItem setTitle:NSLocalizedString(@"EditPermissionTitleBar", "")];
    [self.navigationController setNavigationBarHidden:NO];
    
    if (self.editPermission) {
        [self getPermissionList:self.keyId];
        //[self getcontactlistpermission:self.keyId];
    }
    
    self.friendAlias = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.group removeAllObjects];
    self.groupMember = nil;
    [self.emailList removeAllObjects];
    groupIndex = 0;
    [self listGroup];
    //即使没有分组，也要listcontacts
    [self listTrustedContactStatus];
    // Configure content view
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    
    self.navigationItem.title = NSLocalizedString(@"Set Permission", @"");
    
    // Configure token field
    CGRect viewBounds = self.view.bounds;
    CGRect tokenFieldFrame = CGRectMake(0, 0, CGRectGetWidth(viewBounds), 44.0);
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewBounds),  CGRectGetHeight(viewBounds))];
    scroll.delegate = self;

    //scroll.backgroundColor = [UIColor colorWithRed:0.859 green:0.886 blue:0.925 alpha:1.0];
    scroll.backgroundColor = [UIColor clearColor];
    [scroll setScrollEnabled:YES];
    [scroll setContentSize:CGSizeMake(CGRectGetWidth(viewBounds), 600)];
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(viewBounds),  CGRectGetHeight(viewBounds))];   //+号的都是后面为了调整位置而设置的Directory
    //content.backgroundColor = [UIColor colorWithRed:0.859 green:0.886 blue:0.925 alpha:1.0];
    content.backgroundColor = [UIColor clearColor];

   self.tokenField = [[COTokenField alloc] initWithFrame:tokenFieldFrame];
    self.tokenField.textField.returnKeyType = UIReturnKeyDone;
    self.tokenField.peoplePickerDelegate = self;
    
   self.tokenField.tokenFieldDelegate = self;
   self.tokenField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    self.tokenField.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
   [self.tokenField addObserver:self forKeyPath:kTokenFieldFrameKeyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
  // Configure search table
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       CGRectGetWidth(viewBounds),
                                                                       CGRectGetHeight(viewBounds) - CGRectGetHeight(tokenFieldFrame))
                                                      style:UITableViewStylePlain];
    self.searchTableView.opaque = NO;
    self.searchTableView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.98];
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    self.searchTableView.hidden = YES;
    self.searchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    // Create the scroll view
    self.tokenFieldScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewBounds), self.tokenField.computedRowHeight)];
    self.tokenFieldScrollView.backgroundColor = [UIColor whiteColor];

    UIButton *butTimeArrange = [UIButton buttonWithType:UIButtonTypeCustom];
    [butTimeArrange addTarget:self action:@selector(timeArrangePressed:)
             forControlEvents:UIControlEventTouchUpInside];
    //[butTimeArrange setTitle:NSLocalizedString(@"Restrictions",nil) forState:UIControlStateNormal];
    //No limit 或者Allowcopy状态按钮提示修改
    if (self.allowSaveDecryptCopy || (self.Tf_Duration == 0 && [self.Tf_NumLimit.text integerValue] == 0)) {
        [butTimeArrange setTitle:NSLocalizedString(@"Viewing Restrictions: No Limit", nil) forState:UIControlStateNormal];
    } else {
        [butTimeArrange setTitle:[NSString stringWithFormat:NSLocalizedString(@"Viewing Restrictions: %zi times | %zi seconds", nil), [self.Tf_NumLimit.text integerValue], self.Tf_Duration] forState:UIControlStateNormal];
    }

    butTimeArrange.frame = CGRectMake(0, 10, CGRectGetWidth(viewBounds), 34);
    [butTimeArrange.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [butTimeArrange  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [butTimeArrange setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    //butTimeArrange.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    butTimeArrange.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    butTimeArrange.titleLabel.textColor = [UIColor whiteColor];
    UIView *bottomBorder_1 = [[UIView alloc] initWithFrame:CGRectMake(0, butTimeArrange.frame.size.height - 2.0f, butTimeArrange.frame.size.width, 2)];
    bottomBorder_1.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    [butTimeArrange addSubview:bottomBorder_1];
    
//    butTimeArrange.layer.masksToBounds = YES;
//    butTimeArrange.layer.borderColor = [[UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1] CGColor];
//    butTimeArrange.layer.borderWidth = 1.2;
    
    //move text 10 pixels down
    [butTimeArrange setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
    self.timeArrangeButton = butTimeArrange;
    
    //phone contact
    UIButton *butUsavContact = [UIButton buttonWithType:UIButtonTypeCustom];
    [butUsavContact addTarget:self action:@selector(addContactFromAddressBook:)
             forControlEvents:UIControlEventTouchUpInside];
    [butUsavContact setTitle:NSLocalizedString(@"AddContactFromAddressKey", nil) forState:UIControlStateNormal];
    [butUsavContact.titleLabel setFont:[UIFont systemFontOfSize:13]];
    butUsavContact.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    butUsavContact.frame = CGRectMake(0, 60, CGRectGetWidth(viewBounds), 34);
    butUsavContact.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    [butUsavContact  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [butUsavContact  setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    UIView *bottomBorder_2 = [[UIView alloc] initWithFrame:CGRectMake(0, butUsavContact.frame.size.height - 2.0f, butUsavContact.frame.size.width, 2)];
    bottomBorder_2.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    [butUsavContact addSubview:bottomBorder_2];
    //move text 10 pixels down
    [butUsavContact setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];

    
    //condor contact
    UIButton *butAddBook = [UIButton buttonWithType:UIButtonTypeCustom];
    [butAddBook addTarget:self action:@selector(addBookPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    [butAddBook setTitle:NSLocalizedString(@"AddContactFromUsavKey",nil) forState:UIControlStateNormal];
    //butAddBook.titleEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    butAddBook.frame = CGRectMake(0, 110, CGRectGetWidth(viewBounds), 34);
    [butAddBook.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [butAddBook  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [butAddBook  setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    UIView *bottomBorder_3 = [[UIView alloc] initWithFrame:CGRectMake(0, butAddBook.frame.size.height - 2.0f, butAddBook.frame.size.width, 2)];
    bottomBorder_3.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    [butAddBook addSubview:bottomBorder_3];
    //move text 10 pixels down
    [butAddBook setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    butAddBook.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    butAddBook.titleLabel.textColor = [UIColor whiteColor];
    //butAddBook.backgroundColor = [UIColor whiteColor];
    
    UIButton *butShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [butShare addTarget:self action:@selector(sharePressed:)
       forControlEvents:UIControlEventTouchUpInside];
    [butShare setTitle:NSLocalizedString(@"Confirm and Share",nil) forState:UIControlStateNormal];
    [butShare.titleLabel setFont:[UIFont systemFontOfSize:13]];
    butShare.frame = CGRectMake(0, 160, CGRectGetWidth(viewBounds), 34);
    [butShare  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [butShare setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    butShare.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    butShare.titleLabel.textColor = [UIColor whiteColor];
    UIView *bottomBorder_4 = [[UIView alloc] initWithFrame:CGRectMake(0, butShare.frame.size.height - 2.0f, butShare.frame.size.width, 2)];
    bottomBorder_4.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    [butShare addSubview:bottomBorder_4];
    self.confirmShareBtn = butShare;
    //move text 10 pixels down and right
    [butShare setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
    self.DoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.DoneBtn addTarget:self action:@selector(donePressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.DoneBtn setTitle:NSLocalizedString(@"ConfirmPermissionLabel", nil) forState:UIControlStateNormal];
    [self.DoneBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    //self.DoneBtn.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    self.DoneBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.DoneBtn.titleLabel.textColor = [UIColor whiteColor];
    self.DoneBtn.frame = CGRectMake(0, 210, CGRectGetWidth(viewBounds), 34);
    [self.DoneBtn  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.DoneBtn  setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    UIView *bottomBorder_5 = [[UIView alloc] initWithFrame:CGRectMake(0, self.DoneBtn.frame.size.height - 2.0f, self.DoneBtn.frame.size.width, 2)];
    bottomBorder_5.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    [self.DoneBtn addSubview:bottomBorder_5];
    //move text 10 pixels down
    [self.DoneBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    self.DoneBtn.userInteractionEnabled = YES;
    
    
    
    //单独拿来放button，灵活调整button位置
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 220, self.view.bounds.size.width, 250)]; //因为这个区域的大小设置不正确，导致盖住了textfield，以至于无法选择token，这个错误存在了很久，已经fixed
    
    self.btnShare = butShare;
    self.btnAddBook = butAddBook;
    self.uSavContact = butUsavContact;
    
    [self.tokenFieldScrollView addSubview:self.tokenField];
    [self.buttonView addSubview:butTimeArrange];
    [self.buttonView addSubview:butUsavContact];
    [self.buttonView addSubview:butAddBook];
    [self.buttonView addSubview:self.DoneBtn];
    //如果是Message，则不显示最后一个
    if(![self.textMessageDelegate isKindOfClass:[USAVSecureChatViewController class]]){
        [self.buttonView addSubview:self.confirmShareBtn];
    } else {
        [self.DoneBtn setFrame:self.confirmShareBtn.frame];
    }
    
    
    //[content addSubview:self.searchTableView];
    [content addSubview:self.tokenFieldScrollView];
    UILabel *filename;
    self.tokenField.scrollView = self.view;
    
    if(self.editPermission) {
        filename = [[UILabel alloc] initWithFrame:CGRectMake(10, -35, self.view.bounds.size.width, 20)];
    } else {
        filename = [[UILabel alloc] initWithFrame:CGRectMake(10, -35, self.view.bounds.size.width, 20)];
    }
    //UILabel *filePath = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, CGRectGetWidth(viewBounds), 20)];
    //filename.text = NSLocalizedString([NSString stringWithFormat:@"Add a new email or add from address book"], nil);
    NSString *filenameDisplay = [NSString stringWithFormat:NSLocalizedString(@"Filename: %@", nil), self.fileName];
    filename.text = filenameDisplay;
    filename.font = [UIFont systemFontOfSize:13];
    //filePath.text = self.filePath;
    [content addSubview:filename];
    
    [scroll addSubview:content];
    [scroll addSubview:self.buttonView];
    [scroll addSubview:self.searchTableView];
    [self.view addSubview:scroll];
    //UILabel *L_numLimit = [[UILabel alloc] initWithFrame:CGRectMake(170, 50, 20, 20)];
    //L_numLimit.text = @"n=";
    //[self.view addSubview:L_numLimit];
    /*
    UITextField *Tf_numLimit = [[UITextField alloc] initWithFrame:CGRectMake(200, 45, 80, 37)];
    [Tf_numLimit setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1]];
    [Tf_numLimit setPlaceholder:@"Unlimited"];
    [Tf_numLimit  resignFirstResponder];
    [self.view addSubview:Tf_numLimit];
    self.Tf_NumLimit = Tf_numLimit;
    */
    //[self.view addSubview:filePath];
    
  // Shadow layer
  /*self.shadowLayer = [CAGradientLayer layer];
  self.shadowLayer.frame = CGRectMake(0, CGRectGetMaxY(self.tokenFieldScrollView.frame), CGRectGetWidth(self.view.bounds), kTokenFieldShadowHeight);
  self.shadowLayer.colors = [NSArray arrayWithObjects:
                             (__bridge id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0.0 alpha:0.1].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor, nil];
  self.shadowLayer.locations = [NSArray arrayWithObjects:
                                [NSNumber numberWithDouble:0.0],
                                [NSNumber numberWithDouble:1.0/kTokenFieldShadowHeight],
                                [NSNumber numberWithDouble:1.0/kTokenFieldShadowHeight],
                                [NSNumber numberWithDouble:1.0], nil];
  
  [self.view.layer addSublayer:self.shadowLayer];
  */
  // Subscribe to keyboard notifications
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    self.tokenField.doneBtn = self.DoneBtn;
    self.tokenField.confirmShareBtn = self.confirmShareBtn;
    
    [self.DoneBtn setEnabled:YES];
    [self.DoneBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [self.confirmShareBtn setEnabled:NO];
    [self.confirmShareBtn setBackgroundColor:[UIColor lightGrayColor]];

}

- (void)viewWillAppear:(BOOL)animated {
#pragma unused (animated)
  //[self.tokenField.textField becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.tmpSht dismissWithClickedButtonIndex:0 animated:NO];
}

- (void)readAfterBurn:(NSInteger)count{
    if (!count) {
        self.burnAfterReadCount = 1;
    }
}


-(void)listGroup
{

    
    USAVClient *client = [USAVClient current];
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", client.emailAddress, @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];

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
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    [client.api listGroup:encodedGetParam target:(id)self selector:@selector(listGroupResult:)];
}

-(void) listGroupResult:(NSDictionary*)obj {
    if (obj == nil) {
        //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
        /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
         */
        
        [self.navigationController popViewControllerAnimated:YES];
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"EditPermissionFailedKey", @"") inView:self.view];
        
        return;
        
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
	if (obj != nil) {
        ////NSLog(@"%@ list group result: %@", [self class], obj);
        if (([obj objectForKey:@"groupList"] != nil) && ([[obj objectForKey:@"groupList"] count] > 0)) {
            [self.group addObjectsFromArray:[obj objectForKey:@"groupList"]];
            self.groupMember = [NSMutableArray arrayWithCapacity:0];
            for (NSInteger i = 0; i < [self.group count]; i++) {
                [self.groupMember addObject:[NSMutableArray arrayWithCapacity:0]];
            }
            
            [self.group sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            self.tokenField.group = self.group;
            //NSLog(@"%zi",groupIndex);
            [self listGroupMemberStatus:[self.group objectAtIndex:groupIndex]];
            
        }
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];

        //成功提示
        //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    }
    else {
    
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        
        //WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        //[wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        //[wv show:NSLocalizedString(@"FailedToListGroupKey", @"") inView:self.view];
    }
}

-(void)listGroupMemberStatus:(NSString *)groupId
{
//    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ListGroupMember", @"")
//                                                  delegate:self];
    //NSLog(@"List Group Member Status");
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
    
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    if (!isListed) {
        isListed = YES;
        [client.api listGroupMemberStatus:encodedGetParam target:(id)self selector:@selector(listGroupMemberStatusResult:)];
    }

   
}

-(void) listGroupMemberStatusResult:(NSDictionary*)obj {
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    //NSLog(@"List Group Member Status");
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260){
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"contactList"] != nil)) {
        ////NSLog(@"%@ list group member result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        if (shareByEmail) {
            NSArray *friendList = [obj objectForKey:@"contactList"];
            for (NSInteger i = 0; i < [friendList count]; i++) {
                [self.tempEmails addObject:[[friendList objectAtIndex:i] objectForKey:@"friendEmail"]];
            }
            
            if(++groupIndex < [self.tempGroups count]) {
                isListed = NO;
                [self listGroupMemberStatus:[self.tempGroups objectAtIndex:groupIndex]];
            } else {
                shareByEmail = 0;
                [self emailFile];
            }
            
        }else {
            NSArray *friendList = [obj objectForKey:@"contactList"];
            NSLog(@"Friend: %zi, Group: %zi", [friendList count], [self.group count]);
            for (NSInteger i = 0; i < [friendList count]; i++) {
                [[self.groupMember objectAtIndex:groupIndex] addObject:[[friendList objectAtIndex:i] objectForKey:@"friendEmail"]];
            }
        
            if(++groupIndex < [self.group count]) {
                [self listGroupMemberStatus:[self.group objectAtIndex:groupIndex]];
            }
        }
    }
    else {
        //WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        //[wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        //[wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
    }
     //NSLog(@"List Group Member End");
}

-(void)listTrustedContactStatus
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //////NSLog(@"signature: %@", signature);
    
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
    
    //NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listTrustedContactStatus:encodedGetParam target:(id)self selector:@selector(listTrustedContactStatusResult:)];
}

-(void) listTrustedContactStatusResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    NSLog(@"Contacts List Result: %@", obj);
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        
        return;
    }

    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }

	if (obj != nil) {
        //NSLog(@"%@ list trust contact result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        if ([obj objectForKey:@"contactList"]) {
            for (id i in [obj objectForKey:@"contactList"]) {
                NSDictionary *d = (NSDictionary *)i;
                [self.friend addObject:[d objectForKey:@"friendEmail"]];
                
                //检测Alias是否存在，Alias为空处理
                if ( [[d objectForKey:@"friendAlias"] length] > 0) {
                    [self.friendAlias addObject:[d objectForKey:@"friendAlias"]];
                } else {
                    NSString *alias = [[[d objectForKey:@"friendEmail"] componentsSeparatedByString:@"@"] objectAtIndex:0];
                    [self.friendAlias addObject:alias];
                }
                
            }
            
            //成功提示
            //[SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];

        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
    }
}


- (void)layoutTokenFieldAndSearchTable {
    CGRect bounds = self.view.bounds;
    CGRect tokenFieldBounds = self.tokenField.bounds;
    CGRect tokenScrollBounds = tokenFieldBounds;
//    CGRect butUsavLocal = CGRectMake(0, butYLocation+5, 600, 30.0);
//    CGRect butAddBook = CGRectMake(0, butYLocation + 38, 600, 30.0);
//    CGRect shareBtn = CGRectMake(0, butYLocation + 70, 600, 30.0);
    NSInteger tokenY = tokenFieldBounds.size.height;
    //NSLog(@"token height: %zi", tokenY);
    //if(tokenY >= 192) tokenY = 192;
    /*
    if(accY == 0 && tokenY >= 0) {
        accY = 1;
        previouseY = tokenY;
    }
    
    if(accY != 0 && tokenY > previouseY) {
        NSInteger differ = tokenY - previouseY;
        NSInteger step = 0;
        if(differ == 0) step = 0;
        else if(differ < 40) {
            step = 1;
        } else if (differ < 60) {
            step = 2;
        } else if (differ < 80) {
            step = 3;
        } else if (differ < 200) {
            step = 4;
        }
        previouseY = tokenY;
        if(accY <= 5) {
            butYLocation += step * 27;
            butUsavLocal = CGRectMake(0, butYLocation, 200, 30.0);
            butAddBook = CGRectMake(0, butYLocation + 40, 200, 30.0);
        }
        accY += step;
        if(accY >= 5) accY = 6;
    }
    
    if(accY > 1 && tokenY < previouseY && tokenY <= 150) {
        previouseY = tokenY;
        if(accY >= 0) {
            butYLocation -= 27;
            butUsavLocal = CGRectMake(0, butYLocation, 200, 30.0);
            butAddBook = CGRectMake(0, butYLocation + 40, 200, 30.0);
        }
        if(accY == 6) {
            accY -= 2;
        } else {accY -= 1;}
    }
    */
//  butUsavLocal = CGRectMake(0, tokenY+4, 600, 30.0);
//  butAddBook = CGRectMake(0, tokenY + 35, 600, 30.0);
//  shareBtn = CGRectMake(0, tokenY + 70, 600, 30.0);
  
  self.tokenFieldScrollView.contentSize = tokenFieldBounds.size;
  
  CGFloat maxHeight = [self.tokenField heightForNumberOfRows:5];
  if (!self.searchTableView.hidden) {
    tokenScrollBounds = CGRectMake(0, 0, CGRectGetWidth(bounds), [self.tokenField heightForNumberOfRows:1]);
  }
  else if (CGRectGetHeight(tokenScrollBounds) > maxHeight) {
    tokenScrollBounds = CGRectMake(0, 0, CGRectGetWidth(bounds), maxHeight);
  }
    
  [UIView animateWithDuration:0.25 animations:^{
    self.tokenFieldScrollView.frame = tokenScrollBounds;
//    
//    self.uSavContact.frame =butUsavLocal;
//    self.btnAddBook.frame = butAddBook;
//    self.btnShare.frame = shareBtn;
  }];
  //self.uSavContact.frame =butUsavLocal;
  if (!CGRectIsNull(keyboardFrame_)) {
    CGRect keyboardFrame = [self.view convertRect:keyboardFrame_ fromView:nil];
    CGRect tableFrame = CGRectMake(0,
                                   CGRectGetMaxY(self.tokenFieldScrollView.frame) + [self.tokenField heightForNumberOfRows:1],
                                   CGRectGetWidth(bounds),
                                   CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(self.tokenFieldScrollView.frame) - [self.tokenField heightForNumberOfRows:1] - 10);
    [UIView animateWithDuration:0.25 animations:^{
      self.searchTableView.frame = tableFrame;
    }];
  }
  
  self.shadowLayer.frame = CGRectMake(0, CGRectGetMaxY(self.tokenFieldScrollView.frame), CGRectGetWidth(bounds), kTokenFieldShadowHeight);
  
  CGFloat contentOffset = MAX(0, CGRectGetHeight(tokenFieldBounds) - CGRectGetHeight(self.tokenFieldScrollView.bounds));
  [self.tokenFieldScrollView setContentOffset:CGPointMake(0, contentOffset) animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#pragma unused (object, change, context)
  if ([keyPath isEqualToString:kTokenFieldFrameKeyPath]) {
    [self layoutTokenFieldAndSearchTable];
  }
}

- (void)viewDidUnload {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.tokenField removeObserver:self forKeyPath:kTokenFieldFrameKeyPath];
}

- (NSArray *)selectedRecords {
  NSMutableArray *map = [NSMutableArray new];
  for (COToken *token in self.tokenField.tokens) {
    CORecord *record = [CORecord new];
    record.title = token.title;
    record.person = token.associatedObject;
    [map addObject:record];
  }
  return [NSArray arrayWithArray:map];
}

- (void)resetTokenFieldWithRecords:(NSArray *)records {
    [self.tokenField removeAllTokens];
    NSInteger limit = [self getNumLimit];

    
    for (CORecord *record in records) {
    //[self.tokenField processToken:record.title associatedRecord:record.person];
        if (limit > 1000 || limit == 0) {
           [self.tokenField processToken:record.title associatedRecord:record.person];
        } else{
          [self.tokenField processToken:[NSString stringWithFormat:@"%@ %zi", record.title] associatedRecord:record.person];
        }
    }
}

- (void)keyboardDidShow:(NSNotification *)note {
  keyboardFrame_ = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  [self layoutTokenFieldAndSearchTable];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (![scrollView isKindOfClass:[UITableView class]] && [self.searchTableView isHidden]) {
        [self.tokenField textFieldShouldReturn:self.tokenField.textField];
        [self.tokenField.textField resignFirstResponder];
    }
    
}


#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //弹出的是保存提示
    if (alertView.tag == 300) {
        if (buttonIndex == 0) {
            
            [self donePressed:nil];
            
            if (self.isFromMessage) {
                //移除Message
                //[[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
            }

        }
        else {
            if (self.isFromMessage) {
                //移除Message
                //[[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
    }
}

#pragma mark - COTokenFieldDelegate 

- (void)tokenFieldDidPressAddContactButton:(COTokenField *)tokenField {
#pragma unused (tokenField)
  ABPeoplePickerNavigationController *picker = [ABPeoplePickerNavigationController new];

  picker.addressBook = self.addressBookRef;
  picker.peoplePickerDelegate = self;
  picker.displayedProperties = self.displayedProperties;
  
  // Set same tint color on picker navigation bar
  UIColor *tintColor = self.navigationController.navigationBar.tintColor;
  if (tintColor != nil) {
    picker.navigationBar.tintColor = tintColor;
  }
  
  [self presentModalViewController:picker animated:YES];
}

- (ABAddressBookRef)addressBookForTokenField:(COTokenField *)tokenField {
#pragma unused (tokenField)
  return self.addressBookRef;
}

static NSString *kCORecordFullName = @"fullName";
static NSString *kCORecordEmailLabel = @"emailLabel";
static NSString *kCORecordEmailAddress = @"emailAddress";
static NSString *kCORecordRef = @"record";

- (void)tokenField:(COTokenField *)tokenField updateAddressBookSearchResults:(NSArray *)records {
    self.isChangedSetting = YES;
#pragma unused (tokenField)
  // Split the search results into one email value per row
  NSMutableArray *results = [NSMutableArray new];
#if TARGET_IPHONE_SIMULATOR
  for (NSInteger i=0; i<4; i++) {
    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSString stringWithFormat:@"Name %i", i], kCORecordFullName,
                           [NSString stringWithFormat:@"label%i", i], kCORecordEmailLabel,
                           [NSString stringWithFormat:@"fake%i@address.com", i], kCORecordEmailAddress,
                           nil];
    [results addObject:entry];
  }
#else
  for (COPerson *record in records) {
    for (CORecordEmail *email in record.emailAddresses) {
      NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                             [record.fullName length] != 0 ? record.fullName : email.address, kCORecordFullName,
                             email.label, kCORecordEmailLabel,
                             email.address, kCORecordEmailAddress,
                             record, kCORecordRef,
                             nil];
      if (![results containsObject:entry]) {
        [results addObject:entry];
      }
    }
  }
#endif
  self.discreteSearchResults = [NSArray arrayWithArray:results];
  
  // Update the table
  [self.searchTableView reloadData];
  if (self.discreteSearchResults.count > 0) {
    self.searchTableView.hidden = NO;  
  }
  else {
    self.searchTableView.hidden = YES;
  }
  [self layoutTokenFieldAndSearchTable];
}

- (void)tokenField:(COTokenField *)tokenField updateAddressBookSearchResults2:(NSArray *)records withSearchText:(NSString *)text {
    self.isChangedSetting = YES;
#pragma unused (tokenField)
    // Split the search results into one email value per row
    
    NSMutableArray *results = [NSMutableArray new];
#if TARGET_IPHONE_SIMULATOR
    for (NSInteger i=0; i<4; i++) {
        NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSString stringWithFormat:@"Name %i", i], kCORecordFullName,
                               [NSString stringWithFormat:@"label%i", i], kCORecordEmailLabel,
                               [NSString stringWithFormat:@"fake%i@address.com", i], kCORecordEmailAddress,
                               nil];
        [results addObject:entry];
    }
#else
    for (COPerson *record in records) {
        for (CORecordEmail *email in record.emailAddresses) {
            NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [record.fullName length] != 0 ? record.fullName : email.address, kCORecordFullName,
                                   email.label, kCORecordEmailLabel,
                                   email.address, kCORecordEmailAddress,
                                   record, kCORecordRef,
                                   nil];
            if (![results containsObject:entry]) {
                [results addObject:entry];
            }
        }
    }
#endif
    //这个函数似乎从这里开始才有用
    self.discreteSearchResults = [NSMutableArray arrayWithArray:results];
    [self.discreteSearchResults addObjectsFromArray:[self searchInGroup: text]];
    [self.discreteSearchResults addObjectsFromArray:[self searchInFriend: text]];
    // Update the table
    [self.searchTableView reloadData];
    if (self.discreteSearchResults.count > 0) {
        self.searchTableView.hidden = NO;
    }
    else {
        self.searchTableView.hidden = YES;
    }
    [self layoutTokenFieldAndSearchTable];
}

- (NSArray *)searchInGroup:(NSString *)text{
    
    NSMutableArray *results = [NSMutableArray new];

    NSInteger len = [self.group count];
    for (NSInteger i = 0; i < len; i++) {
        NSString *groupName = [self.group objectAtIndex:i];
        if([groupName rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound) {
            NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"CONDOR Group", nil), kCORecordFullName,
                                @"", kCORecordEmailLabel,
                                groupName , kCORecordEmailAddress,
                                nil, kCORecordRef,
                                nil];
            [results addObject:entry];
        }
    }
    return results;
}

- (NSArray *)searchInFriend:(NSString *)text{
    NSMutableArray *results = [NSMutableArray new];
    
    NSInteger len = [self.friend count];
    for (NSInteger i = 0; i < len; i++) {
        NSString *friendEmail = [self.friend objectAtIndex:i];
        NSString *friendAlias = [self.friendAlias objectAtIndex:i];
        //搜索用户名和EMAIL
        if([friendEmail rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound || [friendAlias rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound)  {
            if([friendEmail isEqualToString:[[USAVClient current] emailAddress]])
            {//[results addObject:nil];
                //WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                //[wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                //[wv show:NSLocalizedString(@"CantAddOwn", @"") inView:self.view];
            }else {
                if ([friendAlias isEqualToString:@""] || [friendAlias length] == 0) {
                    //没有Alias的用户，取Email的名字段为Alias
                    NSArray *EmailStringArray = [friendEmail componentsSeparatedByString:@"@"];
                    friendAlias = [EmailStringArray objectAtIndex:0];
                }
                NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                                   friendAlias, kCORecordFullName,
                                   @"", kCORecordEmailLabel,
                                   friendEmail, kCORecordEmailAddress,
                                   nil, kCORecordRef,
                                   nil];
                [results addObject:entry];
            }
        }
    }
    return results;
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
  return YES;
}


//NEW FOR iOS8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        if (!multi) return;
        
        NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, identifier));
        CFRelease(multi);
        
        COPerson *record = [[COPerson alloc] initWithABRecordRef:person];
        
        NSInteger limit = [self getNumLimit];
        
        //如果选的是其他项，提示
        if (![email isKindOfClass:[NSString class]]) {
            
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"Please Select a Valid Email Address", @"") inView:self.picker.view];
            
        } else if (![self isValidEmail:email]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"Please Select a Valid Email Address", @"") inView:self.picker.view];
        } else {
            if (limit > 1000 || limit == 0) {
                [self.tokenField processToken:email associatedRecord:record];
            } else{
                [self.tokenField processToken:[NSString stringWithFormat:@"%@", email] associatedRecord:record];
            }
            //[self.tokenField processToken:email associatedRecord:record];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        
        //compatible for iOS7
        [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
    }
    
    
    
}

//compatible for iOS7
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
  ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    if (!multi) return NO;
  NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, identifier));
  CFRelease(multi);
  
  COPerson *record = [[COPerson alloc] initWithABRecordRef:person];
    
    NSLog(@"进入iOS7");

    //如果选的是其他项，提示
    if (![email isKindOfClass:[NSString class]]) {
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Please Select a Valid Email Address", @"") inView:self.picker.view];
        
    } else if (![self isValidEmail:email]) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Please Select a Valid Email Address", @"") inView:self.picker.view];
    } else {
        NSInteger limit = [self getNumLimit];
        
        if (limit > 1000 || limit == 0) {
            [self.tokenField processToken:email associatedRecord:record];
        } else{
            [self.tokenField processToken:[NSString stringWithFormat:@"%@", email] associatedRecord:record];
        }
        //[self.tokenField processToken:email associatedRecord:record];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
  
  return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#pragma unused (tableView, section)
  return (NSInteger)self.discreteSearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *result = [self.discreteSearchResults objectAtIndex:(NSUInteger)indexPath.row];

    static NSString *ridf = @"resultCell";
    COEmailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ridf];
    if (cell == nil) {
    cell = [[COEmailTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ridf];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSLog(@"result:%@", self.discreteSearchResults);
    cell.nameLabel.text = [result objectForKey:kCORecordFullName];
    cell.nameLabel.font = [UIFont boldSystemFontOfSize:13];
    cell.emailLabelLabel.text = [result objectForKey:kCORecordEmailLabel];
    cell.emailAddressLabel.text = [result objectForKey:kCORecordEmailAddress];
    cell.associatedRecord = [result objectForKey:kCORecordRef];
    cell.backgroundColor = [UIColor clearColor];

    [cell adjustLabels];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    COEmailTableCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    //NSInteger r =[self.tokenField processToken:cell.emailAddressLabel.text associatedRecord:cell.associatedRecord];
    NSInteger r;
    NSInteger limit = [self getNumLimit];
    if (limit > 1000 || limit == 0) {
        r = [self.tokenField processToken:[NSString stringWithFormat:@"%@", cell.emailAddressLabel.text] associatedRecord:cell.associatedRecord];
     } else{
        r = [self.tokenField processToken:[NSString stringWithFormat:@"%@", cell.emailAddressLabel.text] associatedRecord:cell.associatedRecord];
     }
    if (r ==0) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(160, 150)];
        [wv show:NSLocalizedString(@"Already added", @"") inView:self.view];
    } else {
        [self.searchTableView setHidden:YES];
    }
}

@end

// =============================================================================

@implementation COTokenField
COSynth(tokenFieldDelegate)
COSynth(textField)
COSynth(addContactButton)
COSynth(tokens)
COSynth(selectedToken)
COSynth(group)

static NSString *kCOTokenFieldDetectorString = @"\u200B";

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
    
  if (self) {
      
    self.tokens = [NSMutableArray new];
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    // Setup contact add button
//    self.addContactButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    self.addContactButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//    
//    [self.addContactButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
//    
//    CGRect buttonFrame = self.addContactButton.frame;
//    self.addContactButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldPaddingX,
//                                             CGRectGetHeight(self.bounds) - CGRectGetHeight(buttonFrame) - kTokenFieldPaddingY,
//                                             buttonFrame.size.height,
//                                             buttonFrame.size.width);
//    [self.addContactButton setHidden:YES];
//    [self addSubview:self.addContactButton];
   
    // Setup text field
    CGFloat textFieldHeight = self.computedRowHeight;
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kTokenFieldPaddingX, (CGRectGetHeight(self.bounds) - textFieldHeight) / 2.0, CGRectGetWidth(self.bounds) - kTokenFieldPaddingX * 3.0, textFieldHeight)];
    self.textField.opaque = NO;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.font = [UIFont systemFontOfSize:kTokenFieldFontSize];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.text = kCOTokenFieldDetectorString;
    self.textField.delegate = self;
    self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    //[self.textField setValue:NSLocalizedString(@"Search Contact List or Enter Friend's Email Address", nil) forKey:@"placeholder"];
    [self.textField addTarget:self action:@selector(tokenInputChanged:) forControlEvents:UIControlEventEditingChanged];
//      [self.textField addTarget:self action:@selector(tokenInputBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self addSubview:self.textField];
    
      self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 5, 140, 20)];
      self.placeholderLabel.userInteractionEnabled = NO;
      self.placeholderLabel.text = NSLocalizedString(@"To...", nil);
      self.placeholderLabel.font = [UIFont systemFontOfSize:13];
      self.placeholderLabel.textColor = [UIColor lightGrayColor];
      [self.textField addSubview:self.placeholderLabel];
      
    [self setNeedsLayout];
  }
  return self;
}


- (void)addContact:(id)sender {
#pragma unused (sender)
    id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
    [tokenFieldDelegate tokenFieldDidPressAddContactButton:self];
}

- (CGFloat)computedRowHeight {
  CGFloat buttonHeight = CGRectGetHeight(self.addContactButton.frame);
  return MAX(buttonHeight, (CGFloat)(kTokenFieldPaddingY * 2.0 + kTokenFieldTokenHeight));
}

- (CGFloat)heightForNumberOfRows:(NSUInteger)rows {
  return (CGFloat)rows * self.computedRowHeight + (CGFloat)kTokenFieldPaddingY * 2.0f;
}

- (void)layoutSubviews {
  NSUInteger row = 0;
  NSInteger tokenCount = (NSInteger)self.tokens.count;
  
  CGFloat left = kTokenFieldPaddingX;
  CGFloat maxLeft = CGRectGetWidth(self.bounds) - (CGFloat)kTokenFieldPaddingX;
  CGFloat rowHeight = self.computedRowHeight;

    if (tokenCount > 0) {
        [self.doneBtn setEnabled:YES];
        [self.confirmShareBtn setEnabled:YES];
        [self.doneBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
        [self.confirmShareBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
        
    }
    
  for (NSInteger i=0; i<tokenCount; i++) {
    COToken *token = [self.tokens objectAtIndex:(NSUInteger)i];
    CGFloat right = left + CGRectGetWidth(token.bounds);
    if (right > maxLeft) {
      row++;
      left = kTokenFieldPaddingX;
    }
    
    // Adjust token frame
    CGRect tokenFrame = token.frame;
    tokenFrame.origin = CGPointMake(left, (CGFloat)row * rowHeight + (rowHeight - CGRectGetHeight(tokenFrame)) / 2.0f + (CGFloat)kTokenFieldPaddingY);
    token.frame = tokenFrame;
    
    left += CGRectGetWidth(tokenFrame) + kTokenFieldPaddingX;
      
    [self addSubview:token];
  }
  
  CGFloat maxLeftWithButton = maxLeft - (CGFloat)kTokenFieldPaddingX - CGRectGetWidth(self.addContactButton.frame);
  if (maxLeftWithButton - left < 50) {
    row++;
    left = kTokenFieldPaddingX;
  }
  
    CGRect textFieldFrame = self.textField.frame;
    textFieldFrame.origin = CGPointMake(left, (CGFloat)row * rowHeight + (rowHeight - CGRectGetHeight(textFieldFrame)) / 2.0f + (CGFloat)kTokenFieldPaddingY);
    textFieldFrame.size = CGSizeMake(maxLeftWithButton - left, CGRectGetHeight(textFieldFrame));
    self.textField.frame = textFieldFrame; //这里一定要这么写，否则完全显示不出textfield………………调了一天的错！！
    
    if ([self.tokens count] == 0) {
        [self.confirmShareBtn setEnabled:NO];
        [self.confirmShareBtn setBackgroundColor:[UIColor lightGrayColor]];
    } else {
        [self.confirmShareBtn setEnabled:YES];
        [self.confirmShareBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    }
    //NSLog(@"%@",NSStringFromCGRect(textFieldFrame));
  
  CGRect tokenFieldFrame = self.frame;
  CGFloat minHeight = MAX(rowHeight, CGRectGetHeight(self.addContactButton.frame) + (CGFloat)kTokenFieldPaddingY * 2.0f);
  tokenFieldFrame.size.height = MAX(minHeight, CGRectGetMaxY(textFieldFrame) + (CGFloat)kTokenFieldPaddingY);
  
  self.frame = tokenFieldFrame;
}

- (void)selectToken:(COToken *)token {
    
    self.peoplePickerDelegate.isChangedSetting = YES;
    
  @synchronized (self) {
    if (token != nil) {
      self.textField.hidden = YES;
      [self.textField becomeFirstResponder];
    }
    else {
      self.textField.hidden = NO;
      [self.textField becomeFirstResponder];
    }
    self.selectedToken = token;
      
    for (COToken *t in self.tokens) {
        if(t == token) {
            if(t.highlighted2) t.highlighted2 = FALSE;
            else {
                //自己被选中高亮，其他token取消选择
                t.highlighted2 = YES;
                for (COToken *otherToken in self.tokens) {
                    if (otherToken != token) {
                        otherToken.highlighted2 = FALSE;
                    }
                    [otherToken setNeedsDisplay];
                }
            }
            
            [t setNeedsDisplay];
        }
    }
  }
}

- (void)removeAllTokens {
  for (COToken *token in self.tokens) {
    [token removeFromSuperview];
  }
  [self.tokens removeAllObjects];
  self.textField.hidden = NO;
  self.selectedToken = nil;
  [self setNeedsLayout];
}

- (void)removeToken:(COToken *)token {
  [token removeFromSuperview];
  [self.tokens removeObject:token];
  self.textField.hidden = NO;
  self.selectedToken = nil;
  [self setNeedsLayout];
}

- (void)modifyToken:(COToken *)token {
  if (token != nil) {
    if (token == self.selectedToken) {
      [self removeToken:token];
    }
    else {
      [self selectToken:token];
    }
    [self setNeedsLayout];
  }
}

- (void)modifySelectedToken {
  COToken *token = self.selectedToken;
  if (token == nil) {
    token = [self.tokens lastObject];
  }
  [self modifyToken:token];
}

- (NSInteger)processToken:(NSString *)tokenText associatedRecord:(COPerson *)record {
    for (id i in self.tokens) {
        COToken *t = (COToken *)i;
        if ([tokenText caseInsensitiveCompare:t.title]== NSOrderedSame) return 0;
        
    }
  char *t = [tokenText characterAtIndex:0];
  /*if (t == 48 || t == 49 || t == 50|| t == 51|| t == 52|| t == 53|| t == 54|| t == 55|| t == 56|| t == 57) {
      return 0;
    }
   */
  //[self.searchTableView setHidden:YES];
  COToken *token = [COToken tokenWithTitle:tokenText associatedObject:record container:self];
  [token addTarget:self action:@selector(selectToken:) forControlEvents:UIControlEventTouchUpInside];
  [self.tokens addObject:token];
  self.textField.text = kCOTokenFieldDetectorString;
  [self setNeedsLayout];
  return 1;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
#pragma unused (touches, event)
  [self selectToken:nil];
}

- (NSString *)textWithoutDetector {
  NSString *text = self.textField.text;
  if (text.length > 0) {
    return [text substringFromIndex:1];
  }
  return text;
}

static BOOL containsString(NSString *haystack, NSString *needle) {
  return ([haystack rangeOfString:needle options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound);
}

//- (void)tokenInputBegin:(id)sender {
//    NSLog(@"token token数目 %zi", [self.tokens count]);
//    if ([self.tokens count] > 0) {
//        [self.doneBtn setEnabled:YES];
//    } else {
//        [self.doneBtn setEnabled:NO];
//    }
//}

#pragma mark 文字改变监听
- (void)tokenInputChanged:(id)sender {
    
    self.peoplePickerDelegate.isChangedSetting = YES;
    
    //自己加的，当文字改变，判断内容是否为空，如果不为空，再显示confirm, 这里很奇怪为什么为空的时候长度为1
    if (self.textField.text.length != 1 || [self.tokens count] > 0) {
        [self.doneBtn setEnabled:YES];
        [self.doneBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
        [self.confirmShareBtn setEnabled:YES];
        [self.confirmShareBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
        [self.placeholderLabel removeFromSuperview];
    } else if (self.textField.text.length > 1){
        [self.placeholderLabel removeFromSuperview];    //正在输入中
    } else{
        [self.textField addSubview:self.placeholderLabel];
        [self.doneBtn setEnabled:YES];
        [self.doneBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
        [self.confirmShareBtn setBackgroundColor:[UIColor lightGrayColor]];
        [self.confirmShareBtn setEnabled:NO];
    }
    
  NSString *searchText = self.textWithoutDetector;
  NSArray *matchedRecords = [NSArray array];
  id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
    
  if (searchText.length > 0) {
    // Generate new search dict only after a certain delay
    static NSDate *lastUpdated = nil;;
    static NSMutableArray *records = nil;
    if (records == nil || [lastUpdated timeIntervalSinceDate:[NSDate date]] < -10) {
      ABAddressBookRef ab = [tokenFieldDelegate addressBookForTokenField:self];
      NSArray *people = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(ab));
      records = [NSMutableArray new];
      for (id obj in people) {
        ABRecordRef recordRef = (__bridge CFTypeRef)obj;
        COPerson *record = [[COPerson alloc] initWithABRecordRef:recordRef];
        [records addObject:record];
      }
    //[self constructRecordsFromGroupAndFriend:records];

      lastUpdated = [NSDate date];
    }
    
    NSIndexSet *resultSet = [records indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
#pragma unused (idx, stop)
      COPerson *record = (COPerson *)obj;
      if ([record.fullName length] != 0 && containsString(record.fullName, searchText)) {
        return YES;
      }
      for (CORecordEmail *email in record.emailAddresses) {
        if (containsString(email.address, searchText)) {
          return YES;
        }
      }
      return NO;
    }];
    

    // Generate results to pass to the delegate
    matchedRecords = [records objectsAtIndexes:resultSet];
      [tokenFieldDelegate tokenField:self updateAddressBookSearchResults2:matchedRecords withSearchText:[searchText copy]];

  } else {
      [tokenFieldDelegate tokenField:self updateAddressBookSearchResults:matchedRecords];
  }
}
//#pragma mark 滑动隐藏键盘
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.textField resignFirstResponder];
//}




#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
#pragma unused (range)
  if (string.length == 0 && [textField.text isEqualToString:kCOTokenFieldDetectorString]) {
    [self modifySelectedToken];
    return NO;
  }
  else if (textField.hidden) {
    return NO;
  }
  return YES;
}

- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.+@.+\\..+$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

- (BOOL)isGroup: (NSString *)name
{
    for (id g in self.group) {
        
        NSString *group= (NSString *)g;
        NSInteger i = [name length];
        NSInteger j = [group length];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([name isEqualToString:group])
            return YES;
    }
    return NO;
}


- (BOOL)spacePressed:(UITextField *)textField {
    if (textField.hidden) {
        return NO;
    }
    NSString *text = self.textField.text;
    if ([text length] > 1) {
        if (![self isValidEmail:text])
            if(![self isGroup:text]) {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(160, 150)];
                [wv show:NSLocalizedString(@"groupDontExist", @"") inView:self.scrollView];
                
                return NO;
            }
        
        [self processToken:[text substringFromIndex:1] associatedRecord:nil];
    }
    else {
        return [textField resignFirstResponder];
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField.hidden) {
    return NO;
  }
  NSString *text = self.textField.text;
  if ([text length] > 1) {
    if (![self isValidEmail:text])
        if(![self isGroup:text]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            //这个Position比较特殊
            [wv setCenter:CGPointMake(160, 150)];
            [wv show:NSLocalizedString(@"groupDontExist", @"") inView:self.scrollView];
            //[self.doneBtn setEnabled:NO];
            return NO;
        }
      //[self.doneBtn setEnabled:YES];
    [self processToken:[text substringFromIndex:1] associatedRecord:nil];
    
  }
  else {
    return [textField resignFirstResponder];
  }
  return YES;
}

@end

// =============================================================================


@implementation COToken
COSynth(title)
COSynth(associatedObject)
COSynth(container)

+ (COToken *)tokenWithTitle:(NSString *)title associatedObject:(id)obj container:(COTokenField *)container {
  COToken *token = [self buttonWithType:UIButtonTypeCustom];
  token.associatedObject = obj;
  token.container = container;
  token.backgroundColor = [UIColor clearColor];
  
  UIFont *font = [UIFont systemFontOfSize:kTokenFieldFontSize];
  CGSize tokenSize = [title sizeWithFont:font];
  tokenSize.width = MIN((CGFloat)kTokenFieldMaxTokenWidth, tokenSize.width);
  tokenSize.width += kTokenFieldPaddingX * 2.0;
  
  tokenSize.height = MIN((CGFloat)kTokenFieldFontSize, tokenSize.height);
  tokenSize.height += kTokenFieldPaddingY * 2.0;
  
  token.frame = (CGRect){CGPointZero, tokenSize};
  token.titleLabel.font = font;
  token.title = title;
  
  return token;
}

- (void)drawRect:(CGRect)rect {
#pragma unused (rect)
  CGFloat radius = CGRectGetHeight(self.bounds) / 2.0f;
  
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextAddPath(ctx, path.CGPath);
  CGContextClip(ctx);
  
  NSArray *colors = nil;
  if (self.highlighted2) {
      
    colors = [NSArray arrayWithObjects:
              (__bridge id)[UIColor colorWithRed:0.322 green:0.541 blue:0.976 alpha:1.0].CGColor,
              (__bridge id)[UIColor colorWithRed:0.235 green:0.329 blue:0.973 alpha:1.0].CGColor,
              nil];
  }
  else {
    colors = [NSArray arrayWithObjects:
              (__bridge id)[UIColor colorWithRed:0.863 green:0.902 blue:0.969 alpha:1.0].CGColor,
              (__bridge id)[UIColor colorWithRed:0.741 green:0.808 blue:0.937 alpha:1.0].CGColor,
              nil];
  }
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFTypeRef)colors, NULL);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, CGRectGetHeight(self.bounds)), 0);
  CGGradientRelease(gradient);
  CGContextRestoreGState(ctx);
  
  if (self.highlighted2) {
    [[UIColor colorWithRed:0.275f green:0.478f blue:0.871f alpha:1.0f] set];
  }
  else {
    [[UIColor colorWithRed:0.667f green:0.757f blue:0.914f alpha:1.0f] set];
  }
  
  path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.5, 0.5) cornerRadius:radius];
  [path setLineWidth:1.0];
  [path stroke];
  
  if (self.highlighted2) {
    [[UIColor whiteColor] set];
  }
  else {
    [[UIColor blackColor] set];
  }
    //self.highlighted2 = FALSE;
    
  UIFont *titleFont = [UIFont systemFontOfSize:kTokenFieldFontSize];
  CGSize titleSize = [self.title sizeWithFont:titleFont];
  CGRect titleFrame = CGRectMake((CGRectGetWidth(self.bounds) - titleSize.width) / 2.0f,
                                 (CGRectGetHeight(self.bounds) - titleSize.height) / 2.0f,
                                 titleSize.width,
                                 titleSize.height);
  
  [self.title drawInRect:titleFrame withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
}

/*
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ title: '%@'; associatedObj: '%@'>",
          NSStringFromClass(isa), self.title, self.associatedObject];
}
*/

@end

// =============================================================================

@implementation COPerson {
@private
  ABRecordRef record_;
}

- (id)initWithABRecordRef:(ABRecordRef)record {
  self = [super init];
  if (self) {
    if (record != NULL) {
      record_ = CFRetain(record);
    }
  }
  return self;
}

- (void)dealloc {
  if (record_) {
    CFRelease(record_);
    record_ = NULL;
  }
}

- (NSString *)fullName {
  return CFBridgingRelease(ABRecordCopyCompositeName(record_));
}

- (NSString *)namePrefix {
  return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonPrefixProperty));
}

- (NSString *)firstName {
  return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonFirstNameProperty));
}

- (NSString *)middleName {
  return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonMiddleNameProperty));
}

- (NSString *)lastName {
  return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonLastNameProperty));
}

- (NSString *)nameSuffix {
  return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonSuffixProperty));
}

- (NSArray *)emailAddresses {
  NSMutableArray *addresses = [NSMutableArray new];
  ABMultiValueRef emails = ABRecordCopyValue(record_, kABPersonEmailProperty);
  CFIndex multiCount = ABMultiValueGetCount(emails);
  for (CFIndex i=0; i<multiCount; i++) {
    CORecordEmail *email = [[CORecordEmail alloc] initWithEmails:emails
                                                      identifier:ABMultiValueGetIdentifierAtIndex(emails, i)];
    [addresses addObject:email];
  }
  
  if (emails != NULL) {
    CFRelease(emails);
  }

  return [NSArray arrayWithArray:addresses];
}

- (ABRecordRef)record {
  return record_;
}

@end

// =============================================================================

@implementation CORecordEmail

- (id)initWithEmails:(ABMultiValueRef)emails identifier:(ABMultiValueIdentifier)identifier {
  self = [super init];
  if (self) {
    if (emails != NULL) {
      emails_ = CFRetain(emails);
    }
    identifier_ = identifier;
  }
  return self;
}

- (void)dealloc {
  if (emails_ != NULL) {
    CFRelease(emails_);
    emails_ = NULL;
  }
}

- (NSString *)label {
  CFStringRef label = ABMultiValueCopyLabelAtIndex(emails_, ABMultiValueGetIndexForIdentifier(emails_, identifier_));
  if (label != NULL) {
    CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(label);
    CFRelease(label);
    return CFBridgingRelease(localizedLabel);
  }
  return @"email";
}

- (NSString *)address {
  return CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails_, ABMultiValueGetIndexForIdentifier(emails_, identifier_)));
}

@end

// =============================================================================

@implementation COEmailTableCell
COSynth(nameLabel)
COSynth(emailLabelLabel)
COSynth(emailAddressLabel)
COSynth(associatedRecord)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.emailLabelLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.emailLabelLabel.font = [UIFont boldSystemFontOfSize:13];
    self.emailLabelLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    self.emailLabelLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    
    self.emailAddressLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.emailAddressLabel.font = [UIFont systemFontOfSize:13];
    self.emailAddressLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    self.emailAddressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.nameLabel];
    [self addSubview:self.emailLabelLabel];
    [self addSubview:self.emailAddressLabel];
    
    [self adjustLabels];
  }
  return self;
}

- (void)adjustLabels {
  CGSize emailLabelSize = [self.emailLabelLabel.text sizeWithFont:self.emailLabelLabel.font];
  CGFloat leftInset = 8;
  CGFloat yInset = 4;
  CGFloat labelWidth = emailLabelSize.width;
  self.nameLabel.frame = CGRectMake(leftInset, yInset, CGRectGetWidth(self.bounds) - leftInset * 2, CGRectGetHeight(self.bounds) / 2.0 - yInset);
  self.emailLabelLabel.frame = CGRectMake(leftInset, CGRectGetMaxY(self.nameLabel.frame), labelWidth, CGRectGetHeight(self.bounds) / 2.0 - yInset);
  self.emailAddressLabel.frame = CGRectMake(labelWidth + leftInset * 2, CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(self.bounds) - labelWidth - leftInset * 3, CGRectGetHeight(self.bounds) / 2.0 - yInset);
}

@end
