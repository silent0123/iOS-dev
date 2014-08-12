//
//  FileDetailViewController.m
//  uSav-newUI
//
//  Created by Luca on 11/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileDetailViewController.h"

@interface FileDetailViewController ()

@end

@implementation FileDetailViewController

- (void)viewDidLoad {
    
    _PreviewButton.layer.masksToBounds = YES;
    _PreviewButton.layer.cornerRadius = 4;
    //button要用这个设置字体，不能用titlelable，因为button是分状态的。
    [_PreviewButton setTitle:@"Preview" forState:UIControlStateNormal];
    [_PreviewButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _PreviewButton.titleLabel.font = [UIFont systemFontOfSize:12];  //大小可以这样设置
    _PreviewButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    _OpenButton.layer.masksToBounds = YES;
    _OpenButton.layer.cornerRadius = 4;
    [_OpenButton setTitle:@"Open in" forState:UIControlStateNormal];
    [_OpenButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    _OpenButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _OpenButton.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
    
    //通过上个页面传来的值设置当前页面
    _FileName.text = _segueTransFileName;
    _FileName.font = [UIFont boldSystemFontOfSize:14];
    self.title = _segueTransFileName;
    
    _Bytes.text = _segueTransBytes;
    _Bytes.font = [UIFont systemFontOfSize:12];
    _Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    
    //NSLog(@"%@", _OpenButton.titleLabel.text);
    [super viewDidLoad];
    

    
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
