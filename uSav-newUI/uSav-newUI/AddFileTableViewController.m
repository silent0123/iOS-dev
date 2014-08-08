//
//  AddFileTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "AddFileTableViewController.h"

@interface AddFileTableViewController ()

@end

@implementation AddFileTableViewController

- (void)viewDidLoad {
    
    _CellData = [InitiateWithData initiateDataForAddFile];
    
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        //NSLog(@"section为0号，返回2");
        return 2;
    } else {
        //NSLog(@"section为1号，返回%zi", [_CellData count]);
        return [_CellData count];
    }
}

//设置Section Title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Recent Files";
    } else {
        return @"";
    }

}

//设置行高，我们的section0和1要不同
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section) {
        return 48;
    } else {
        return 54;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        //创建CELL
        AddFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFileCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        FileDataBase *cellData = _CellData[indexPath.row];

        
        if (cell == nil) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddFileCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        
        //CELL的主体, 在里面分别设置两个section的样式
        switch (section) {
            case 0:
                cell.FileImage = nil; //暂时
                cell.FileName.font = [UIFont boldSystemFontOfSize:15];
                if (row == 0) {
                    cell.FileName.text = @"Take a Photo";
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                } else {
                    cell.FileName.text = @"Select in Album";
                }
                break;
            default:
                cell.FileImage = nil; //暂时
                cell.FileName.text = cellData.FileName;
                cell.FileName.font = [UIFont systemFontOfSize:14];
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
        }
        return cell;
    }
    return nil;
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
