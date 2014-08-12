//
//  FileDecryptionTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 7/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileDecryptionTableViewController.h"

@interface FileDecryptionTableViewController ()

@end

@implementation FileDecryptionTableViewController

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


#pragma mark FileTable操作相关
//------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    //NSLog(@"数据已经初始化，获取section的数目为2");
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"获取每个Section的行数: %zi", [_CellData count]);
    return [_CellData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"进入Cell创建");
    //创建CELL
    FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    //    if(cell == nil){
    //        FileTableViewCell *cell = [[FileTableViewCell alloc] initWithFrame:CGRectZero];
    //    }
    //创建数据对象，用之前定义了的_CellData初始化
    FileDataBase *cellData = _CellData[indexPath.row];
        
    //CELL的主体
    cell.TableImage.image = nil;
    cell.FileName.text = cellData.FileName;
    cell.FileName.font = [UIFont systemFontOfSize:14];
    //cell.FileName.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    cell.Bytes.text = cellData.Bytes;
    cell.Bytes.font = [UIFont systemFontOfSize:10];
    cell.Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:cellData.TableColor];
    cell.ReceiveTime.text = cellData.ReceiveTime;
    cell.ReceiveTime.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    //cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    
    //Image不用在数据类中加，直接在这里加
    if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#44BBC1"].CGColor)) {
        cell.TableImage.image = [UIImage imageNamed:@"Word@2x.png"];
    } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#ED6F00"].CGColor)) {
        cell.TableImage.image = [UIImage imageNamed:@"Powerpoint@2x.png"];
    } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#A0BD2B"].CGColor)) {
        cell.TableImage.image = [UIImage imageNamed:@"Excel@2x.png"];
    } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#D6006F"].CGColor)) {
        cell.TableImage.image = [UIImage imageNamed:@"Mutimedia@2x.png"];
    } else {
        cell.TableImage.image = [UIImage imageNamed:@"Others@2x.png"];
    }
    
    //高亮状态
    //cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    //cell.selectedBackgroundView.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    // Configure the cell...
    return cell;
}

//cell编辑/删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;//可以编辑
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_CellData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //NSLog(@"现在的第%zi行已经被移除, 还剩下%zi",indexPath.row,[_CellData count]);
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


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
