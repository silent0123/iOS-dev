//
//  USAVGuidedSharingViewController.m
//  uSav
//
//  Created by NWHKOSX49 on 28/1/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//
#import "USAVGuidedSharingViewController.h"
#import "USAVGuidedSetPermissionViewController.h"

#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"

@interface USAVGuidedSharingViewController ()
@property (nonatomic, strong) UIAlertView *alert;

@property (nonatomic) NSInteger numberOfSetPermissionSuccess;
@property (nonatomic) NSInteger numberOfTargetPermissions;
@end

@implementation USAVGuidedSharingViewController

@synthesize emailTxt = _emailTxt;
@synthesize emailList = _emailList;
@synthesize fileName = _fileName;
@synthesize filePath = _filePath;
@synthesize tbView = _tbView;

#define ALERTVIEW_EMPTY_EMAIL_PERMISSION 0

- (UIImage *)selectImgForFile:(NSString *) filename
{
    if ([[filename pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
        return [USAVClient SelectImgForuSavFile:[filename stringByDeletingPathExtension]];
    } else {
        return [USAVClient SelectImgForOriginalFile:filename];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (NSMutableArray *)emailList {
    if (!_emailList) {
        _emailList = [NSMutableArray arrayWithCapacity:0];
    }
    return _emailList;
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

- (IBAction)AddFriendBtnPressed:(id)sender {
    if ([self isValidEmail:self.emailTxt.text]) {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarAddFriend", @"")
                                                      delegate:self];
        [self addFriendRequest:self.emailTxt.text];
    } else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"InvalidEmail", @"") inView:self.view];
    }
}

- (IBAction)shareBtnPressed:(id)sender {
    [self setPermissionFinal];
}

/*
 - (IBAction)selectFromContactList:(id)sender {
 USAVGuidedSetPermissionViewController *f = [[USAVGuidedSetPermissionViewController alloc] init];
 f.emails = self.emailList;
 //Set self to listen for the message "SecondViewControllerDismissed and run a method when this message is detected
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(didDismissSecondViewController)
 name:@"ContactListViewControllerDismissed"
 object:nil];
 [self presentViewController:f animated:YES completion:nil];
 }
 */

-(void)didDismissSecondViewController {
    NSLog(@"Dismissed SecondViewController");
}

- (void)contactListViewControllerDidFinish:(USAVGuidedSetPermissionViewController *)controller {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self addEmails:[controller.emails copy] toCurrentEmailList:self.emailList];
    //self.shareView.emailList = [[self getCheckedEmails] copy];
    //[self.view setNeedsDisplay];
    [self.tbView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.emailList removeObjectAtIndex:indexPath.row];
    [self.tbView reloadData];
}

- (void)addEmails:(NSMutableArray *)emails toCurrentEmailList:(NSMutableArray *)current {
    NSInteger j,i;
    BOOL exist;
    //NSInteger currentLen = [current count];
    for (j = 0; j < [emails count]; j++) {
        exist = false;
        NSString *email = [emails objectAtIndex:j];
        for (i = 0; i < [current count]; i++) {
            if ([email isEqualToString:[current objectAtIndex:i]]) {
                exist = true;
                break;
            }
        }
        if (!exist) {
            [current addObject:email];
        }
    }
}

- (void)addEmail:(NSString *)email toCurrentEmailList:(NSMutableArray *)current {
    NSInteger i;
    BOOL exist;
    //NSInteger currentLen = [current count];
    //exist = false;
    
    for (i = 0; i < [current count]; i++) {
        if ([email isEqualToString:[current objectAtIndex:i]]) {
            //exist = true;
            break;
        }
    }
    
    //if (!exist) {
    if (i == [current count]) {
        [current addObject:email];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditPermission"]) {
        USAVGuidedSetPermissionViewController *f = (USAVGuidedSetPermissionViewController*)segue.destinationViewController;
        //f.emails = self.emailList;
        //f.shareView = self;
        [f setDelegate:self];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // return 24;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.emailList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.text = [self.emailList objectAtIndex:indexPath.row];
    return cell;
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

-(void) addFriendRequest:(NSString *)friendName {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", friendName, @"\n", @"\n"];
    
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
    
    [client.api addFriend:encodedGetParam target:(id)self selector:@selector(addFriendResult:)];
}

-(void) addFriendResult:(NSDictionary*)obj {
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        //[self.tblView reloadData];
        return;
    }
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupResult: %@", obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:  // Friend does not exist, system will send invite, valid case
            {                /*
                              WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                              [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                              [wv show:NSLocalizedString(@"UserNotExist", @"") inView:self.view];
                              */
                [self addEmail:self.emailTxt.text toCurrentEmailList:self.emailList];
                self.emailTxt.text = @"";
                [self.tbView reloadData];
                return;
            }
                break;
            case FRIEND_EXIST:  // valid case
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                [wv show:NSLocalizedString(@"UserAddedSuccuss", @"") inView:self.view];
                
                [self addEmail:self.emailTxt.text toCurrentEmailList:self.emailList];
                self.emailTxt.text = @"";
                [self.tbView reloadData];
                
                NSLog(@"AddFriend: friend already exist: %@", self.emailTxt);
                
                return;
            }
                break;
            case ACC_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                [wv show:NSLocalizedString(@"ContactNameNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_FD_ALIAS:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                [wv show:NSLocalizedString(@"AliasNameInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_EMAIL:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                [wv show:NSLocalizedString(@"EmailNameInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_FD_NOTE:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                [wv show:NSLocalizedString(@"NoteInvalidKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_FD:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 100)];
                [wv show:NSLocalizedString(@"AddSelf", @"") inView:self.view];
                return;
            }
                
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
}

- (void)setPermissionCallBack:(NSDictionary*)obj
{
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"SetPermissionFailed", @"") inView:self.view];
        self.numberOfSetPermissionSuccess = 0;
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    if ((obj != nil) && ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0)) {
        self.numberOfSetPermissionSuccess += 1;
        if (self.numberOfSetPermissionSuccess == self.numberOfTargetPermissions) {
            /*
             UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EditPermissionSuccessKey", "")
             message:NSLocalizedString(@"EditPermissionSuccessMsg", "")
             delegate:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
             [message show];
             */
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
            [controller setToRecipients:self.emailList];
            [controller setMessageBody:NSLocalizedString(@"Attached is a secure file.", @"") isHTML:YES];
            [controller addAttachmentData:[NSData dataWithContentsOfFile:self.filePath]
                                 mimeType:@"application/octet-stream"
                                 fileName:self.fileName];
            if (controller) {
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
        
    } else {
        /*
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
         */
    }
}

- (void)setPermissionMono:(NSString *)keyId for:(NSString *)name isUser:(NSInteger)isUser withPermission:(NSInteger)permission
{
    
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",[[NSString alloc] initWithFormat:@"%zi",isUser], @"\n", keyId, @"\n",
                                name, @"\n", [[NSString alloc] initWithFormat:@"%zi", permission]];
    
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
    
    paramElement = [GDataXMLNode elementWithName:@"isUser" stringValue:[[NSString alloc] initWithFormat:@"%zi", isUser]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"permission" stringValue:[[NSString alloc] initWithFormat:@"%zi",permission]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api setFriendListPermision:encodedGetParam target:(id)self selector:@selector(setPermissionCallBack:)];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case ALERTVIEW_EMPTY_EMAIL_PERMISSION:
            break;
            
        default:
            break;
    }
    
}



- (void)setPermissionFinal
{
    NSInteger totalEmail = [self.emailList count];
    
    self.numberOfTargetPermissions = totalEmail;
    self.numberOfSetPermissionSuccess = 0;
    
    if (![self.emailList count]) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Share List Empty", @"") message:NSLocalizedString(@"Share List Empty Alert", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
        [alert show];
        alert.alertViewStyle = UIAlertViewStyleDefault; // UIAlertViewStylePlainTextInput;
        alert.tag = ALERTVIEW_EMPTY_EMAIL_PERMISSION;
        [alert show];
        
        /*
        NSArray *components = [NSArray arrayWithArray:[self.filePath componentsSeparatedByString:@"/"]];
        NSString *filenameComponent = [components lastObject];
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        NSString *emailAddress = [[USAVClient current] emailAddress];
        controller.mailComposeDelegate = self;
        [controller setSubject:[NSString stringWithFormat:@"%@ from %@", filenameComponent, emailAddress]];
        //[controller setMessageBody:@"Hi , <br/>  Attached is the secured file." isHTML:YES];
        [controller setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"SentByEmailLabel", @""), emailAddress] isHTML:YES];
        [controller addAttachmentData:[NSData dataWithContentsOfFile:self.filePath]
                             mimeType:@"application/octet-stream"
                             fileName:filenameComponent];
        if (controller) {
            //[self presentModalViewController:controller animated:YES];
            [self presentViewController:controller animated:YES completion:nil];
        }
        */
        return;
    } else {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"FileEditPermissionKey", @"")
                                                      delegate:self];
    }
    
    for (NSInteger i = 0; i < totalEmail; i++)
    {
        [self setPermissionMono:self.keyId for:[self.emailList objectAtIndex:i] isUser:1 withPermission:1];
    }
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

-(void)emailFile:(NSString *)fullPath
{
    
    NSArray *components = [NSArray arrayWithArray:[fullPath componentsSeparatedByString:@"/"]];
    NSString *filenameComponent = [components lastObject];
    
    NSLog(@"EmailFile: fullPath:%@ filenameComponent:%@", fullPath, filenameComponent);
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    NSString *emailAddress = [[USAVClient current] emailAddress];
    controller.mailComposeDelegate = self;
    [controller setSubject:[NSString stringWithFormat:@"%@ from %@", filenameComponent, emailAddress]];
    //[controller setMessageBody:@"Hi , <br/>  Attached is the secured file." isHTML:YES];
    [controller setMessageBody:[NSString stringWithFormat: NSLocalizedString(@"SentByEmailLabel", @""), emailAddress] isHTML:YES];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:fullPath]
                         mimeType:@"application/octet-stream"
                         fileName:filenameComponent];
    if (controller) {
        //[self presentModalViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.sendBtn.title = NSLocalizedString(@"SendBtn", @"");
    
    [self.barItem setTitle:NSLocalizedString(@"ShareBar", @"")];
    self.InstructionOne.text = NSLocalizedString(@"InstructionOne", @"");
    self.InstructionTwo.text = NSLocalizedString(@"InstructionTwo", @"");
    
    [self.ContactListBtn setTitle:NSLocalizedString(@"ContactListBtnLabel", @"") forState:nil];
    
    [self.tbView setDelegate:self];
    [self.tbView setDataSource:self];
    [self.emailTxt setDelegate:self];
    self.fileImg.image = [self selectImgForFile:self.fileName];
    self.fileNameTxt.text = self.fileName;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self.currentView setView:self.view];
    //[self.currentView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    
    [self setEmailTxt:nil];
    [self setTbView:nil];
    [self setFileImg:nil];
    [self setFileNameTxt:nil];
    [super viewDidUnload];
}

@end
