//
//  AppDelegate.m
//  uSav-NewMac
//
//  Created by Luca on 23/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "USAVLoginViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet MainViewController *mainViewController;
@property (strong, nonatomic) USAVLoginViewController *loginViewController;

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    //测试用
    //[[NSUserDefaults standardUserDefaults] setObject:@"x.usav.demo@gmail.com" forKey:@"emailAddress"];
    //[[NSUserDefaults standardUserDefaults] setObject:@"pdsp2006" forKey:@"password"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"emailAddress"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    
    //NSMutableArray *accountArray = [NSMutableArray arrayWithObjects: @"", nil];
    //[[NSUserDefaults standardUserDefaults] setObject:accountArray forKey:@"HistoryAccount"];
    
    //初始化USAV系统文件
    [[USAVClient alloc] init];
    [[USAVAccountHandler alloc] init];

    NSLog(@"用户名%@, 密码%@",[[USAVClient current] emailAddress], [[USAVClient current] password]);
    
    if (![[[USAVClient current] emailAddress] length] || ![[[USAVClient current] password] length]) {
        
        self.loginViewController = [[USAVLoginViewController alloc] initWithNibName:@"USAVLoginViewController" bundle:nil];
        //没有登陆则进入登陆页面
        [self.window.contentView addSubview:self.loginViewController.view];
        self.loginViewController.view.frame = [self.window.contentView bounds];

    } else {
        //创建一个MainViewController
        [USAVClient current].userHasLogin = YES;
        self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        //将它添加到主界面
        [self.window.contentView addSubview:self.mainViewController.view];
        self.mainViewController.view.frame = [self.window.contentView bounds];
        //初始化Contact List并且获取Contact List
        USAVContactHandler *contactHandler = [[USAVContactHandler alloc] init];
        [contactHandler getContactList];
    }

    

    
    //初始化文件处理函数
    [[USAVFileHandler alloc] init];


    
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"] || ![[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultLimit"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"DefaultLimit"];
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"DefaultDuration"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"AllowDecryptCopy"] != 0 || [[NSUserDefaults standardUserDefaults] integerForKey:@"AllowDecryptCopy"] != 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"AllowDecryptCopy"];
    }
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
@end
