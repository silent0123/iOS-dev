//
//  FileDetailViewController.h
//  uSav-newUI
//
//  Created by Luca on 11/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorFromHex.h"

@interface FileDetailViewController : UIViewController

//公共变量，用于接收从上个页面传来的值
@property (strong, nonatomic) NSString *segueTransFileName;
@property (strong, nonatomic) NSString *segueTransBytes;

@property (weak, nonatomic) IBOutlet UIButton *PreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *OpenButton;
@property (weak, nonatomic) IBOutlet UILabel *FileName;
@property (weak, nonatomic) IBOutlet UILabel *Bytes;


@end
