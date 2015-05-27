//
//  USAVLock.h
//  uSav
//
//  Created by NWHKOSX49 on 18/3/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USAVLock : NSObject
{}

+ (id)defaultLock;

//write current time into share as a timestamp copy. It occurs when uSav click home or sleep button.
- (void)resetTimeShare;
- (void)resetTimeShareWhenTerminate;

//if Current time - baseTime > timeout thoreshold. It will be called when the app resumes.
- (BOOL)isSessionTimeOut;

- (void)setLock: (BOOL) onOrOff;

- (BOOL)isLocked;

- (void)setTimeOut:(NSNumber*)timeout;
- (void)setLockOff;
- (void)setLockOn;

- (BOOL)isLogin;
- (void)setLoginOff;
- (void)setLoginOn;

- (int)getLockTime;
- (NSString*)getLockTimeStr;

- (void)setLockTime:(int)lockTime;
- (void)setUserLoginOn;
- (void)setUserLoginOff;

- (BOOL)isMainWindowOpen;

- (void)setMainWindowOpenOn;
- (void)setMainWindowOpenOff;
@end
