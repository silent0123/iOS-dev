//
//  USAVAccountHandler.h
//  uSav-NewMac
//
//  Created by Luca on 9/12/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsavFileHeader.h"
#import "USAVClient.h"
#import "UsavCipher.h"
#import "UsavStreamCipher.h"
#import "API.h"
#import "HTTPHelper.h"
#import "GDataXMLNode.h"
#import "NSData+Base64.h"

@interface USAVAccountHandler : NSObject


+ (USAVAccountHandler *)currentHandler;

- (void)getAccountInfoForAccount: (NSString *)email andPassword: (NSString *)password;

@end
