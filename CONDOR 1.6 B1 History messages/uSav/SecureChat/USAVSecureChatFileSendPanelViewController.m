//
//  USAVSecureChatFileSendPanelViewController.m
//  CONDOR
//
//  Created by Luca on 27/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureChatFileSendPanelViewController.h"

@interface USAVSecureChatFileSendPanelViewController ()

@end

@implementation USAVSecureChatFileSendPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustUIforPanel {
    [self.sendPanelAlbumBtn setImage:[UIImage imageNamed:@"Function_album_r_B"] forState:UIControlStateHighlighted];
    [self.sendPanelCameraBtn setImage:[UIImage imageNamed:@"Function_cam_s_B"] forState:UIControlStateHighlighted];
    [self.sendPanelSecureAlbumBtn setImage:[UIImage imageNamed:@"Function_album_s_B"] forState:UIControlStateHighlighted];
    [self.sendPanelSecureFolderBtn setImage:[UIImage imageNamed:@"Function_folder_s_B"] forState:UIControlStateHighlighted];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendPanelAlbumBtnPressed:(id)sender {
}

- (IBAction)sendPanelCameraBtnPressed:(id)sender {
}

- (IBAction)sendPanelSecureFolderBtnPressed:(id)sender {
}

- (IBAction)sendPanelSecureAlbumBtnPressed:(id)sender {
}

@end
