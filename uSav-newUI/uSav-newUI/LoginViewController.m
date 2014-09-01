//
//  LoginViewController.m
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController (){
    BOOL isTransformed;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isTransformed = NO;
    
    [_Username setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_Username setValue:[UIColor colorWithWhite:1 alpha:0.8] forKeyPath:@"_placeholderLabel.textColor"];
    _Username.font = [UIFont systemFontOfSize:14];
    _Username.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    [_Password setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_Password setValue:[UIColor colorWithWhite:1 alpha:0.8] forKeyPath:@"_placeholderLabel.textColor"];
    _Password.font = [UIFont systemFontOfSize:14];
    _Password.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    //圆角
    [_SignupButton.layer setMasksToBounds:YES];
    [_SignupButton.layer setCornerRadius:2.0];
    
    [_SigninButton.layer setMasksToBounds:YES];
    [_SigninButton.layer setCornerRadius:2.0];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 点击空白处隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_Username resignFirstResponder];
    [_Password resignFirstResponder];
}
  
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)SigninClick:(id)sender {
    [self performSegueWithIdentifier:@"SigninSuccessSegue" sender:self];
}
- (IBAction)SignupClick:(id)sender {
}

- (IBAction)ForgetClick:(id)sender {
}

#pragma mark 编辑时上移
- (IBAction)UsernameEditBegin:(id)sender {
    
    if (!isTransformed) {
        //创建一个线程来控制视图上移，因为如果直接在这个线程里做的话，会出现一个视觉错误
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(Change:) object:nil];
        //状态标识位切换
        isTransformed = YES;
        //线程开始
        [thread start];
    }
}

- (IBAction)PasswordEditBegin:(id)sender {
    
    if (!isTransformed) {
        //创建一个线程来控制视图上移，因为如果直接在这个线程里做的话，会出现一个视觉错误
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(Change:) object:nil];
        //状态标识位切换
        isTransformed = YES;
        //线程开始
        [thread start];
    }
    
}

#pragma mark 上移函数
- (void)Change:(id)sender{
    //线程睡眠0.2秒，实现延迟上弹
    [NSThread sleepForTimeInterval:0.2];
    //创建仿射变换，平移(0,-100)
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,-100);
    //对当前试图使用仿射变换
    self.view.transform = transform;
}
@end
