//
//  USAVLanguageTableViewController.h
//  CONDOR
//
//  Created by Luca on 10/4/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundleLocalization.h"
#import "USAVAppDelegate.h"


@interface USAVLanguageTableViewController : UITableViewController <UIAlertViewDelegate>


@property (strong, nonatomic) BundleLocalization *languageControl;
@property (strong, nonatomic) UIAlertView *alert;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;

- (IBAction)barkBtnPressed:(id)sender;



@end
