//
//  USAVContactHandler.h
//  uSav-NewMac
//
//  Created by Luca on 8/12/14.
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

@interface USAVContactHandler : NSObject

@property (strong, nonatomic) NSMutableArray *contactList;


//Init
+ (USAVContactHandler *)currentHandler;


//Get Contact List

-(void)getContactList;

@end
