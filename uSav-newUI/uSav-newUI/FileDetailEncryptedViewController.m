//
//  FileDetailEncryptedViewController.m
//  uSav-newUI
//
//  Created by Luca on 12/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileDetailEncryptedViewController.h"

@interface FileDetailEncryptedViewController ()

@end

@implementation FileDetailEncryptedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //照样三个按钮设置
    _DecryptionButton.layer.masksToBounds = YES;
    _DecryptionButton.layer.cornerRadius = 4;
    //button要用这个设置字体，不能用titlelable，因为button是分状态的。
    [_DecryptionButton setTitle:@"Decrypt" forState:UIControlStateNormal];
    [_DecryptionButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _DecryptionButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];  //大小可以这样设置
    _DecryptionButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    
    _PermissionButton.layer.masksToBounds = YES;
    _PermissionButton.layer.cornerRadius = 4;
    [_PermissionButton setTitle:@"Permission" forState:UIControlStateNormal];
    [_PermissionButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _PermissionButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _PermissionButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    _ShareButton.layer.masksToBounds = YES;
    _ShareButton.layer.cornerRadius = 4;
    [_ShareButton setTitle:@"Audit" forState:UIControlStateNormal];
    [_ShareButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _ShareButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _ShareButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    

    _CenterPicture.image = [UIImage imageNamed:@"BiguSav@2x.png"]; //这里暂时没有写根据颜色换大图片的
    
    //通过上个页面传来的值设置当前页面
    _FileName.text = _segueTransFileName;
    _FileName.font = [UIFont boldSystemFontOfSize:14];
    self.title = _segueTransFileName;
    
    _Bytes.text = _segueTransBytes;
    _Bytes.font = [UIFont systemFontOfSize:12];
    _Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
