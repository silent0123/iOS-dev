//
//  MoreTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 14/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "MoreTableViewController.h"

@implementation MoreTableViewController

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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 1) {
        return 4;
    } else {
        return 1;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"General";
            break;
        case 1:
            return @"Share by";
            break;
        default:
            return @"";
            break;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return NSLocalizedString(@"If you want to share by Dropbox or Wechat, you need to install corresponding app before sharing.", @"Footer hint");
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    //创建CELL
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //CELL的主体
    switch (section) {
        case 0:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Rename", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            } else {}
            break;
        case 1:
            //cell.TableImage.image = [UIImage imageNamed:@"uSav@2x.png"];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Share by Wechat", nil);
            } else if (row == 1){
                cell.textLabel.text = NSLocalizedString(@"Share by Dropbox", nil);
            } else if (row == 2){
                cell.textLabel.text = NSLocalizedString(@"Send by Email", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Another Application", nil);
            }
            break;
        case 2: {
            cell.textLabel.text = NSLocalizedString(@"Delete", nil);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E8251E"];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
            cell.accessoryType = UITableViewCellAccessoryNone;
            //[cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            break;
        }
            default:
            break;
    }
    return cell;
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
    
//    if (section == 1 && row == 0) {
//        [self performSegueWithIdentifier:@"PasswordSegue" sender:self];
//    } else if (section == 1 && row == 1){
//        [self performSegueWithIdentifier:@"SecurityLockSegue" sender:self];
//    } else if (section == 2 && row == 1){
//        [self performSegueWithIdentifier:@"AboutSegue" sender:self];
//    } else if (section == 0 && row == 0){
//        [self performSegueWithIdentifier:@"ProfileSegue" sender:self];
//    } else if (section == 0 && row == 1){
//        [self performSegueWithIdentifier:@"LanguageSegue" sender:self];
//    }
    UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [comingSoon show];
    
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

@end
