//
//  个人有用代码集.m
//  收集的是开发以来经常使用到的一些内容
//
//  Created by Luca on 2/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//
#import <UIKit/UIKit.h>

/*
----------个人笔记本----------
 1. 在我们ios的开发中gdataxml是一个常用的开源实现，很多第三方的库在实现里也会加入它的源码。我们在使用此类库或者直接使用gdataxml库时，切记要在工程中引入libxml2这个框架，否则编译会报错。
    引入方法：Project -> Edit Project Settings -> Build You need to add “/usr/include/libxml2″ to the “Header Search Paths” and you need to add “-lxml2″ to the “Other Linker Flags”.
 2. 提示类似ld: 3 duplicate symbols for architecture i386（arm7）的错误。可能是您用了与SDK相同的第三方库，解决方法是删除引起错误的第三方法库的实现文件（.m文件）
 3. 使用一个类似USAVClient这样的类，去保存程序运行的全局信息，在程序运行的过程中，将数据写进这个类中，然后在别的类中去调用它里面的公共变量即可，如[[USAVClient current] username]
*/

#pragma mark - Label渐变动画
CATransition *menuTransition = [CATransition animation];    //定义一个渐变效果
menuTransition.duration = 0.8;    //持续时间
menuTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    //渐变时间函数(线性、曲线型……)
menuTransition.type = @"fade";  //效果包括`fade', `moveIn', `push' and `reveal'. 默认是 `fade'.
menuTransition.delegate = self;
[menu.layer addAnimation:menuTransition forKey:nil];    //将这个效果加到某个Layer上


#pragma mark - UIView上增加动画
//这个例子是TextFiled编辑时界面上移的，UIView的增加动画就是上移过程中的效果
#pragma mark 开始编辑上移
- (void)textFiledDidBeginEditing: (UITextField *)textFiled {
    [self animateTextFiled: textFiled up:YES];
}

#pragma mark 完成编辑下移
- (void)textFiledDidFinishEditing: (UITextField *)textFiled {
    [self animateTextFiled: textFiled up:NO];
}

#pragma mark 上下移动函数
- (void)animateTextFiled: (UITextField *)textFiled up:(BOOL)up {
    
    //移动参数
    NSInteger movementDistance = 60;
    NSInteger movementDuration = 1;
    NSInteger movement = (up ? -movementDistance : movementDistance);
    
    //Label半透明参数
    float labelAlpha = (up ? 0.5 : 1);
    
    //动画开始到结束的描述
    [UIView beginAnimations:@"anim" context:nil];   //开始
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    //这里自己加了一些效果，比如让顶端的Label半透明，突出输入框
    [_TopLabel setAlpha:labelAlpha];
    [_ULabel setAlpha:labelAlpha];
    [_SavLabel setAlpha:labelAlpha];
    [_VersionLabel setAlpha:labelAlpha];
    [UIView commitAnimations];  //结束
}


#pragma mark - 设置Placeholder的字体效果
[_Username setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
[_Username setValue:[UIColor colorWithWhite:1 alpha:0.8] forKeyPath:@"_placeholderLabel.textColor"];

#pragma mark - 点击空白处隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_Username resignFirstResponder];
    [_Password resignFirstResponder];
}

#pragma mark - 判断第一次启动
if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
         //如果是第一次启动的话,使用UserGuideViewController (用户引导页面) 作为根视图
         UserGuideViewController *userGuideViewController = [[UserGuideViewController alloc] init];
         self.window.rootViewController = userGuideViewController;
         [userGuideViewController release];
     }
     else
     {
         //如果不是第一次启动的话,使用LoginViewController作为根视图
         WeiBoViewController *weiBoViewController = [[WeiBoViewController alloc] init];
         self.window.rootViewController = weiBoViewController;
         [weiBoViewController release];

     }


#pragma mark - 在Appdelegate获取storyboard
//先获取到storyboard，这样才可以加载相应界面
UIStoryboard *currentStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

#pragma mark 通过storyboard去加载对应的storyboard里的viewcontroller
//记得要在storyboard中去确定对应页面的storyboard ID
UserGuideViewController *userGuideController = [currentStoryboard instantiateViewControllerWithIdentifier:@"UserGuide_Storyboard"];

#pragma mark - 隐藏Navigation Bar
self.navigationController.navigationBarHidden = YES;

#pragma mark - status bar颜色（白色）
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - 使用正则表达式判断输入合法
#pragma mark 判断用户名合法
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

#pragma mark 判断密码合法
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

#pragma mark 判断邮箱合法
- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.+@.+\\..+$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

#pragma mark 计时隐藏alert
//显示alert的函数，输入title和content
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
    //这个userInfo可以将这个函数里的某个参数，装进timer中，传递给别的函数
    [alert show];
}
- (void)timerForHideAlert: (NSTimer *)timer {
    UIAlertView *alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES]; //在这里把其他同时显示的alert一起dismiss了，免得之后出现Attempt to dismiss from view controller xxxx while a presentation or dismiss is in progress!这个错误  这个self.alert是其他弹框
    
}

#pragma mark -使用GDataXML封装数据和编码
//封装数据
GDataXMLElement *requestElement = [GDataXMLNode elementWithName:@"request"];    //头节点用来说明类型
GDataXMLElement *paramElement = [GDataXMLNode elementWithName:@"accountID" stringValue:username];   //生成一个参数节点
[requestElement addChild:paramElement]; //参数节点加到头节点后面
paramElement = [GDataXMLElement elementWithName:@"password" stringValue:_Password.text];    //修改参数节点（只用一个中间变量）
[requestElement addChild:paramElement]; //加到头节点后面
paramElement = [GDataXMLElement elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", nil)];

//编码
GDataXMLDocument *XMLDocument = [[GDataXMLDocument alloc] initWithRootElement:requestElement];  //把之前的element放到一个容器内
NSData *XMLData = [[NSData alloc] initWithData:XMLDocument.XMLData];    //再把这个容器内的XMLData以NSData形式封装
NSString *getParam = [[NSString alloc] initWithData:XMLData encoding:NSUTF8StringEncoding]; //get参数就是要发送的参数，放入NSData，编码为UTF8
NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];    //UTF8转换为USAV服务器识别的请求格式