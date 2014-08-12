//
//  PasswordViewController.h
//  uSav-newUI
//
//  Created by Luca on 11/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *CurrentPassword;
@property (weak, nonatomic) IBOutlet UITextField *NewPassword;
@property (weak, nonatomic) IBOutlet UITextField *ConfirmPassword;

@end
