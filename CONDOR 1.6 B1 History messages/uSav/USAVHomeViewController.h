//
//  USAVHomeViewController.h
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAVLoginViewController.h"
#import "USAVGuidedDecryptViewController.h"
#import "USAVGuidedEncryptViewController.h"
#import "USAVFileViewController.h"

@interface USAVHomeViewController : UIViewController
    <USAVLoginViewControllerDelegate, USAVGuidedDecryptViewControllerDelegate, USAVGuidedEncryptViewControllerDelegate, USAVFileViewControllerDelegate, UIAlertViewDelegate, USAVFileViewerViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *guidedEncryptShareLabel;
@property (strong, nonatomic) IBOutlet UILabel *guidedDecryptViewLabel;
@property (strong, nonatomic) IBOutlet UILabel *expertModeLabel;
@property (strong, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIButton *btnDecrypt;
@property (weak, nonatomic) IBOutlet UIButton *btnEncrypt;

- (IBAction)guidedEncryptBtnPressed:(id)sender;
- (IBAction)guidedDecryptBtnPressed:(id)sender;
- (IBAction)expertModeBtnPressed:(id)sender;

@end
