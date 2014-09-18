//
//  ContactDetailTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 13/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "ContactDetailTableViewController.h"

@interface ContactDetailTableViewController ()

@end

@implementation ContactDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    
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
    tableView.scrollEnabled = NO;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 1){
        return 3;
    } else {
        return 1;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 60;
    } else {
        return 44;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    cell.detailTextLabel.text = @"";
    
    
    switch (section) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Remark", @"remark string");
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.detailTextLabel.text = NSLocalizedString(_segueTransName, nil);
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Email", @"email string");
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = NSLocalizedString(_segueTransEmail, nil);
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            } else if (row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Groupname", @"临时的");
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            } else {
                cell.textLabel.text = NSLocalizedString(@"uSav status", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = NSLocalizedString(_segueTransActivated, nil);
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            }
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Add to group", nil);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
            break;
        default:
            cell.textLabel.text = NSLocalizedString(@"Delete", nil);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E8251E"];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"ChangeRemarkSegue" sender:self];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
