//
//  USAVTimeoutTableViewController.m
//  CONDOR
//
//  Created by Luca on 9/2/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVTimeoutTableViewController.h"
#import "SGDUtilities.h"

@interface USAVTimeoutTableViewController ()

@end

@implementation USAVTimeoutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.navigationItem.title = NSLocalizedString(@"Login Timeout", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonPressed:)];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    
    
    self.timeoutSwitch = [[UISwitch alloc] init];
    self.timeoutSwitch.onTintColor = [UIColor colorWithWhite:0.2 alpha:1];
    [self.timeoutSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    
    self.timeoutSlider = [[UISlider alloc] init];
    self.timeoutSlider.minimumValue = 1;
    self.timeoutSlider.maximumValue = 100;
    self.timeoutSlider.minimumTrackTintColor = [UIColor colorWithWhite:0.2 alpha:1];
    [self.timeoutSlider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];

    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isSessionTimeOut"] == nil || ![[NSUserDefaults standardUserDefaults] integerForKey:@"isSessionTimeOut"]) {
        self.timeoutEnabled = NO;
        [self.timeoutSwitch setOn:NO];
    } else {
        self.timeoutEnabled = YES;
        [self.timeoutSwitch setOn:YES];
    }
    
    //默认为30s
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sessionTimeOutInterval"] == nil || ![[NSUserDefaults standardUserDefaults] floatForKey:@"sessionTimeOutInterval"]) {
        self.timeoutSlider.value = 30;
        self.timeInterval = self.timeoutSlider.value;
    } else {
        //保存的值是秒数，这里设置时候设置的是分钟
        self.timeoutSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"sessionTimeOutInterval"]/60;
        self.timeInterval = self.timeoutSlider.value;
    }
    
    [self.tableView reloadData];
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
    if (self.timeoutEnabled) {
        return 2;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSInteger *row = [indexPath row];
    NSInteger *section = [indexPath section];
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeoutCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    //选中颜色
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:(255.0/255.0) alpha:1];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    if (section == 0) {
        cell.textLabel.text = NSLocalizedString(@"Enable Timeout", nil);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.accessoryView = self.timeoutSwitch;
    } else {
        cell.textLabel.text = [NSLocalizedString(@"Force Logout After ", nil) stringByAppendingString:[NSString stringWithFormat:@"%.0f (min)", self.timeInterval]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.accessoryView = self.timeoutSlider;
    }
    
    
    return cell;
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

- (void)switchChanged {


    if ([self.timeoutSwitch isOn]) {
        self.timeoutEnabled = YES;
    } else {
        self.timeoutEnabled = NO;
    }
    
    [self.tableView reloadData];
}

- (void)sliderChanged {
    
    self.timeInterval = self.timeoutSlider.value;
    [self.tableView reloadData];
    
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if (self.timeoutSlider.value > 0) {
        //这个页面滑动的值是s，乘以60表示分钟
        [[NSUserDefaults standardUserDefaults] setFloat:self.timeInterval * 60 forKey:@"sessionTimeOutInterval"];
    }
    
    if ([self.timeoutSwitch isOn]) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.timeoutEnabled forKey:@"isSessionTimeOut"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:self.timeoutEnabled forKey:@"isSessionTimeOut"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonPressed: (id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
