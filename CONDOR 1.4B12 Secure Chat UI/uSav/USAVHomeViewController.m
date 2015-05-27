//
//  USAVHomeViewController.m
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVHomeViewController.h"
#import "USAVClient.h"
#import "WarningView.h"
#import "KKPasscodeLock.h"
#import "API.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"
#import "USAVLock.h"

@interface USAVHomeViewController ()
@property (nonatomic) NSInteger switchToFunction;
@property (nonatomic, strong) UIBarButtonItem *rightBarLoginBtn;
@property (nonatomic, strong) UIBarButtonItem *rightBarLogoutBtn;
@property (nonatomic) BOOL *forceUpdate;
@property (nonatomic) BOOL clicked;
@end

#define HOME_NONE_SELECTED           0
#define HOME_GUIDED_ENCRYPT_SELECTED 1
#define HOME_GUIDED_DECRYPT_SELECTED 2
#define HOME_EXPERT_MODE_SELECTED    3

@implementation USAVHomeViewController

@synthesize switchToFunction;
@synthesize rightBarLoginBtn;
@synthesize rightBarLogoutBtn;
@synthesize guidedEncryptShareLabel;
@synthesize guidedDecryptViewLabel;
@synthesize expertModeLabel;
@synthesize companyLabel;

- (IBAction)infoButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"helpViewerSegue" sender:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.guidedEncryptShareLabel.text = NSLocalizedString(@"GuidedEncryptShareKey", @"");
        self.guidedDecryptViewLabel.text =  NSLocalizedString(@"GuidedDecryptViewKey", @"");
        self.expertModeLabel.text =  NSLocalizedString(@"ExpertModeKey", @"");
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            // OK
            [USAVClient current].userHasLogin = NO;
            [USAVClient current].emailAddress = nil;
            [self enableLoginBtn];
            [[USAVLock defaultLock] setUserLoginOff];
        }
    }
}

- (void)logoutBarBtnPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LogoutKey", @"") message:NSLocalizedString(@"AreYouSureKey", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"YesKey", @""), nil];
    [alert setTag:1];
    [alert show];
}

- (void)loginBarBtnPressed:(id)sender {
    [self performLogin];
}

-(void)enableLogoutBtn
{
    [self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
}

-(void)enableLoginBtn
{
    [self.navigationItem setRightBarButtonItem:self.rightBarLoginBtn];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"LoginSegue"]) {
        USAVLoginViewController *loginViewController = [segue destinationViewController];
        loginViewController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"ManageSegue"]) {
    }
    else if ([[segue identifier] isEqualToString:@"GuidedEncryptSegue"]) {
        USAVGuidedEncryptViewController *encryptViewController = [segue destinationViewController];
        encryptViewController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"GuidedDecryptSegue"]) {
        // no need to set delegate, the tab view controller alwasy call the client.homeViewController
    }
    
    else if ([segue.identifier isEqualToString:@"helpViewerSegue"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        // NSURL *indexFileURL = [bundle URLForResource:@"HelpIndex" withExtension:@"html"];
        NSString *filePath = [bundle pathForResource:NSLocalizedString(@"LanguageCode", @"") ofType:@"html"];
        USAVFileViewerViewController *vc = [segue destinationViewController];
        vc.fullFilePath = filePath;
        vc.delegate = self;
    }
}

-(void)done:(USAVFileViewerViewController *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)performLogin
{
    USAVClient *client = [USAVClient current];
    
    if (![[USAVLock defaultLock] isLogin]) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"AlreadyLoginKey", @"") inView:self.view];
        
        [self performSelector: @selector(loginSucceeded:) withObject:nil afterDelay:0.5f];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.clicked = false;
    if (![[USAVLock defaultLock] isLogin]) {
        if ([[USAVLock defaultLock] isLogin]) {
            [self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
        } else {
            [self.navigationItem setRightBarButtonItem:self.rightBarLoginBtn];
        }
        
        [self.view setNeedsDisplay];
    }
}

- (void)viewDidLoad
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    BOOL isAtLeast6 = [version floatValue]  < 7.0;
    if (isAtLeast6) {
    CGRect newFrame = self.btnEncrypt.frame;
    newFrame.origin.y -= 60;
    self.btnEncrypt.frame = newFrame;
  
    newFrame = self.btnDecrypt.frame;
    newFrame.origin.y -= 60;
    self.btnDecrypt.frame = newFrame;
    
    newFrame = self.btnSetting.frame;
    newFrame.origin.y -= 60;
    self.btnSetting.frame = newFrame;
    
    newFrame = self.guidedDecryptViewLabel.frame;
    newFrame.origin.y -= 60;
    self.guidedDecryptViewLabel.frame = newFrame;
    
    newFrame = self.guidedEncryptShareLabel.frame;
    newFrame.origin.y -= 60;
    self.guidedEncryptShareLabel.frame = newFrame;
    
    newFrame = self.expertModeLabel.frame;
    newFrame.origin.y -= 60;
    self.expertModeLabel.frame = newFrame;
    }
    
    [self checkUpdates];
    [super viewDidLoad];
    
    self.clicked = false;
    [USAVClient current].homeViewController = self;
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"homebackground.png"]];
    self.view.backgroundColor = background;
    
    self.guidedDecryptViewLabel.text = NSLocalizedString(@"QuickDecrypt", @"");
    self.guidedEncryptShareLabel.text = NSLocalizedString(@"QuickEncrypt", @"");
    self.expertModeLabel.text = NSLocalizedString(@"FullFeature", @"");
    
    self.rightBarLoginBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LoginKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(loginBarBtnPressed:)];
    self.rightBarLogoutBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LogoutKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(logoutBarBtnPressed:)];
    
    if ([[USAVLock defaultLock] isLogin]) {
        [self.navigationItem setRightBarButtonItem:self.rightBarLogoutBtn];
    } else {
        [self.navigationItem setRightBarButtonItem:self.rightBarLoginBtn];
    }
    /*
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    CGRect lblFrame = CGRectMake(self.companyLabel.frame.origin.x , screenHeight - 90.0, self.companyLabel.frame.size.width, self.companyLabel.frame.size.height);
    
    self.companyLabel.frame = lblFrame;*/
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)checkUpdates {
    USAVClient *client = [USAVClient current];
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement;
    
    paramElement = [GDataXMLNode elementWithName:@"os" stringValue:@"IOS"];
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSLog(@"getParam encoding: raw:%@", requestElement);
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api checkClientUpdate:encodedGetParam target:(id)self selector:@selector(checkUpdatesResult:)];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
     if (self.forceUpdate = true) {
     return;
     } else {
     
     }
     */
}

- (void)checkUpdatesResult:(NSDictionary*)obj {
    /*if (obj == nil) {
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
     
     return;
     }
     
     if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
     return;
     }
     */
    if (obj != nil) {
        
        //force update
        if ([[obj objectForKey:@"leastVersionCode"] integerValue] > [NSLocalizedString(@"versionNumber", @"") integerValue]) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[obj objectForKey:@"releaseNote"] message:@"You must upgrade uSav in App Store before using." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            
            self.forceUpdate = true;
            
            [alert show];
        }
        
        else if ([[obj objectForKey:@"versionCode"] integerValue] > [NSLocalizedString(@"versionNumber", @"") integerValue]) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[obj objectForKey:@"releaseNote"] message:@"You can upgrade uSav now in App Store" delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OkKey", @""),nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Success!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];*/
            /*
             UITextField *alertTextField = [alert textFieldAtIndex:0];
             alertTextField.keyboardType = UIKeyboardTypeDefault;
             alertTextField.placeholder = NSLocalizedString(@"Update", @"");
             alertTextField.text = [obj objectForKey:@"releaseNote"];
             self.forceUpdate = false;*/
            //self.aliasHolder = nil;po
            //self.inEditNote = true;
            [alert show];
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListGroupKey", @"") inView:self.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginSucceeded:(id)obj
{
    // DY: go to the originally selected function
    
    switch (switchToFunction) {
        case HOME_NONE_SELECTED:
        {
            
        }
            break;
        case HOME_GUIDED_ENCRYPT_SELECTED:
        {
            [self performSegueWithIdentifier:@"GuidedEncryptSegue" sender:self];
        }
            break;
        case HOME_GUIDED_DECRYPT_SELECTED:
        {
            [self performSegueWithIdentifier:@"GuidedDecryptSegue" sender:self];
        }
            break;
        case HOME_EXPERT_MODE_SELECTED:
        {
            [self performSegueWithIdentifier:@"ManageSegue" sender:self];
        }
            break;
        default:
            break;
    }
}


// delegate to LoginView
-(void)loginResult:(BOOL)success
            target:(USAVLoginViewController *)sender
{
    if (success == TRUE) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"LoginSucceededKey", @"") inView:self.view];
        
        [self enableLogoutBtn];
        [self performSelector: @selector(loginSucceeded:) withObject:nil afterDelay:0.5f];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"LoginFailedKey", @"") inView:self.view];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

// delegate to LoginView
-(void)loginCancelled:(USAVLoginViewController *)sender
{
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"LoginCancelledKey", @"") inView:self.view];
    [self dismissModalViewControllerAnimated:YES];
}

// delegate to FileView
-(void)fileViewGoHome:(USAVFileViewController *)sender
{
    if ([USAVClient current].userHasLogin) [self enableLogoutBtn];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)guidedEncryptBtnPressed:(id)sender {
    // [[DNGClient current] playClick];
    if (self.clicked) {
        return;
    }
    
    self.clicked = true;
    [[USAVClient current] playClick];
    self.switchToFunction = HOME_GUIDED_ENCRYPT_SELECTED;
    
    if ([[USAVLock defaultLock] isLogin]) {
        [self performSelector: @selector(loginSucceeded:) withObject:nil afterDelay:0.5f];
    } else {
        [self performLogin];
    }
}

- (IBAction)guidedDecryptBtnPressed:(id)sender {
    if (self.clicked) {
        return;
    }
    
    self.clicked = true;
    [[USAVClient current] playClick];
    self.switchToFunction = HOME_GUIDED_DECRYPT_SELECTED;
    
    if ([[USAVLock defaultLock] isLogin]) {
        [self performSelector: @selector(loginSucceeded:) withObject:nil afterDelay:0.5f];
    } else {
        [self performLogin];
    }
}

- (IBAction)expertModeBtnPressed:(id)sender {
    if (self.clicked) {
        return;
    }
    
    self.clicked = true;
    [[USAVClient current] playClick];
    self.switchToFunction = HOME_EXPERT_MODE_SELECTED;
    
    if ([[USAVLock defaultLock] isLogin]) {
        [self performSelector: @selector(loginSucceeded:) withObject:nil afterDelay:0.5f];
    } else {
        [self performLogin];
    }
}

- (void)viewDidUnload {
    [self setGuidedEncryptShareLabel:nil];
    [self setGuidedDecryptViewLabel:nil];
    [self setExpertModeLabel:nil];
    [self setCompanyLabel:nil];
    [super viewDidUnload];
}

@end
