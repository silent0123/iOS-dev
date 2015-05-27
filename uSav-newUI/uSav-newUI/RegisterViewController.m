//
//  RegisterViewController.m
//  uSav-newUI
//
//  Created by Luca on 2/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController (){
    BOOL isTransformed;
}

@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) TYDotIndicatorView *loadingAlert;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_Username setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_Username setValue:[UIColor colorWithWhite:1 alpha:0.8] forKeyPath:@"_placeholderLabel.textColor"];
    
    [_Password setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_Password setValue:[UIColor colorWithWhite:1 alpha:0.8] forKeyPath:@"_placeholderLabel.textColor"];
    
    [_ConfirmPassword setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_ConfirmPassword setValue:[UIColor colorWithWhite:1 alpha:0.8] forKeyPath:@"_placeholderLabel.textColor"];
    
#warning 测试用账户
    //外部账户
    //    _Username.text = @"Luca@gmail.com";
    //    _Password.text = @"abcabc123";
    
    //没有activate的账户
    //    _Username.text = @"himstjapanplay@gmail.com";
    //    _Password.text = @"a1234567";
    
    //内部账户
    //激活的
//    _Username.text = @"luca.li@nwstor.com";
//    _Password.text = @"test123456";
//    _ConfirmPassword.text = @"test123456";
    
    //没有激活
//    _Username.text = @"hellworld222@gmail.com";
//    _Password.text = @"test123456";
//    _ConfirmPassword.text = @"test123456";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark status bar颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark 点击空白处隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_Username resignFirstResponder];
    [_Password resignFirstResponder];
    [_ConfirmPassword resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark 按钮点击
- (IBAction)BackClick:(id)sender {
    [self performSegueWithIdentifier:@"BackToLoginSegue" sender:self];
    //[self.view removeFromSuperview];
}

- (IBAction)RegisterClick:(id)sender {
    
    NSString *username = [_Username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![self isValidEmail:username] || ![self isValidPassword:_Password.text]) {
        [self showAlert:@"Register Error" andContent:@"Invalid username or password"];
    } else if (![_Password.text isEqualToString:_ConfirmPassword.text]){
        NSLog(@"%@, %@", _Password.text, _ConfirmPassword.text);
        [self showAlert:@"Register Error" andContent:@"The two passwords you entered must be consistent"];
    } else {
        [self showLoadingAlert];
        [self getAccountInfoInRegistration];
    }
    
}


#pragma mark 输入状态改变
- (IBAction)UsernameBeginEdit:(id)sender {
    if (!isTransformed) {
        [self textFiledDidBeginEditing:_Username];
        isTransformed = YES;
    }
}

- (IBAction)UsernameEndEdit:(id)sender {
    
    if (isTransformed) {
        [self textFiledDidFinishEditing:_Username];
        isTransformed = NO;
    }
}

- (IBAction)PasswordBeginEdit:(id)sender {
    if (!isTransformed) {
        [self textFiledDidBeginEditing:_Password];
        isTransformed = YES;
    }
}

- (IBAction)ConfirmPasswordBeginEdit:(id)sender {
    if (!isTransformed) {
        [self textFiledDidBeginEditing:_ConfirmPassword];
        isTransformed = YES;
    }
}

- (IBAction)PasswordEndEdit:(id)sender {
    
    if (isTransformed) {
        [self textFiledDidFinishEditing:_Password];
        isTransformed = NO;
    }
}

- (IBAction)ConfirmPasswordEndEdit:(id)sender {
    
    if (isTransformed) {
        [self textFiledDidFinishEditing:_ConfirmPassword];
        isTransformed = NO;
    }
}

#pragma mark 编辑时上移
- (void)textFiledDidBeginEditing: (UITextField *)textFiled {
    [self animateTextFiled: textFiled up:YES];
}

#pragma mark 完成编辑下移
- (void)textFiledDidFinishEditing: (UITextField *)textFiled {
    [self animateTextFiled: textFiled up:NO];
}

#pragma mark 上下移动和半透明函数
- (void)animateTextFiled: (UITextField *)textFiled up:(BOOL)up {
    
    //移动参数
    NSInteger movementDistance = 60;
    NSInteger movementDuration = 1;
    NSInteger movement = (up ? -movementDistance : movementDistance);
    
    //Label半透明参数
    float labelAlpha = (up ? 0.3 : 1);
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    //半透明顶端Label免得挡住状态栏
    [_WelcomeLabel setAlpha:labelAlpha];
    [_GetStartedLabel setAlpha:labelAlpha];
    [UIView commitAnimations];  //结束
}

#pragma mark 判断输入合法
//username
- (BOOL) isValidUsername: (NSString *)username {
    
    if ([username length] < 5 || [username length] > 99) {
        return false;
    } else {
        NSError *error = nil;
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9]{5-99}$" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSRange rangeOfFristMatch = [regularExpression rangeOfFirstMatchInString:username options:0 range:NSMakeRange(0, [username length])];
        
        if (rangeOfFristMatch.location == NSNotFound || rangeOfFristMatch.length != [username length]) {
            return false;
        }
        
        return true;
    }
}

//password
- (BOOL) isValidPassword: (NSString *)password {
    
    if ([password length] < 6 || [password length] > 16) {
        return false;
    } else {
        NSError *error = nil;
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"^(.*[a-zA-Z].*\\d.*)|(.*\\d.*[a-zA-Z].*)$" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSRange rangeOfFristMatch = [regularExpression rangeOfFirstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
        
        if (rangeOfFristMatch.location == NSNotFound || rangeOfFristMatch.length != [password length]) {
            return false;
        }
        
        return true;
    }
}

//email
- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

#pragma mark 计时隐藏alert
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
    //这个userInfo可以将这个函数里的某个参数，装进timer中，传递给别的函数
    [alert show];
}
- (void)timerForHideAlert: (NSTimer *)timer {
    UIAlertView *alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];  //在这里把其他同时显示的alert一起dismiss了，免得之后出现Attempt to dismiss from view controller xxxx while a presentation or dismiss is in progress!这个错误
}

#pragma mark loading进度条
- (void)showLoadingAlert {
    
    _loadingAlert = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(30, 260, 260, 50) dotStyle:TYDotIndicatorViewStyleRound dotColor:[UIColor colorWithRed:0.85f green:0.86f blue:0.88f alpha:1.00f] dotSize:CGSizeMake(15, 15) withBackground:YES];
    _loadingAlert.backgroundColor = [UIColor colorWithRed:0.20f green:0.27f blue:0.36f alpha:0.9f];
    _loadingAlert.layer.cornerRadius = 5.0f;
    [self.view addSubview:_loadingAlert];
    [_loadingAlert startAnimating];
}

#pragma mark 注册函数
- (void)getAccountInfoInRegistration {
    
    NSString *username = [_Username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //封装数据
    
    GDataXMLElement *requestElement = [GDataXMLNode elementWithName:@"request"];
    
    GDataXMLElement *paramElement = [GDataXMLNode elementWithName:@"accountId" stringValue:username];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLElement elementWithName:@"password" stringValue:_Password.text];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLElement elementWithName:@"lang" stringValue:NSLocalizedString(@"en-us", nil)];  //这里需要后期改动
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLElement elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *XMLDocument = [[GDataXMLDocument alloc] initWithRootElement:requestElement];  //把之前的element放到一个容器内
    NSData *XMLData = [[NSData alloc] initWithData:XMLDocument.XMLData];    //再把这个容器内的XMLData以NSData形式封装
    NSString *getParam = [[NSString alloc] initWithData:XMLData encoding:NSUTF8StringEncoding]; //get参数就是要发送的参数，放入NSData，编码为UTF8
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];    //UTF8转换为USAV服务器识别的请求格式
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [[USAVClient current].api register:encodedGetParam target:self selector:@selector(registerResultCallBack:)];
}

#pragma mark 注册返回之后的函数
- (void)registerResultCallBack: (NSDictionary *)obj {
    
    // 隐藏之前的提示框
    [self.loadingAlert stopAnimating];
    
    // 有未知错误
    if ([obj objectForKey:@"httpErrorCode"]!= nil) {
        [self showAlert:@"Unknown Error" andContent:[NSString stringWithFormat:@"error code: %zi", [obj objectForKey:@"httpErrorCode"]]];
        return;
    }
    
    // 超时
    if (obj == nil) {
        [self showAlert:@"Time Out" andContent:@"Please chech your network condition"];
        return;
    }
    
    // timestamp错误
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue]== 260) {
        [self showAlert:@"Timestamp Error" andContent:@"please chech your system clock"];
    }
    
    // 正常返回
    if (obj != nil && [obj objectForKey:@"httpErrorCode"] == nil) {
        NSLog(@"%@: registerCallback: resp: %@", [self class], obj);
        
        NSString *rawStringStatus = [obj objectForKey:@"rawStringStatus"];
        NSInteger rawStatus = [rawStringStatus integerValue];
        
        switch (rawStatus) {
                
            case SUCCESS: {
                [self showAlert:@"Success" andContent:@"An activation letter has been sent to your email address"];
                //把信息存到全局类内
                [USAVClient current].emailAddress = [_Username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [USAVClient current].password = _Password.text;
                [self BackClick:self];  //返回上一页
                break;
            }
            case TIMESTAMP_OLD: {
                [self showAlert:@"Timestamp Error" andContent:@"please chech your system clock, it may be too slow"];
                break;
            }
            case TIMESTAMP_FUTURE: {
                [self showAlert:@"Timestamp Error" andContent:@"please chech your system clock, it may be too fast"];
                break;
            }
            case INVALID_ACC_ID: {
                [self showAlert:@"Invalid Account" andContent:@"Invalid email address"];
                break;
            }
            case ACC_EXIST: {
                [self showAlert:@"Account Exists" andContent:nil];
                break;
            }
            case UNSECURE_PASSWORD: {
                [self showAlert:@"Invalid Password" andContent:@"Password may not secure"];
                break;
            }
            case INVALID_EMAIL: {
                [self showAlert:@"Invalid Account" andContent:@"Invalid email address"];
                break;
            }
            case EMAIL_IN_USE: {
                [self showAlert:@"Invalid Email" andContent:@"This email has been used by another account"];
                break;
            }
            default: {
                [self showAlert:@"Unknown Error" andContent:[NSString stringWithFormat:@"error code: %zi", rawStatus]];
                break;
            }
        }
        return;
    }
    
    //其他错误的测试段
    if (obj == nil) {
        NSLog(@"%@: resp is nil", [self class]);
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        NSLog(@"%@: http error code: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    }
}


@end
