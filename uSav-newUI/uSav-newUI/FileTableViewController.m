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
    
    //SearchBar相关
    UISearchBar *fileSearchBar;
    UISearchDisplayController *searchDisplayController;
    
    //用来识别当前显示的数据源，从而控制segue跳转
    NSString *dataSourceIdentifier;
    //用来segue传参
    NSString *segueTransFileName;
    NSString *segueTransBytes;
    NSString *segueTransColor;
    
    NSMutableArray *allFileName;   //用来搜索的时候查询,这个需要是可变数组，因为要取出所有的cell文件名放进去
    NSArray *searchFileName;    //只用赋值一次即可
    //BOOL firstVisit;
    
}

@end
@implementation FileTableViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数据
    _CellData = [InitiateWithData initiateDataForFiles];
    allFileName = [[NSMutableArray alloc] initWithCapacity:[_CellData count]]; //这句非常重要，要不然allFile为空
    //初始化第二个数据源
    decryptionController =[[FileDecryptionTableViewController alloc] init];
    dataSourceIdentifier = @"Encrypted";
    
    //刷新功能增加
    [self SetBeginRefresh];
    [self AddSearchBarAndDisplayController];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//- (void)viewWillAppear:(BOOL)animated {
//
//    CGRect newBounds = _FileTable.bounds;
//    newBounds.origin.y = newBounds.origin.y + 44;
//    _FileTable.bounds = newBounds;
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    
//    [super viewDidAppear:animated];
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidAppear:(BOOL)animated {
//    //之后再次进入该页面
//    //默认隐藏SearchBar，设置TableView的默认位移（否则每次返回该页面都会出现searchbar跳出来的情况）
//    if (!firstVisit) {
//        _FileTable.contentOffset = CGPointMake(0, 32);
//    }
//}

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
    if (tableView == _FileTable) {
        return [_CellData count];
    } else {
        return [searchFileName count];
    }

}


//这里的内容都只是为了demo自定义, 数据从appdelegate传过来的。里面只有颜色和图片还有字体可以保留

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //创建CELL
    FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    
    //如果不存在，就创建一个默认样式的。其实是用来创建给searchResultDisplay用，因为searchDisplay是没有identifier的。
    if (cell == nil) {
        UITableViewCell *searchCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchCell"];
        self.searchCell = searchCell;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //NSLog(@"%@",cell);
    }
    
    if (tableView == self.tableView) {
        //创建数据对象，用之前定义了的_CellData初始化
        FileDataBase *cellData = _CellData[indexPath.row];
        //把所有文件名放到一个数组里，方便搜索(allFileName已经在开始初始化)

        [allFileName addObject:cellData.FileName];

        //CELL的主体
        //cell.TableImage.image = nil;
        cell.FileName.text = [NSString stringWithFormat:@"%@.usav", cellData.FileName]; //人工usav结尾
        cell.FileName.font = [UIFont boldSystemFontOfSize:14];
        //cell.FileName.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        cell.Bytes.text = cellData.Bytes;
        cell.Bytes.font = [UIFont systemFontOfSize:10];
        cell.Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:cellData.TableColor];
        cell.ReceiveTime.text = cellData.ReceiveTime;
        cell.ReceiveTime.textColor = [ColorFromHex getColorFromHex:@"#929292"];
        //cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        
        //Image不用在数据类中加，直接在这里加
        if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#44BBC1"].CGColor)) {
            cell.TableImage.image = [UIImage imageNamed:@"EncryptedWord@2x.png"];
        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#ED6F00"].CGColor)) {
            cell.TableImage.image = [UIImage imageNamed:@"EncryptedPowerpoint@2x.png"];
        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#A0BD2B"].CGColor)) {
            cell.TableImage.image = [UIImage imageNamed:@"EncryptedExcel@2x.png"];
        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#D6006F"].CGColor)) {
            cell.TableImage.image = [UIImage imageNamed:@"EncryptedMultimedia@2x.png"];
        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#E8251E"].CGColor)){
            cell.TableImage.image = [UIImage imageNamed:@"EncryptedPdf@2x.png"];
        } else {
            cell.TableImage.image = [UIImage imageNamed:@"EncryptedOthers@2x.png"];
        }
            
        
        //高亮状态
        //cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        //cell.selectedBackgroundView.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        // Configure the cell...
    }
    else {
        
        if ([dataSourceIdentifier  isEqual: @"Encryption"]) {
            NSString *searchResult = [NSString stringWithFormat:@"%@.usav", searchFileName[indexPath.row]];
            _searchCell.textLabel.text = searchResult;
            _searchCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        } else {
            NSString *searchResult = searchFileName[indexPath.row];
            _searchCell.textLabel.text = searchResult;
            _searchCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        }
        

        return self.searchCell;
        
        //CELL的主体
//        cell.TableImage.image = nil;
//        cell.FileName.text = [NSString stringWithFormat:@"%@.usav", searchFileName.FileName]; //人工usav结尾
//        cell.FileName.font = [UIFont boldSystemFontOfSize:14];
//        //cell.FileName.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
//        cell.Bytes.text = searchFileName.Bytes;
//        cell.Bytes.font = [UIFont systemFontOfSize:10];
//        cell.Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
//        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:searchFileName.TableColor];
//        cell.ReceiveTime.text = searchFileName.ReceiveTime;
//        cell.ReceiveTime.textColor = [ColorFromHex getColorFromHex:@"#929292"];
        //cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        
        //Image不用在数据类中加，直接在这里加
//        if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#44BBC1"].CGColor)) {
//            cell.TableImage.image = [UIImage imageNamed:@"EncryptedWord@2x.png"];
//        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#ED6F00"].CGColor)) {
//            cell.TableImage.image = [UIImage imageNamed:@"EncryptedPowerpoint@2x.png"];
//        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#A0BD2B"].CGColor)) {
//            cell.TableImage.image = [UIImage imageNamed:@"EncryptedExcel@2x.png"];
//        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#D6006F"].CGColor)) {
//            cell.TableImage.image = [UIImage imageNamed:@"EncryptedMultimedia@2x.png"];
//        } else if (CGColorEqualToColor(cell.TableColor.backgroundColor.CGColor, [ColorFromHex getColorFromHex:@"#E8251E"].CGColor)){
//            cell.TableImage.image = [UIImage imageNamed:@"EncryptedPdf@2x.png"];
//        } else {
//            cell.TableImage.image = [UIImage imageNamed:@"EncryptedOthers@2x.png"];
//        }
    }
    
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
        NSLog(@"现在的第%zi行已经被移除, 还剩下%zi",indexPath.row,[_CellData count]);
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //如果是在加密文件页面，跳转到有解密按钮的页面；如果是解密文件页面，跳转到有预览按钮的页面
    if (indexPath.row >= 0 && [dataSourceIdentifier  isEqual: @"Decrypted"]) {
        FileDataBase *cellData = _CellData[indexPath.row];
        segueTransFileName = cellData.FileName;
        segueTransBytes = cellData.Bytes;
        segueTransColor = cellData.TableColor;
        [self performSegueWithIdentifier:@"FileDetailSegue" sender:self];
    } else if (indexPath.row >= 0 && [dataSourceIdentifier isEqual: @"Encrypted"]) {
        FileDataBase *cellData = _CellData[indexPath.row];
        segueTransFileName = [NSString stringWithFormat:@"%@.usav", cellData.FileName];
        segueTransBytes = cellData.Bytes;
        segueTransColor = cellData.TableColor;
        [self performSegueWithIdentifier:@"FileDetailEncryptedSegue" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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


#pragma mark PrepareforSegue传值

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual: @"FileDetailSegue"]) {
        // 将本页面的值通过segue传递给下一个页面
        FileDetailViewController *fileDetailController = segue.destinationViewController;
        // 下一个页面获取到值
        fileDetailController.segueTransFileName = segueTransFileName;
        fileDetailController.segueTransBytes = segueTransBytes;
        fileDetailController.segueTransColor = segueTransColor;
    } else if ([segue.identifier isEqual: @"FileDetailEncryptedSegue"]) {
        FileDetailEncryptedViewController *fileDetailEncryptedController = segue.destinationViewController;
        // 下一个页面获取到值
        fileDetailEncryptedController.segueTransFileName = segueTransFileName;
        fileDetailEncryptedController.segueTransBytes = segueTransBytes;
        fileDetailEncryptedController.segueTransColor = segueTransColor;
    }

}


#pragma mark SearchBar相关
- (void)AddSearchBarAndDisplayController {
    
    if (_FileTable.tableHeaderView == nil) {
        //这里临时生成一个searchBar
        UISearchBar *_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        fileSearchBar = _searchBar;
        fileSearchBar.placeholder = @"Search Filename or Extension";
        //fileSearchBar.barTintColor = [UIColor colorWithWhite:1 alpha:1];
        fileSearchBar.delegate = self;
        [fileSearchBar setTranslucent:YES];
        _FileTable.tableHeaderView = fileSearchBar;
        //默认隐藏SearchBar，设置TableView的默认位移
        //[_FileTable setContentOffset:CGPointMake(0, _searchBar.frame.size.height) animated:NO];
        //[fileSearchBar sizeToFit];
        
        //临时生成一个searchDisplayController
        searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:fileSearchBar contentsController:self];
        searchDisplayController.searchResultsDataSource=self;
        searchDisplayController.searchResultsDelegate=self;
        [self.searchDisplayController setActive:NO];
        
    }
    
}

//searchBar的delegate方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //生成一个判断器
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", fileSearchBar.text];
    //用判断器筛选原始数据(的文件名)，放入新数组
    searchFileName = (NSArray *)[allFileName filteredArrayUsingPredicate:predicate];
    
}

#pragma mark 滑动隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    UIView *searchBarView = fileSearchBar.subviews[0];
    
    [searchBarView.subviews[1] resignFirstResponder];
}

#pragma mark Segment相关
//切换按钮，切换数据源
- (IBAction)SegmentChange:(id)sender {
    
    NSInteger selectedSegment = _FileSegent.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //NSLog(@"当前数据源为self");
        dataSourceIdentifier = @"Encrypted";
        [_FileTable setDelegate:self];
        [_FileTable setDataSource:self];
        [_FileTable reloadData];
    } else if (selectedSegment == 1) {
        dataSourceIdentifier = @"Decrypted";
        decryptionController.CellData = [InitiateWithData initiateDataForFiles];
        _FileTable.dataSource = decryptionController;
        [_FileTable reloadData];
    }

}

#pragma mark AddButton事件
//- (IBAction)AddButtonClicked:(id)sender {
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
//}

#pragma mark 传递给View动画效果
//- (UIView *)TransitionAnimationEffect:(UIView *)view {
//
//    //动画效果
//    CATransition *menuTransition = [CATransition animation];
//    menuTransition.duration = 0.5;
//    menuTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];  //设定动画的时间函数，也就是进出的快慢
//    menuTransition.type = @"fade"; //动画效果
//    menuTransition.delegate = self;
//    //加到构件上
//    [view.layer addAnimation:menuTransition forKey:nil];
//    
//    return view;
//}

#pragma mark 下拉刷新
//结束事件(数据处理)
- (void)RefreshData {
    //定义刷新过程的提示信息
    //时间格式定义和时间获取
    NSString *systemDate = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    systemDate = [dateFormatter stringFromDate:[NSDate date]];
    //下拉显示的内容
    NSString *titleString = NSLocalizedString(@"Recent update at ", nil);
    NSString *recentUpdateString = [NSString stringWithFormat:@"%@%@", titleString,systemDate];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:recentUpdateString];
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

//刷新中事件(动作)
- (void)RefreshTableViewAction: (UIRefreshControl *)refresh {

    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing", nil)];
        [self performSelector:@selector(RefreshData) withObject:nil afterDelay:2];
    }
    
}

//监听事件(监听事件并且开始响应)
- (void)SetBeginRefresh {
    
    //生成一个refresh控制器，并且不用管理它的frame，系统会自己管理
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [ColorFromHex getColorFromHex:@"#929292"];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Update", nil)];
    
    //UIRefreshControl会触发一个UIContentEventValueChanged事件，通过监听事件，我们可以进行需要的操作
    [refresh addTarget:self action:@selector(RefreshTableViewAction:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    

}
@end
