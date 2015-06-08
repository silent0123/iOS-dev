//
//  USAVTimeoutTableViewController.h
//  CONDOR
//
//  Created by Luca on 9/2/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAVTimeoutTableViewController : UITableViewController

@property (strong, nonatomic) UISwitch *timeoutSwitch;
@property (strong, nonatomic) UISlider *timeoutSlider;
@property (assign, nonatomic) BOOL timeoutEnabled;
@property (assign, nonatomic) CGFloat timeInterval;
- (IBAction)doneButtonPressed:(id)sender;

@end
