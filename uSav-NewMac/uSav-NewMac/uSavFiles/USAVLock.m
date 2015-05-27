//
//  USAVLock.m
//  uSav
//
//  Created by NWHKOSX49 on 18/3/13.
//  Copyright (c) 2013 young dennis. All rights reserved.
//
#import "USAVLock.h"
@interface USAVLock ()
@property (nonatomic, strong) NSUserDefaults *share;
@property (nonatomic, strong) NSDateFormatter *dateFormatterLocal;

@end

@implementation USAVLock
@synthesize share = _share;
@synthesize dateFormatterLocal = _dateFormatterLocal;

- (NSDateFormatter*) dateFormatterLocal
{
    if(!_dateFormatterLocal) {
        _dateFormatterLocal = [[NSDateFormatter alloc] init];
        
        [_dateFormatterLocal setLocale:[NSLocale systemLocale]];
        [_dateFormatterLocal setTimeZone:[NSTimeZone localTimeZone]];
        [_dateFormatterLocal setDateFormat:@"yyyy-M-d HH:mm:ss"];
    }
    return _dateFormatterLocal;
}

+ (id)defaultLock
{
    return [[self alloc] init];
}

//write current time into share as a timestamp copy. It occurs when uSav click home or sleep button.
- (void)resetTimeShare {
    NSDate *now = [NSDate date];
    NSNumber *num = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
    //NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:[num doubleValue]];
    //[[NSUserDefaults standardUserDefaults] setObject:[self.dateFormatterLocal stringFromDate:msgdate] forKey:@"baseTime"];
    [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"baseTime"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetTimeShareWhenTerminate {
    NSDate *now = [NSDate date];
    NSNumber *num = [NSNumber numberWithDouble:([now timeIntervalSince1970] - 900)];
    //NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:[num doubleValue]];
    //[[NSUserDefaults standardUserDefaults] setObject:[self.dateFormatterLocal stringFromDate:msgdate] forKey:@"baseTime"];
    [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"baseTime"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//if Current time - baseTime > timeout thoreshold. It will be called when the app resumes.
- (BOOL)isSessionTimeOut{
    //now
    NSDate *now = [NSDate date];
    NSNumber *num = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
    
    double timeout = [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeout"] intValue];
    
    //NSString *current =  [self.dateFormatterLocal stringFromDate:msgdate];
    ////nslog(@"getParam encoding: raw:%f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"baseTime"] doubleValue]);
    double diff = [num doubleValue] - [[[NSUserDefaults standardUserDefaults] objectForKey:@"baseTime"] doubleValue];
    if ( (diff > timeout || diff < 0)) {
        return true;
    } else {
        return false;
    }
    
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLockOn{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"passcodeLock"];
}

- (void)setLockOff {
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt:0] forKey:@"passcodeLock"];
}

- (void)setTimeOut:(NSNumber*)timeout {
    [[NSUserDefaults standardUserDefaults] setObject:timeout forKey:@"timeout"];
}

- (BOOL)isLocked {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passcodeLock"] intValue] == 1) {
        return true;
    } else {
        return false;
    }
}

- (BOOL)isLogin {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"login"] intValue] == 1) {
        return true;
    } else {
        return false;
    }
}

- (void)setUserLoginOn {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"login"];
}

- (void)setUserLoginOff {
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt:0] forKey:@"login"];
}

- (BOOL)isMainWindowOpen {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"mainwindow"] intValue] == 1) {
        return true;
    } else {
        return false;
    }
}

- (void)setMainWindowOpenOn {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"mainwindow"];
}

- (void)setMainWindowOpenOff {
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt:0] forKey:@"mainwindow"];
}

- (int)getLockTime {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"lockTime"] integerValue];
}

- (NSString*)getLockTimeStr {
    switch ([self getLockTime]) {
        case 0:return NSLocalizedString(@"Never", @"");
        case 1:return NSLocalizedString(@"1  Minute", @"");
        case 2:return NSLocalizedString(@"2  Minutes", @"");
        case 3:return NSLocalizedString(@"3  Minutes", @"");
        case 4:return NSLocalizedString(@"4  Minutes", @"");
        case 5:return NSLocalizedString(@"5  Minutes", @"");
        case 6:return NSLocalizedString(@"10 Minutes", @"");
        case 7:return NSLocalizedString(@"15 Minutes", @"");
        case 8:return NSLocalizedString(@"Always", @"");
        default: return @"";
    }
}

- (void)setLockTime:(int)lockTime {
    switch (lockTime) {
        case 0:[self setTimeOut:[NSNumber numberWithInt:2147483647]]; break;
        case 1:[self setTimeOut:[NSNumber numberWithInt:60]]; break;
        case 2:[self setTimeOut:[NSNumber numberWithInt:120]]; break;
        case 3:[self setTimeOut:[NSNumber numberWithInt:180]]; break;
        case 4:[self setTimeOut:[NSNumber numberWithInt:240]]; break;
        case 5:[self setTimeOut:[NSNumber numberWithInt:300]]; break;
        case 6:[self setTimeOut:[NSNumber numberWithInt:600]]; break;
        case 7:[self setTimeOut:[NSNumber numberWithInt:900]]; break;
        case 8:[self setTimeOut:[NSNumber numberWithInt:0]];   break;
        default: break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:lockTime] forKey:@"lockTime"];
}

@end