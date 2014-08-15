//
//  FileDetailEncryptedViewController.h
//  uSav-newUI
//
//  Created by Luca on 12/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"

@interface FileDetailEncryptedViewController : UIViewController

@property (strong, nonatomic) NSString *segueTransFileName;
@property (strong, nonatomic) NSString *segueTransBytes;
@property (strong, nonatomic) NSString *segueTransColor;


@property (weak, nonatomic) IBOutlet UIImageView *CenterPicture;
@property (weak, nonatomic) IBOutlet UILabel *FileName;
@property (weak, nonatomic) IBOutlet UILabel *Bytes;
@property (weak, nonatomic) IBOutlet UIButton *DecryptionButton;
@property (weak, nonatomic) IBOutlet UIButton *PermissionButton;
@property (weak, nonatomic) IBOutlet UIButton *ShareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *OtherButton;

@end
