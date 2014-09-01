//
//  LogsOperationTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "LogsOperationTableViewController.h"


@implementation LogsOperationTableViewController


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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_CellData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogsCell" forIndexPath:indexPath];
    LogsDataBase *cellData = _CellData[indexPath.row];
    
    cell.LogType.text = cellData.LogType;
    cell.LogType.font = [UIFont boldSystemFontOfSize:16];
    
    cell.LogTime.text = cellData.LogTime;
    cell.LogTime.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    cell.LogTime.font = [UIFont systemFontOfSize:10];
    
    //与成功和失败相关代码，包括字颜色和content, logsuccess内容
    if (cellData.LogSuccess) {
        cell.LogType.textColor = [ColorFromHex getColorFromHex:@"#A0BD2B"];
        
        NSString *logContentWithState = cellData.LogContent;
        cell.LogContent.text = logContentWithState;
        cell.LogContent.font = [UIFont systemFontOfSize:12];
        
        cell.LogSuccess.text = NSLocalizedString(@"SUCCEED", nil);
        cell.LogSuccess.font = [UIFont systemFontOfSize:12];
    } else {
        cell.LogType.textColor = [ColorFromHex getColorFromHex:@"#E8251E"];
        
        NSString *logContentWithState = cellData.LogContent;
        cell.LogContent.text = logContentWithState;
        cell.LogContent.font = [UIFont systemFontOfSize:12];
        
        cell.LogSuccess.text = NSLocalizedString(@"FAILED", nil);
        cell.LogSuccess.font = [UIFont systemFontOfSize:12];
        cell.LogSuccess.textColor = [ColorFromHex getColorFromHex:@"#E8251E"];
    }
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO; //不允许编辑
}

#pragma mark 选中方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
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
