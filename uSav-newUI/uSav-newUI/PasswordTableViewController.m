//
//  PasswordTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 15/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "PasswordTableViewController.h"

@implementation PasswordTableViewController{
    UITextField *currentPasswordTextField;
    UITextField *newPasswordTextField;
    UITextField *confirmPasswordTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.scrollEnabled = NO;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 1 || section == 2) {
        return 1;
    }
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        //创建CELL
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (cell == nil) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasswordCell"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        //CELL的主体
        switch (section) {
            case 0:
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.textLabel.userInteractionEnabled = NO; //防止点击文字
                
                if (row == 0) {
                    cell.textLabel.text = NSLocalizedString(@"Current", nil);
                    currentPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x + 80, cell.frame.origin.y + 1, cell.frame.size.width - 80, cell.frame.size.height)];   //修改y来控制placeholder位置
                    [currentPasswordTextField setPlaceholder:@"Current password"];
                    currentPasswordTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
                    currentPasswordTextField.clearsContextBeforeDrawing = YES;  //把周围的context清理，否则可能会出错
                    currentPasswordTextField.clearButtonMode = 5;
                    currentPasswordTextField.autocorrectionType = NO;
                    currentPasswordTextField.returnKeyType = UIReturnKeyNext;
                    [currentPasswordTextField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
                    currentPasswordTextField.font = [UIFont systemFontOfSize:14];
                    [currentPasswordTextField setSecureTextEntry:YES];
                    [cell addSubview:currentPasswordTextField];
                } else if (row == 1){
                    cell.textLabel.text = NSLocalizedString(@"New", nil);
                    newPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x + 80, cell.frame.origin.y + 1, cell.frame.size.width - 80, cell.frame.size.height)];
                    [newPasswordTextField setPlaceholder:@"New password (8 to 49 characters)"];
                    newPasswordTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
                    newPasswordTextField.clearsContextBeforeDrawing = YES;  //把周围的context清理，否则可能会出错
                    newPasswordTextField.clearButtonMode = 5;
                    newPasswordTextField.autocorrectionType = NO;
                    newPasswordTextField.returnKeyType = UIReturnKeyNext;
                    [newPasswordTextField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
                    newPasswordTextField.font = [UIFont systemFontOfSize:14];
                    [newPasswordTextField setSecureTextEntry:YES];
                    [cell addSubview:newPasswordTextField];
                
                } else {
                    cell.textLabel.text = NSLocalizedString(@"Confirm", nil);
                    confirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x + 80, cell.frame.origin.y + 1, cell.frame.size.width - 80, cell.frame.size.height)];
                    [confirmPasswordTextField setPlaceholder:@"Confirm new password"];
                    confirmPasswordTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
                    confirmPasswordTextField.clearsContextBeforeDrawing = YES;  //把周围的context清理，否则可能会出错
                    confirmPasswordTextField.clearButtonMode = 5;
                    confirmPasswordTextField.autocorrectionType = NO;
                    confirmPasswordTextField.returnKeyType = UIReturnKeyDone;
                    [confirmPasswordTextField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
                    confirmPasswordTextField.font = [UIFont systemFontOfSize:14];
                    [confirmPasswordTextField setSecureTextEntry:YES];
                    [cell addSubview:confirmPasswordTextField];
                }
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Change", nil);
                cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
                //cell.textLabel.textAlignment = NSTextAlignmentCenter;
                break;
            default:
                cell.textLabel.text = NSLocalizedString(@"Forget password", nil);
                cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.backgroundColor = [ColorFromHex getColorFromHex:@"#929292"];
                //cell.textLabel.textAlignment = NSTextAlignmentCenter;
                break;
                
        }
        return cell;
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 1) {
        [self changePassword];
    } else if (section == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://webapi.usav-nwstor.com/%@/password",NSLocalizedString(@"LanguageCode", @"")]]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

#pragma mark 调用改密码API
- (void)changePassword {
    
    //有效性判断
    if (![self isValidPassword:currentPasswordTextField.text]) {
        [self showAlert:@"Invalid Current Password" andContent:nil];
        return;
    }
    
    if (![self isValidPassword:newPasswordTextField.text]) {
        [self showAlert:@"Invalid New Password" andContent:nil];
        return;
    }
    
    if (![self isValidPassword:confirmPasswordTextField.text] || ![newPasswordTextField.text isEqualToString:confirmPasswordTextField.text]) {
        [self showAlert:@"None Consistant New Password" andContent:nil];
        return;
    }
    
    //封装数据
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@%@%@", newPasswordTextField.text, @"\n", currentPasswordTextField.text];
    
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
    paramElement = [GDataXMLNode elementWithName:@"oldPassword" stringValue:currentPasswordTextField.text];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"newPassword" stringValue:newPasswordTextField.text];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [self showLoadingAlertAt:self.view];
    [client.api editPassword:encodedGetParam target:(id)self selector:@selector(changePasswordCallback:)];
    
}

- (void)changePasswordCallback: (NSDictionary *)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        [self showAlert:@"Time Stamp Error" andContent:@"Please check your system time"];
    }
    
    if (obj == nil) {
        [self showAlert:@"Unknown Error" andContent:nil];
        return;
    }
    
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0) {
        [self showAlert:@"Succeed" andContent:nil];
        USAVClient *client = [USAVClient current];
        client.password = [newPasswordTextField.text copy];
        [_loadingAlert stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showAlert:@"Failed" andContent:nil];
    }
    return;
}

#pragma mark 密码有效性判断
- (BOOL)isValidPassword: (NSString *)password {
    
    if ([password length] < 8 || [password length] > 49) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*[a-zA-Z].*\\d.*)|(.*\\d.*[a-zA-Z].*)$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [password length]) {
        return false;
    }
    
    return true;
}

#pragma mark - 计时隐藏alert
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
    //这个userInfo可以将这个函数里的某个参数，装进timer中，传递给别的函数
    [alert show];
    
}
- (void)timerForHideAlert: (NSTimer *)timer {
    UIAlertView *alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark loading进度条
- (void)showLoadingAlertAt:(UIView *)view {
    if (_loadingAlert.isAnimating) {
        [_loadingAlert stopAnimating];
        return;
    } else {
        _loadingAlert = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(30, 260, 260, 50) dotStyle:TYDotIndicatorViewStyleRound dotColor:[UIColor colorWithRed:0.85f green:0.86f blue:0.88f alpha:1.00f] dotSize:CGSizeMake(15, 15) withBackground:NO];
        _loadingAlert.backgroundColor = [UIColor colorWithRed:0.20f green:0.27f blue:0.36f alpha:0.9f];
        _loadingAlert.layer.cornerRadius = 5.0f;
        [view addSubview:_loadingAlert];
        [_loadingAlert startAnimating];
    }
}
@end
