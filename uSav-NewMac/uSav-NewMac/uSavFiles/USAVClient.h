//
//  USAVClient.h
//  uSav
//
//  Created by dennis young on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

// #import "ProcessorEventDelegate.h"


//#define URL_PREFIX @"https://webapi.usav-nwstor.com/api"
#define URL_PREFIX @"https://usav-new.azurewebsites.net/api"

//#define URL_PREFIX @"http://int.usav-nwstor.com:8081/api"
  

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
#define IS_IPHONE (!IS_IPAD)

@class API;
@class EventProcessor;

enum CkmsStatus
{
    SUCCESS = 0,
    WRONG_SIGNATURE = 0X0100,
    ACC_NOT_FOUND = 0X0101,
    DISABLE_USER = 0X0102,
    EXCEED_LIMIT = 0X0103,
    TIMESTAMP_OLD = 0X0104,
    TIMESTAMP_FUTURE = 0X0105,
    INVALID_PARAMETER = 0x0106,
    
    INVALID_KEY_SIZE = 0x0200,
    KEY_NOT_FOUND = 0x0201,
    INVALID_META_DATA = 0x0203,
    DELETE_KEY_FAIL = 0x0204,
    PERMISSION_DENIED = 0x0205,
    
    INCORRECT_OLD_EMAIL = 0x0400,
    INVALID_EMAIL = 0x0401,
    WRONG_ADDRESS = 0x0402,
    INVALID_ADDRESS = 0x0403,
    WRONG_PHONE = 0x0404,
    INVALID_PHONE = 0x0405,
    INVALID_PAY_METHOD = 0x0406,
    WRONG_PAYMENT = 0x0407,
    INVALID_STORAGE_LOC = 0x0408,
    INVOICE_NOT_FOUND = 0x0409,
    QUOTA_NOT_FOUND = 0x040a,
    INVALID_SECURE_QUESTION = 0x040b,
    INVALID_SECURE_ANSWER = 0x040c,
    EMAIL_IN_USE = 0x040d,
    
    INVALID_ACC_ID = 0x0500,
    UNSECURE_PASSWORD = 0x0501,
    DUPLICATIE_USER = 0x0502,
    ACC_EXIST = 0x0503,
    WRONG_SEC_ANS = 0x0504,
    
    // contact list
    INVALID_FD_ALIAS = 0x0510,
    INVALID_FD = 0x0511,
    INVALID_FD_NOTE = 0x0512,
    
    //log error
    KEYLOG_NOT_FOUND = 0x0601,
    OPTLOG_NOT_FOUND = 0x0602,
    
    //payment info error
    INVALID_PAYMENT_METHOD = 0x0701,
    
    //server error
    SERVER_FAILURE = 0x0901,
    CONNECTION_ERROR = 0x0902,
    
    // ernal error
    SQL_ERR = 0x0a01,
    
    //time format error
    TIME_INVALID = 0x0c01,
    
    //group
    INVALID_GROUP_NAME = 0x2001,
    INVALID_GROUP_MEMBER = 0x2002,
    GROUP_NOT_FOUND = 0x2003,
    GROUP_EXIST = 0x2004,
    FRIEND_EXIST = 0x2005,
    MEMBER_EXIST = 0x2006,
    FRIEND_NOT_FOUND = 0x2007,
    MEMBER_NOT_EXIST = 0x2008,
    
    //network connection error
    CONN_DISCONNECTED = 0x3001
    
};

#define SHA256_DIGEST_LENGTH 32
//@class ProgressViewController;

@interface USAVClient : NSObject  {
    
@private
	NSTimer *updateTimer;
    
}

@property (nonatomic, strong) id homeViewController;
@property (nonatomic, strong) API *api;
@property (nonatomic) BOOL userHasLogin;
@property (nonatomic) int usavRole;
@property (nonatomic) int usavState;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *emailAddress;

+(USAVClient *) current;
-(void)load;

- (NSString*)emailAddress;
- (void)setEmailAddress:(NSString *)email;

-(void)startProgress;
-(void)stopProgress;
-(void)playClick;

-(NSString *)encodeToPercentEscapeString:(NSString *)string;
-(NSString *)decodeFromPercentEscapeString:(NSString *)string;
-(NSString *)getDateTimeStr;
-(NSString *)generateSignature:(NSString *)stringToSign withKey:(NSString *)key;

+(NSString *)convertNumberToKMString:(int)num;

@end
