//
//  LogDataBase.h
//  uSav-newUI
//
//  Created by Luca on 18/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogsDataBase : NSObject

@property (assign, nonatomic) NSString *LogType;
@property (assign, nonatomic) NSString *LogContent;
@property (assign, nonatomic) NSString *LogImage;
@property (assign, nonatomic) NSString *LogTime;
@property (assign, nonatomic) BOOL LogSuccess;


@end
