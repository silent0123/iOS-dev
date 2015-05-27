//
//  USAVProfileEditPassViewController.h
//  uSav
//
//  Created by NWHKOSX49 on 15/12/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface USAVProfileEditPassViewController : UIViewController
<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *oldPassTxt;
@property (weak, nonatomic) IBOutlet UILabel *nPassTxt;
@property (weak, nonatomic) IBOutlet UILabel *verifyPassTxt;

@property (weak, nonatomic) IBOutlet UITextField *oldPass;
@property (weak, nonatomic) IBOutlet UITextField *nPass;
@property (weak, nonatomic) IBOutlet UITextField *verifyPass;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *CancleBtn;
@property (strong, nonatomic) IBOutlet UINavigationItem *EditPassItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ConfirmBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)oldPassTextChanged:(id)sender;
- (IBAction)nPassTextChanged:(id)sender;
- (IBAction)verifyPassTextChanged:(id)sender;
- (IBAction)cancelBtnPressed:(id)sender;

@end
