//
//  AboutViewController.m
//  uSav-newUI
//
//  Created by Luca on 11/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "AboutTableViewController.h"

@interface AboutTableViewController ()

@end

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.scrollEnabled = NO; //在这里设置不允许滚动
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        return 3;
    }

}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    switch (section) {
//        case 0:
//            return @"Profile";
//            break;
//        case 1:
//            return @"Security";
//            break;
//        case 2:
//            return @"Help";
//            break;
//        default:
//            return @"";
//            break;
//    }
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 200;
    } else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _AboutTable) {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        //创建CELL
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (cell == nil) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AboutCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        //CELL的主体
        if (section == 1) {
            switch (row) {
                case 0:
                    cell.textLabel.text = @"Version                                                       3.0";//55 space
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                case 1:
                    cell.textLabel.text = @"Feedback";
                    break;
                case 2:
                    cell.textLabel.text = @"About nwstor";
                    break;
                default:
                    break;
            }
        } else {
            //清空背景色，这里使用一个空的UIView来设置
            cell.accessoryType = UITableViewCellAccessoryNone;
            UIView *nullView = [[UIView alloc] init];
            cell.backgroundView = nullView;
            cell.backgroundColor = [UIColor clearColor];
            //这里动态生成一个image
        
        }

        return cell;
    }
    return nil;
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 1 && row == 1) {
        [self performSegueWithIdentifier:@"FeedbackSegue" sender:self];
    } else if (section == 1 && row == 2){
        [self performSegueWithIdentifier:@"NwstorSegue" sender:self];
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


@end
