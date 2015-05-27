//
//  USAVLoginViewController.m
//  uSav-NewMac
//
//  Created by Luca on 9/12/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVLoginViewController.h"
#import "MainViewController.h"

@interface USAVLoginViewController ()

@end

@implementation USAVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.accountHandler = [USAVAccountHandler currentHandler];
    [self.errorMessageLabel setHidden:YES];
    [self displayActivityCircle:NO];
    [self displayHistoryAccountTable:NO];
    self.isHistoryAccountTableShowed = NO;
    self.isLoginInProgress = NO;
    
    //更新登陆历史
    self.historyAccountList = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"HistoryAccount"]];
    [self.historyAccountTableView reloadData];
    
    // Do view setup here.
}

#pragma mark - tableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return [self.historyAccountList count];
    
    //return 3;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
        
    NSTableCellView *historyAccountCell = [tableView makeViewWithIdentifier:@"historyAccountCell" owner:self];
    
    historyAccountCell.textField.textColor = [NSColor darkGrayColor];
    historyAccountCell.textField.stringValue = [self.historyAccountList objectAtIndex:row];
    
    return historyAccountCell;

    
}

#pragma mark - tableview delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    if (!self.isLoginInProgress) {
        //因为每次隐藏和显示Table都会触发这个方法，所以再Login的时候可能会错误地选择到某个账号（line 0），用这个BOOL变量来防止这种事情的发生
        
        NSTableView *tableView = notification.object;
        NSInteger selectedRow = [tableView selectedRow];
        
        self.accountTextField.stringValue = [self.historyAccountList objectAtIndex:selectedRow];
        
        [self displayHistoryAccountTable:NO];
        
    }
    
}


#pragma mark 按钮响应
- (IBAction)historyAccountDeleteButtonPressed:(id)sender {

    NSInteger selectedRow = [self.historyAccountTableView selectedRow];
    [self.historyAccountList removeObjectAtIndex:selectedRow];
    [self.historyAccountTableView reloadData];
    
    //更新登陆历史
    [[NSUserDefaults standardUserDefaults] setObject:self.historyAccountList forKey:@"HistoryAccount"];
    
    //更新输入框
    if ([[self.historyAccountList objectAtIndex:0] length] > 0) {
        self.accountTextField.stringValue = [self.historyAccountList objectAtIndex:0];
    } else {
        self.accountTextField.stringValue = @"";
    }
    
    [self displayHistoryAccountTable:NO];

}

- (IBAction)signUpButtonPressed:(id)sender {
 
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://usav-new.azurewebsites.net/%@/register",NSLocalizedString(@"en-us", @"")]]];
    
}

- (IBAction)loginButtonPressed:(id)sender {
 
    self.isLoginInProgress = YES;
    [self displayHistoryAccountTable:NO];
    
    if ([self isValidEmail:self.accountTextField.stringValue] && ([self.passwordTextField.stringValue length] > 6 && [self.passwordTextField.stringValue length] < 49)) {
        
        [self.errorMessageLabel setHidden:YES];
        
        [self.accountHandler getAccountInfoForAccount:self.accountTextField.stringValue andPassword:self.passwordTextField.stringValue];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCallBack:) name:@"LoginResult" object:nil];
        
        //更新登陆历史
        if (![self.historyAccountList containsObject:self.accountTextField.stringValue]) {
            [self.historyAccountList insertObject:self.accountTextField.stringValue atIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:self.historyAccountList forKey:@"HistoryAccount"];
        }
        
        [self displayActivityCircle:YES];
        [self.historyAccountTableView reloadData];
        
    } else {
        self.isLoginInProgress = NO;
        [self.errorMessageLabel setHidden:NO];
        [self.errorMessageLabel setTextColor:[NSColor redColor]];
        self.errorMessageLabel.stringValue = @"Invalid Email or Password";
        
    }
    
    
    

}

- (IBAction)forgetPasswordButtonPressed:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://usav-new.azurewebsites.net/%@/password",NSLocalizedString(@"en-us", @"")]]];
     
}

- (IBAction)historyAccountButtonPressed:(id)sender {
    
    if (self.isHistoryAccountTableShowed) {
        [self displayHistoryAccountTable:NO];
    } else {
        [self displayHistoryAccountTable:YES];
    }
    [self.accountTextField becomeFirstResponder];
    
}

#pragma mark call back
- (void)loginCallBack: (NSNotification *)notification {

    NSString *result = notification.object;
    self.isLoginInProgress = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginResult" object:nil];
    [self displayActivityCircle:NO];
    
    if ([result isEqualToString:@"Login Successful"]) {
        
        [USAVClient current].userHasLogin = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.accountTextField.stringValue forKey:@"emailAddress"];
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.stringValue forKey:@"password"];
        
        
        //创建一个MainViewController
        self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [self.view.superview addSubview:self.mainViewController.view];
        
        [self.view removeFromSuperview];
        [[USAVContactHandler currentHandler] getContactList];
        
    } else {
        [self.errorMessageLabel setHidden:NO];
        [self.errorMessageLabel setStringValue:result];
        [self.errorMessageLabel setTextColor:[NSColor redColor]];
    }
    
}

#pragma mark display
- (void)displayActivityCircle: (BOOL)show {
    
    if (show) {
        [self.loginActivityIndicator setHidden:NO];
        [self.loginActivityIndicator startAnimation:nil];
    } else {
        [self.loginActivityIndicator setHidden:YES];
        [self.loginActivityIndicator stopAnimation:nil];
    }

}

- (void)displayHistoryAccountTable: (BOOL)show {
    
    if (show) {
        [self.historyAccountTableView.animator setAlphaValue:1.0];
        [self.historyAccountTableView setHidden:NO];
        [self.historyAccountTableView.superview.superview setHidden:NO];
        self.isHistoryAccountTableShowed = YES;
    } else {
        [self.historyAccountTableView.animator setAlphaValue:0.0];
        [self.historyAccountTableView setHidden:YES];
        [self.historyAccountTableView.superview.superview setHidden:YES];
        self.isHistoryAccountTableShowed = NO;
    }
}

#pragma mark 有效性

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

@end
