//
//  USAVSecureChatListTableViewController.m
//  CONDOR
//
//  Created by Luca on 26/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureChatListTableViewController.h"

@interface USAVSecureChatListTableViewController ()

@end

@implementation USAVSecureChatListTableViewController

- (void)viewDidAppear:(BOOL)animated {
    [self.view.window setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar.topItem setTitle:NSLocalizedString(@"Secure Chat", nil)];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //navigation bar
    self.navigationController.navigationBarHidden = NO;
    
    self.resultArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.resultDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary *dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Himst", @"account", @"file://xxx.docx", @"lastFile", @"1", @"hasRead",nil];
    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Luca", @"account", @"file://23939301T22131231/sada.usam", @"lastFile", @"0", @"hasRead",nil];
    NSMutableDictionary *dic3 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Cyng", @"account", @"file://afsadf/adf.xlsx", @"lastFile", @"0", @"hasRead",nil];
    
    [self.resultArray addObjectsFromArray:@[dic1, dic2, dic3]];
    
    //tableview background
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.resultArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    USAVSecureChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecureChatListCell" forIndexPath:indexPath];
    
    NSInteger *row = indexPath.row;
    
    //Load single data
    self.resultDic = [self.resultArray objectAtIndex:row];
    
    cell.headerImage.frame = CGRectMake(10, 5, 46, 46);
    cell.headerImage.layer.masksToBounds = YES;
    cell.headerImage.layer.cornerRadius = 3;
    cell.backgroundColor = [UIColor clearColor];
    cell.accountLabel.text = [self.resultDic objectForKey:@"account"];
    cell.detailLabel.text = [self.resultDic objectForKey:@"lastFile"];
    [cell.unreadMessageImageView setHidden:[[self.resultDic objectForKey:@"hasRead"] boolValue]];
    
    return cell;
}


#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"SecureChatSegue" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.resultArray removeObjectAtIndex:indexPath.row];
        
        [self.tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (IBAction)backBtnPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.fileViewControllerDelegate showDashBoard];
}

- (IBAction)addBtnPressed:(id)sender {
    
}
@end
