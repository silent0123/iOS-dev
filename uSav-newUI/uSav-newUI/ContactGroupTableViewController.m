//
//  ContactGroupTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "ContactGroupTableViewController.h"

@interface ContactGroupTableViewController (){
    NSIndexPath *globalIndexPath;

}

@end

@implementation ContactGroupTableViewController

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //创建一个提示Label，在空的时候显示，有值的时候隐藏
    
    return [_CellData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        //创建CELL
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        //创建数据对象，用之前定义了的_CellData初始化
        NSString *cellData = _CellData[indexPath.row];  //因为这里从服务器取回的_CellData装的只是单行的字符串，而不像之前是字典。
    
        if ([_CellData[0] count] == 0) {
            cell.Name.text = NSLocalizedString(@"You Have No Group", nil);
            cell.Name.font = [UIFont boldSystemFontOfSize:14];
            cell.Header.image = nil;
            cell.separatorInset = UIEdgeInsetsZero;
            return cell;
        }
        cell.separatorInset = UIEdgeInsetsMake(0, 44, 0, 0);
        //CELL的主体
        cell.Header.image = [UIImage imageNamed:@"Group@2x.png"];
        cell.Name.text = cellData;
        cell.Name.font = [UIFont boldSystemFontOfSize:14];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.FileName.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        
        //Image不用在数据类中加，直接在这里加
        //        if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#44bbc1"].CGColor)) {
        //            cell.TableImage.image = [UIImage imageNamed:@"Word"];
        //        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#ED6F00"].CGColor)) {
        //            cell.TableImage.image = [UIImage imageNamed:@"Powerpoint"];
        //        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#A0BD2B"].CGColor)) {
        //            cell.TableImage.image = [UIImage imageNamed:@"Excel"];
        //        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#D6006F"].CGColor)) {
        //            cell.TableImage.image = [UIImage imageNamed:@"Mutimedia"];
        //        } else {
        //            cell.TableImage.image = [UIImage imageNamed:@"Others"];
        //        }
        
        //高亮状态
        //cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        //cell.selectedBackgroundView.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        // Configure the cell...
        return cell;
}

//cell编辑/删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 有数据才可以编辑，没有就不可以
    if ([_CellData count] > 0) {
        return YES;//可以编辑
    } else {
        return NO;
    }
}

//这个方法是datasource的
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_dataInitiator initiateDataFordeleteGroup:_CellData[globalIndexPath.row]];
        globalIndexPath = indexPath;
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark 删除分组后修改CellData
- (void)editCellData {
    [_CellData removeObjectAtIndex:globalIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[globalIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
