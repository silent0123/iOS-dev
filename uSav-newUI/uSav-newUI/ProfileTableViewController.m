//
//  ProfileTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 13/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "ProfileTableViewController.h"

@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.scrollEnabled = NO;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    }
    else if (section ==1) {
        return 3;
    } else {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"", nil);
    } else {
        return NSLocalizedString(@"", nil);
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 54;
    } else {
        return 44;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (section) {
        case 0:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Name", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = @"DemoUser A";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                //位置调整, 因为格子大小有调整
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 10, cell.frame.size.width, cell.frame.size.height);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Email", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = @"Demo.A@nwstor.com";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                //位置调整, 因为格子大小有调整
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 10, cell.frame.size.width, cell.frame.size.height);
            }
            break;
        case 1:
            if (row == 0){
                cell.textLabel.text = NSLocalizedString(@"Phone", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = @"(+852)3999 2666";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            } else if (row == 1){
                cell.textLabel.text = NSLocalizedString(@"Gender", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = @"Male";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.textLabel.text = NSLocalizedString(@"Region", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = @"Hong Kong";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case 2:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Account Type", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = @"Club";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            } else {
                cell.textLabel.text = NSLocalizedString(@"Num of Keys", nil);
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.detailTextLabel.text = @"17";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
            if (row == 0) {
                UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [comingSoon show];
            } else {
                UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [comingSoon show];
            }
            break;
        case 1:
            if (row == 1) {
                UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [comingSoon show];
            }
            else if (row == 2) {
                UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [comingSoon show];
            }
        default:
            break;
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
