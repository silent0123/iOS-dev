//
//  USAVSingleFileLogDetailViewController.h
//  uSav
//
//  Created by Luca on 29/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAVSingleFileLogDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@property (weak, nonatomic) IBOutlet UILabel *operation;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) NSString *stringOfContent2;
@property (strong, nonatomic) NSString *stringOfContent;
@property (strong, nonatomic) NSString *stringOfDate;
@property (strong, nonatomic) NSString *stringOfOperation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;

- (IBAction)cancelBtnPressed:(id)sender;
@end
