//
//  USAVLanguageTableViewController.m
//  CONDOR
//
//  Created by Luca on 10/4/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVLanguageTableViewController.h"
#import "SGDUtilities.h"

@interface USAVLanguageTableViewController () {
    NSInteger selectedIndex;
}

@end

@implementation USAVLanguageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    self.backBtn.image = [UIImage imageNamed:@"icon_back_blue"];
    [self.navigationItem setTitle:NSLocalizedString(@"LanguageSetting", @"")];
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

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"English", nil);
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"简体中文", nil);
    }
    
    
    if ([[BundleLocalization sharedInstance].language isEqualToString:@"zh-Hans"]) {
        //chinese simplified
        
        if (indexPath.row == 1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else if ([[BundleLocalization sharedInstance].language isEqualToString:@"en"]) {
        //english
        
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else {
        //others using english
        
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    selectedIndex = indexPath.row;
    
    if (selectedIndex == 0) {
        
        if (!(cell.accessoryType == UITableViewCellAccessoryCheckmark)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Language" message:[NSString stringWithFormat:@"Language will be changed to %@", cell.textLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
            [alert show];
        }
        

    } else if (selectedIndex == 1) {
        
        if (!(cell.accessoryType == UITableViewCellAccessoryCheckmark)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改语言" message:[NSString stringWithFormat:@"语言会被设置为 %@", cell.textLabel.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [alert show];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //cancel
        [self.tableView reloadData];
    } else {
        //confirm
        if (selectedIndex == 0) {
            [[BundleLocalization sharedInstance] setLanguage:@"en"];
        } else {
            [[BundleLocalization sharedInstance] setLanguage:@"zh-Hans"];
        }
        
        
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"Changing", nil) delegate:self];
        [self performSelector:@selector(reloadLocalizationAfterDelay) withObject:nil afterDelay:1.5];
        
    }

    
}

- (void)reloadLocalizationAfterDelay {
    
//    USAVAppDelegate *delegate = (USAVAppDelegate *)[UIApplication sharedApplication].delegate;
//    NSString *storyboardName = @"MainStoryboard_iPhone"; // Your storyboard name
//    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:storyboardName bundle:[BundleLocalization sharedInstance].localizationBundle];
    
    //reset navi controller
    //delegate.navigationController = [storybaord instantiateInitialViewController];
    //delegate.window.rootViewController = delegate.navigationController;
    
    //then will post notification to let appdelegate set the navigationbar background

    [[NSNotificationCenter defaultCenter] postNotificationName:@"LanguageChanged" object:nil];
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", nil) message:nil delegate:self];
    [self.navigationController popViewControllerAnimated:YES];
    
}

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

- (IBAction)barkBtnPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
