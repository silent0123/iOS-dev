//
//  USAVProfileEditPassViewController.m
//  uSav
//
//  Created by NWHKOSX49 on 15/12/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVProfileEditPassViewController.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"

@interface USAVProfileEditPassViewController ()
@property (nonatomic,strong) UIAlertView *alert;
@end

@implementation USAVProfileEditPassViewController
@synthesize oldPassTxt = _oldPassTxt;
@synthesize nPassTxt = _nPassTxt;
@synthesize verifyPassTxt = _verifyPassTxt;

@synthesize oldPass = _oldPass;
@synthesize nPass = _nPass;
@synthesize verifyPass = _verifyPass;
@synthesize alert = _alert;

- (IBAction)cancelBtnPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmPressed:(id)sender
{
    [self.verifyPass resignFirstResponder];
    
    if (![self isValidPassword:self.oldPass.text]) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"InvalidOldPass", @"") inView:self.view];
        return;
    }

    if (![self isValidPassword:self.nPass.text]) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"InvalidNewPass", @"") inView:self.view];
        return;
    }
    
    if (![self.verifyPass.text isEqualToString:self.nPass.text] ) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"InvalidConfirmPass", @"") inView:self.view];
        return;
    }
    [self editPassword:self.oldPass.text toNewPassword:self.nPass.text];
}

- (BOOL)isValidPassword: (NSString *) email
{
    if ([email length] < 8 || [email length] > 49) {
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
        
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.ConfirmBtn setEnabled:NO];
    
    UIGraphicsBeginImageContext(self.tableView.frame.size);
    [[UIImage imageNamed:@"Inner_bg_lightgray"] drawInRect:self.tableView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];

    self.oldPassTxt.text = NSLocalizedString(@"OldPassLabel", @"");
    self.nPassTxt.text = NSLocalizedString(@"NewPassLabel", @"");
    self.verifyPassTxt.text = NSLocalizedString(@"ConfirmPassLabel", @"");

    self.CancleBtn.image = [UIImage imageNamed:@"icon_back_blue"];;
    [self.ConfirmBtn setTitle:NSLocalizedString(@"ConfirmLabel", @"")];
    [self.EditPassItem setTitle:NSLocalizedString(@"EditPassLabel", @"")];
    [self.navigationItem setTitle:NSLocalizedString(@"EditPassLabel", @"")];
    
    self.oldPass.delegate = self;
    self.nPass.delegate = self;
    self.verifyPass.delegate = self;
    
    self.oldPass.secureTextEntry = YES;
    self.nPass.secureTextEntry = YES;
    self.verifyPass.secureTextEntry = YES;
    
    self.oldPass.placeholder = NSLocalizedString(@"ProfileOldPassPlaceHolder", "");
    self.nPass.placeholder = NSLocalizedString(@"ProfileNewPassPlaceHolder", "");
    self.verifyPass.placeholder = NSLocalizedString(@"ProfileVerifyPassPlaceHolder", "");
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appToBackground:) name:@"AppIntoBackground"
object:nil];
}
	// Do any additional setup after loading the view.


-(void)appToBackground:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) editPassCallback:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y  - 120)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password Failed" message:@"Network too slow or error occurs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];*/

        //[self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
 
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0) {
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", nil) message:@"" delegate:self];
       
        USAVClient *client = [USAVClient current];
        client.password = [self.nPass.text copy];
        [self performSelector:@selector(popViewControllerAfterDelay) withObject:nil afterDelay:0.5];
    } else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"EditPasswordFailed", @"") inView:self.view];
    }
}

-(void)popViewControllerAfterDelay {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editPassword:(NSString *)oldPass toNewPassword:(NSString *)nPass
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEditPassword", @"")
                                                  delegate:self];
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@%@%@", nPass, @"\n", oldPass];
    
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
    paramElement = [GDataXMLNode elementWithName:@"oldPassword" stringValue:oldPass];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"newPassword" stringValue:nPass];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);

    [client.api editPassword:encodedGetParam target:(id)self selector:@selector(editPassCallback:)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidUnload {
    [self setOldPassTxt:nil];
    [self setVerifyPassTxt:nil];
    [self setOldPass:nil];
    
    [self setVerifyPass:nil];
    [self setNPassTxt:nil];
    [self setNPass:nil];
    [super viewDidUnload];
}


- (IBAction)oldPassTextChanged:(id)sender {
    return;
}

- (IBAction)nPassTextChanged:(id)sender {
    return;
}

- (IBAction)verifyPassTextChanged:(id)sender {
    if (self.oldPass.text.length != 0 && self.nPass.text.length != 0 && self.verifyPass.text.length != 0) {
        [self.ConfirmBtn setEnabled:YES];
    } else {
        [self.ConfirmBtn setEnabled:NO];
    }
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"passwordCell" forIndexPath:indexPath];
    
    NSInteger *section = indexPath.section;
    NSInteger *row = indexPath.row;
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    
    cell.backgroundColor = [UIColor clearColor];
    
    //选中颜色
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    if (section == 0) {
        
        //previous
        cell.textLabel.text = NSLocalizedString(@"OldPassLabel", @"");
        self.oldPass.font = [UIFont systemFontOfSize:13];
        self.oldPass.frame = CGRectMake(0, 0, 220, 40);
        cell.accessoryView = self.oldPass;
        
    } else {
        //new
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"NewPassLabel", @"");
            self.nPass.font = [UIFont systemFontOfSize:13];
            self.nPass.frame = CGRectMake(0, 0, 220, 40);
            cell.accessoryView = self.nPass;
        } else {
            cell.textLabel.text = NSLocalizedString(@"ConfirmPassLabel", @"");
            self.verifyPass.font = [UIFont systemFontOfSize:13];
            self.verifyPass.frame = CGRectMake(0, 0, 220, 40);
            cell.accessoryView = self.verifyPass;
        }
    }
    
    return cell;
}

@end