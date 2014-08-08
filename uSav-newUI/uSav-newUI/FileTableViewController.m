//
//  FileTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 6/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileTableViewController.h"

@interface FileTableViewController (){

    FileDecryptionTableViewController *decryptionController;
    
}

@end

@implementation FileTableViewController

- (void)viewDidLoad {
    
    //初始化数据
    _CellData = [InitiateWithData initiateDataForFiles];
    //初始化第二个数据源
    decryptionController =[[FileDecryptionTableViewController alloc] init];
    
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
    
    if (tableView == _FileTable) {
        //创建CELL
        FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
        //创建数据对象，用之前定义了的_CellData初始化
        FileDataBase *cellData = _CellData[indexPath.row];
        
        //CELL的主体
        cell.TableImage.image = nil;
        cell.FileName.text = cellData.FileName;
        cell.FileName.font = [UIFont systemFontOfSize:14];
        //cell.FileName.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        cell.Bytes.text = cellData.Bytes;
        cell.Bytes.font = [UIFont systemFontOfSize:10];
        //cell.Bytes.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:cellData.TableColor];
        cell.ReceiveTime.text = cellData.ReceiveTime;
        //cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        
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
    return YES;//不可以编辑
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
    _searchBar.placeholder = @"Search a File";
    //_searchBar.barTintColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    _searchBar.delegate = self;
    [_searchBar setTranslucent:YES];
    _FileTable.tableHeaderView = _searchBar;
    //默认隐藏SearchBar，设置TableView的默认位移
    _FileTable.contentOffset = CGPointMake(0, CGRectGetHeight(_searchBar.bounds));
}

#pragma mark Segment相关
//切换按钮，切换数据源
- (IBAction)SegmentChange:(id)sender {
    
    NSInteger selectedSegment = _FileSegent.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //NSLog(@"当前数据源为self");
        [_FileTable setDelegate:self];
        [_FileTable setDataSource:self];
        [_FileTable reloadData];
    } else if (selectedSegment == 1) {
        decryptionController.CellData = _CellData;
        _FileTable.dataSource = decryptionController;
        [_FileTable reloadData];
    }

}

#pragma mark AddButton事件
- (IBAction)AddButtonClicked:(id)sender {
//    由于addsubview只能放到tableview上去，有滚动效果，所以这里不做弹出窗口了
//    if (menuIsOpen) {
//        [self TransitionAnimationEffect:addMenu];
//        [addMenu setHidden:YES];
//        menuIsOpen = !menuIsOpen;
//    } else {
//        [self TransitionAnimationEffect:addMenu];
//        [addMenu setHidden:NO];
//        menuIsOpen = !menuIsOpen;
//    }
}

#pragma mark 传递给View动画效果
- (UIView *)TransitionAnimationEffect:(UIView *)view {

    //动画效果
    CATransition *menuTransition = [CATransition animation];
    menuTransition.duration = 0.5;
    menuTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];  //设定动画的时间函数，也就是进出的快慢
    menuTransition.type = @"fade"; //动画效果
    menuTransition.delegate = self;
    //加到构件上
    [view.layer addAnimation:menuTransition forKey:nil];
    
    return view;
}


@end
