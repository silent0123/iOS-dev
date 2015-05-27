//
//  USAVAppDelegate.m
//  uSav
//
//  Created by young dennis on 3/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
#import "USAVAppDelegate.h"
#import "USAVClient.h"
#import "KKPasscodeLock.h"
#import "USAVHomeViewController.h"
#import "USAVLock.h"
#import <Foundation/Foundation.h>
#import "USAVClient.h"
#import "SGDUtilities.h"
#import "USAVPrefixHeader.pch"
#import <CrashReporter/CrashReporter.h>#
#import <dlfcn.h>


#define JAILBROKEN_ALERT_TAG 100
@implementation USAVAppDelegate

@synthesize window = _window;
@synthesize navigationController=_navigationController;
@synthesize viewController = _viewController;


- (void)handleCrashReport {
    UILabel *u = [[UILabel alloc] init];
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    // We could send the report from here, but we'll just print out
    // some debugging info instead
    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error];
    if (report == nil) {
        NSLog(@"Could not parse crash report");
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    NSString *rep = [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:PLCrashReportTextFormatiOS];
    //u.text = [NSString stringWithFormat:@"%@", report.signalInfo.name];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:report.signalInfo.name delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
    //[alert show];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Jailbreak detection
    if (JAILBREAK_DETECT) {
        if ([self isJailBreak]) {
            
            return YES;
        }
    }

    
    //文件系统初始化
    if ([USAVClient current] == nil)
        [[USAVClient alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    _navigationController = (UINavigationController *)self.window.rootViewController;

    
    NSString *currentPath = [paths objectAtIndex:0];
    NSString *encryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Encrypted"];
    NSString *decryptPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"Decrypted"];
    NSString *albumPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"PhotoAlbum"];
    NSString *decryptedCopyPath = [NSString stringWithFormat:@"%@/%zi/%@", currentPath, [[USAVClient current] uId], @"DecryptedCopy"];
    
    
    
    //    //如果Inbox不存在，则创建
    //    if (![fileManager fileExistsAtPath:inboxPath isDirectory:YES]) {
    //        NSError *error;
    //        [fileManager createDirectoryAtPath:inboxPath withIntermediateDirectories:NO attributes:nil error:&error];
    //        NSLog(@"%@", error);
    //    }
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:encryptPath error:nil]];
    for (NSInteger i = 0; i < [allFile count]; i++) {
        //Get one file's full name
        NSString *singleFile = [allFile objectAtIndex:i];
        if ([[singleFile pathExtension] caseInsensitiveCompare:@"usav-temp"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"IncompleteFile", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
            [alert show];
            
            //return YES;
        }
    }
    
#pragma mark 清空decrypt - 启用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ReserveDecrypt"]) {
        //如果设为不保留，删除当前文件在decrypte的备份和临时文件
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [self clearFilesAtDirectoryPath:decryptPath];
        [self clearFilesAtDirectoryPath:tmpPath];
    }

    [self.window makeKeyAndVisible];
    
    //添加一个深色背景，在图片载入完成前显示，防止出现白色闪烁
    self.blackView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.blackView.backgroundColor = [UIColor blackColor];
    [self.window addSubview:self.blackView];
    
    //动态启动页面
    self.launchImageView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.launchImageView.delegate = self;
    
    NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Start-Page_animation" ofType:@"gif"]];
    [self.launchImageView loadData:imageData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.launchImageView setScalesPageToFit:YES];
    self.launchImageView.scrollView.scrollEnabled = NO;
    
    if ([[[UIDevice currentDevice].model substringToIndex:4] isEqualToString:@"iPad"] || [UIScreen mainScreen].bounds.size.height == 480) {
        //ipad和iphone4上增加遮挡
        UIImageView *overLapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbar"]];
        [overLapImageView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 30)];
        [overLapImageView setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height)];
        [overLapImageView setAlpha:1];
        [self.launchImageView addSubview:overLapImageView];
    }

    
    self.willShowLaunchImage = 1;
    
    return YES;
}

- (void)launchImageAnimationStartToPlay {
    [self.launchImageView.layer addAnimation:[self fadeOut] forKey:@"fadeOut"];
}

- (void)launchPreparation {
    
    [self.launchImageView removeFromSuperview];
    self.willShowLaunchImage = 0;
    
    //修改TOPBAR
    [self customizedNavigationBar:self.navigationController.navigationBar WithTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]]];
    
#pragma mark 这里控制全局是否保留DecryptFile - 现在不保留
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ReserveDecrypt"];
    
    [[USAVLock defaultLock] resetTimeShare];
    // Override point for customization after application launch.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AlreadyLaunched"]){
        // First launch logic
        [[KKPasscodeLock sharedLock] setDefaultSettings];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AlreadyLaunched"];
        //首次启动，设置为不锁
        [[USAVLock defaultLock] setTimeOut:[NSNumber numberWithInt:2147483647]];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"timesEncryption"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"timesDecryption"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"timesExpertMode"];
        
        //首次使用app，设置阅读时间限制默认值为1，10
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"DefaultLimit"];
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"DefaultDuration"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[USAVLock defaultLock] resetTimeShareWhenTerminate];
    
    //如果Login，并且没PASSCODE 没有LOGIN SESSION TIMEOUT，处理inbox
    if (!([[USAVLock defaultLock] isSessionTimeOut] && [[KKPasscodeLock sharedLock] isPasscodeRequired]) && ![[USAVLock defaultLock] isLoginSessionTimeOut]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DealInboxFile" object:self];
    }

    
    //清空Encrypt的file和photo方便
    //    [allFile removeAllObjects];
    //    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:encryptPath error:nil]];
    //    for(NSInteger i = 0; i < [allFile count]; i++){
    //        NSString *encryptFilePath = [NSString stringWithFormat:@"%@/%@", encryptPath, [allFile objectAtIndex:i]];   //allFile只是文件名
    //        [fileManager removeItemAtPath:encryptFilePath error:nil];
    //    }
    //    [allFile removeAllObjects];
    //    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:albumPath error:nil]];
    //    for(NSInteger i = 0; i < [allFile count]; i++){
    //        NSString *albumFilePath = [NSString stringWithFormat:@"%@/%@", albumPath, [allFile objectAtIndex:i]];   //allFile只是文件名
    //        [fileManager removeItemAtPath:albumFilePath error:nil];
    //    }
    
    
    //return YES;
    /*
     PLCrashReporter *crashReporter;
     PLCrashReporterConfig *config =  [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeMach symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll];
     
     crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
     NSError *error;
     
     // Check if we previously crashed
     if ([crashReporter hasPendingCrashReport])
     [self handleCrashReport];
     // Enable the Crash Reporter
     if (![crashReporter enableCrashReporterAndReturnError: &error])
     NSLog(@"Warning: Could not enable crash reporter: %@", error);
     */
    
    /*
     //RemoteNotification
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
     
     UIUserNotificationSettings * notificationSetting =[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
     [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSetting];
     [[UIApplication sharedApplication] registerForRemoteNotifications];
     
     }else{
     [[UIApplication sharedApplication]registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
     }
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

/*
#pragma mark - RemoteNotification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"Device Push Token Rigistered: %@", deviceToken);
    //把deviceToken发出去, call API
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // 处理推送消息
    NSLog(@"userinfo:%@",userInfo);
    
    NSLog(@"收到推送消息:%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Device Push Token FAILED: %@", error);
}
 */

#pragma mark - Become Active
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
//    if ([[USAVLock defaultLock] isLoginSessionTimeOut]) {
//        
//        NSLog(@"LOGIN SESSION HAS TIME OUT");
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSessionTimeOut" object:nil];
//        return;
//    }

    // Jailbreak detection
    if (JAILBREAK_DETECT) {
        if ([self isJailBreak]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONDOR Security Detection", nil) message:NSLocalizedString(@"Your device has been jail broken, CONDOR will NOT launch for secure reason", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil, nil];
            alert.tag = JAILBROKEN_ALERT_TAG;
            [alert show];
            
            //clear inbox file
            NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                                 NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *currentPath = [paths objectAtIndex:0];
            NSString *inboxPath = [NSString stringWithFormat:@"%@/%@", currentPath, @"Inbox"];
            [self clearFilesAtDirectoryPath: inboxPath];
            
            //disable all local notification
            [application cancelAllLocalNotifications];
            return;
        }
    }
    
    
    //根据版本升级需要，如果之前已经打开PASSCODE，并且设置为了NEVER，则更新为ALWAYS
    if ([[KKPasscodeLock sharedLock] isPasscodeRequired] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeout"] integerValue] == 2147483647) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timeout"];
    }
    
    NSLog(@"Lock status: %zi, and is timeout? %zi, is Login? %zi",[[KKPasscodeLock sharedLock] isPasscodeRequired], [[USAVLock defaultLock] isSessionTimeOut], [[USAVLock defaultLock] isLogin]);
    
    
    //超时，并且已经登陆有帐号，则弹出密码锁。
    if ([[USAVLock defaultLock] isSessionTimeOut] && [[USAVLock defaultLock] isLogin]) {
        
        // for debug - to prevent fatal crash
        //[[KKPasscodeLock sharedLock] setDefaultSettings];
        
        if ([[KKPasscodeLock sharedLock] isPasscodeRequired] && !self.touchIdShowed) {
            

            //这里不用异步弹出了
            //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            //[_navigationController presentViewController:nav animated:NO completion:nil];
            
            //找到当前的viewController, 然后弹出lock
            UIViewController *currentViewController = [self.navigationController visibleViewController];
            
            if (![currentViewController isKindOfClass:[KKPasscodeViewController class]]) {
            
                if (self.willShowLaunchImage) {
                    [self performSelector:@selector(showPasscodeLockAfterDelayOn:) withObject:currentViewController afterDelay:3.2];
                } else {
                    [self performSelector:@selector(showPasscodeLockAfterDelayOn:) withObject:currentViewController afterDelay:0];
                }
            }
            
            self.willShowLaunchImage = 0;
        
            

            
//            dispatch_async(dispatch_get_main_queue(),^ {
//                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//                
//                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                    nav.modalPresentationStyle = UIModalPresentationFormSheet;
//                    nav.navigationBar.barStyle = UIBarStyleBlack;
//                    nav.navigationBar.opaque = NO;
//                } else {
//                    nav.navigationBar.tintColor = _navigationController.navigationBar.tintColor;
//                    nav.navigationBar.translucent = _navigationController.navigationBar.translucent;
//                    nav.navigationBar.opaque = _navigationController.navigationBar.opaque;
//                    nav.navigationBar.barStyle = _navigationController.navigationBar.barStyle;
//                }
//                
//                //[_navigationController presentModalViewController:nav animated:YES];
//                //[_navigationController dismissViewControllerAnimated:YES completion:nil];
//                [_navigationController presentViewController:nav animated:NO completion:nil];
//                
//            });
        }
    }
}


- (void)showPasscodeLockAfterDelayOn: (UIViewController *)currentViewController {
    
    KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    vc.mode = KKPasscodeModeEnter;
    vc.delegate = self;
    
    NSLog(@"Presenting Passcode Lock on:%@", currentViewController);
    

    [currentViewController presentViewController:vc animated:NO completion:nil];
    
    self.touchIdShowed = YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alert show];*/
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppIntoBackground" object:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self];
    
    NSLog(@"Into background, reset basetime");
    self.touchIdShowed = NO;
    [[USAVLock defaultLock] resetTimeShare];
    [[USAVLock defaultLock] setLockOn];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissSheet" object:self];

    //[_navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    /*if ([[USAVLock defaultLock] isSessionTimeOut]) {
     
     if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
     KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
     vc.mode = KKPasscodeModeEnter;
     vc.delegate = self;
     
     dispatch_async(dispatch_get_main_queue(),^ {
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
     
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
     nav.modalPresentationStyle = UIModalPresentationFormSheet;
     nav.navigationBar.barStyle = UIBarStyleBlack;
     nav.navigationBar.opaque = NO;
     } else {
     nav.navigationBar.tintColor = _navigationController.navigationBar.tintColor;
     nav.navigationBar.translucent = _navigationController.navigationBar.translucent;
     nav.navigationBar.opaque = _navigationController.navigationBar.opaque;
     nav.navigationBar.barStyle = _navigationController.navigationBar.barStyle;
     }
     
     //[_navigationController presentModalViewController:nav animated:YES];
     [_navigationController presentViewController:nav animated:YES completion:nil];
     
     });
     }
     }*/

    //如果Login，并且没PASSCODE 没有LOGIN SESSION TIMEOUT，处理inbox
    if (!([[USAVLock defaultLock] isSessionTimeOut] && [[KKPasscodeLock sharedLock] isPasscodeRequired]) && ![[USAVLock defaultLock] isLoginSessionTimeOut]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DealInboxFile" object:self];
    }
    
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[USAVLock defaultLock] resetTimeShare];
    [[USAVLock defaultLock] setLockOn];
}

- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController
{ /*
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
   */
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == JAILBROKEN_ALERT_TAG) {
        for (NSInteger i = 0; i < [[self.window subviews] count]; i ++) {
            [[[self.window subviews] objectAtIndex:i] removeFromSuperview];
        }
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLogin" object:self];
    }
    
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController
{
    [USAVClient current].userHasLogin = NO;
    //[[USAVLock defaultLock] setUserLoginOff];
    //[self disableRemainFeature];
    //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
    
    [[USAVLock defaultLock] setUserLoginOff];
    [[KKPasscodeLock sharedLock] setDefaultSettings];   //输入失败5次，强制退出，并且关闭密码锁
    
    //这里是把原有的默认文件移除，暂时不这么做
    /*
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    */
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AlreadyLaunched"];
    [[USAVLock defaultLock] setTimeOut:[NSNumber numberWithInt:2147483647]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PasscodeIncorrect", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey",@"") otherButtonTitles:nil];
    [alert show];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLogin" object:self];
    [_navigationController dismissViewControllerAnimated:YES completion:nil];   //弹走PASSCODE LOCK
    [_navigationController popToRootViewControllerAnimated:YES];    //弹回File页面
    [(USAVFileViewController *)[[_navigationController viewControllers] objectAtIndex:0] showDashBoard];    //显示Dashboard
    [_navigationController setNavigationBarHidden:YES];

    
    
}

- (void)didPasscodeEnteredCorrectly:(KKPasscodeViewController *)viewController
{

    //解锁之后再检测一次有没有没处理的INBOX
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DealInboxFile" object:self];
    
}

- (void)clearFilesAtDirectoryPath: (NSString *)path {
    
    //每次启动清空decrypt文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *allFile = [[NSMutableArray alloc] initWithCapacity:0];
    
    [allFile removeAllObjects];
    [allFile addObjectsFromArray:[fileManager contentsOfDirectoryAtPath:path error:nil]];
    NSError *error;
    for(NSInteger i = 0; i < [allFile count]; i++){
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, [allFile objectAtIndex:i]];   //allFile只是文件名
        [fileManager removeItemAtPath:filePath error:&error];
    }
}

- (CABasicAnimation *)fadeOut
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.5;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    return animation;
}

#pragma mark - webview delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"ERROR WHEN LOADING START PAGE: %@", error);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.blackView removeFromSuperview];
    [self.window addSubview:self.launchImageView];
    

    [self performSelector:@selector(launchImageAnimationStartToPlay) withObject:nil afterDelay:2.5];
    [self performSelector:@selector(launchPreparation) withObject:nil afterDelay:2.9];

}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    NSLog(@"START LOADING START PAGE..");
}

#pragma mark - NavigationBar颜色修改
- (void)customizedNavigationBar: (UINavigationBar *)navigationBar WithTintColor: (UIColor *)tintColor {
    
    [navigationBar setBarTintColor:tintColor];
}

- (void)defaultChanged: (NSNotification *)notification {
    NSLog(@"Default changed: %zi", [((NSUserDefaults *)notification.object) integerForKey:@"DefaultDuration"]);
    
}

#pragma mark - Jailbreak Detection

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
#define USER_APP_PATH  @"/User/Applications/"  

const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};


//whether this device can open cydia
- (BOOL)isJailBreak {
    //cydia path detection
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken! -- cydia path");
        return YES;
    }
    
    //jailbreak file detection
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            NSLog(@"The device is jail broken! -- file detected");
            return YES;
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        NSLog(@"The device is jail broken! -- applist");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        //NSLog(@"applist = %@", applist);
        return YES;
    }

    
    NSLog(@"The device is NOT jail broken!");
    return NO;
}
@end

