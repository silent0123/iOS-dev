//
//  USAVSecureQATableViewController.m
//  CONDOR
//
//  Created by Luca on 25/2/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureQATableViewController.h"
#import "USAVFileViewController.h"

@interface USAVSecureQATableViewController ()

@end

@implementation USAVSecureQATableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIGraphicsBeginImageContext(self.tableView.frame.size);
    [[UIImage imageNamed:@"Inner_bg_lightgray"] drawInRect:self.tableView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    [self.navigationItem setTitle:NSLocalizedString(@"Secure Q&A", @"")];
    //design of textfield
    self.secureQuestionTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    self.secureQuestionTextField.placeholder = NSLocalizedString(@"10 - 99 characters", nil);
    self.secureQuestionTextField.font = [UIFont systemFontOfSize:13];
    self.secureAnswerTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    self.secureAnswerTextField.placeholder = NSLocalizedString(@"10 - 99 characters", nil);
    self.secureAnswerTextField.font = [UIFont systemFontOfSize:13];
    
    //backbutton
    self.homeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(homeBtnPressed)];
    self.navigationItem.leftBarButtonItem = self.homeBtn;
    
    //donebutton
    self.doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ConfirmLabel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnPressed)];
    self.navigationItem.rightBarButtonItem = self.doneBtn;
}

- (void)homeBtnPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneBtnPressed {
    
    //length 10 - 99
    if ([self.secureQuestionTextField.text length] >= 10 && [self.secureQuestionTextField.text length] <= 99 && [self.secureAnswerTextField.text length] >= 10 && [self.secureAnswerTextField.text length] <= 99) {
        
        [self.secureQuestionTextField resignFirstResponder];
        [self.secureAnswerTextField resignFirstResponder];
        
        [self sendSecureQAChangeRequrest];
        
    } else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Invalid Question or Answer Length", @"") inView:self.view];
    }
}

- (void)sendSecureQAChangeRequrest {
    
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarEditPassword", @"")
                                                  delegate:self];
    
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@%@%@", self.secureAnswerTextField.text, @"\n", self.secureQuestionTextField.text];
    
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
    paramElement = [GDataXMLNode elementWithName:@"securityAnswer" stringValue:self.secureAnswerTextField.text];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"securityQuestion" stringValue:self.secureQuestionTextField.text];
    [paramsElement addChild:paramElement];

    
    [requestElement addChild:paramsElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"change Q&A encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api setSecurityQuestionAnswer:encodedGetParam target:self selector:@selector(sendSecureQAChangeCallback:)];
    
}

- (void)sendSecureQAChangeCallback: (NSDictionary *)obj {
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"change QA Call back:%@", obj);
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y  - 120)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        return;
    }
    
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0) {
        
        [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:nil delegate:self];
        
        [self performSelector:@selector(performBackAfterDelay) withObject:self afterDelay:0.5];
        
    } else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Change Q&A Failed", @"") inView:self.view];
    }
}

- (void)performBackAfterDelay {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return NSLocalizedString(@"New Secure Q&A", nil);

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecureQACell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    switch (row) {
        case 0: {
            cell.textLabel.text = NSLocalizedString(@"New Question", nil);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.accessoryView = self.secureQuestionTextField;
        }
        break;
            
        default: {
            cell.textLabel.text = NSLocalizedString(@"New Answer", nil);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.accessoryView = self.secureAnswerTextField;
        }
            break;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
