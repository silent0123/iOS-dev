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

//内部变量
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) TYDotIndicatorView *loadingAlert;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
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
    
    //将login按钮设置为不能点击，除非输入内容
    //[_SigninButton setEnabled:NO];

#warning 测试用账户
    //外部账户
    _Username.text = @"mo7upyan@gmail.com";
    _Password.text = @"womenDEyueding12";
    
    //没有activate的账户
//    _Username.text = @"himstjapanplay@gmail.com";
//    _Password.text = @"a1234567";

    //内部账户
    //激活
//    _Username.text = @"luca.li@nwstor.com";
//    _Password.text = @"test123456";
    
    //没有激活
//    _Username.text = @"hellworld222@gmail.com";
//    _Password.text = @"test123";
    
    
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
- (IBAction)SigninClick:(id)sender {
    
    NSString *username = [_Username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];  //去掉用户名空格
    
    if (![self isValidEmail:username] || ![self isValidPassword:_Password.text]) {
        [self showAlert:@"Login Error" andContent:@"Invalid username or password."];
    } else {
        [self getAccountInfo];
    }
    
    //[self.view removeFromSuperview];
}
- (IBAction)SignupClick:(id)sender {
    
    [self performSegueWithIdentifier:@"RegisterSegue" sender:self];
    //[self.view removeFromSuperview];
}

- (IBAction)ForgetClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://webapi.usav-nwstor.com/%@/password",NSLocalizedString(@"LanguageCode", @"")]]];
}

#pragma mark TextFiled状态
- (IBAction)UsernameBeginEditing:(id)sender {
    
    if (!isTransformed) {
        [self textFiledDidBeginEditing:_Username];
        isTransformed = YES;
    }
    [_Username setPlaceholder:NSLocalizedString(nil, nil)];  //开始输入，去掉placeholder

}

- (IBAction)UsernameEndEditing:(id)sender {
    
    if (isTransformed) {
        [self textFiledDidFinishEditing:_Username];
        isTransformed = NO;
    }

    if ([_Username.text length] == 0) {
        [_Username setPlaceholder:NSLocalizedString(@"Username", nil)]; //完成输入，如果没输入东西，恢复placeholder
    }
//    if (![self checkAndEnableLogin]) {
//        [_Username setPlaceholder:NSLocalizedString(@"Invalid Username", nil)];
//        [_Username setValue:[ColorFromHex getColorFromHex:@"#FFFFFF"] forKeyPath:@"_placeholderLabel.textColor"];
//    }   //判断输入长度，来确定login按钮是否可以点击, 并且不合法的时候红色字体提示

}

- (IBAction)PasswordBeginEditing:(id)sender {
    
    if (!isTransformed) {
        [self textFiledDidBeginEditing:_Password];
        isTransformed = YES;
    }
    [_Password setPlaceholder:NSLocalizedString(nil, nil)];
}

- (IBAction)PasswordEndEditing:(id)sender {
    
    if (isTransformed) {
        [self textFiledDidFinishEditing:_Password];
        isTransformed = NO;
    }
    
    if ([_Password.text length] == 0) {
        [_Password setPlaceholder:NSLocalizedString(@"Password", nil)];
    }
    
//    if (![self checkAndEnableLogin]) {
//        [_Password setPlaceholder:NSLocalizedString(@"Invalid Password", nil)];
//        [_Password setValue:[ColorFromHex getColorFromHex:@"#FFFFFF"] forKeyPath:@"_placeholderLabel.textColor"];
//    }   //判断输入长度，来确定login按钮是否可以点击, 并且不合法的时候红色字体提示
    [self checkAndEnableLogin];
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
    //这里自己加了一些效果，比如让顶端的Label半透明，突出输入框
    [_TopLabel setAlpha:labelAlpha - 0.3];  //直接消失，免得挡着状态栏了
    [_ULabel setAlpha:labelAlpha];
    [_SavLabel setAlpha:labelAlpha];
    [_VersionLabel setAlpha:labelAlpha];
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

#pragma mrak 登陆按钮有效性
- (BOOL)checkAndEnableLogin {
    if ([_Username.text length] >= 5 && [_Password.text length] >= 6) {
        [_SigninButton setEnabled:YES];
        return true;
    } else {
        [_SigninButton setEnabled:NO];
    }
    return false;
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
    
    if (_loadingAlert.isAnimating) {
        [_loadingAlert stopAnimating];
        return;
    } else {
        _loadingAlert = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(30, 260, 260, 50) dotStyle:TYDotIndicatorViewStyleRound dotColor:[UIColor colorWithRed:0.85f green:0.86f blue:0.88f alpha:1.00f] dotSize:CGSizeMake(15, 15) withBackground:YES];
        _loadingAlert.backgroundColor = [UIColor colorWithRed:0.20f green:0.27f blue:0.36f alpha:0.9f];
        _loadingAlert.layer.cornerRadius = 5.0f;
        [self.view addSubview:_loadingAlert];
        [_loadingAlert startAnimating];
    }
}

#pragma mark 获取登陆信息
-(void)getAccountInfo
{
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", _Username.text, @"\n", [[USAVClient current] getDateTimeStr], @"\n", @"1", @"\n"];
    NSString *signature = [[USAVClient current] generateSignature:stringToSign withKey:_Password.text];
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:_Username.text];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"params" stringValue:@""];
    GDataXMLElement * loginP = [GDataXMLNode elementWithName:@"login" stringValue:@"1"];
    [paramElement addChild:loginP];
    [requestElement addChild:paramElement];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    //NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [self showLoadingAlert];
    
    //demo用，第二次登陆不和服务器通信，不会出现卡死（待解决）
//    if ([[USAVClient current] userHasLogin]) {
//        [self performSelectorOnMainThread:@selector(performToNextView) withObject:nil waitUntilDone:YES];
//    } else {
        [[USAVClient current].api getAccountInfo:encodedGetParam target:self selector:@selector(getAccountInfoResultCallback:)];
//    }
    


}

-(void)getAccountInfoResultCallback:(NSDictionary*)obj {
    //将alert隐藏
    [self.loadingAlert stopAnimating];
    
    // timestamp错误
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
        [self showAlert:@"Fatal Error" andContent:@"Please check your system clock"];
        return;
    }
    
    // get GetAccountInfo as if Login has occured
    // 网络连接失败
    if (obj == nil) {
        [self showAlert:@"Time Out" andContent:@"Please chech your network condition"];
        return;
    }
    
    // 正常返回
    if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        
        NSLog(@"%@: getAccountInfoResultCallback: resp: %@", [self class], obj);
        
        NSString *statusCodeStr = [obj objectForKey:@"statusCode"];
        NSInteger statusCode = [statusCodeStr integerValue];
        
        
        switch (statusCode) {
            case SUCCESS:
            {
                // get GetAccountInfo as if Login has occured
                /*
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 44) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y - 60)];
                [wv show:NSLocalizedString(@"GetAccountInfoSuccessKey", @"") inView:self.view];
                 */
                
                //[self showAlert:@"Success" andContent:@"GetAccountInfoSuccessKey"];
                
                [[USAVClient current] setPassword:_Password.text];
                
                NSString *latestUsername = [obj objectForKey:@"name"];
                NSString *lastUsername = [[USAVClient current] username];
                if(![latestUsername isEqualToString:lastUsername])
                {
                    //[self deleteDecryptedFiles];
                }
                
                [[USAVClient current] setUsername:latestUsername];
                [[USAVClient current] setEmailAddress:[obj objectForKey:@"accountId"]];
                [[USAVClient current] setUserHasLogin:YES];
                
                [[USAVLock defaultLock] setUserLoginOn];
                
                //[delegate loginResult:TRUE target:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSucceed" object:self];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
                [self performSelectorOnMainThread:@selector(performToNextView) withObject:nil waitUntilDone:YES];

                break;
                
            // 账户没有激活，258
            case DISABLE_USER:
            {
                [self showAlert:@"Disabled Account" andContent:@"Please activate this account from your email address"];
            }
                break;
                
            case ACC_NOT_FOUND:
            {
                [self showAlert:@"Account Not Found" andContent:@"Please check your username"];
            }
            default:
            {
                [self showAlert:@"Invalid Account" andContent:@"Invalid username or password"];
                [[USAVClient current] setUserHasLogin:NO];
                //[delegate loginResult:FALSE target:self];
            }
                break;
        }
        return;
    }
    
    if (obj == nil) {
        NSLog(@"%@: resp is nil", [self class]);
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        NSLog(@"%@: http error code: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    }
}

- (void)performToNextView {
    
    [self performSegueWithIdentifier:@"SigninSuccessSegue" sender:self];
    [self.view removeFromSuperview];
}

@end
