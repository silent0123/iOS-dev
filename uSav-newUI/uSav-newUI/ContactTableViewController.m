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
    
    //SearchBar相关
    UISearchBar *contactSearchBar;
    UISearchDisplayController *searchDisplayController;
    
    NSString *dataSourceIdentifier; //用来识别当前显示的数据源，从而控制segue跳转
    NSString *segueTransName;
    NSString *segueTransEmail;
    NSString *segueTransGroup;
    NSString *segueTransActivated;
    
    NSIndexPath *globalIndexPath; //用来删除的时候，记录是哪一行
    
    NSMutableArray *allContactName;
    NSMutableArray *searchContactName;
    
    InitiateWithData *dataInitiator;
    
}

//@property (strong, nonatomic) TYDotIndicatorView *loadingAlert;
@end

@implementation ContactTableViewController

- (void)viewWillAppear:(BOOL)animated{
    //初始化数据，在这里先调用一次initdataforcontact来触发向server发送请求，然后等后面回调回来之后再调用一次装载数据
    dataInitiator = [[InitiateWithData alloc] initData];
    dataInitiator.contactCaller = self;
    [dataInitiator initiateDataForContact];
    //_CellData = dataInitiator.mutableDataForGlobal;
}

- (void)viewDidLoad {
    
    //初始化搜索数组，不初始化会导致始终为空
    allContactName = [[NSMutableArray alloc] initWithCapacity:0];
    searchContactName = [[NSMutableArray alloc] initWithCapacity:0];    //不初始化默认是NSArray，不管声明的是NSMutableArray
    
    //初始化第二个数据源
    GroupController =[[ContactGroupTableViewController alloc] init];
    dataSourceIdentifier = @"Friend";
    
    
    [self SetBeginRefresh];
    [self AddSearchBarAndDisplayController];
    
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
    // 这个方法对search的Table和普通的table都有效，都会被调用
    
    
    
    if (tableView == _ContactTable) {
        [allContactName removeAllObjects];  //每次重置都清空，但是只是在这个Table里
        return [_CellData count];
    } else {
        return [searchContactName count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


//这里的内容都只是为了demo自定义, 数据从appdelegate传过来的。里面只有颜色和图片还有字体可以保留

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //创建CELL
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _searchCell = cell;
    }
    
    if (tableView == _ContactTable) {
        
        cell.separatorInset = UIEdgeInsetsMake(0, 44, 0, 0);
        //创建数据对象，用之前定义了的_CellData初始化
        NSDictionary *cellData = _CellData[indexPath.row];
        //把用户名取出来放到搜索数组中
        [allContactName addObject:[cellData objectForKey:@"friendEmail"]];
        
        //CELL的主体
        cell.Header.image = nil;
        if ([[cellData objectForKey:@"friendAlias"] isEqualToString:@""]) {
            [cellData setValue:[cellData objectForKey:@"friendEmail"] forKey:@"friendAlias"];
            cell.Name.text = [cellData objectForKey:@"friendEmail"];
        } else {
            cell.Name.text = [cellData objectForKey:@"friendAlias"];
        }
        cell.Name.font = [UIFont boldSystemFontOfSize:14];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.FileName.textColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        
        //Image不用在数据类中加，直接在这里加
        if ([[cellData objectForKey:@"friendStatus"] isEqualToString:@"activated"]) {
           cell.Header.image = [UIImage imageNamed:@"Friend@2x.png"];
        } else {
            cell.Header.image = [UIImage imageNamed:@"NoneRegisterFriend@2x.png"];
        }
    
        return cell;
        //高亮状态
        //cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        //cell.selectedBackgroundView.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
        // Configure the cell...
    } else {
    
        _searchCell.textLabel.text = searchContactName[indexPath.row];
        _searchCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        return _searchCell;
    }
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        globalIndexPath = indexPath;
        [dataInitiator initiateDataFordeleteContact: [[_CellData objectAtIndex:indexPath.row] objectForKey:@"friendEmail"]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //这里也要分开，点search和点普通的table不一样
    if (tableView == _ContactTable) {
        //因为要分别传递Group和Friend的详细数据，所以这里传值的时候也要分开传，值也要分开赋
        if (indexPath.row >= 0 && [dataSourceIdentifier  isEqual: @"Friend"]) {
            
            NSDictionary *cellData = _CellData[indexPath.row];
            segueTransName = [cellData objectForKey:@"friendAlias"];
            segueTransEmail = [cellData objectForKey:@"friendEmail"];
            segueTransActivated = [cellData objectForKey:@"friendStatus"];
            [self performSegueWithIdentifier:@"ContactDetailSegue" sender:self];
            
        } else if (indexPath.row >= 0 && [dataSourceIdentifier isEqual:@"Group"]) {
            
            //[dataInitiator initiateDataForContact_Group];
            //dataInitiator.contactCaller = self;
            NSString *cellData_Group = GroupController.CellData[indexPath.row]; //因为这里从服务器取回的_CellData装的只是单行的字符串，而不像之前是字典。
            segueTransGroup = cellData_Group;
            
            [self performSegueWithIdentifier:@"GroupDetailSegue" sender:self];
        }
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


 #pragma mark - segue传递数据
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([segue.identifier isEqual:@"ContactDetailSegue"]) {
         ContactDetailTableViewController *contactDetail = segue.destinationViewController;
         contactDetail.segueTransName = segueTransName;
         contactDetail.segueTransEmail = segueTransEmail;
         contactDetail.segueTransActivated = segueTransActivated;
     } else if ([segue.identifier isEqual:@"GroupDetailSegue"]) {
         ContactGroupDetailTableViewController *groupDetail = segue.destinationViewController;
         groupDetail.segueTransGroup = segueTransGroup;
     }

 }


#pragma mark SearchBar相关
- (void)AddSearchBarAndDisplayController {
    
    if (_ContactTable.tableHeaderView == nil) {
        //这里临时生成一个searchBar
        UISearchBar *_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        contactSearchBar = _searchBar;
        contactSearchBar.placeholder = @"Search Contact";
        //fileSearchBar.barTintColor = [UIColor colorWithWhite:1 alpha:1];
        contactSearchBar.delegate = self;
        [contactSearchBar setTranslucent:YES];
        _ContactTable.tableHeaderView = contactSearchBar;
        //默认隐藏SearchBar，设置TableView的默认位移
        //[_ContactTable setContentOffset:CGPointMake(0, _searchBar.frame.size.height) animated:NO];
        //[fileSearchBar sizeToFit];
        
        //临时生成一个searchDisplayController
        searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:contactSearchBar contentsController:self];
        searchDisplayController.searchResultsDataSource=self;
        searchDisplayController.searchResultsDelegate=self;
        [self.searchDisplayController setActive:NO];
        
    }
    
}

//searchBar的delegate方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //生成一个判断器
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", contactSearchBar.text];
    [searchContactName removeAllObjects];   //每次都清空
    //用判断器筛选原始数据(的文件名)，放入新数组
    //searchContactName = (NSMutableArray *)[allContactName filteredArrayUsingPredicate:predicate]; 典型错误！强制类型转换也没有用，后者返回的NSArray，赋值给前者，前者被变成了NSArray，下次调用removeAllObject出错
    [searchContactName addObjectsFromArray:[allContactName filteredArrayUsingPredicate:predicate]];
    
}


#pragma mark 滑动隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    UIView *searchBarView = contactSearchBar.subviews[0];
    
    [searchBarView.subviews[1] resignFirstResponder];
}

#pragma mark Segment相关
//切换按钮，切换数据源
- (IBAction)SegmentChange:(id)sender {
    
    NSInteger selectedSegment = _ContactSegment.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //NSLog(@"当前数据源为self");
        [_ContactTable setDelegate:self];
        [_ContactTable setDataSource:self];
        [dataInitiator initiateDataForContact];
        dataSourceIdentifier = @"Friend";
        [_ContactTable reloadData];
    } else if (selectedSegment == 1) {
        [dataInitiator initiateDataForContact_Group];   //执行之后，全局变量里已经装的是group了，之后在回调函数内，会执行reload
        GroupController.dataInitiator = dataInitiator;  //这个用来在那个数据源里执行删除操作，callAPI用
        GroupController.contactTable = _ContactTable;
        dataInitiator.groupCaller = GroupController;
        _ContactTable.dataSource = GroupController;
        dataSourceIdentifier = @"Group";
        [_ContactTable reloadData];
    }
    
}

#pragma mark 下拉刷新
//结束事件(数据处理)
- (void)RefreshData {
    
    //由于每次初始化都会调用，所以判断下是不是正在刷新
    if (self.refreshControl.refreshing) {
        //定义刷新过程的提示信息
        //时间格式定义和时间获取
        NSString *systemDate = nil;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        systemDate = [dateFormatter stringFromDate:[NSDate date]];
        //下拉显示的内容
        NSString *titleString = NSLocalizedString(@"Recent update at ", nil);
        NSString *recentUpdateString = [NSString stringWithFormat:@"%@%@", titleString,systemDate];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:recentUpdateString];
        
        [self.refreshControl endRefreshing];
    }
    
    //[self.tableView reloadData];
}

//刷新中事件(动作)
- (void)RefreshTableViewAction: (UIRefreshControl *)refresh {
    
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing", nil)];
        //[self performSelector:@selector(RefreshData) withObject:nil afterDelay:2]; 这句肯定要在回调函数里处理了
        if (_ContactSegment.selectedSegmentIndex == 0) {
            [dataInitiator initiateDataForContact];
        } else {
            [dataInitiator initiateDataForContact_Group];
        }   //这一句加来，重新获取数据，并且回调函数里面已经有reload了，注意，由于两个界面共用一个刷新，所以必须区分开
    }
}

//监听事件(监听事件并且开始响应)
- (void)SetBeginRefresh {
    
    //生成一个refresh控制器，并且不用管理它的frame，系统会自己管理
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [ColorFromHex getColorFromHex:@"#929292"];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to update", nil)];
    
    //UIRefreshControl会触发一个UIContentEventValueChanged事件，通过监听事件，我们可以进行需要的操作
    [refresh addTarget:self action:@selector(RefreshTableViewAction:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
}

#pragma mark 删除联系人后修改CellData
- (void)editCellData {
    [_CellData removeObjectAtIndex:globalIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[globalIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    NSLog(@"现在的第%zi行已经被移除, 还剩下%zi",globalIndexPath.row,[_CellData count]);
}

#pragma mark - 计时隐藏alert
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
    //这个userInfo可以将这个函数里的某个参数，装进timer中，传递给别的函数
    [alert show];
}
- (void)timerForHideAlert: (NSTimer *)timer {
    UIAlertView *alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark loading进度条
- (void)showLoadingAlertAt:(UIView *)view {
    _loadingAlert = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(30, 260, 260, 50) dotStyle:TYDotIndicatorViewStyleRound dotColor:[UIColor colorWithRed:0.85f green:0.86f blue:0.88f alpha:1.00f] dotSize:CGSizeMake(15, 15) withBackground:NO];
    _loadingAlert.backgroundColor = [UIColor colorWithRed:0.20f green:0.27f blue:0.36f alpha:0.9f];
    _loadingAlert.layer.cornerRadius = 5.0f;
    [_loadingAlert startAnimating];
    [view addSubview:_loadingAlert];
}

@end
