//
//  USAVClient.m
//  uSav
//
//  Created by dennis young on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "USAVClient.h"

#import "API.h"

#import "NSData+Base64.h"

@interface USAVClient()

@property (nonatomic) BOOL getShortIdFailed;

// @property (nonatomic, strong) NSString *identifier;

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

static USAVClient *usavClient = nil;

@implementation USAVClient

@synthesize homeViewController;
@synthesize api;


// @synthesize identifier;
@synthesize username;
@synthesize password;
@synthesize emailAddress;


// @synthesize getShortIdFailed;
@synthesize userHasLogin;


@synthesize soundFileURLRef;
@synthesize soundFileObject;
@synthesize dateFormatter;


+(NSString *)convertNumberToKMString:(int)num {
    
    if (num > (1024 * 1024)) {
        float m = (float)num / (1024.0 * 1024.0);
        return ([NSString stringWithFormat:@"%.2fM", m]);
    }
    else if (num > 1024) {
        float k = (float)num / 1024.0;
        return ([NSString stringWithFormat:@"%.2fK", k]);
    }
    else
        return [NSString stringWithFormat:@"%d", num];
    
}

// Encode a string to embed in an URL.
-(NSString *)encodeToPercentEscapeString:(NSString *)string {
    return (__bridge NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef) string,
                                            NULL,
                                            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
}

// Decode a percent escape encoded string.
-(NSString *)decodeFromPercentEscapeString:(NSString *)string {
    return (__bridge NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}

-(NSString *)getDateTimeStr
{
    NSDate *now = [NSDate date];
    NSNumber *num = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
    NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:[num doubleValue]];
    return [dateFormatter stringFromDate:msgdate];
}

-(NSString *)generateSignature:(NSString *)stringToSign withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSUTF8StringEncoding];
   
    unsigned char cHMAC[SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    return [HMAC base64EncodedString];
}

- (NSString*)uuid {
	CFUUIDRef uid = CFUUIDCreate(NULL);
	return (__bridge NSString*)CFUUIDCreateString(NULL, uid);
}


- (NSString*)username {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"aliasName"];
}

- (void)setUsername:(NSString *)username  {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"aliasName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)emailAddress {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"emailAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
 
- (void)setEmailAddress:(NSString *)email  {
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"emailAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)password {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
}
 
- (void)setPassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(USAVClient*)init {
	if (nil != usavClient) {
		return usavClient;
	}
	else {
		if (self = [super init]) {
			usavClient = self;
            self.userHasLogin = NO;
			self.api = [[API alloc] initWithURLPrefix:URL_PREFIX];
	
            dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setLocale:[NSLocale systemLocale]];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            
			return self;
		}
		else {
			return nil;
		}
	}
}

+(USAVClient*) current {
	return usavClient;
}



@end

