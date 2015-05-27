//
//  USAVSecureChatFileSendPanelViewController.h
//  CONDOR
//
//  Created by Luca on 27/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAVSecureChatFileSendPanelViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *sendPanelAlbumBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendPanelCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendPanelFileBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendPanelSecureFolderBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendPanelSecureAlbumBtn;


- (IBAction)sendPanelAlbumBtnPressed:(id)sender;
- (IBAction)sendPanelCameraBtnPressed:(id)sender;
- (IBAction)sendPanelSecureFolderBtnPressed:(id)sender;
- (IBAction)sendPanelSecureAlbumBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendPanelFileBtnPressed;



@end
