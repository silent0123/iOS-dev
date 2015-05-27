//
//  COPeoplePickerViewController.m
//  COPeoplePickerViewController
//
//  Created by Erik Aigner on 08.10.11.
//  Copyright (c) 2011 chocomoko.com. All rights reserved.
//
groupIndex = 0;
#define ALERTVIEW_EMPTY_EMAIL_PERMISSION 0
#import "COPeoplePickerViewController2.h"
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

#define COSynth(x) @synthesize x = x##_;
int butYLocation = 50;
int butYMax = 50 * 5 ;

int previouseY = 0;
int accY = 0;
// =============================================================================

@class COTokenField;

@interface COToken : UIButton
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id associatedObject;
@property (nonatomic, strong) COTokenField *container;

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

#define kTokenFieldFontSize 14.0
#define kTokenFieldPaddingX 6.0
#define kTokenFieldPaddingY 6.0
#define kTokenFieldTokenHeight (kTokenFieldFontSize + 4.0)
#define kTokenFieldMaxTokenWidth 260.0
#define kTokenFieldFrameKeyPath @"frame"
#define kTokenFieldShadowHeight 14.0

@interface COTokenField : UIView <UITextFieldDelegate>
@property (nonatomic, weak) id<COTokenFieldDelegate> tokenFieldDelegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *addContactButton;
@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, strong) COToken *selectedToken;
@property (nonatomic, readonly) CGFloat computedRowHeight;
@property (nonatomic, readonly) NSString *textWithoutDetector;

- (CGFloat)heightForNumberOfRows:(NSUInteger)rows;
- (void)selectToken:(COToken *)token;
- (void)removeAllTokens;
- (void)removeToken:(COToken *)token;
- (void)modifyToken:(COToken *)token;
- (void)modifySelectedToken;
- (void)processToken:(NSString *)tokenText associatedRecord:(COPerson *)record;
- (void)tokenInputChanged:(id)sender;

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

@interface COPeoplePickerViewController2 () <UITableViewDelegate, UITableViewDataSource, COTokenFieldDelegate, ABPeoplePickerNavigationControllerDelegate,USAVContactListViewControllerDelegate, MFMailComposeViewControllerDelegate> {
@private
    ABAddressBookRef addressBook_;
    CGRect           keyboardFrame_;
}

@property (nonatomic, strong) COTokenField *tokenField;
@property (nonatomic, strong) UIScrollView *tokenFieldScrollView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *discreteSearchResults;
@property (nonatomic, strong) CAGradientLayer *shadowLayer;
@property (nonatomic, strong) UIButton *uSavContact;
@property (nonatomic, strong) UIButton *btnAddBook;
@property (strong, nonatomic) NSMutableArray *emailList;
@property (nonatomic) int numberOfSetPermissionSuccess;
@property (nonatomic) int numberOfTargetPermissions;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) NSMutableArray *group;
@property (nonatomic, strong) NSMutableArray *friend;
@property (nonatomic, strong) NSMutableArray *groupMember;
@property (nonatomic, strong) NSMutableArray *groupFinal;
@property (nonatomic, strong) NSMutableArray *emailFinal;

/*
 @property (strong, nonatomic) NSString *encryptedFileName;
 @property (strong, nonatomic) NSString *encryptedFilePath;
 @property (strong, nonatomic) NSString *keyId;
 */
@end

@implementation COPeoplePickerViewController2
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

- (void)contactListViewControllerDidFinish:(USAVGuidedSetPermissionViewController *)controller {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    /* [self addEmails:[controller.emails copy] toCurrentEmailList:self.emailList];[self.tbView reloadData];*/
    for (id i in controller.groups) {
        [self.tokenField processToken:i associatedRecord:nil];
    }
    
    for (id i in controller.friends2) {
        [self.tokenField processToken:i associatedRecord:nil];
    }
    
}



- (ABAddressBookRef)addressBookRef {
    return addressBook_;
}



- (void)addBookPressed:(id)sender {
    [self performSegueWithIdentifier:@"EditPermission" sender:self];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EditPermission"]) {
        USAVGuidedSetPermissionViewController *usavContact = (USAVGuidedSetPermissionViewController  *)segue.destinationViewController;
        usavContact.delegate = self;
    }
}



- (void)addContactFromAddressBook:(id)sender {
#pragma unused (sender)
    //id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
    //[tokenFieldDelegate tokenFieldDidPressAddContactButton:self];
    
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
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(shareBtnPressed:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (IBAction)shareBtnPressed:(id)sender {
    [self setPermissionFinal];
}

- (void)getPermissionList:(NSString *)keyId
{
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listFriendListPermision:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack:)];
}

- (void)getPermissionListCallBack:(NSDictionary*)obj
{
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        NSArray *permissionList = [obj objectForKey:@"permissionList"];
        if (!permissionList)
        {
            return;
        }
        
        NSMutableArray *permissionForGroups = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *permissionForFriends = [NSMutableArray arrayWithCapacity:0];
        
        for (int i = 0; i < [permissionList count]; i++) {
            NSDictionary *unit = [permissionList objectAtIndex:i];
            if ([[unit objectForKey:@"permission"] integerValue] == 1) {
                if ([[unit objectForKey:@"isUser"] integerValue]== 0) {
                    [permissionForGroups addObject:[unit objectForKey:@"name"]];
                } else {
                    [permissionForFriends addObject:[unit objectForKey:@"name"]];
                }
            }
        }
        
        //self.originPermissionGroups = permissionForGroups;
        //self.originPermissionFriends = permissionForFriends;
        //self.indexForOriginGroup = 0;
        //[self setOriginPermission];
        
        /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
         [wv setCenter:CGPointMake(160, 230)];
         [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
         */
    }
    else {
        //[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
        /*
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
         [wv setCenter:CGPointMake(160, 230)];
         [wv show:NSLocalizedString(@"PermissionDenied", @"") inView:self.view];*/
        //[ dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
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

-(void)getMemberForGroup:(NSString *)group to:(NSMutableArray *)emailList {
    bool in = false;
    int index = -1;
    for(int i = 0; i < [self.group count]; i++) {
        if([group isEqualToString:[self.group objectAtIndex:i]]) {
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



- (void)setPermissionFinal
{
    self.emailFinal = [NSMutableArray arrayWithCapacity:0];
    self.groupFinal = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *tokenTextList = [NSMutableArray arrayWithCapacity:0];
    
    for(int i =0; i< [self.tokenField.tokens count]; i++)
    {
        [tokenTextList addObject:((COToken *)[self.tokenField.tokens objectAtIndex:i]).title];
    }
    NSArray *tokenText= [[NSSet setWithArray:tokenTextList] allObjects];
    
    self.emailList = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < [tokenText count]; i++) {
        NSString *text = [tokenText objectAtIndex:i];
        if ([self isValidEmail:text]) {
            [self.emailList addObject:text];
            [self.emailFinal addObject:text];
        } else {
            [self getMemberForGroup:text to:self.emailList];
        }
    }
    self.emailList = [[NSSet setWithArray:self.emailList] allObjects];
    
    int totalEmail = [self.emailList count];
    
    
    self.numberOfTargetPermissions = totalEmail;
    self.numberOfSetPermissionSuccess = 0;
    
    if (![self.emailList count]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Share List Empty", @"") message:NSLocalizedString(@"Share List Empty Alert", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
        [alert show];
        alert.alertViewStyle = UIAlertViewStyleDefault; // UIAlertViewStylePlainTextInput;
        alert.tag = ALERTVIEW_EMPTY_EMAIL_PERMISSION;
        [alert show];
        
        return;
    } else {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"FileEditPermissionKey", @"") delegate:self];
    }
    
    NSMutableArray *groupP = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *friendP = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < [self.emailFinal count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[self.emailFinal objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%d",1]];
        
        [friendP addObject:root];
    }
    for (int i = 0; i < [self.groupFinal count]; i++)
    {
        NSMutableArray *root = [NSMutableArray arrayWithCapacity:0];
        [root addObject:[NSString stringWithFormat:@"%@",[self.groupFinal objectAtIndex:i]]];
        [root addObject:[NSString stringWithFormat:@"%d",1]];
        
        [groupP addObject:root];
    }
    
    [self setContactPermissionForKey:self.keyId group:groupP andFriends:friendP];
    
    self.emailFinal = nil;
    self.groupFinal = nil;
}
- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
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

-(void) setContactPermissionForKey:(NSString *)kid group: (NSArray *)group andFriends: (NSArray *)friend {
    //NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.currentFullPath];
    //NSString *keyIdString = [keyId base64EncodedString];
    //NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", //keyIdString, @"\n"];
    
    GDataXMLElement * post= [GDataXMLNode elementWithName:@"params"];
    GDataXMLElement * keyId = [GDataXMLNode elementWithName:@"keyId" stringValue:kid];
    [post addChild:keyId];
    
    for (id g in group) {
        GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"GroupPermission"];
        GDataXMLElement * contact = [GDataXMLNode elementWithName:@"Contact" stringValue:[g objectAtIndex:0]];
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
    //md5 = [self base64String:md5];
    
    
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", md5, @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"content-md5" stringValue:md5];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    //[client.api setcontactlistpermission:data target:(id)self selector:@selector(setPermissionCallBack:)];
    [client.api setcontactlistpermission:encodedGetParam P:[[post XMLString]  dataUsingEncoding:NSUTF8StringEncoding] target:(id)self selector:@selector(setPermissionCallBack:)];
    
}


- (void)setPermissionMono:(NSString *)keyId for:(NSString *)name isUser:(int)isUser withPermission:(int)permission
{
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",[[NSString alloc] initWithFormat:@"%d",isUser], @"\n", keyId, @"\n",
                                name, @"\n", [[NSString alloc] initWithFormat:@"%d", permission]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"name" stringValue:name];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"isUser" stringValue:[[NSString alloc] initWithFormat:@"%d", isUser]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"permission" stringValue:[[NSString alloc] initWithFormat:@"%d",permission]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api setFriendListPermision:encodedGetParam target:(id)self selector:@selector(setPermissionCallBack:)];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
        {
            UINavigationController *ctr = [self parentViewController];
            [self dismissViewControllerAnimated:YES completion:nil];
            [ctr popToRootViewControllerAnimated:NO];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:@"Email Sent Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            return;
        case MFMailComposeResultFailed:
            //NSLog(@"Result: failed");
            break;
        default:
            //NSLog(@"Result: not sent");
            break;
    }
    // [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPermissionCallBack:(NSDictionary*)obj
{
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"SetPermissionFailed", @"") inView:self.view];
        self.numberOfSetPermissionSuccess = 0;
        return;
    }
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(160, 230)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    if ((obj != nil) && ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0)) {
        //self.numberOfSetPermissionSuccess += 1;
        //if (self.numberOfSetPermissionSuccess == self.numberOfTargetPermissions) {
        
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
        
    } else {
        /*
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
         [wv setCenter:CGPointMake(160, 230)];
         [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
         */
    }
}

- (void)viewDidLoad {
    
    [self getPermissionList:self.keyId];
    
    [self.group removeAllObjects];
    [self.group removeAllObjects];
    self.groupMember = nil;
    [self.emailList removeAllObjects];
    groupIndex = 0;
    [self listGroup];
    // Configure content view
    self.view.backgroundColor = [UIColor colorWithRed:0.859 green:0.886 blue:0.925 alpha:1.0];
    
    self.navigationItem.title = NSLocalizedString(@"Set Permission", @"");
    
    // Configure token field
    CGRect viewBounds = self.view.bounds;
    CGRect tokenFieldFrame = CGRectMake(0, 0, CGRectGetWidth(viewBounds), 44.0);
    
    
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(viewBounds),  CGRectGetHeight(viewBounds))];
    
    [scroll setScrollEnabled:YES];
    [scroll setContentSize:CGSizeMake(CGRectGetWidth(viewBounds), 600)];
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewBounds),  CGRectGetHeight(viewBounds))];
    
    self.tokenField = [[COTokenField alloc] initWithFrame:tokenFieldFrame];
    self.tokenField.tokenFieldDelegate = self;
    self.tokenField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.tokenField addObserver:self forKeyPath:kTokenFieldFrameKeyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    // Configure search table
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                         100,
                                                                         CGRectGetWidth(viewBounds),
                                                                         CGRectGetHeight(viewBounds) - CGRectGetHeight(tokenFieldFrame))
                                                        style:UITableViewStylePlain];
    
    self.searchTableView.opaque = NO;
    self.searchTableView.backgroundColor = [UIColor whiteColor];
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    self.searchTableView.hidden = YES;
    self.searchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    // Create the scroll view
    self.tokenFieldScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewBounds), self.tokenField.computedRowHeight)];
    self.tokenFieldScrollView.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *butUsavContact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [butUsavContact addTarget:self action:@selector(addContactFromAddressBook:)
             forControlEvents:UIControlEventTouchDown];
    [butUsavContact setTitle:NSLocalizedString(@"Address book", nil) forState:UIControlStateNormal];
    //butUsavContact.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    butUsavContact.titleEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    
    butUsavContact.frame = CGRectMake(0, 75, CGRectGetWidth(viewBounds), 15);
    butUsavContact.layer.borderColor = [[UIColor redColor]CGColor];
    
    UIButton *butAddBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [butAddBook addTarget:self action:@selector(addBookPressed:)
         forControlEvents:UIControlEventTouchDown];
    [butAddBook setTitle:NSLocalizedString(@"uSav contact list",nil) forState:UIControlStateNormal];
    
    butAddBook.titleEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    butAddBook.frame = CGRectMake(0, 90, CGRectGetWidth(viewBounds), 15);
    
    self.btnAddBook = butAddBook;
    self.uSavContact = butUsavContact;
    
    [self.tokenFieldScrollView addSubview:self.tokenField];
    [content addSubview:butUsavContact];
    [content addSubview:butAddBook];
    
    [content addSubview:self.searchTableView];
    [content addSubview:self.tokenFieldScrollView];
    [scroll addSubview:content];
    [self.view addSubview:scroll];
    
    UILabel *filename = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(viewBounds), 20)];
    //UILabel *filePath = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, CGRectGetWidth(viewBounds), 20)];
    filename.text = self.fileName;
    //filePath.text = self.filePath;
    [self.view addSubview:filename];
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
}

- (void)viewWillAppear:(BOOL)animated {
#pragma unused (animated)
    [self.tokenField.textField becomeFirstResponder];
}

-(void)listGroup
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarContactList", @"")
                                                  delegate:self];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", client.emailAddress, @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
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

-(void) listGroupResult:(NSDictionary*)obj {
    if (obj == nil) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
         */
        
        [self.navigationController popViewControllerAnimated:YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EditPermissionFailedKey", "")
                                                          message:NSLocalizedString(@"EditPermissionFailedMsg", "")
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
        
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(160, 230)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
	if (obj != nil) {
        NSLog(@"%@ list group result: %@", [self class], obj);
        
        if (([obj objectForKey:@"groupList"] != nil) && ([[obj objectForKey:@"groupList"] count] > 0)) {
            [self.group addObjectsFromArray:[obj objectForKey:@"groupList"]];
            self.groupMember = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < [self.group count]; i++) {
                [self.groupMember addObject:[NSMutableArray arrayWithCapacity:0]];
            }
            
            [self listGroupMemberStatus:[self.group objectAtIndex:groupIndex]];
            
            [self listTrustedContactStatus];
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(160, 230)];
        [wv show:NSLocalizedString(@"FailedToListGroupKey", @"") inView:self.view];
    }
}

-(void)listGroupMemberStatus:(NSString *)groupId
{
    //self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ListGroupMember", @"")
    //                                              delegate:self];
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

-(void) listGroupMemberStatusResult:(NSDictionary*)obj {
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260){
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(160, 230)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"contactList"] != nil)) {
        NSLog(@"%@ list group member result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        NSArray *friendList = [obj objectForKey:@"contactList"];
        for (int i = 0; i < [friendList count]; i++) {
            [[self.groupMember objectAtIndex:groupIndex] addObject:[[friendList objectAtIndex:i] objectForKey:@"friendEmail"]];
        }
        
        if(++groupIndex < [self.group count]) {
            [self listGroupMemberStatus:[self.group objectAtIndex:groupIndex]];
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(160, 230)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
    }
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

-(void) listTrustedContactStatusResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(160, 230)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
	if (obj != nil) {
        NSLog(@"%@ list trust contact result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        if ([obj objectForKey:@"contactList"]) {
            for (id i in [obj objectForKey:@"contactList"]) {
                NSDictionary *d = (NSDictionary *)i;
                [self.friend addObject:[d objectForKey:@"friendEmail"]];
            }
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
        [wv setCenter:CGPointMake(160, 230)];
        [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
    }
}


- (void)layoutTokenFieldAndSearchTable {
    CGRect bounds = self.view.bounds;
    CGRect tokenFieldBounds = self.tokenField.bounds;
    CGRect tokenScrollBounds = tokenFieldBounds;
    CGRect butUsavLocal = CGRectMake(0, butYLocation, 200, 30.0);
    CGRect butAddBook = CGRectMake(0, butYLocation + 40, 200, 30.0);
    
    int tokenY = tokenFieldBounds.size.height;
    //if(tokenY >= 192) tokenY = 192;
    
    if(accY == 0 && tokenY >= 0) {
        accY = 1;
        previouseY = tokenY;
    }
    
    if(accY != 0 && tokenY > previouseY) {
        int differ = tokenY - previouseY;
        int step = 0;
        if(differ < 40) {
            step = 1;
        } else if (differ < 60) {
            step = 2;
        } else if (differ < 80) {
            step = 3;
        } else if (differ < 120) {
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
        
        self.uSavContact.frame =butUsavLocal;
        self.btnAddBook.frame = butAddBook;
        
    }];
    //self.uSavContact.frame =butUsavLocal;
    if (!CGRectIsNull(keyboardFrame_)) {
        CGRect keyboardFrame = [self.view convertRect:keyboardFrame_ fromView:nil];
        CGRect tableFrame = CGRectMake(0,
                                       CGRectGetMaxY(self.tokenFieldScrollView.frame),
                                       CGRectGetWidth(bounds),
                                       CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(self.tokenFieldScrollView.frame));
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
    for (CORecord *record in records) {
        [self.tokenField processToken:record.title associatedRecord:record.person];
    }
}

- (void)keyboardDidShow:(NSNotification *)note {
    keyboardFrame_ = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self layoutTokenFieldAndSearchTable];
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
#pragma unused (tokenField)
    // Split the search results into one email value per row
    NSMutableArray *results = [NSMutableArray new];
#if TARGET_IPHONE_SIMULATOR
    for (int i=0; i<4; i++) {
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
#pragma unused (tokenField)
    // Split the search results into one email value per row
    
    NSMutableArray *results = [NSMutableArray new];
#if TARGET_IPHONE_SIMULATOR
    for (int i=0; i<4; i++) {
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
    
    int len = [self.group count];
    for (int i = 0; i < len; i++) {
        NSString *groupName = [self.group objectAtIndex:i];
        if([groupName rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound) {
            NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"uSav Group", kCORecordFullName,
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
    
    int len = [self.group count];
    for (int i = 0; i < len; i++) {
        NSString *friendEmail = [self.friend objectAtIndex:i];
        if([friendEmail rangeOfString:text options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound) {
            NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"uSav Friend", kCORecordFullName,
                                   @"", kCORecordEmailLabel,
                                   friendEmail, kCORecordEmailAddress,
                                   nil, kCORecordRef,
                                   nil];
            [results addObject:entry];
        }
    }
    return results;
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
#pragma unused (peoplePicker, person)
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
#pragma unused (peoplePicker)
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, identifier));
    CFRelease(multi);
    
    COPerson *record = [[COPerson alloc] initWithABRecordRef:person];
    
    [self.tokenField processToken:email associatedRecord:record];
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
#pragma unused (peoplePicker)
    [self dismissModalViewControllerAnimated:YES];
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
    cell.nameLabel.text = [result objectForKey:kCORecordFullName];
    cell.emailLabelLabel.text = [result objectForKey:kCORecordEmailLabel];
    cell.emailAddressLabel.text = [result objectForKey:kCORecordEmailAddress];
    cell.associatedRecord = [result objectForKey:kCORecordRef];
    
    [cell adjustLabels];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    COEmailTableCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    [self.tokenField processToken:cell.emailAddressLabel.text associatedRecord:cell.associatedRecord];
}

@end

// =============================================================================

@implementation COTokenField
COSynth(tokenFieldDelegate)
COSynth(textField)
COSynth(addContactButton)
COSynth(tokens)
COSynth(selectedToken)

static NSString *kCOTokenFieldDetectorString = @"\u200B";

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tokens = [NSMutableArray new];
        self.opaque = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        // Setup contact add button
        self.addContactButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        self.addContactButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        
        [self.addContactButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect buttonFrame = self.addContactButton.frame;
        self.addContactButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldPaddingX,
                                                 CGRectGetHeight(self.bounds) - CGRectGetHeight(buttonFrame) - kTokenFieldPaddingY,
                                                 buttonFrame.size.height,
                                                 buttonFrame.size.width);
        [self.addContactButton setHidden:YES];
        [self addSubview:self.addContactButton];
        
        // Setup text field
        CGFloat textFieldHeight = self.computedRowHeight;
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kTokenFieldPaddingX,
                                                                       (CGRectGetHeight(self.bounds) - textFieldHeight) / 2.0,
                                                                       CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldPaddingX * 3.0,
                                                                       textFieldHeight)];
        self.textField.opaque = NO;
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.font = [UIFont systemFontOfSize:kTokenFieldFontSize];
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.text = kCOTokenFieldDetectorString;
        self.textField.delegate = self;
        
        [self.textField addTarget:self action:@selector(tokenInputChanged:) forControlEvents:UIControlEventEditingChanged];
        
        [self addSubview:self.textField];
        
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
    self.textField.frame = textFieldFrame;
    
    CGRect tokenFieldFrame = self.frame;
    CGFloat minHeight = MAX(rowHeight, CGRectGetHeight(self.addContactButton.frame) + (CGFloat)kTokenFieldPaddingY * 2.0f);
    tokenFieldFrame.size.height = MAX(minHeight, CGRectGetMaxY(textFieldFrame) + (CGFloat)kTokenFieldPaddingY);
    
    self.frame = tokenFieldFrame;
}

- (void)selectToken:(COToken *)token {
    @synchronized (self) {
        if (token != nil) {
            self.textField.hidden = YES;
        }
        else {
            self.textField.hidden = NO;
            [self.textField becomeFirstResponder];
        }
        self.selectedToken = token;
        for (COToken *t in self.tokens) {
            t.highlighted = (t == token);
            [t setNeedsDisplay];
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

- (void)processToken:(NSString *)tokenText associatedRecord:(COPerson *)record {
    COToken *token = [COToken tokenWithTitle:tokenText associatedObject:record container:self];
    [token addTarget:self action:@selector(selectToken:) forControlEvents:UIControlEventTouchUpInside];
    [self.tokens addObject:token];
    self.textField.text = kCOTokenFieldDetectorString;
    [self setNeedsLayout];
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



- (void)tokenInputChanged:(id)sender {
#pragma unused (sender)
    NSString *searchText = self.textWithoutDetector;
    NSArray *matchedRecords = [NSArray array];
    id<COTokenFieldDelegate> tokenFieldDelegate = self.tokenFieldDelegate;
    if (searchText.length > 2) {
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.hidden) {
        return NO;
    }
    NSString *text = self.textField.text;
    if ([text length] > 1) {
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
    if (self.highlighted) {
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
    
    if (self.highlighted) {
        [[UIColor colorWithRed:0.275f green:0.478f blue:0.871f alpha:1.0f] set];
    }
    else {
        [[UIColor colorWithRed:0.667f green:0.757f blue:0.914f alpha:1.0f] set];
    }
    
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.5, 0.5) cornerRadius:radius];
    [path setLineWidth:1.0];
    [path stroke];
    
    if (self.highlighted) {
        [[UIColor whiteColor] set];
    }
    else {
        [[UIColor blackColor] set];
    }
    
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
        self.emailLabelLabel.font = [UIFont boldSystemFontOfSize:14];
        self.emailLabelLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        self.emailLabelLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        self.emailAddressLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.emailAddressLabel.font = [UIFont systemFontOfSize:14];
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
