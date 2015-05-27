//
//  USAVLoginViewController.m
//  uSav

//  Created by young dennis on 3/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVLoginViewController.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
// #import "USAVFileViewController.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"
#import "USAVLock.h"

@interface USAVLoginViewController ()
@property (nonatomic) BOOL saveInfoFlag;
@property (nonatomic) BOOL autoLoginFlag;
@property (nonatomic) BOOL displayPasswordFlag;
@property (nonatomic) BOOL isLoginState;

@property (nonatomic) BOOL isNetworkOK;
@property (nonatomic, strong) UILabel *networkStatusLabel;
@property (nonatomic) BOOL locked;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, assign) BOOL hasMovedUp;
@end

@implementation USAVLoginViewController

@synthesize topLabel;
@synthesize userEmailTextField;
@synthesize passwordTextField;
@synthesize displayPwBtn;
@synthesize displayPwLabel;
@synthesize reenterPwTextField;
@synthesize askToRegisterBtn;
@synthesize loginRegBtn;
@synthesize saveInfoFlag;
@synthesize autoLoginFlag;
@synthesize displayPasswordFlag;

@synthesize securityAnswerTextField;
@synthesize securityQuestionTextField;
@synthesize loginObj;   // pass in from caller optionally
@synthesize autologinFailMsg;
@synthesize scrollView;
@synthesize contentView;
@synthesize naviBar;
@synthesize alert = _alert;
@synthesize delegate;
@synthesize userNameTxt = _userNameTxt;
@synthesize isLoginState;


 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
 if ([[segue identifier] isEqualToString:@"Tutorial"]) {
 // USAVManageTableViewController *manageTVC = [segue destinationViewController];
 }
     
 }


- (IBAction)forgetPasswordPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://usav-new.azurewebsites.net/%@/password",NSLocalizedString(@"LanguageCode", @"")]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //cell is the TableView's cell
    
    //self.locked = false;
    
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Function_bg"]];
    
    self.securityAnswerTextField.hidden = true;
    self.securityQuestionTextField.hidden = true;
    self.userNameTxt.hidden = true;
    
    [self.naviBar.topItem setTitle:NSLocalizedString(@"appTitleKey", @"")];
    self.ReEmail.hidden = true;
    
    self.topLabel.text = NSLocalizedString(@"LoginColonKey", @"");
    [self.userEmailTextField setPlaceholder:NSLocalizedString(@"RegisterEmail", @"")];
    [self.passwordTextField setPlaceholder:NSLocalizedString(@"PasswordPlaceholderKey", @"")];
    [self.reenterPwTextField setPlaceholder:NSLocalizedString(@"RetypePwPlaceholderKey", @"")];
    
    [self.securityQuestionTextField setPlaceholder:NSLocalizedString(@"SecurityQuestionPlaceholderKey", @"")];
    [self.securityAnswerTextField setPlaceholder:NSLocalizedString(@"SecurityAnswerPlaceholderKey", @"")];
    [self.displayPwLabel setText:NSLocalizedString(@"DisplayPasswordLabelKey", @"")];
    [self.askToRegisterBtn setTitle:NSLocalizedString(@"AskToRegiserBtnKey", @"") forState:UIControlStateNormal];
    [self.userNameTxt setPlaceholder:NSLocalizedString(@"UserNamePlaceholderKey", @"")];
    [self.ReEmail setPlaceholder:NSLocalizedString(@"RetypePassword", @"")];
    [self.ReEmail setKeyboardType: UIKeyboardTypeEmailAddress];
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    /*[self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView addSubview:self.view];*/
    self.scrollView.scrollEnabled = YES;
    
    self.userEmailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.reenterPwTextField.delegate = self;
    self.userNameTxt.delegate = self;
    self.ReEmail.delegate = self;
    
    self.securityQuestionTextField.delegate = self;
    self.securityAnswerTextField.delegate = self;

    if ([[USAVClient current] emailAddress] != nil) {
        self.userEmailTextField.text = [[USAVClient current] emailAddress];
    }
    
    //按钮样式
    [self.loginRegBtn setTitle:NSLocalizedString(@"SubmitKey", @"") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:NSLocalizedString(@"CancelKey", @"") forState:UIControlStateNormal];
    // [self.loginRegBtn setEnabled:NO];
    // [self.loginRegBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.isLoginState = TRUE;
//    self.loginRegBtn.titleLabel.textColor = [UIColor whiteColor];
//    self.askToRegisterBtn.titleLabel.textColor = [UIColor whiteColor];
//    self.btnForgetPassword.titleLabel.textColor = [UIColor whiteColor];
//    [self.loginRegBtn setBackgroundColor:[UIColor colorWithRed:(30/255) green:(144/255) blue:(255/255) alpha:0.5]];
//    [self.askToRegisterBtn setBackgroundColor:[UIColor colorWithRed:(30/255) green:(144/255) blue:(255/255) alpha:0.5]];
//    [self.btnForgetPassword setBackgroundColor:[UIColor colorWithRed:(30/255) green:(144/255) blue:(255/255) alpha:0.5]];

    [self.loginRegBtn.layer setMasksToBounds:YES];
    [self.askToRegisterBtn.layer setMasksToBounds:YES];
    [self.btnForgetPassword.layer setMasksToBounds:YES];
    [self.loginRegBtn.layer setCornerRadius:4];
    [self.askToRegisterBtn.layer setCornerRadius:4];
    [self.btnForgetPassword.layer setCornerRadius:4];
    
    // init the Display password setting to hide password
    [self.displayPwBtn setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"] forState:UIControlStateNormal];
    self.displayPasswordFlag = FALSE;
    self.passwordTextField.secureTextEntry = TRUE;
    self.reenterPwTextField.secureTextEntry = TRUE;
    
    
    //增加Keyboard监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.hasMovedUp = NO;
    //增加单击监听
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissKeyboard)];
    [self.scrollView addGestureRecognizer:tapRec];
    [tapRec setNumberOfTapsRequired:1];
    [tapRec setNumberOfTouchesRequired:1];
    
    // initially always show login screen, so hide nickname and move some buttons up
    /*
    CGRect frame;
    frame = self.reenterPwTextField.frame;
    frame.size.height = 0.0f;
    self.reenterPwTextField.frame = frame;
    
    
    frame = self.userNameTxt.frame;
    frame.size.height = 0.0f;
    self.userNameTxt.frame = frame;
     
    frame = self.securityQuestionTextField.frame;
    frame.size.height = 0.0f;
    self.securityQuestionTextField.frame = frame;
     
    frame = self.securityAnswerTextField.frame;
    frame.size.height = 0.0f;
    self.securityAnswerTextField.frame = frame;
    
    
    frame = self.loginRegBtn.frame;
    frame.origin.y -= 60.0;
    self.loginRegBtn.frame = frame;
    
    frame = self.cancelBtn.frame;
    frame.origin.y -= 60.0;
    self.cancelBtn.frame = frame;
    
    frame = self.askToRegisterBtn.frame;
    frame.origin.y -= 60.0;
    self.askToRegisterBtn.frame = frame;
    */
    if (self.autologinFailMsg != nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:self.autologinFailMsg inView:self.view];
    }
    
    
    
    // USAVClient *client = [USAVClient current];
    
    // setup the UI
    // self.usernameTextField.text = [client username];
    // self.passwordTextField.text = [client password];
    
    /*
     if ([[client autoLoginFlag] boolValue]) {
     [self.autoLoginBtn setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState: UIControlStateNormal];
     self.autoLoginFlag = TRUE;
     }
     else {
     [self.autoLoginBtn setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"] forState:UIControlStateNormal];
     self.autoLoginFlag = FALSE;
     }
     
     if ([[client saveInfoFlag] boolValue]) {
     [self.saveLoginInfoBtn setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState:UIControlStateNormal];
     self.saveInfoFlag = TRUE;
     }
     else {
     [self.saveLoginInfoBtn setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"] forState:UIControlStateNormal];
     self.saveInfoFlag = FALSE;
     }
     */
    [self.txtPassRecv setTitle:NSLocalizedString(@"ForgetPasswrod", @"") forState:nil];
    //[self performSegueWithIdentifier:@"Tutorial" sender:self];
}

- (void)dissmissKeyboard {
    [self.ReEmail resignFirstResponder];
    [self.userEmailTextField resignFirstResponder];
    [self.reenterPwTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}
/*
 - (void) reachabilityChanged: (NSNotification* )note
 {
 Reachability* curReach = [note object];
 NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
 [self updateInterfaceWithReachability: curReach];
 }
 
 - (NSString *)getNetworkStatusString:(Reachability*) curReach
 {
 NetworkStatus netStatus = [curReach currentReachabilityStatus];
 switch (netStatus)
 {
 case NotReachable:
 {
 return @"Server Not Reachable";
 }
 case ReachableViaWWAN:
 {
 return @"Reachable Via WWAN";
 }
 case ReachableViaWiFi:
 {
 return @"Reachable Via WiFi";
 }
 }
 return @"";
 }
 
 - (void) updateInterfaceWithReachability: (Reachability*) curReach
 {
 NetworkStatus netStatus = [curReach currentReachabilityStatus];
 NSLog(@"Network status:curReach:%@", [self getNetworkStatusString:curReach]);
 
 if (curReach == self.hostReach) {
 if (netStatus == NotReachable) {
 self.networkStatusLabel.hidden = NO;
 self.is         NetworkOK = NO;
 }
 else {
 self.isNetworkOK = YES;
 self.networkStatusLabel.hidden = YES;
 }
 }
 }
 */
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    //CGRect keyboardRect = [aValue CGRectValue];
    //hasMovedUp防止重复升高
    if (!self.hasMovedUp) {
        [self animateView:self.view up:YES forHeight:70];
        self.hasMovedUp = YES;
    }
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification {

    if (self.hasMovedUp) {
        [self animateView:self.view up:NO forHeight:70];
        self.hasMovedUp = NO;
    }
    
    
}

#pragma mark 上下移动和半透明函数
- (void)animateView: (UIView *)view up:(BOOL)up forHeight: (CGFloat)distance {
    
    //移动参数
    NSInteger movementDistance = distance;
    NSInteger movementDuration = 1.0f;
    NSInteger movement = (up ? -movementDistance : movementDistance);
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height + movement);
    [UIView commitAnimations];  //结束
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // [self.usernameTextField becomeFirstResponder];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [super viewDidAppear:animated];
    
    [self.view.window setUserInteractionEnabled:YES];
}

- (void)viewDidUnload
{
    [self setUserEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setDisplayPwBtn:nil];
    [self setDisplayPwLabel:nil];
    [self setAskToRegisterBtn:nil];
    [self setReenterPwTextField:nil];
    [self setLoginRegBtn:nil];
    [self setTopLabel:nil];
    [self setScrollView:nil];
    [self setContentView:nil];
    
    [self setSecurityQuestionTextField:nil];
    [self setSecurityAnswerTextField:nil];
    [self setNaviBar:nil];
    [self setCancelBtn:nil];
    
    [self setUserNameTxt:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)isValidQuestion: (NSString *) question
{
    if ([question length] < 10 || [question length] > 99) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.{10,99}$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:question options:0 range:NSMakeRange(0, [question length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [question length]) {
        return false;
    }
    return true;
}

- (BOOL)isValidAnswer: (NSString *) answer
{
    if ([answer length] < 5 || [answer length] > 49) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.{5,49}$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:answer options:0 range:NSMakeRange(0, [answer length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [answer length]) {
        return false;
    }
    
    return true;
}

- (BOOL)isValidUserName: (NSString *) username
{
    if ([username length] < 5 || [username length] > 99) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9]{5,99}$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:username options:0 range:NSMakeRange(0, [username length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [username length]) {
        return false;
    }
    return true;
}

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

- (BOOL)isValidPassword: (NSString *) email
{
    //查找是否包括空格和回车
    NSRange rangeOfSpace = [email rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //查找是否包括汉字
    for (NSInteger i = 0; i < [email length]; i ++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [email substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3)
        {
            return false;
        }
    }
    
    
    if ([email length] < 8 || [email length] > 49 || rangeOfSpace.length > 0) {
        return false;
    }
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*[a-zA-Z].*\\d.*)|(.*\\d.*[a-zA-Z].*)$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    /*
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
     return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
     } else {
     return YES;
     }
     */
}

- (BOOL)checkAndEnableSubmitBtn {
    if (self.isLoginState) {
        if (([self.userEmailTextField.text length] > 5) &&
            ([self.passwordTextField.text length] > 5)) {
            [self.loginRegBtn setEnabled:YES];
            [self.loginRegBtn setTitleColor:[UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0] forState:UIControlStateNormal];
            return TRUE;
        }
        else {
            [self.loginRegBtn setEnabled:NO];
            [self.loginRegBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            return FALSE;
        }
    }
    else {
        if (([self.userEmailTextField.text length] > 5) &&
            ([self.passwordTextField.text length] > 5) &&
            ([self.reenterPwTextField.text length] > 5)) {
            [self.loginRegBtn setEnabled:YES];
            [self.loginRegBtn setTitleColor:[UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0] forState:UIControlStateNormal];
            return TRUE;
        }
        else {
            [self.loginRegBtn setEnabled:NO];
            [self.loginRegBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            return FALSE;
        }
    }
}

-(void) checkUsernameExistResultCallback:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    if ((obj != nil) &&
        ([obj objectForKey:@"httpErrorCode"] == nil)) {
        // normal/good case
        NSLog(@"%@ checkUsernameCallback: resp: %@", [self class], obj);
        
        NSString *rawStringStatus = [obj objectForKey:@"rawStringStatus"];
        NSInteger rawStatus = [rawStringStatus integerValue];
        if (rawStatus == ACC_EXIST) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"UserNameTakenKey", @"") inView:self.view];
        }
        else { // user name is valid
            [self.userEmailTextField resignFirstResponder];
        }
        return;
    }
    
    if (obj == nil) {
        NSLog(@"%@: resp is nil", [self class]);
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        NSLog(@"%@: http error code: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    }
}

-(void) checkUsernameExist:(NSString *)str
{
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * param1Element = [GDataXMLNode elementWithName:@"accountId" stringValue:self.userEmailTextField.text];
    GDataXMLElement * param2Element = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:param1Element];
    [requestElement addChild:param2Element];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    USAVClient *client = [USAVClient current];
    [client.api checkUsernameExist:encodedGetParam target:self selector:@selector(checkUsernameExistResultCallback:)];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*
     if ((textField == self.usernameTextField) && [textField.text length] < 5) {
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"Use6orMoreCharsKey", @"") inView:self.view];
     return FALSE;
     }
     
     if ((textField == self.passwordTextField) && [textField.text length] < 8) {
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"Use6orMoreCharsKey", @"") inView:self.view];
     return FALSE;
     }
     
     if ((textField == self.reenterPwTextField) && [textField.text length] < 8) {
     WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
     [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
     [wv show:NSLocalizedString(@"Use6orMoreCharsKey", @"") inView:self.view];
     return FALSE;
     }
     
     if ((textField == self.usernameTextField) && (self.isLoginState == FALSE)) {
     [self checkUsernameExist:self.usernameTextField.text];
     return FALSE;
     }
     */
    // [self checkAndEnableSubmitBtn];
    [textField resignFirstResponder];
    return YES;
}

-(void)getAccountInfoResultCallback:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    // get GetAccountInfo as if Login has occured
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        return;
    }
    
    if ((obj != nil) &&
        ([obj objectForKey:@"httpErrorCode"] == nil)) {
        // normal/good case
        NSLog(@"%@: getAccountInfoResultCallback: resp: %@", [self class], obj);
        
        NSString *statusCodeStr = [obj objectForKey:@"statusCode"];
        NSInteger statusCode = [statusCodeStr integerValue];
        
        switch (statusCode) {
            case SUCCESS:
            {
                // get GetAccountInfo as if Login has occured
                
                [[USAVClient current] setPassword:self.passwordTextField.text];
                
                //---------- 版本更新需要, 首次更新登陆完成后，移动文件系统
                if (![[USAVClient current] uId]){
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                                         NSDocumentDirectory, NSUserDomainMask, YES);
                    NSLog(@"document paths: %@", paths);
                    
                    NSString *currentPath = [paths objectAtIndex:0];
                   // NSString *basePath = [paths objectAtIndex:0];
                    
                    NSString *newEncryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[obj objectForKey:@"uId"] integerValue], @"Encrypted"];
                    NSString *newDecryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[obj objectForKey:@"uId"] integerValue], @"Decrypted"];
                    NSString *newDecryptCopyPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[obj objectForKey:@"uId"] integerValue], @"DecryptedCopy"];
                    NSString *newPhotoAlbumPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[obj objectForKey:@"uId"] integerValue], @"PhotoAlbum"];
                    
                    NSString *oldEncryptPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"Encrypted"];
                    NSString *oldDecryptPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"Decrypted"];
                    NSString *oldDecryptCopyPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"DecryptedCopy"];
                    NSString *oldPhotoAlbumPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"PhotoAlbum"];

                    [self moveAllFilesFromDirectory:oldEncryptPath toDirectory:newEncryptPath];
                    [self moveAllFilesFromDirectory:oldDecryptPath toDirectory:newDecryptPath];
                    [self moveAllFilesFromDirectory:oldDecryptCopyPath toDirectory:newDecryptCopyPath];
                    [self moveAllFilesFromDirectory:oldPhotoAlbumPath toDirectory:newPhotoAlbumPath];
                }
                
                //uId
                [[USAVClient current] setUId:[[obj objectForKey:@"uId"] integerValue]];
                
                NSString *latestUsername = [obj objectForKey:@"name"];
                NSString *lastUsername = [[USAVClient current] username];
                if(![latestUsername isEqualToString:lastUsername])
                {
                    [self deleteDecryptedFiles];
                }
                
                [[USAVClient current] setUsername:latestUsername];
                [[USAVClient current] setEmailAddress:[obj objectForKey:@"accountId"]];
                [[USAVClient current] setUserHasLogin:YES];
                
                [[USAVLock defaultLock] setUserLoginOn];
                
                //[delegate loginResult:TRUE target:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSucceed" object:self];
                //登陆成功，继续处理之前的文件
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DealInboxFile" object:self];
                [delegate loginResult:YES target:self];
                //[self.fileControllerDelegate showDashBoard];
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                
                [self dismissViewControllerAnimated:NO completion:nil];
            }
                break;
            case DISABLE_USER:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                [wv show:NSLocalizedString(@"DisabledUser", @"") inView:self.view];
                [[USAVClient current] setUserHasLogin:NO];
            }
                break;
            default:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"Authen_Failed", @"") inView:self.view];
                [[USAVClient current] setUserHasLogin:NO];
                //[delegate loginResult:FALSE target:self];
            }
                break;
        }
        return;
    }
    
    if (obj == nil) {
        NSLog(@"%@: resp is nil", [self class]);
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        NSLog(@"%@: http error code: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    }
}

- (void)deleteDecryptedFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    NSString *currentPath = [paths objectAtIndex:0];
   // NSString *encryptPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"Encrypted"];
    NSString *decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Decrypted"];
   //NSString *inboxPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"Inbox"];
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:decryptPath error:nil]];
    for (NSInteger i = 0; i < [allFile count]; i++) {
        //Get one file's full name
        NSString *singleFile = [allFile objectAtIndex:i];
        /*
        if ([[singleFile pathExtension] caseInsensitiveCompare:@"usav-temp"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"IncompleteFile", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
            [alert show];
            //return YES;
        }
        */
        NSError *ferror = nil;
        BOOL frc;
        frc = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",decryptPath, singleFile] error:&ferror];
    }
}

-(void)getAccountInfo
{
    NSString *email = self.userEmailTextField.text;
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", email, @"\n", [[USAVClient current] getDateTimeStr], @"\n", [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] model]], @"\n", [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] name]], @"\n", @"1", @"\n", [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]], @"\n",[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemName]], @"\n"];
    NSString *signature = [[USAVClient current] generateSignature:stringToSign withKey:self.passwordTextField.text];
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:email];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"params" stringValue:@""];
    GDataXMLElement * deviceModel = [GDataXMLNode elementWithName:@"device" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] model]]];
    [paramElement addChild:deviceModel];
    GDataXMLElement * deviceName = [GDataXMLNode elementWithName:@"devicename" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] name]]];
    [paramElement addChild:deviceName];
    GDataXMLElement * loginP = [GDataXMLNode elementWithName:@"login" stringValue:@"1"];
    [paramElement addChild:loginP];
    GDataXMLElement * deviceVersion = [GDataXMLNode elementWithName:@"OSVersion" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]]];
    [paramElement addChild:deviceVersion];
    GDataXMLElement * deviceSystem = [GDataXMLNode elementWithName:@"platform" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemName]]];
    [paramElement addChild:deviceSystem];
    [requestElement addChild:paramElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarLogin", @"")
                                                  delegate:self];
    [[USAVClient current].api getAccountInfo:encodedGetParam target:self selector:@selector(getAccountInfoResultCallback:)];
}

#pragma mark 帐号状态检测
-(void)getAccountLoginStatusInfoForAccount: (NSString *)email AndPassword: (NSString *)password
{
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", email, @"\n", [[USAVClient current] getDateTimeStr], @"\n", [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] model]], @"\n", [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] name]], @"\n", @"1", @"\n", [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]], @"\n",[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemName]], @"\n"];
    
    NSString *signature = [[USAVClient current] generateSignature:stringToSign withKey:password];
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:email];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"params" stringValue:@""];

    GDataXMLElement * deviceModel = [GDataXMLNode elementWithName:@"device" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] model]]];
    [paramElement addChild:deviceModel];
    GDataXMLElement * deviceName = [GDataXMLNode elementWithName:@"devicename" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] name]]];
    [paramElement addChild:deviceName];
    GDataXMLElement * loginP = [GDataXMLNode elementWithName:@"login" stringValue:@"1"];
    [paramElement addChild:loginP];
    GDataXMLElement * deviceVersion = [GDataXMLNode elementWithName:@"OSVersion" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]]];
    [paramElement addChild:deviceVersion];
    GDataXMLElement * deviceSystem = [GDataXMLNode elementWithName:@"platform" stringValue:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemName]]];
    [paramElement addChild:deviceSystem];
    [requestElement addChild:paramElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"Login status detection %@, encoded: %@", getParam, encodedGetParam);
    
    [[USAVClient current].api getAccountInfo:encodedGetParam target:self selector:@selector(getAccountLoginStatusInfoResultCallback:)];
}

-(void)registerResultCallback:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (([obj objectForKey:@"httpErrorCode"] != nil)) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"RegisterUnknownStatusCodeKey", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 120)];
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
    
    
    if ((obj != nil) &&
        ([obj objectForKey:@"httpErrorCode"] == nil)) {
        // normal/good case
        NSLog(@"%@: registerCallback: resp: %@", [self class], obj);
        
        NSString *rawStringStatus = [obj objectForKey:@"rawStringStatus"];
        NSInteger rawStatus = [rawStringStatus integerValue];
        
        switch (rawStatus) {
            case SUCCESS:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Register Account",@"") message:NSLocalizedString(@"RegistrationSuccess", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                //[self dismissViewControllerAnimated:YES completion:nil];
                // get GetAccountInfo as if Login has occured
                self.isLoginState = FALSE;
                [self askToRegisterBtnPressed:self];
                
//                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
//                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
//                [wv show:NSLocalizedString(@"RegisterSuccessKey", @"") inView:self.view];
                
                [USAVClient current].emailAddress = nil;    //注册完成并不准备登陆，不写这两个位置
                [USAVClient current].password = nil;    //注册完成并不准备登陆，不写这两个位置
                
                //成功提示
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
                //[[USAVLock defaultLock] setUserLoginOn];
                //[self getAccountInfo];
            }
                break;
            case TIMESTAMP_OLD:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RegisterTimestampOldKey", @"") inView:self.view];
            }
                break;
            case TIMESTAMP_FUTURE:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RegisterTimestampFutureKey", @"") inView:self.view];
            }
                break;
            case INVALID_ACC_ID:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RegisterInvalidAccIdKey", @"") inView:self.view];
            }
                break;
            case ACC_EXIST:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"UserNameTakenKey", @"") inView:self.view];
            }
                break;
            case UNSECURE_PASSWORD:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RegisterUnsecurePasswordKey", @"") inView:self.view];
            }
                break;
            case INVALID_EMAIL:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RegisterInvalidEmailKey", @"") inView:self.view];
            }
                break;
            case EMAIL_IN_USE:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RegisterEmailInUseKey", @"") inView:self.view];
            }
                break;
            default:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"RegisterUnknownStatusCodeKey", @"") inView:self.view];
            }
                break;
        }
        
        return;
    }
    
    if (obj == nil) {
        NSLog(@"%@: resp is nil", [self class]);
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        NSLog(@"%@: http error code: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    }
}

- (BOOL)getAccountLoginStatusInfoResultCallback: (NSDictionary *)obj {
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        //0表示检测失败
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginStatus" object:[NSNumber numberWithInt:0]];
        return NO;
    }
    
    // get GetAccountInfo as if Login has occured
    if (obj == nil) {
        //0表示检测失败
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginStatus" object:[NSNumber numberWithInt:0]];
        return NO;
    }
    
    if ((obj != nil) &&
        ([obj objectForKey:@"httpErrorCode"] == nil)) {
        // normal/good case
        NSLog(@"%@: getAccountInfoResultCallback: resp: %@", [self class], obj);
        
        NSString *statusCodeStr = [obj objectForKey:@"statusCode"];
        NSInteger statusCode = [statusCodeStr integerValue];
        
        switch (statusCode) {
            case SUCCESS:
            {
                
                //只有1表示检测成功
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginStatus" object:[NSNumber numberWithInt:1]];
                return YES;
            }
                break;
            default:
            {
                
            }
                break;
        }
        //0表示检测失败
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginStatus" object:[NSNumber numberWithInt:0]];
        return NO;
    }
    //0表示检测失败
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginStatus" object:[NSNumber numberWithInt:0]];
    return NO;
}

- (IBAction)askToRegisterBtnPressed:(id)sender {
    [[USAVClient current] playClick];
    if (self.isLoginState == TRUE) {
        [self.btnForgetPassword setHidden:YES];
        self.topLabel.text = NSLocalizedString(@"RegisterColonKey", @"");
        [self.askToRegisterBtn setTitle:NSLocalizedString(@"GoBackToLoginBtnKey", @"") forState:UIControlStateNormal];
        [self.loginRegBtn setTitle:NSLocalizedString(@"SubmitKey", @"") forState:UIControlStateNormal];
        
        self.isLoginState = FALSE;
        [UIView animateWithDuration:.5
                            delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.ReEmail.hidden = false;
                             self.reenterPwTextField.hidden = false;
                             
                             CGRect frame;
                             frame = self.reenterPwTextField.frame;
                             frame.size.height = 31.0f;
                             frame.origin.y += 40;
                             self.reenterPwTextField.frame = frame;
                             self.reenterPwTextField.text = @""; //清空password
                             
                             frame = self.passwordTextField.frame;
                             frame.size.height = 31.0f;
                             frame.origin.y += 45;
                             frame.size.width = 280.0f;
                             self.passwordTextField.frame = frame;
                             self.passwordTextField.text = @""; //清空password
                             
                             frame = self.displayCheckBox.frame;
                             frame.size.height = 18.0f;
                             frame.origin.y += 90;
                             self.displayCheckBox.frame = frame;
                             
                             frame = self.dispalyLabel.frame;
                             frame.size.height = 18.0f;
                             frame.origin.y += 88;
                             self.dispalyLabel.frame = frame;
               
                             frame = self.loginRegBtn.frame;
                             frame.origin.y += 100.0;
                             self.loginRegBtn.frame = frame;
                             
                             frame = self.cancelBtn.frame;
                             frame.origin.y += 100.0;
                             self.cancelBtn.frame = frame;
                             
                             frame = self.askToRegisterBtn.frame;
                             frame.origin.y += 100.0;
                             self.askToRegisterBtn.frame = frame;
                             
                         }
                         completion:^(BOOL finished) {
                         }];
        [self dissmissKeyboard];
    }
    else {
        [self.btnForgetPassword setHidden:NO];

        self.topLabel.text = NSLocalizedString(@"LoginColonKey", @"");
        [self.askToRegisterBtn setTitle:NSLocalizedString(@"AskToRegiserBtnKey", @"") forState:UIControlStateNormal];
        [self.loginRegBtn setTitle:NSLocalizedString(@"SubmitKey", @"") forState:UIControlStateNormal];
        
        self.isLoginState = TRUE;
        
        // [self checkAndEnableSubmitBtn];
        
        [UIView animateWithDuration:.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.ReEmail.hidden = true;
                             self.reenterPwTextField.hidden = true;
                             
                             CGRect frame;
                             frame = self.reenterPwTextField.frame;
                             frame.size.height = 31.0f;
                             frame.origin.y -= 40;
                             self.reenterPwTextField.frame = frame;
                             
                             frame = self.passwordTextField.frame;
                             frame.size.height = 31.0f;
                             frame.origin.y -= 45;
                             frame.size.width = 195.0f;
                             self.passwordTextField.frame = frame;
                             self.passwordTextField.text = @""; //清空password
                             
                             frame = self.displayCheckBox.frame;
                             frame.size.height = 18.0f;
                             frame.origin.y -= 90;
                             self.displayCheckBox.frame = frame;
                             
                             frame = self.dispalyLabel.frame;
                             frame.size.height = 18.0f;
                             frame.origin.y -= 88;
                             self.dispalyLabel.frame = frame;
                             
                             frame = self.userNameTxt.frame;
                             frame.size.height = 0.0f;
                             self.userNameTxt.frame = frame;
                             
                             frame = self.securityQuestionTextField.frame;
                             frame.size.height = 0.0f;
                             self.securityQuestionTextField.frame = frame;
                             
                             frame = self.securityAnswerTextField.frame;
                             frame.size.height = 0.0f;
                             self.securityAnswerTextField.frame = frame;
                             
                             frame = self.loginRegBtn.frame;
                             frame.origin.y -= 100.0;
                             self.loginRegBtn.frame = frame;
                             
                             frame = self.cancelBtn.frame;
                             frame.origin.y -= 100.0;
                             self.cancelBtn.frame = frame;
                             
                             frame = self.askToRegisterBtn.frame;
                             frame.origin.y -= 100.0;
                             self.askToRegisterBtn.frame = frame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (IBAction)displayPasswordBtnPressed:(id)sender {
    if (self.displayPasswordFlag) {
        [self.displayPwBtn setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"] forState:UIControlStateNormal];
        self.displayPasswordFlag = FALSE;
        self.passwordTextField.secureTextEntry = TRUE;
        self.reenterPwTextField.secureTextEntry = TRUE;
    }
    else {
        [self.displayPwBtn setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState:UIControlStateNormal];
        self.displayPasswordFlag = TRUE;
        self.passwordTextField.secureTextEntry = FALSE;
        self.reenterPwTextField.secureTextEntry = FALSE;
    }
}

- (IBAction)loginRegBtnPressed:(id)sender {
    
    NSString *email = [self.userEmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *reEmail = [self.ReEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (self.isLoginState) { // button being used for login
        if (![self isValidEmail:email]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"InvalidEmail", @"") inView:self.view];
            return;
        }
        
        if (![self isValidPassword:self.passwordTextField.text]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"InvalidPass", @"") inView:self.view];
            return;
        }
        [self getAccountInfo];
    }
    else {
        if (![self isValidPassword:self.passwordTextField.text]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"InvalidNewPass", @"") inView:self.view];
            return;
        }
        
        if (![self.passwordTextField.text isEqualToString:self.reenterPwTextField.text]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"InvalidConfirmPass", @"") inView:self.view];
            return;
        }
        
        if (![self isValidEmail: email]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"InvalidNewEmail", @"") inView:self.view];
            return;
        }
        
        if (![email isEqualToString:reEmail]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"InvalidConfirmEmail", @"") inView:self.view];
            return;
        }
        
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarRegister", @"")
                                                      delegate:self];
        
        GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
        GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"accountId" stringValue:email];
        [requestElement addChild:paramElement];
        paramElement = [GDataXMLNode elementWithName:@"password" stringValue:self.passwordTextField.text];
        [requestElement addChild:paramElement];

        paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", @"")];
        [requestElement addChild:paramElement];
        
        
        paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
        [requestElement addChild:paramElement];
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
        NSData *xmlData = document.XMLData;
        NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        
        NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
        NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
        [[USAVClient current].api register:encodedGetParam target:self selector:@selector(registerResultCallback:)];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 2) {
        self.passwordTextField.placeholder =  NSLocalizedString(@"PasswordPlaceholderKey2", @"");
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.passwordTextField.placeholder = NSLocalizedString(@"PasswordPlaceholderKey", @"");
}

- (IBAction)cancelBtnPressed:(id)sender {
    [self.delegate loginCancelled:self];
    //[self.fileControllerDelegate showDashBoard];
    [self dismissViewControllerAnimated:NO completion:Nil];
}


#pragma mark 点击空白处隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self dissmissKeyboard];
}

#pragma mark 更新之后，移动文件
- (void)moveAllFilesFromDirectory: (NSString *)source toDirectory:(NSString *)destination {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *allFile = [[NSMutableArray alloc] initWithCapacity:0];
    
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:source error:nil]];
    [fileManager createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:nil error:nil];
    NSError *error;
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *sourceFilePath = [NSString stringWithFormat:@"%@/%@", source, [allFile objectAtIndex:i]];   //allFile只是文件名
        NSString *destinationFilePath = [NSString stringWithFormat:@"%@/%@", destination, [allFile objectAtIndex:i]];
        [fileManager moveItemAtPath:sourceFilePath toPath:destinationFilePath error:&error];
        NSLog(@"Moving file:%@, with ERROR: %@", [allFile objectAtIndex:i], error);
    }
}

- (void)loginStatusCheckForAccount:(NSString *)email andPassword:(NSString *)password {
    [self getAccountLoginStatusInfoForAccount:email AndPassword:password];
}
@end
