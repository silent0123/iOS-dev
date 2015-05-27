//
//  USAVPassTimeValueProtocol.h
//  uSav
//
//  Created by Luca on 13/10/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimeArrangeDelegate <NSObject>

@optional
- (void)passLimit: (NSInteger)limit;
- (void)passDuration: (NSInteger)duration;
- (void)passTimeOfStart: (NSString *)startTime andEndTime: (NSString *)endTime;
//---- Decrypt Copy
- (void)passSaveDecryptCopy: (NSInteger)save;
@end

