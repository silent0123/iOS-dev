//
//  USAVAddContactView.m
//  uSAV
//
//  Created by young dennis on 2/9/12.
//
//

#import "USAVAddContactView.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"

@interface USAVAddContactView()
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) NSMutableArray *penSizeCheckBoxButtonArray;
@property (nonatomic, strong) NSMutableArray *penStyleCheckBoxButtonArray;
@property (nonatomic, strong) NSMutableArray *strokeSizeArray;

@property (nonatomic, strong) UITextField *contactNameTextField;
@property (nonatomic, strong) UITextField *aliasNameTextField;
@property (nonatomic, strong) UITextField *emailAddressTextField;
@end

@implementation USAVAddContactView

@synthesize saveBtn;
@synthesize cancelBtn;
@synthesize delegate;
// @synthesize initialPenSize;
// @synthesize initialPenStyle;

@synthesize contactNameTextField;
@synthesize aliasNameTextField;
@synthesize emailAddressTextField;

@synthesize penSizeCheckBoxButtonArray;
@synthesize penStyleCheckBoxButtonArray;
@synthesize strokeSizeArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.cancelBtn addTarget:self
                           action:@selector(cancelBtnPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.cancelBtn setTitle:NSLocalizedString(@"CancelKey", @"") forState:UIControlStateNormal];
        self.cancelBtn.frame = CGRectMake(40.0, 20.0, 60.0, 34);
        [self addSubview:self.cancelBtn];
        
        self.saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.saveBtn addTarget:self
                   action:@selector(saveBtnPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.saveBtn setTitle:NSLocalizedString(@"SaveKey", @"") forState:UIControlStateNormal];
        self.saveBtn.frame = CGRectMake(220.0, 20.0, 60.0, 34);
        [self addSubview:self.saveBtn];
        
        self.contactNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 80.0, 220.0, 30.0)];
        self.contactNameTextField.delegate = self;
        self.contactNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.contactNameTextField.placeholder = NSLocalizedString(@"AddContactUserNameKey", @"");
        [self addSubview:self.contactNameTextField];
        
        self.aliasNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 120.0, 220.0, 30.0)];
        self.aliasNameTextField.delegate = self;
        self.aliasNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.aliasNameTextField.placeholder = NSLocalizedString(@"AddContactAliasKey", @"");
        [self addSubview:self.aliasNameTextField];
        
        self.emailAddressTextField = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 160.0, 220.0, 30.0)];
        self.emailAddressTextField.delegate = self;
        self.emailAddressTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.emailAddressTextField.placeholder = NSLocalizedString(@"AddContactEmailAddressKey", @"");
        [self addSubview:self.emailAddressTextField];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) addContactResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupResult: %@", obj);
        
        NSInteger rc = [[obj objectForKey:@"statusCode"] integerValue];  // if statusCode doesn't exist, we assume rc is 0
        switch (rc) {
            case SUCCESS:
            {
                [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                return;
            }
                break;
            case INVALID_FD_ALIAS:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"AliasNameInvalidKey", @"") inView:self];
                return;
            }
                break;
            case INVALID_EMAIL:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"EmailNameInvalidKey", @"") inView:self];
                return;
            }
                break;
            case FRIEND_EXIST:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"FriendNameAlreadyExistKey", @"") inView:self];
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
    [wv show:NSLocalizedString(@"AddTrustContactUnknownErrorKey", @"") inView:self];
    
}

-(void) addContactBuildRequest:(NSString *)friendName alias:(NSString *)aliasName email:(NSString *)emailAddress {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", aliasName, @"\n", emailAddress, @"\n", friendName, @"\n"];
    
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
    paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:aliasName];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"email" stringValue:emailAddress];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addTrustContact:encodedGetParam target:(id)self selector:@selector(addContactResult:)];
}


- (void)saveBtnPressed:(id)sender {
    if (([self.contactNameTextField.text length] < 1) ||
        ([self.aliasNameTextField.text length] < 1) ||
        ([self.emailAddressTextField.text length] < 1))
    {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"AddContactTextFieldEmptyKey", @"") inView:self];
        return;
    }
    
    [self addContactBuildRequest:self.contactNameTextField.text alias:self.aliasNameTextField.text email:self.emailAddressTextField.text];
}

- (void)cancelBtnPressed:(id)sender {
    [delegate addContactViewCancelCmd:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
