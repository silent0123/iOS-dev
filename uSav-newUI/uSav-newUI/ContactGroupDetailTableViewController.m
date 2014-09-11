//
//  ContactGroupDetailTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 13/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "ContactGroupDetailTableViewController.h"

@interface ContactGroupDetailTableViewController (){

    NSString *segueTransName;
    NSString *seguetransEmail;
    
}
@end

@implementation ContactGroupDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _segueTransGroup;
    
    //临时
    //_CellData = [InitiateWithData initiateDataForContact];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    } else if (section == 2) {
        return 1;
    } else {
        return [_CellData count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"Members", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    ContactDataBase *cellData = _CellData[indexPath.row];
    
    cell.detailTextLabel.text = @"";
    cell.textLabel.text = @"";
    
    NSString *numString = [NSString stringWithFormat:@"%zi", [_CellData count]];
    
    switch (section) {
        case 0:
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Group Name", @"remark string");
                cell.detailTextLabel.text = NSLocalizedString(_segueTransGroup, nil);
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            } else if (row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Num of Members", @"num string");
                cell.detailTextLabel.text = NSLocalizedString(numString, nil);
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            } else {
                cell.textLabel.text = NSLocalizedString(@"Add new member", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case 1: {
            //两个View都临时生成的，因为不想再到storyboard里去修改cell，还得单独加cell类了
            //显示的内容还没有区分是哪个组的
            UILabel *FriendName = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, 207, 21)];
            FriendName.text = cellData.friendAlias;
            FriendName.font = [UIFont boldSystemFontOfSize:14];
            [cell addSubview:FriendName];
            //增加一个头像框
            UIImageView *Header = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Friend@2x.png"]];
            Header.frame = CGRectMake(8, 8, 30, 30);
            [cell addSubview:Header];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            cell.textLabel.text = NSLocalizedString(@"Delete and Leave", nil);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E8251E"];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row == 2) {
        UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [comingSoon show];
    } else if (section == 1) {
        ContactDataBase *cellData = _CellData[row];
        segueTransName = cellData.friendAlias;
        seguetransEmail = cellData.friendEmail;
        [self performSegueWithIdentifier:@"MemberDetailSegue" sender:self];
    } else {
        [_CellData removeObject:_CellData[row]];
        [self.navigationController popViewControllerAnimated:YES];
    
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ContactDetailTableViewController *contactDetail = segue.destinationViewController;
    contactDetail.segueTransName = segueTransName;
    contactDetail.segueTransEmail = seguetransEmail;
}


@end
