//
//  PermissionTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "PermissionTableViewController.h"

@implementation PermissionTableViewController{
    UITextField *textFiled;
}

- (void)viewDidLoad {
    
    self.title = NSLocalizedString(@"Edit Permission", nil);
    
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
    self.tableView.scrollEnabled = NO;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0 || section == 2) {
        return 1;
    } else {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return NSLocalizedString(@"User ID", nil);
            break;
        case 1:
            return @"";
            break;
        default:
            return @"";
            break;
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    //创建CELL
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PermissionCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PermissionCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    //CELL的主体
    switch (section) {
        case 0:
            //创建一个输入框
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            textFiled = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+16, cell.frame.origin.y + 1, cell.frame.size.width - 16, cell.frame.size.height)];
            [textFiled setPlaceholder:@"Email"];
            textFiled.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            textFiled.clearsContextBeforeDrawing = YES;  //把周围的context清理，否则可能会出错
            textFiled.clearButtonMode = 5;
            textFiled.autocorrectionType = NO;
            textFiled.returnKeyType = UIReturnKeyGo;
            [textFiled setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
            textFiled.font = [UIFont systemFontOfSize:14];
            [cell addSubview:textFiled];
            
            break;
        case 1:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Add from contact list",nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Add from address book",nil);
            }
            break;
        default:
            cell.textLabel.text = NSLocalizedString(@"Done", nil);
            cell.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    return cell;
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    
//    if (section == 1 && row == 0) {
//        [self performSegueWithIdentifier:@"PasswordSegue" sender:self];
//    } else if (section == 1 && row == 1){
//        [self performSegueWithIdentifier:@"SecurityLockSegue" sender:self];
//    } else if (section == 2 && row == 1){
//        [self performSegueWithIdentifier:@"AboutSegue" sender:self];
//    } else if (section == 2 && row == 0){
//        UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [comingSoon show];
//    } else if (section == 0 && row == 0){
//        [self performSegueWithIdentifier:@"ProfileSegue" sender:self];
//    } else if (section == 0 && row == 1){
//        [self performSegueWithIdentifier:@"LanguageSegue" sender:self];
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark 滑动隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [textFiled resignFirstResponder];
}
@end
