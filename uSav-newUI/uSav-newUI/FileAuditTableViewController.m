//
//  FileAuditTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileAuditTableViewController.h"

@implementation FileAuditTableViewController
- (void)viewDidLoad {
    
    self.title = NSLocalizedString(@"Audit Log", nil);
    
    _CellData = [InitiateWithData initiateDataForLogs_FileAudit];
    
    //刷新
    [self SetBeginRefresh];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileAuditCell" forIndexPath:indexPath];
    
    cell.userInteractionEnabled = NO;
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
        
        cell.LogSuccess.text = NSLocalizedString(@"SUCCESSFUL", nil);
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
