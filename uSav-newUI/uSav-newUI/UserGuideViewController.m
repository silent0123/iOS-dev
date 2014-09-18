//
//  UserGuideViewController.m
//  uSav-newUI
//
//  Created by Luca on 3/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "UserGuideViewController.h"

@interface UserGuideViewController ()

@end

@implementation UserGuideViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initGuide];
    
    self.navigationController.navigationBarHidden = YES;    //隐藏Navigation Bar
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchToExit)];
    gestureRecognizer.delegate = self;
    gestureRecognizer.numberOfTapsRequired = 1; //点击次数需求
    gestureRecognizer.numberOfTouchesRequired = 1;  //手指数目
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 创建一个scrollview的userguide
- (void)initGuide {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 640)];
    [scrollView setContentSize:CGSizeMake(1600, 0)];
    [scrollView setPagingEnabled:YES];  //分页模式
    
    [scrollView setBounces:NO];   //弹跳效果关闭
    
    UIImageView *imageView_0 = [[UIImageView alloc] initWithFrame:CGRectMake(0 * 320, 0, 320, 640)];
    [imageView_0 setImage:[UIImage imageNamed:@"ImageView_0@2x.png"]];
    [scrollView addSubview:imageView_0];
    
    UIImageView *imageView_1 = [[UIImageView alloc] initWithFrame:CGRectMake(1 * 320, 0, 320, 640)];
    [imageView_1 setImage:[UIImage imageNamed:@"ImageView_1@2x.png"]];
    [scrollView addSubview:imageView_1];
    
    UIImageView *imageView_2 = [[UIImageView alloc] initWithFrame:CGRectMake(2 * 320, 0, 320, 640)];
    [imageView_2 setImage:[UIImage imageNamed:@"ImageView_2@2x.png"]];
    [scrollView addSubview:imageView_2];
    
    UIImageView *imageView_3 = [[UIImageView alloc] initWithFrame:CGRectMake(3 * 320, 0, 320, 640)];
    [imageView_3 setImage:[UIImage imageNamed:@"ImageView_3@2x.png"]];
    [scrollView addSubview:imageView_3];
    
    UIImageView *imageView_4 = [[UIImageView alloc] initWithFrame:CGRectMake(4 * 320, 0, 320, 640)];
    [imageView_4 setImage:[UIImage imageNamed:@"ImageView_4@2x.png"]];
    [scrollView addSubview:imageView_4];
    
    //在第四页加一个按钮，设置样式，点击之后跳转
    imageView_4.userInteractionEnabled = YES;
    UIButton *button_4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button_4.layer setMasksToBounds:YES];
    [button_4.layer setCornerRadius:2.0];
    button_4.backgroundColor = [ColorFromHex getColorFromHex:@"#FFFFFF"];
    [button_4 setFrame:CGRectMake(88, 180, 140, 36)];
    [button_4 setTitle:NSLocalizedString(@"Begin", nil) forState:UIControlStateNormal];
    button_4.titleLabel.font = [UIFont systemFontOfSize:14];
    [button_4 setTitleColor:[ColorFromHex getColorFromHex:@"#ED6F00"] forState:UIControlStateNormal];
    [button_4 addTarget:self action:@selector(pressToJump) forControlEvents:UIControlEventTouchUpInside];
    [imageView_4 addSubview:button_4];
    
    [self.view addSubview:scrollView];
}

- (void)pressToJump {
    [self performSegueWithIdentifier:@"UserGuideFinishedSegue" sender:self];
}

#pragma mark status bar颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark gesture delegate方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark gesture处理函数
- (void)touchToExit {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
