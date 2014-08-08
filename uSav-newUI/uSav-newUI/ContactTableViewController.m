//
//  ContactTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "ContactTableViewController.h"

@interface ContactTableViewController (){

    ContactGroupTableViewController *GroupController;
    
}

@end

@implementation ContactTableViewController

- (void)viewDidLoad {
    
    //初始化数据
    _CellData = [InitiateWithData initiateDataForContact];
    //初始化第二个数据源
    GroupController =[[ContactGroupTableViewController alloc] init];
    [self AddSearchBar];
    
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
    return [_CellData count];
}


//这里的内容都只是为了demo自定义, 数据从appdelegate传过来的。里面只有颜色和图片还有字体可以保留

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _ContactTable) {
        //创建CELL
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        //创建数据对象，用之前定义了的_CellData初始化
        ContactDataBase *cellData = _CellData[indexPath.row];
        
        //CELL的主体
        cell.Header.image = nil;
        cell.Name.text = cellData.Name;
        cell.Name.font = [UIFont systemFontOfSize:16];
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
    return nil;
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
        NSLog(@"现在的第%zi行已经被移除, 还剩下%zi",indexPath.row,[_CellData count]);
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

#pragma mark SearchBar相关

- (void)AddSearchBar {
    //这里临时生成一个searchBar
    UISearchBar *_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(2, 0, 320, 32)];
    _searchBar.placeholder = @"Search";
    //_searchBar.barTintColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _searchBar.delegate = self;
    [_searchBar setTranslucent:YES];
    _ContactTable.tableHeaderView = _searchBar;
    //默认隐藏SearchBar，设置TableView的默认位移
    _ContactTable.contentOffset = CGPointMake(0, CGRectGetHeight(_searchBar.bounds));
}

#pragma mark Segment相关
//切换按钮，切换数据源
- (IBAction)SegmentChange:(id)sender {
    
    NSInteger selectedSegment = _ContactSegment.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //NSLog(@"当前数据源为self");
        [_ContactTable setDelegate:self];
        [_ContactTable setDataSource:self];
        [_ContactTable reloadData];
    } else if (selectedSegment == 1) {
        GroupController.CellData = [InitiateWithData initiateDataForContact_Group];
        _ContactTable.dataSource = GroupController;
        [_ContactTable reloadData];
    }
    
}
@end
