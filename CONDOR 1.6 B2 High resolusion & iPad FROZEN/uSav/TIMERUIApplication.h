//
//  TIMERUIApplication.h
//  timeout
//
//  Created by NWHKOSX49 on 23/5/14.
//  Copyright (c) 2014 nwStor. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kApplicationTimeoutInMinutes 1

//the notification your AppDelegate needs to watch for in order to know that it has indeed "timed out"
#define kApplicationDidTimeoutNotification @"AppTimeOut"

@interface TIMERUIApplication : UIApplication
{
    NSTimer     *myidleTimer;
}

-(void)resetIdleTimer;

@end
