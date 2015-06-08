//
//  USAVSecureQATableViewController.h
//  CONDOR
//
//  Created by Luca on 25/2/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAVSecureQATableViewController : UITableViewController

@property (strong, nonatomic) UITextField *secureQuestionTextField;
@property (strong, nonatomic) UITextField *secureAnswerTextField;
@property (strong, nonatomic) UIBarButtonItem *homeBtn;
@property (strong, nonatomic) UIBarButtonItem *doneBtn;
@property (strong, nonatomic) UIAlertView *alert;

@end
