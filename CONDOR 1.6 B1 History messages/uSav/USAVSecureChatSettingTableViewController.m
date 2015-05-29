//
//  USAVSecureChatSettingTableViewController.m
//  CONDOR
//
//  Created by Luca on 29/5/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureChatSettingTableViewController.h"
#import "SGDUtilities.h"

#define CONFIRM_LIMIT_CHANGE_ALERT_TAG 100
#define CONFIRM_ERASE_SESSION_MESSAGE_TAG 101

@interface USAVSecureChatSettingTableViewController () {
    
    NSInteger selectedLimit;
}

@end

@implementation USAVSecureChatSettingTableViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Done", nil)];
    [self.navigationItem setTitle:NSLocalizedString(@"More", nil)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"] >= 0) {
        
        selectedLimit = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return NSLocalizedString(@"Default Viewing Limit", nil);
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Default viewing limit will be assigned to receiver automatically during message sending", nil);
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecureChatSettingCell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%zi time", nil), 1];
            if (selectedLimit == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 1){
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%zi times", nil), 3];
            if (selectedLimit == 3) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 2){
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%zi times", nil), 5];
            if (selectedLimit == 5) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%zi times", nil), 10];
            if (selectedLimit == 10) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    } else {
        
        cell.textLabel.text = NSLocalizedString(@"EraseAllMessagesInThisSession", @"");
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:0.91 green:0.145 blue:0.118 alpha:1];
    }
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                selectedLimit = 1;
                break;
            case 1:
                selectedLimit = 3;
                break;
            case 2:
                selectedLimit = 5;
                break;
            case 3:
                selectedLimit = 10;
                break;
            default:
                break;
        }
        
        [tableView reloadData];
        
    } else if (indexPath.section == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:[NSString stringWithFormat:NSLocalizedString(@"This operation will erase history messages in this chatting session", nil), selectedLimit] delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", nil) otherButtonTitles:NSLocalizedString(@"OkKey", nil), nil];
        alert.delegate = self;
        alert.tag = CONFIRM_ERASE_SESSION_MESSAGE_TAG;
        [alert show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backBtnPressed:(id)sender {
    
    [self popChatSettingViewController];
}

- (IBAction)doneBtnPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Default setting of viewing limit for all new messges and files will be changed to %zi time(s)", nil), selectedLimit] delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", nil) otherButtonTitles:NSLocalizedString(@"OkKey", nil), nil];
    alert.delegate = self;
    alert.tag = CONFIRM_LIMIT_CHANGE_ALERT_TAG;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == CONFIRM_LIMIT_CHANGE_ALERT_TAG) {
        if (buttonIndex == 1) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:selectedLimit forKey:@"DefaultLimit"];
            [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", nil) message:nil delegate:self];
            
            [self performSelector:@selector(popChatSettingViewController) withObject:nil afterDelay:0.8];
        }
    } else {
        if (buttonIndex == 1) {
            
            if (self.messageFolder) {
                
                [self clearFilesAtDirectoryPath:self.messageFolder];
                [self.secureChatDelegate.resultArray removeAllObjects];
                [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", nil) message:nil delegate:self];
            } else {
                [SGDUtilities showErrorMessageWithTitle:NSLocalizedString(@"Failed", nil) message:nil delegate:self];
            }
            
            
            
        }
    }

}

- (void)popChatSettingViewController{
    
    [self.secureChatDelegate.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - others
- (void)clearFilesAtDirectoryPath: (NSString *)path {
    
    //每次启动清空decrypt文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *allFile = [[NSMutableArray alloc] initWithCapacity:0];
    
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:path error:nil]];
    NSError *error;
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:filePath error:&error];
    }
}
@end
