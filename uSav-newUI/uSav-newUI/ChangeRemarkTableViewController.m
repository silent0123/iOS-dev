//
//  ChangeRemarkTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 14/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "ChangeRemarkTableViewController.h"

@implementation ChangeRemarkTableViewController{

    UITextField *textFiled;

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return @"";
    }
    return NSLocalizedString(@"New Remark", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;
    //创建CELL
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChangeRemarkCell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChangeRemarkCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //CELL的主体
    if (section == 0) {
        //创建一个输入框
        textFiled = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+16, cell.frame.origin.y + 1, cell.frame.size.width, cell.frame.size.height)];
        [textFiled setPlaceholder: NSLocalizedString(@"No more than 16 characters",nil)];
        textFiled.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        textFiled.clearsContextBeforeDrawing = YES;  //把周围的context清理，否则可能会出错
        textFiled.clearButtonMode = 5;
        textFiled.autocorrectionType = NO;
        textFiled.returnKeyType = UIReturnKeyGo;
        [textFiled setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        textFiled.font = [UIFont systemFontOfSize:14];
        [cell addSubview:textFiled];
    }
    else {
        cell.textLabel.text = NSLocalizedString(@"Done", nil);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    }
    return cell;
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;

    if (section == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark 滑动隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [textFiled resignFirstResponder];
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
