//
//  USAVPermissionViewController.m
//  uSav-NewMac
//
//  Created by Luca on 2/12/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "USAVPermissionViewController.h"

@interface USAVPermissionViewController ()

@end

@implementation USAVPermissionViewController {
}

- (instancetype)initWithKeyId: (NSString *)keyId {
    
    self.keyId = keyId;
    return [self init];
    
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.panelIsShowed = NO;
    //隐藏Panel
    [self.addContactPanel close];
    [self displayContactActivityCircle:NO];
    
    // Do view setup here.
    self.permissionEmailList = [[NSMutableArray alloc] initWithCapacity:0];
    self.permissionAliasList = [[NSMutableArray alloc] initWithCapacity:0];
    self.deleteEmailPermissionList = [[NSMutableArray alloc] initWithCapacity:0];
    self.deleteAliasPermissionList = [[NSMutableArray alloc] initWithCapacity:0];
    self.contactsAliasList = [[NSMutableArray alloc] initWithCapacity:0];
    self.contactsEmailList = [[NSMutableArray alloc] initWithCapacity:0];
    self.contactsStatusList = [[NSMutableArray alloc] initWithCapacity:0];
    self.selectedRows = [[NSMutableArray alloc] initWithCapacity:0];
    
    //default setting
    self.limitTextField.stringValue = [NSString stringWithFormat:@"%zi",[[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"]];
    self.durationTextField.stringValue = [NSString stringWithFormat:@"%zi",[[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultDuration"]];
    
    if ([self.limitTextField.stringValue integerValue] == 0) {
        self.limitTextField.stringValue = @"No Limit";
    }
    if ([self.durationTextField.stringValue integerValue] == 0) {
        self.durationTextField.stringValue = @"No Limit";
    }
    self.startTimePicker.dateValue = [NSDate date];
    self.startTimePicker.minDate = [NSDate date];
    self.endTimePicker.dateValue = [NSDate date];
    self.endTimePicker.minDate = [NSDate date];
    
    //view control
    [self displayAddPermissionView:NO];
    [self activityViewDisplay:NO withMessage:nil animate:NO];
    
    //----Decrypt Copy
    self.allowDecryptCopy = [[NSUserDefaults standardUserDefaults] integerForKey:@"AllowDecryptCopy"];
    [self.decryptCopySegmentController setSelectedSegment:self.allowDecryptCopy];
    
    //Test
//    [self.permissionEmailList addObject:@"a.usav.demo@gmail.com"];
//    [self.permissionAliasList addObject:@"a.usav.demo"];
//    [self.permissionEmailList addObject:@"b.usav.demo@gmail.com"];
//    [self.permissionAliasList addObject:@"b.usav.demo"];
//    [self.permissionEmailList addObject:@"c.usav.demo@gmail.com"];
//    [self.permissionAliasList addObject:@"c.usav.demo"];


    //得到参数.hasGotList会在CallBack的时候改变
    [[USAVFileHandler currentHandler] getPermissionListForKey:self.keyId delegate:self];
    [self activityViewDisplay:YES withMessage:@"Getting Permission List" animate:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getpermissionListCallBack:) name:@"GetPermissionListResult" object:nil];
    
}


#pragma mark - tableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    if (tableView == self.permissionTableView) {
        return [self.permissionEmailList count];
    } else {
        return [self.contactsEmailList count];
    }
    
    //return 3;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{

    
    if (tableView == self.permissionTableView) {
        if ([tableColumn.identifier isEqualToString:@"AliasCell"]) {
            
            
            NSTableCellView *aliasCell = [tableView makeViewWithIdentifier:@"AliasCell" owner:self];
            aliasCell.textField.stringValue = [self.permissionAliasList objectAtIndex:row];
            
            return aliasCell;
            
        } else if ([tableColumn.identifier isEqualToString:@"EmailCell"]) {
            
            
            NSTableCellView *emailCell = [tableView makeViewWithIdentifier:@"EmailCell" owner:self];
            emailCell.textField.stringValue = [self.permissionEmailList objectAtIndex:row];
            
            return emailCell;
        }
    } else if (tableView == self.addContactPanelTableView) {
        
        if ([tableColumn.identifier isEqualToString:@"AliasCell"]) {
            
            
            NSTableCellView *aliasCell = [tableView makeViewWithIdentifier:@"AliasCell" owner:self];
            aliasCell.textField.stringValue = [self.contactsAliasList objectAtIndex:row];
            
            if ([[self.contactsStatusList objectAtIndex:row] isEqualToString:@"inactivated"]) {
                aliasCell.textField.textColor = [NSColor grayColor];
            } else {
                aliasCell.textField.textColor = [NSColor blackColor];
            }
            
            return aliasCell;
            
        } else if ([tableColumn.identifier isEqualToString:@"EmailCell"]) {
            
            NSTableCellView *emailCell = [tableView makeViewWithIdentifier:@"EmailCell" owner:self];
            emailCell.textField.stringValue = [self.contactsEmailList objectAtIndex:row];
            
            if ([[self.contactsStatusList objectAtIndex:row] isEqualToString:@"inactivated"]) {
                emailCell.textField.textColor = [NSColor grayColor];
            } else {
                emailCell.textField.textColor = [NSColor blackColor];
            }
            
            return emailCell;
        }
        
    }
    
    
    return nil;
}

#pragma mark - tableview delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSTableView *tableView = notification.object;
    NSIndexSet *rowIndexs = [tableView selectedRowIndexes];
    NSIndexSet *columnIndex = [tableView selectedColumnIndexes];
    

    [self.selectedRows removeAllObjects];
    
    if (tableView == self.permissionTableView) {
        
        [rowIndexs enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
            
            [self.selectedRows addObject:[NSNumber numberWithInteger:index]];
            
        }];
        
    } else {
        
        [rowIndexs enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
            
            [self.selectedRows addObject:[NSNumber numberWithInteger:index]];
            
        }];
        
    }

    
    
}


#pragma mark - 按钮响应
- (IBAction)saveAsDefaultPressed:(id)sender {
    
    //有效性验证
    if ([self isValidLimit:self.limitTextField.stringValue] && [self isValidDuration:self.durationTextField.stringValue]) {
        
        //如果为空，则设置为0，表示没有Limit或者Duration，否则保存实际值
        if ([self.limitTextField.stringValue isEqualToString:@""] || [self.limitTextField.stringValue isEqualToString:@"No Limit"]) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"DefaultLimit"];
        } else {
            [[NSUserDefaults standardUserDefaults] setInteger:[self.limitTextField.stringValue integerValue] forKey:@"DefaultLimit"];
        }
        if ([self.durationTextField.stringValue isEqualToString:@""] || [self.durationTextField.stringValue isEqualToString:@"No Limit"]) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"DefaultDuration"];
        } else {
            [[NSUserDefaults standardUserDefaults] setInteger:[self.durationTextField.stringValue integerValue] forKey:@"DefaultDuration"];
        }
        

        [[NSUserDefaults standardUserDefaults] setInteger:self.allowDecryptCopy forKey:@"AllowDecryptCopy"];
        
        [self activityViewDisplay:YES withMessage:@"Saved Successful" animate:NO];
        [self performSelector:@selector(removeSavedActivityIndicator) withObject:nil afterDelay:2];
        

    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Please input a valid Viewing Limit or Duration, 0 means no limit."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    
    
}


- (IBAction)addFromCondorContactsPressed:(id)sender {
    
    //先清空之前选择好的
    [self.selectedRows removeAllObjects];
    
    //加载Contact List
    [self.contactsEmailList removeAllObjects];
    [self.contactsAliasList removeAllObjects];
    [self.contactsStatusList removeAllObjects];
    NSArray *tempContactList = [[NSUserDefaults standardUserDefaults] objectForKey:@"ContactList"];
    for (NSInteger i = 0; i < [tempContactList count]; i ++) {
        
        [self.contactsEmailList addObject:[[tempContactList objectAtIndex:i] objectForKey:@"friendEmail"]];
        
        if ([[[tempContactList objectAtIndex:i] objectForKey:@"friendAlias"] length] == 0) {
            NSString *alias = [[[[tempContactList objectAtIndex:i] objectForKey:@"friendEmail"] componentsSeparatedByString:@"@"] objectAtIndex:0];
            [self.contactsAliasList addObject:alias];
        } else {
            [self.contactsAliasList addObject:[[tempContactList objectAtIndex:i] objectForKey:@"friendAlias"]];
        }
        
        [self.contactsStatusList addObject:[[tempContactList objectAtIndex:i] objectForKey:@"friendStatus"]];
    }
   
    
    if (!self.panelIsShowed) {
        [self.addContactPanelTableView reloadData];
        [self.addContactPanel makeKeyAndOrderFront:nil];
        self.panelIsShowed = YES;
    } else {
        [self.addContactPanel close];
        self.panelIsShowed = NO;
    }
    
}

- (IBAction)addFromSystemContactsPressed:(id)sender {
    
    
}
- (IBAction)addButtonPressed:(id)sender {
    
    if ([self.addPermissionView isHidden]) {
        [self displayAddPermissionView:YES];
    }
}

- (IBAction)addConfirmButtonPressed:(id)sender {
    
    [self.invalidEmailIndicator setHidden:YES];
    [self.invalidAliasIndicator setHidden:YES];
    
    if ([self.addAliasTextField.stringValue length] > 0 && [self isValidEmail:self.addEmailTextField.stringValue]) {
        //防止重复
        if (![self.permissionEmailList containsObject:self.addEmailTextField.stringValue]) {
            [self.permissionAliasList addObject:self.addAliasTextField.stringValue];
            [self.permissionEmailList addObject:self.addEmailTextField.stringValue];
        }

        
        [self.permissionTableView reloadData];
        
        [self displayAddPermissionView:NO];
        
    } else if (![self isValidEmail:self.addEmailTextField.stringValue]){
        self.addEmailTextField.textColor = [NSColor redColor];
        [self.invalidEmailIndicator setHidden:NO];
    }
    
    if ([self.addAliasTextField.stringValue length] == 0){
        [self.invalidAliasIndicator setHidden:NO];
    }
    
}

- (IBAction)addCancelButtonPressed:(id)sender {
 
    if (![self.addPermissionView isHidden]) {
        [self displayAddPermissionView:NO];
        [self.addContactPanel close];
        self.panelIsShowed = NO;
    }
    
}

- (IBAction)removeButtonPressed:(id)sender {
    
    if ([self.permissionEmailList count] > 0 && [self.selectedRows count] > 0) {
        
        //批量删除
        for (NSInteger i = 0; i < [self.selectedRows count]; i ++) {
            
            //为了避免删除错位，先检测是否在里面，在的话才删除
            if ([self.permissionEmailList containsObject:[self.permissionEmailList objectAtIndex:[[self.selectedRows objectAtIndex:i] integerValue]]]){
            [self.deleteEmailPermissionList addObject:[self.permissionEmailList objectAtIndex:[[self.selectedRows objectAtIndex:i] integerValue]]];
            }
            
            if ([self.permissionAliasList containsObject:[self.permissionAliasList objectAtIndex:[[self.selectedRows objectAtIndex:i] integerValue]]]) {
            [self.deleteAliasPermissionList addObject:[self.permissionAliasList objectAtIndex:[[self.selectedRows objectAtIndex:i] integerValue]]];
            }
        }


        
        [self.permissionEmailList removeObjectsInArray:self.deleteEmailPermissionList];
        [self.permissionAliasList removeObjectsInArray:self.deleteAliasPermissionList];

        
        [self.permissionTableView reloadData];
        [self.selectedRows removeAllObjects];
    }

}

- (IBAction)cancelPressed:(id)sender {
    
    [self removePermissionView];
}

- (IBAction)confirmPressed:(id)sender {
    
    NSInteger limit;
    NSInteger duration;
    
    [self activityViewDisplay:YES withMessage:@"Editting Permission" animate:YES];
    
    if ([self.limitTextField.stringValue isEqualToString:@""] || self.limitTextField.integerValue == 0) {
        limit = 0;
    } else if ([self isValidLimit:self.limitTextField.stringValue]){
        limit = self.limitTextField.integerValue;
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Please input a valid Viewing Limit, 0 means no limit."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        
        return;
    }
    
    if ([self.durationTextField.stringValue isEqualToString:@""] || self.durationTextField.integerValue == 0) {
        duration = 0;
    } else if ([self isValidDuration:self.durationTextField.stringValue]){
        duration = self.durationTextField.integerValue;
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Please input a valid Viewing Duration, 0 means no limit."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        
        return;
    }
    
    
    [[USAVFileHandler currentHandler] setPermissionForKeyId:self.keyId withFriend:self.permissionEmailList andGroup:nil andLimit:limit andDuration:duration withDelete: self.deleteEmailPermissionList delegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setpermissionCallBack:) name:@"EditPermissionResult" object:nil];
}

- (IBAction)addContactPanelCancel:(id)sender {
    
    [self.addContactPanel close];
    self.panelIsShowed = NO;
}

- (IBAction)addContactPanelConfirm:(id)sender {

    for (NSInteger i = 0; i < [self.selectedRows count]; i ++) {
        
        //防止重复
        if (![self.permissionEmailList containsObject:[self.contactsEmailList objectAtIndex:[[self.selectedRows objectAtIndex:i] integerValue]]]) {
            [self.permissionEmailList addObject:[self.contactsEmailList objectAtIndex:[[self.selectedRows objectAtIndex:i] integerValue]]];
            [self.permissionAliasList addObject:[self.contactsAliasList objectAtIndex:[[self.selectedRows objectAtIndex:i] integerValue]]];
        }

    }
    
    [self.selectedRows removeAllObjects];
    [self.permissionTableView reloadData];
    [self.addContactPanel close];
    self.panelIsShowed = NO;

}

- (IBAction)addContactPanelRefresh:(id)sender {
    
    [self displayContactActivityCircle:YES];
    [[USAVContactHandler currentHandler] getContactList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactData) name:@"getContactListResult" object:nil];
    
}

- (void)reloadContactData {

    [self.contactsAliasList removeAllObjects];
    [self.contactsEmailList removeAllObjects];
    [self.contactsStatusList removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getContactListResult" object:nil];
    [self displayContactActivityCircle:NO];
    
    //获取Contact数据
    NSArray *tempContactList = [[NSUserDefaults standardUserDefaults] objectForKey:@"ContactList"];
    
    NSLog(@"得到contactList ===: %zi",[[[NSUserDefaults standardUserDefaults] objectForKey:@"ContactList"] count]);
    
    for (NSInteger i = 0; i < [tempContactList count]; i ++) {
        
        [self.contactsEmailList addObject:[[tempContactList objectAtIndex:i] objectForKey:@"friendEmail"]];
        
        if ([[[tempContactList objectAtIndex:i] objectForKey:@"friendAlias"] length] == 0) {
            NSString *alias = [[[[tempContactList objectAtIndex:i] objectForKey:@"friendEmail"] componentsSeparatedByString:@"@"] objectAtIndex:0];
            [self.contactsAliasList addObject:alias];
        } else {
            [self.contactsAliasList addObject:[[tempContactList objectAtIndex:i] objectForKey:@"friendAlias"]];
        }
        
        [self.contactsStatusList addObject:[[tempContactList objectAtIndex:i] objectForKey:@"friendStatus"]];
        
    }
    

    [self.addContactPanelTableView reloadData];
}

#pragma mark - CallBacks
- (void)setpermissionCallBack: (NSNotification *)notification {
    
    NSLog(@"Permission Result: %@", notification);
    //移除notification observer，否则会重复监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EditPermissionResult" object:nil];
    
    [self activityViewDisplay:YES withMessage:notification.object animate:NO];
    
    if ([notification.object isEqualToString:@"Edit Permission Successful"]) {
        
        [self performSelector:@selector(removePermissionView) withObject:nil afterDelay:1];
    }
    
}

- (void)getpermissionListCallBack: (NSNotification *)notification {
    
    //NSLog(@"收到");
    NSLog(@"List Permission Result: %@", notification);
    
    NSDictionary *objectDic = notification.object;
    
    //移除notification observer，否则会重复监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetPermissionListResult" object:nil];
    
    if (![notification.object isKindOfClass:[NSString class]]) {
        
        self.permissionEmailList = [objectDic objectForKey:@"FriendList"];
        //暂时用@前面的部分代替Alias
        for (NSInteger i = 0; i < [self.permissionEmailList count]; i ++) {
            NSString *alias = [[[self.permissionEmailList objectAtIndex:i] componentsSeparatedByString:@"@"] objectAtIndex:0];
            [self.permissionAliasList addObject:alias];
        }
        self.durationTextField.stringValue = [objectDic objectForKey:@"Duration"];
        self.limitTextField.stringValue = [objectDic objectForKey:@"Limit"];
        
        [self activityViewDisplay:NO withMessage:nil animate:NO];
        [self.permissionTableView reloadData];
        
    } else {
        NSLog(@"Result: %@", notification.object);
        [self activityViewDisplay:YES withMessage:notification.object animate:NO];
        
        if (![notification.object isEqualToString:@"Get Permission Successful"]) {
            [self performSelector:@selector(removePermissionView) withObject:nil afterDelay:0.8];
        }
        
    }
}

#pragma mark - 验证函数
//0 means no limit
- (BOOL)isValidLimit: (NSString *)limit {
    
    if ([limit isEqualToString:@""]) {
        return YES;
    }
    
    if (limit) {
        if ([limit integerValue] >= 0 && [limit integerValue] < 65535) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isValidDuration: (NSString *)duration {
    
    if ([duration isEqualToString:@""]) {
        return YES;
    }
    
    if (duration) {
        if ([duration integerValue] >= 0 && [duration integerValue] < 65535) {
            return YES;
        }
    }
    return NO;
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

#pragma mark - view display
- (void)displayAddPermissionView: (BOOL)show {
    
    //动画
    if (show) {
        [self.addPermissionView.animator setAlphaValue:1.0];
    } else {
        [self.addPermissionView.animator setAlphaValue:0.0];
    }
    
    [self.addPermissionView setHidden:!show];
    self.addEmailTextField.stringValue = @"";
    self.addAliasTextField.stringValue = @"";
    [self.invalidAliasIndicator setHidden:YES];
    [self.invalidEmailIndicator setHidden:YES];
}

#pragma mark Activity display
- (void)activityViewDisplay: (BOOL)show withMessage: (NSString *)message animate: (BOOL)animate{
    
    if (show) {
        [self.activityCircle setHidden:!show];
        [self.activityLabel setHidden:!show];
        self.activityLabel.stringValue = message;
    } else {
        [self.activityCircle setHidden:!show];
        [self.activityLabel setHidden:!show];
    }
    
    if (animate) {
        [self.activityCircle setHidden:!animate];
        [self.activityCircle startAnimation:nil];
    } else {
        [self.activityCircle stopAnimation:nil];
        [self.activityCircle setHidden:!animate];
    }
    
}

- (void)removeSavedActivityIndicator {
    [self activityViewDisplay:NO withMessage:nil animate:NO];
}

- (void)removePermissionView {
    [self.view removeFromSuperview];
    [self.addContactPanel close];
    self.panelIsShowed = NO;
}

- (void)displayContactActivityCircle: (BOOL)show {
    
    if ([self.contactActivityCircle isHidden] == NO && show) {
        return;
    }
    
    if (show) {
        [self.contactActivityCircle setHidden:!show];
        [self.contactActivityCircle startAnimation:nil];
    } else {
        [self.contactActivityCircle setHidden:!show];
    }
}

- (IBAction)decryptCopySegmentChanged:(NSSegmentedControl *)sender {
    
    if (sender.selectedSegment == 0) {
        self.allowDecryptCopy = 0;
    } else {
        self.allowDecryptCopy = 1;
    }
}
@end
